"""
FastAPI application for the Market Intelligence War Room scoring microservice.
"""
import json
import logging
import time
from datetime import datetime
from typing import Dict, Any
from pathlib import Path

from fastapi import FastAPI, HTTPException, Depends, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import structlog

from .models import (
    GradeSubmissionRequest, GradeSubmissionResponse, HealthResponse,
    ScoringConfig, BATTLE_TEMPLATES
)
from .scoring_engine import ScoringEngine
from .evidence_extractor import EvidenceExtractor, EvidenceCache, EvidenceValidator

# Configure structured logging
structlog.configure(
    processors=[
        structlog.stdlib.filter_by_level,
        structlog.stdlib.add_logger_name,
        structlog.stdlib.add_log_level,
        structlog.stdlib.PositionalArgumentsFormatter(),
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.StackInfoRenderer(),
        structlog.processors.format_exc_info,
        structlog.processors.UnicodeDecoder(),
        structlog.processors.JSONRenderer()
    ],
    context_class=dict,
    logger_factory=structlog.stdlib.LoggerFactory(),
    wrapper_class=structlog.stdlib.BoundLogger,
    cache_logger_on_first_use=True,
)

logger = structlog.get_logger()

# Initialize FastAPI app
app = FastAPI(
    title="Market Intelligence War Room - Scoring Microservice",
    description="Production-ready scoring service for competitive intelligence game",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure appropriately for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Global variables
scoring_engine: Optional[ScoringEngine] = None
evidence_extractor: Optional[EvidenceExtractor] = None
evidence_cache: Optional[EvidenceCache] = None
evidence_validator: Optional[EvidenceValidator] = None
reference_data: Optional[Dict[str, Any]] = None
scoring_config: Optional[ScoringConfig] = None
start_time = time.time()


@app.on_event("startup")
async def startup_event():
    """Initialize services on startup."""
    global scoring_engine, evidence_extractor, evidence_cache, evidence_validator
    global reference_data, scoring_config
    
    logger.info("Starting Market Intelligence War Room Scoring Service")
    
    try:
        # Load reference data
        reference_data_path = Path(__file__).parent.parent / "data" / "ezz_steel_reference.json"
        with open(reference_data_path, 'r', encoding='utf-8') as f:
            reference_data = json.load(f)
        
        logger.info("Loaded reference data", company=reference_data.get("company", {}).get("name"))
        
        # Initialize scoring configuration
        scoring_config = ScoringConfig()
        
        # Initialize scoring engine
        scoring_engine = ScoringEngine(reference_data, scoring_config)
        
        # Initialize evidence services
        evidence_extractor = EvidenceExtractor(timeout=30)
        evidence_cache = EvidenceCache(ttl_seconds=3600)
        evidence_validator = EvidenceValidator()
        
        logger.info("Scoring service initialized successfully")
        
    except Exception as e:
        logger.error("Failed to initialize scoring service", error=str(e))
        raise


@app.on_event("shutdown")
async def shutdown_event():
    """Cleanup on shutdown."""
    global evidence_extractor
    
    if evidence_extractor:
        await evidence_extractor.close()
    
    logger.info("Scoring service shutdown complete")


@app.get("/health", response_model=HealthResponse)
async def health_check():
    """Health check endpoint."""
    uptime = time.time() - start_time
    
    return HealthResponse(
        status="healthy",
        timestamp=datetime.utcnow(),
        version="1.0.0",
        uptime_seconds=uptime
    )


@app.post("/grade_submission", response_model=GradeSubmissionResponse)
async def grade_submission(
    request: GradeSubmissionRequest,
    background_tasks: BackgroundTasks
):
    """
    Grade a battle submission.
    
    This endpoint processes submissions and returns detailed scoring breakdown.
    """
    if not scoring_engine:
        raise HTTPException(status_code=500, detail="Scoring engine not initialized")
    
    logger.info(
        "Processing submission",
        submission_id=request.submission_id,
        team=request.team,
        battle_no=request.battle_no
    )
    
    try:
        # Validate battle number
        if request.battle_no not in BATTLE_TEMPLATES:
            raise HTTPException(
                status_code=400,
                detail=f"Invalid battle number: {request.battle_no}. Must be 1-5."
            )
        
        # Grade the submission
        response = scoring_engine.grade_submission(request)
        
        # Log the result
        logger.info(
            "Submission graded",
            submission_id=request.submission_id,
            raw_ai_percent=response.raw_ai_percent,
            battle_points=response.battle_points_out_of_20,
            confidence=response.confidence,
            escalated=response.escalated_for_human_review
        )
        
        # Schedule background evidence extraction if source link provided
        if request.source_link:
            background_tasks.add_task(
                extract_evidence_background,
                str(request.source_link),
                list(request.fields.keys())
            )
        
        return response
    
    except Exception as e:
        logger.error(
            "Error grading submission",
            submission_id=request.submission_id,
            error=str(e),
            exc_info=True
        )
        raise HTTPException(status_code=500, detail=f"Error grading submission: {str(e)}")


@app.get("/battle_templates")
async def get_battle_templates():
    """Get battle templates configuration."""
    return {
        "templates": {
            str(battle_no): {
                "name": template.name,
                "field_weights": template.field_weights,
                "required_fields": template.required_fields,
                "field_types": template.field_types
            }
            for battle_no, template in BATTLE_TEMPLATES.items()
        }
    }


@app.get("/reference_data")
async def get_reference_data():
    """Get reference data (for debugging/admin purposes)."""
    if not reference_data:
        raise HTTPException(status_code=500, detail="Reference data not loaded")
    
    return reference_data


@app.get("/scoring_config")
async def get_scoring_config():
    """Get scoring configuration."""
    if not scoring_config:
        raise HTTPException(status_code=500, detail="Scoring config not initialized")
    
    return scoring_config.dict()


@app.post("/admin/override_score")
async def override_score(
    submission_id: str,
    new_score: float,
    reason: str,
    admin_key: str = Depends(verify_admin_key)
):
    """Admin endpoint to override scores (human-in-the-loop)."""
    # This would integrate with your admin system
    logger.info(
        "Score override requested",
        submission_id=submission_id,
        new_score=new_score,
        reason=reason,
        admin_key=admin_key
    )
    
    # In a real implementation, this would:
    # 1. Verify admin permissions
    # 2. Update the score in the database
    # 3. Log the override for audit purposes
    # 4. Notify relevant parties
    
    return {"status": "success", "message": "Score override logged"}


async def extract_evidence_background(source_url: str, search_terms: List[str]):
    """Background task to extract evidence from source URL."""
    if not evidence_extractor or not evidence_cache:
        return
    
    try:
        # Check cache first
        cached_evidence = evidence_cache.get(source_url, search_terms)
        if cached_evidence:
            logger.info("Using cached evidence", url=source_url)
            return
        
        # Extract evidence
        evidence = await evidence_extractor.extract_evidence(source_url, search_terms)
        
        # Validate evidence
        if evidence_validator:
            validation = evidence_validator.validate_evidence(evidence, source_url)
            logger.info(
                "Evidence extracted and validated",
                url=source_url,
                snippet_count=validation["snippet_count"],
                quality_score=validation["quality_score"]
            )
        
        # Cache evidence
        evidence_cache.set(source_url, search_terms, evidence)
        
    except Exception as e:
        logger.error("Error in background evidence extraction", url=source_url, error=str(e))


def verify_admin_key(admin_key: str):
    """Verify admin key for protected endpoints."""
    # In production, this would check against a secure key store
    expected_key = "admin_key_placeholder"  # Replace with actual key management
    
    if admin_key != expected_key:
        raise HTTPException(status_code=401, detail="Invalid admin key")
    
    return admin_key


@app.exception_handler(Exception)
async def global_exception_handler(request, exc):
    """Global exception handler."""
    logger.error(
        "Unhandled exception",
        path=request.url.path,
        method=request.method,
        error=str(exc),
        exc_info=True
    )
    
    return JSONResponse(
        status_code=500,
        content={"detail": "Internal server error", "error_id": str(hash(str(exc)))}
    )


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info"
    )
