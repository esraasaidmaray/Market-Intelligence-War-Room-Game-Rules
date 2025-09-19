"""
Tests for the scoring engine.
"""
import pytest
from datetime import datetime
from app.models import GradeSubmissionRequest, Team, ScoringConfig
from app.scoring_engine import ScoringEngine


@pytest.fixture
def reference_data():
    """Sample reference data for testing."""
    return {
        "company": {
            "name": "Ezz Steel",
            "overview": {
                "description": "Egypt's largest steel producer",
                "plants": 4,
                "capacity_million_tons": 7
            }
        },
        "leadership_and_ownership": {
            "founders": {
                "company": "Ezz Steel Company S.A.E.",
                "founding_year": 1994,
                "current_role": "Hassan Ahmed Nouh — CEO"
            },
            "key_executives": [
                {
                    "name": "Hassan Ahmed Nouh",
                    "title": "Chairman and Managing Director (CEO)",
                    "years_with_firm": 21
                }
            ]
        },
        "market": {
            "competitive_position": {
                "market_share": {"overall": "50-60%"}
            }
        }
    }


@pytest.fixture
def scoring_config():
    """Scoring configuration for testing."""
    return ScoringConfig()


@pytest.fixture
def scoring_engine(reference_data, scoring_config):
    """Scoring engine instance for testing."""
    return ScoringEngine(reference_data, scoring_config)


