"""
Integration tests for the scoring microservice.
"""
import pytest
import json
from datetime import datetime
from fastapi.testclient import TestClient
from app.main import app
from app.models import Team


@pytest.fixture
def client():
    """Test client for the FastAPI app."""
    return TestClient(app)


@pytest.fixture
def sample_submission():
    """Sample submission data for testing."""
    return {
        "team": "Alpha",
        "battle_no": 1,
        "submission_id": "test-integration-001",
        "submitted_at": datetime.utcnow().isoformat(),
        "time_taken_seconds": 1200,  # 20 minutes
        "total_time_seconds": 3600,  # 60 minutes
        "company_reference": {
            "company_id": "ezz-steel-001",
            "use_reference_as_primary": True
        },
        "source_link": "https://ezzsteel.com/about",
        "fields": {
            "founders": "Ezz Steel Company S.A.E.",
            "key_executives": "Hassan Ahmed Nouh",
            "market_share": "55%",
            "geographic_footprint": "Egypt"
        },
        "attachments": []
    }


class TestIntegration:
    """Integration tests for the scoring service."""
    
    def test_health_check(self, client):
        """Test health check endpoint."""
        response = client.get("/health")
        assert response.status_code == 200
        
        data = response.json()
        assert data["status"] == "healthy"
        assert "timestamp" in data
        assert "version" in data
        assert "uptime_seconds" in data
    
    def test_grade_submission_success(self, client, sample_submission):
        """Test successful submission grading."""
        response = client.post("/grade_submission", json=sample_submission)
        assert response.status_code == 200
        
        data = response.json()
        assert data["submission_id"] == "test-integration-001"
        assert data["team"] == "Alpha"
        assert data["battle_no"] == 1
        assert 0 <= data["raw_ai_percent"] <= 85
        assert 0 <= data["scaled_battle_percent"] <= 100
        assert 0 <= data["battle_points_out_of_20"] <= 20
        assert 0 <= data["confidence"] <= 1
        assert "breakdown" in data
        assert "diagnostics" in data
        assert "explain_text" in data
    
    def test_grade_submission_invalid_battle(self, client, sample_submission):
        """Test submission with invalid battle number."""
        sample_submission["battle_no"] = 6  # Invalid battle number
        
        response = client.post("/grade_submission", json=sample_submission)
        assert response.status_code == 400
        assert "Invalid battle number" in response.json()["detail"]
    
    def test_grade_submission_missing_fields(self, client, sample_submission):
        """Test submission with missing required fields."""
        # Remove required fields
        del sample_submission["fields"]["key_executives"]
        del sample_submission["fields"]["market_share"]
        
        response = client.post("/grade_submission", json=sample_submission)
        assert response.status_code == 200
        
        data = response.json()
        assert "key_executives" in data["diagnostics"]["missing_fields"]
        assert "market_share" in data["diagnostics"]["missing_fields"]
    
    def test_grade_submission_with_reference(self, client, sample_submission):
        """Test submission using reference data."""
        response = client.post("/grade_submission", json=sample_submission)
        assert response.status_code == 200
        
        data = response.json()
        assert data["breakdown"]["matched_from_reference"] == True
        assert data["breakdown"]["reference_company_id"] == "ezz-steel-001"
        assert data["breakdown"]["reference_verified"] == True
    
    def test_grade_submission_with_source_link(self, client, sample_submission):
        """Test submission with source link."""
        sample_submission["company_reference"] = None
        sample_submission["source_link"] = "https://reuters.com/article/ezz-steel"
        
        response = client.post("/grade_submission", json=sample_submission)
        assert response.status_code == 200
        
        data = response.json()
        assert data["breakdown"]["matched_from_reference"] == False
        assert data["breakdown"]["source_verified"] == True
        assert data["breakdown"]["source_credibility"] > 0
    
    def test_get_battle_templates(self, client):
        """Test getting battle templates."""
        response = client.get("/battle_templates")
        assert response.status_code == 200
        
        data = response.json()
        assert "templates" in data
        assert len(data["templates"]) == 5
        
        # Check Battle 1 template
        battle_1 = data["templates"]["1"]
        assert battle_1["name"] == "Leadership Recon"
        assert "field_weights" in battle_1
        assert "required_fields" in battle_1
        assert "field_types" in battle_1
    
    def test_get_reference_data(self, client):
        """Test getting reference data."""
        response = client.get("/reference_data")
        assert response.status_code == 200
        
        data = response.json()
        assert "company" in data
        assert data["company"]["name"] == "Ezz Steel"
        assert "leadership_and_ownership" in data
        assert "market" in data
        assert "products" in data
        assert "funding" in data
        assert "customers" in data
    
    def test_get_scoring_config(self, client):
        """Test getting scoring configuration."""
        response = client.get("/scoring_config")
        assert response.status_code == 200
        
        data = response.json()
        assert "name_similarity_threshold" in data
        assert "date_tolerance_years" in data
        assert "numeric_tolerance_percent" in data
        assert "confidence_threshold" in data
        assert "source_credibility_scores" in data
    
    def test_admin_override_score(self, client):
        """Test admin score override endpoint."""
        response = client.post(
            "/admin/override_score",
            params={
                "submission_id": "test-001",
                "new_score": 18.5,
                "reason": "Manual review correction",
                "admin_key": "admin_key_placeholder"
            }
        )
        assert response.status_code == 200
        
        data = response.json()
        assert data["status"] == "success"
        assert "Score override logged" in data["message"]
    
    def test_admin_override_invalid_key(self, client):
        """Test admin override with invalid key."""
        response = client.post(
            "/admin/override_score",
            params={
                "submission_id": "test-001",
                "new_score": 18.5,
                "reason": "Manual review correction",
                "admin_key": "invalid_key"
            }
        )
        assert response.status_code == 401
        assert "Invalid admin key" in response.json()["detail"]
    
    def test_grade_all_battles(self, client):
        """Test grading submissions for all five battles."""
        base_submission = {
            "team": "Delta",
            "submission_id": "test-all-battles",
            "submitted_at": datetime.utcnow().isoformat(),
            "time_taken_seconds": 1800,  # 30 minutes
            "total_time_seconds": 3600,
            "company_reference": {
                "company_id": "ezz-steel-001",
                "use_reference_as_primary": True
            },
            "source_link": None,
            "attachments": []
        }
        
        # Test each battle
        for battle_no in range(1, 6):
            submission = base_submission.copy()
            submission["battle_no"] = battle_no
            submission["submission_id"] = f"test-battle-{battle_no}"
            
            # Add appropriate fields for each battle
            if battle_no == 1:  # Leadership Recon
                submission["fields"] = {
                    "founders": "Ezz Steel Company S.A.E.",
                    "key_executives": "Hassan Ahmed Nouh",
                    "market_share": "55%",
                    "geographic_footprint": "Egypt"
                }
            elif battle_no == 2:  # Product Arsenal
                submission["fields"] = {
                    "product_lines": "Rebar, Wire Rod, HRC",
                    "pricing": "38200 EGP",
                    "social_presence": "LinkedIn, Facebook, YouTube",
                    "influencers": "Company executives"
                }
            elif battle_no == 3:  # Funding Fortification
                submission["fields"] = {
                    "funding": "2.02 billion USD",
                    "investors": "Ahmed Ezz, Bank of New York Mellon",
                    "revenue": "4.7 billion USD",
                    "citations": "https://ezzsteel.com/investors"
                }
            elif battle_no == 4:  # Customer Frontlines
                submission["fields"] = {
                    "b2c": "Small contractors, Large developers",
                    "b2b": "Medium contractors, Large developers",
                    "reviews": "3.5/5",
                    "citations": "https://ezzsteel.com/customers"
                }
            elif battle_no == 5:  # Alliance Forge
                submission["fields"] = {
                    "partners": "Strategic partnerships",
                    "suppliers": "International scrap brokers, Natural gas companies",
                    "growth": "62% revenue growth",
                    "expansions": "Capacity increase, Eco-friendly steel",
                    "citations": "https://ezzsteel.com/growth"
                }
            
            response = client.post("/grade_submission", json=submission)
            assert response.status_code == 200
            
            data = response.json()
            assert data["battle_no"] == battle_no
            assert 0 <= data["battle_points_out_of_20"] <= 20
            assert data["team"] == "Delta"
    
    def test_error_handling(self, client):
        """Test error handling for malformed requests."""
        # Test with invalid JSON
        response = client.post(
            "/grade_submission",
            data="invalid json",
            headers={"Content-Type": "application/json"}
        )
        assert response.status_code == 422
        
        # Test with missing required fields
        response = client.post("/grade_submission", json={})
        assert response.status_code == 422
        
        # Test with invalid enum values
        invalid_submission = {
            "team": "InvalidTeam",
            "battle_no": 1,
            "submission_id": "test",
            "submitted_at": datetime.utcnow().isoformat(),
            "time_taken_seconds": 1200,
            "total_time_seconds": 3600,
            "fields": {}
        }
        response = client.post("/grade_submission", json=invalid_submission)
        assert response.status_code == 422
