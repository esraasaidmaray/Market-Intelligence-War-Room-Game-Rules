"""
Pydantic models for the scoring microservice API.
"""
from typing import List, Optional, Dict, Any, Union
from pydantic import BaseModel, Field, HttpUrl
from datetime import datetime
from enum import Enum


class Team(str, Enum):
    ALPHA = "Alpha"
    DELTA = "Delta"


class AttachmentType(str, Enum):
    SCREENSHOT = "screenshot"
    PDF = "pdf"


class CompanyReference(BaseModel):
    company_id: str
    use_reference_as_primary: bool


class Attachment(BaseModel):
    type: AttachmentType
    url: HttpUrl


class EvidenceSnippet(BaseModel):
    snapshot_path: str
    xpath: str
    start_offset: int
    end_offset: int
    text_snippet: str


class FieldAccuracyDetail(BaseModel):
    field: str
    submitted: str
    found_in_source: bool
    match_score: float
    weight: float
    contribution: float
    evidence_snippets: List[EvidenceSnippet] = []


class Breakdown(BaseModel):
    data_accuracy_raw: float
    speed_raw: float
    source_raw: float
    data_accuracy_details: List[FieldAccuracyDetail] = []
    source_credibility: float
    source_verified: bool
    matched_from_reference: bool
    reference_company_id: Optional[str] = None
    reference_verified: bool


class Diagnostics(BaseModel):
    missing_fields: List[str] = []
    evidence_not_found_for: List[str] = []
    fetch_warnings: List[str] = []
    conflict_details: Dict[str, Any] = {}


class GradeSubmissionRequest(BaseModel):
    team: Team
    battle_no: int = Field(..., ge=1, le=5)
    submission_id: str
    submitted_at: datetime
    time_taken_seconds: int
    total_time_seconds: int
    company_reference: Optional[CompanyReference] = None
    source_link: Optional[HttpUrl] = None
    fields: Dict[str, Any]
    attachments: List[Attachment] = []


class GradeSubmissionResponse(BaseModel):
    submission_id: str
    team: Team
    battle_no: int
    raw_ai_percent: float
    scaled_battle_percent: float
    battle_points_out_of_20: float
    breakdown: Breakdown
    diagnostics: Diagnostics
    escalated_for_human_review: bool
    confidence: float
    explain_text: str


class BattleTemplate(BaseModel):
    """Template defining field weights and validation rules for each battle."""
    battle_number: int
    name: str
    field_weights: Dict[str, float]
    required_fields: List[str]
    field_types: Dict[str, str]  # field_name -> type (name, date, number, percentage, category)


# Battle templates configuration
BATTLE_TEMPLATES = {
    1: BattleTemplate(
        battle_number=1,
        name="Leadership Recon",
        field_weights={
            "founders": 12.0,
            "key_executives": 18.0,
            "market_share": 20.0,
            "geographic_footprint": 10.0
        },
        required_fields=["founders", "key_executives", "market_share"],
        field_types={
            "founders": "name",
            "key_executives": "name",
            "market_share": "percentage",
            "geographic_footprint": "category"
        }
    ),
    2: BattleTemplate(
        battle_number=2,
        name="Product Arsenal",
        field_weights={
            "product_lines": 30.0,
            "pricing": 15.0,
            "social_presence": 20.0,
            "influencers": 15.0
        },
        required_fields=["product_lines", "pricing", "social_presence"],
        field_types={
            "product_lines": "category",
            "pricing": "number",
            "social_presence": "category",
            "influencers": "name"
        }
    ),
    3: BattleTemplate(
        battle_number=3,
        name="Funding Fortification",
        field_weights={
            "funding": 40.0,
            "investors": 20.0,
            "revenue": 25.0,
            "citations": 15.0
        },
        required_fields=["funding", "investors", "revenue"],
        field_types={
            "funding": "number",
            "investors": "name",
            "revenue": "number",
            "citations": "url"
        }
    ),
    4: BattleTemplate(
        battle_number=4,
        name="Customer Frontlines",
        field_weights={
            "b2c": 25.0,
            "b2b": 25.0,
            "reviews": 25.0,
            "citations": 25.0
        },
        required_fields=["b2c", "b2b", "reviews"],
        field_types={
            "b2c": "category",
            "b2b": "category",
            "reviews": "number",
            "citations": "url"
        }
    ),
    5: BattleTemplate(
        battle_number=5,
        name="Alliance Forge",
        field_weights={
            "partners": 25.0,
            "suppliers": 20.0,
            "growth": 25.0,
            "expansions": 15.0,
            "citations": 15.0
        },
        required_fields=["partners", "suppliers", "growth"],
        field_types={
            "partners": "name",
            "suppliers": "name",
            "growth": "percentage",
            "expansions": "category",
            "citations": "url"
        }
    )
}


class ScoringConfig(BaseModel):
    """Configuration for scoring parameters."""
    # Similarity thresholds
    name_similarity_threshold: float = 0.90
    name_partial_threshold: float = 0.70
    category_similarity_threshold: float = 0.85
    
    # Date tolerance
    date_tolerance_years: int = 1
    
    # Numeric tolerances
    numeric_tolerance_percent: float = 5.0
    numeric_partial_tolerance_percent: float = 10.0
    percentage_tolerance: float = 2.0
    percentage_partial_tolerance: float = 5.0
    
    # Speed scoring tiers (in minutes)
    speed_tiers: List[Dict[str, Union[int, float]]] = [
        {"max_minutes": 10, "score": 10.0},
        {"max_minutes": 20, "score": 8.0},
        {"max_minutes": 30, "score": 6.0},
        {"max_minutes": 40, "score": 4.0},
        {"max_minutes": 50, "score": 2.0},
        {"max_minutes": 60, "score": 1.0}
    ]
    
    # Source credibility scores
    source_credibility_scores: Dict[str, float] = {
        "filings": 0.95,
        "company_domain": 0.90,
        "reuters_bloomberg": 0.85,
        "crunchbase": 0.80,
        "linkedin": 0.75,
        "blogs": 0.50,
        "social_media": 0.40,
        "unknown": 0.30
    }
    
    # Escalation thresholds
    confidence_threshold: float = 0.75
    source_credibility_threshold: float = 0.50
    max_missing_fields: int = 2


class HealthResponse(BaseModel):
    """Health check response."""
    status: str
    timestamp: datetime
    version: str
    uptime_seconds: float