class TestScoringEngine:
    """Test cases for the scoring engine."""
    
    def test_normalize_text(self, scoring_engine):
        """Test text normalization."""
        assert scoring_engine.normalize_text("  John Doe  ") == "john doe"
        assert scoring_engine.normalize_text("José María") == "jose maria"
        assert scoring_engine.normalize_text("") == ""
        assert scoring_engine.normalize_text(None) == ""
    
    def test_calculate_name_similarity(self, scoring_engine):
        """Test name similarity calculation."""
        # Exact match
        assert scoring_engine.calculate_name_similarity("John Doe", "John Doe") == 1.0
        
        # High similarity
        assert scoring_engine.calculate_name_similarity("John Doe", "John D.") >= 0.7
        
        # Low similarity
        assert scoring_engine.calculate_name_similarity("John Doe", "Jane Smith") < 0.7
        
        # Empty values
        assert scoring_engine.calculate_name_similarity("", "John Doe") == 0.0
        assert scoring_engine.calculate_name_similarity("John Doe", "") == 0.0
    
    def test_calculate_date_similarity(self, scoring_engine):
        """Test date similarity calculation."""
        # Exact year match
        assert scoring_engine.calculate_date_similarity("1994", "1994") == 1.0
        
        # Within tolerance
        assert scoring_engine.calculate_date_similarity("1995", "1994") == 1.0
        assert scoring_engine.calculate_date_similarity("1993", "1994") == 1.0
        
        # Outside tolerance
        assert scoring_engine.calculate_date_similarity("1996", "1994") == 0.0
        
        # Invalid dates
        assert scoring_engine.calculate_date_similarity("invalid", "1994") == 0.0
    
    def test_calculate_numeric_similarity(self, scoring_engine):
        """Test numeric similarity calculation."""
        # Exact match
        assert scoring_engine.calculate_numeric_similarity("100", "100") == 1.0
        
        # Within 5% tolerance
        assert scoring_engine.calculate_numeric_similarity("105", "100") == 1.0
        assert scoring_engine.calculate_numeric_similarity("95", "100") == 1.0
        
        # Within 10% tolerance (partial credit)
        assert scoring_engine.calculate_numeric_similarity("108", "100") > 0.0
        assert scoring_engine.calculate_numeric_similarity("92", "100") > 0.0
        
        # Outside tolerance
        assert scoring_engine.calculate_numeric_similarity("120", "100") == 0.0
        
        # Zero reference
        assert scoring_engine.calculate_numeric_similarity("100", "0") == 0.0
    
    def test_calculate_percentage_similarity(self, scoring_engine):
        """Test percentage similarity calculation."""
        # Exact match
        assert scoring_engine.calculate_percentage_similarity("50%", "50%") == 1.0
        
        # Within 2% tolerance
        assert scoring_engine.calculate_percentage_similarity("52%", "50%") == 1.0
        assert scoring_engine.calculate_percentage_similarity("48%", "50%") == 1.0
        
        # Within 5% tolerance (partial credit)
        assert scoring_engine.calculate_percentage_similarity("53%", "50%") > 0.0
        assert scoring_engine.calculate_percentage_similarity("47%", "50%") > 0.0
        
        # Outside tolerance
        assert scoring_engine.calculate_percentage_similarity("60%", "50%") == 0.0
    
    def test_calculate_speed_score(self, scoring_engine):
        """Test speed score calculation."""
        # Fast submission (5 minutes)
        assert scoring_engine.calculate_speed_score(300, 3600) == 10.0
        
        # Medium submission (25 minutes)
        assert scoring_engine.calculate_speed_score(1500, 3600) == 6.0
        
        # Slow submission (55 minutes)
        assert scoring_engine.calculate_speed_score(3300, 3600) == 1.0
        
        # Very slow submission (65 minutes)
        assert scoring_engine.calculate_speed_score(3900, 3600) == 0.0
    
    def test_calculate_source_credibility(self, scoring_engine):
        """Test source credibility calculation."""
        # Company domain
        assert scoring_engine.calculate_source_credibility("https://ezzsteel.com/about") == 0.90
        
        # News source
        assert scoring_engine.calculate_source_credibility("https://reuters.com/article") == 0.85
        
        # LinkedIn
        assert scoring_engine.calculate_source_credibility("https://linkedin.com/company/ezzsteel") == 0.75
        
        # Unknown domain
        assert scoring_engine.calculate_source_credibility("https://unknown-site.com") == 0.30
        
        # Empty URL
        assert scoring_engine.calculate_source_credibility("") == 0.0
    
    def test_grade_submission_leadership_recon(self, scoring_engine):
        """Test grading a Leadership Recon submission."""
        request = GradeSubmissionRequest(
            team=Team.ALPHA,
            battle_no=1,
            submission_id="test-001",
            submitted_at=datetime.utcnow(),
            time_taken_seconds=1200,  # 20 minutes
            total_time_seconds=3600,  # 60 minutes
            company_reference=None,
            source_link=None,
            fields={
                "founders": "Ezz Steel Company S.A.E.",
                "key_executives": "Hassan Ahmed Nouh",
                "market_share": "55%",
                "geographic_footprint": "Egypt"
            }
        )
        
        response = scoring_engine.grade_submission(request)
        
        assert response.submission_id == "test-001"
        assert response.team == Team.ALPHA
        assert response.battle_no == 1
        assert 0 <= response.raw_ai_percent <= 85
        assert 0 <= response.scaled_battle_percent <= 100
        assert 0 <= response.battle_points_out_of_20 <= 20
        assert 0 <= response.confidence <= 1
        assert response.breakdown.data_accuracy_raw >= 0
        assert response.breakdown.speed_raw >= 0
        assert response.breakdown.source_raw >= 0
    
    def test_grade_submission_with_reference(self, scoring_engine):
        """Test grading with company reference."""
        from app.models import CompanyReference
        
        request = GradeSubmissionRequest(
            team=Team.DELTA,
            battle_no=1,
            submission_id="test-002",
            submitted_at=datetime.utcnow(),
            time_taken_seconds=600,  # 10 minutes
            total_time_seconds=3600,
            company_reference=CompanyReference(
                company_id="ezz-steel-001",
                use_reference_as_primary=True
            ),
            source_link=None,
            fields={
                "founders": "Ezz Steel Company S.A.E.",
                "key_executives": "Hassan Ahmed Nouh",
                "market_share": "55%"
            }
        )
        
        response = scoring_engine.grade_submission(request)
        
        assert response.breakdown.matched_from_reference == True
        assert response.breakdown.reference_company_id == "ezz-steel-001"
        assert response.breakdown.reference_verified == True
    
    def test_grade_submission_missing_fields(self, scoring_engine):
        """Test grading with missing required fields."""
        request = GradeSubmissionRequest(
            team=Team.ALPHA,
            battle_no=1,
            submission_id="test-003",
            submitted_at=datetime.utcnow(),
            time_taken_seconds=1800,
            total_time_seconds=3600,
            company_reference=None,
            source_link=None,
            fields={
                "founders": "Ezz Steel Company S.A.E.",
                # Missing key_executives and market_share
            }
        )
        
        response = scoring_engine.grade_submission(request)
        
        assert "key_executives" in response.diagnostics.missing_fields
        assert "market_share" in response.diagnostics.missing_fields
        assert response.breakdown.data_accuracy_raw < 60  # Should be lower due to missing fields
    
    def test_grade_submission_escalation(self, scoring_engine):
        """Test escalation for human review."""
        # Create a submission that should be escalated
        request = GradeSubmissionRequest(
            team=Team.ALPHA,
            battle_no=1,
            submission_id="test-004",
            submitted_at=datetime.utcnow(),
            time_taken_seconds=3000,  # Very slow
            total_time_seconds=3600,
            company_reference=None,
            source_link="https://unknown-blog.com/article",  # Low credibility
            fields={
                "founders": "Wrong Company Name",  # Wrong data
                "key_executives": "Unknown Person",
                "market_share": "10%"  # Wrong percentage
            }
        )
        
        response = scoring_engine.grade_submission(request)
        
        # Should be escalated due to low confidence and poor data
        assert response.escalated_for_human_review == True
        assert response.confidence < 0.75
        assert response.breakdown.source_credibility < 0.50
    
    def test_find_reference_value(self, scoring_engine):
        """Test finding reference values."""
        # Test existing field
        value = scoring_engine.find_reference_value("founders", scoring_engine.battle_templates[1])
        assert value == "Ezz Steel Company S.A.E."
        
        # Test non-existing field
        value = scoring_engine.find_reference_value("non_existing", scoring_engine.battle_templates[1])
        assert value is None
    
    def test_extract_year(self, scoring_engine):
        """Test year extraction from date strings."""
        assert scoring_engine.extract_year("1994") == 1994
        assert scoring_engine.extract_year("Founded in 1994") == 1994
        assert scoring_engine.extract_year("01/15/1994") == 1994
        assert scoring_engine.extract_year("1994-01-15") == 1994
        assert scoring_engine.extract_year("invalid") is None
        assert scoring_engine.extract_year("") is None
    
    def test_extract_number(self, scoring_engine):
        """Test number extraction from text."""
        assert scoring_engine.extract_number("100") == 100.0
        assert scoring_engine.extract_number("$1,000") == 1000.0
        assert scoring_engine.extract_number("Revenue: $2.5M") == 2.5
        assert scoring_engine.extract_number("No numbers here") is None
        assert scoring_engine.extract_number("") is None
    
    def test_extract_percentage(self, scoring_engine):
        """Test percentage extraction from text."""
        assert scoring_engine.extract_percentage("50%") == 50.0
        assert scoring_engine.extract_percentage("50 percent") == 50.0
        assert scoring_engine.extract_percentage("Market share: 55%") == 55.0
        assert scoring_engine.extract_percentage("No percentage") is None
        assert scoring_engine.extract_percentage("") is None
