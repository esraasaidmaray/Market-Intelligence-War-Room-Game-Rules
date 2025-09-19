"""
Configuration settings for the scoring microservice.
"""
import os
from typing import List, Dict, Any
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """Application settings."""
    
    # API Settings
    api_title: str = "Market Intelligence War Room - Scoring Microservice"
    api_version: str = "1.0.0"
    api_description: str = "Production-ready scoring service for competitive intelligence game"
    
    # Server Settings
    host: str = "0.0.0.0"
    port: int = 8000
    debug: bool = False
    
    # Database Settings
    database_url: str = "sqlite:///./scoring.db"
    
    # Redis Settings
    redis_url: str = "redis://localhost:6379"
    redis_ttl: int = 3600
    
    # Storage Settings
    s3_bucket: str = "evidence-snapshots"
    s3_region: str = "us-east-1"
    s3_access_key: str = ""
    s3_secret_key: str = ""
    
    # Scoring Settings
    max_submission_size: int = 1024 * 1024  # 1MB
    max_attachments: int = 10
    evidence_cache_ttl: int = 3600
    request_timeout: int = 30
    
    # Security Settings
    admin_key: str = "admin_key_placeholder"
    jwt_secret: str = "jwt_secret_placeholder"
    jwt_algorithm: str = "HS256"
    jwt_expiration: int = 3600
    
    # Monitoring Settings
    enable_metrics: bool = True
    metrics_port: int = 9090
    log_level: str = "INFO"
    
    # Rate Limiting
    rate_limit_requests: int = 100
    rate_limit_window: int = 3600  # 1 hour
    
    # Evidence Extraction
    max_evidence_snippets: int = 50
    evidence_snippet_length: int = 200
    ocr_timeout: int = 30
    
    # Trusted Domains
    trusted_domains: List[str] = [
        "ezzsteel.com",
        "linkedin.com",
        "crunchbase.com",
        "reuters.com",
        "bloomberg.com",
        "wsj.com",
        "ft.com",
        "sec.gov",
        "edgar.sec.gov",
        "statista.com",
        "pitchbook.com",
        "cbinsights.com"
    ]
    
    # Source Credibility Scores
    source_credibility_scores: Dict[str, float] = {
        "filings": 0.95,
        "company_domain": 0.90,
        "reuters_bloomberg": 0.85,
        "crunchbase": 0.80,
        "linkedin": 0.75,
        "statista": 0.70,
        "blogs": 0.50,
        "social_media": 0.40,
        "unknown": 0.30
    }
    
    # Similarity Thresholds
    name_similarity_threshold: float = 0.90
    name_partial_threshold: float = 0.70
    category_similarity_threshold: float = 0.85
    date_tolerance_years: int = 1
    numeric_tolerance_percent: float = 5.0
    numeric_partial_tolerance_percent: float = 10.0
    percentage_tolerance: float = 2.0
    percentage_partial_tolerance: float = 5.0
    
    # Escalation Thresholds
    confidence_threshold: float = 0.75
    source_credibility_threshold: float = 0.50
    max_missing_fields: int = 2
    
    # Speed Scoring Tiers (minutes)
    speed_tiers: List[Dict[str, Any]] = [
        {"max_minutes": 10, "score": 10.0},
        {"max_minutes": 20, "score": 8.0},
        {"max_minutes": 30, "score": 6.0},
        {"max_minutes": 40, "score": 4.0},
        {"max_minutes": 50, "score": 2.0},
        {"max_minutes": 60, "score": 1.0}
    ]
    
    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
        case_sensitive = False


# Global settings instance
settings = Settings()
