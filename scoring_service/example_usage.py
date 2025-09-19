#!/usr/bin/env python3
"""
Example usage of the Market Intelligence War Room scoring microservice.
"""
import requests
import json
from datetime import datetime
from typing import Dict, Any


class ScoringServiceClient:
    """Client for interacting with the scoring microservice."""
    
    def __init__(self, base_url: str = "http://localhost:8000"):
        self.base_url = base_url
        self.session = requests.Session()
    
    def health_check(self) -> Dict[str, Any]:
        """Check service health."""
        response = self.session.get(f"{self.base_url}/health")
        response.raise_for_status()
        return response.json()
    
    def grade_submission(self, submission_data: Dict[str, Any]) -> Dict[str, Any]:
        """Grade a battle submission."""
        response = self.session.post(
            f"{self.base_url}/grade_submission",
            json=submission_data
        )
        response.raise_for_status()
        return response.json()
    
    def get_battle_templates(self) -> Dict[str, Any]:
        """Get battle templates configuration."""
        response = self.session.get(f"{self.base_url}/battle_templates")
        response.raise_for_status()
        return response.json()
    
    def get_reference_data(self) -> Dict[str, Any]:
        """Get reference data."""
        response = self.session.get(f"{self.base_url}/reference_data")
        response.raise_for_status()
        return response.json()


def create_sample_submissions() -> list:
    """Create sample submissions for all battles."""
    base_time = datetime.utcnow()
    
    submissions = []
    
    # Battle 1: Leadership Recon
    submissions.append({
        "team": "Alpha",
        "battle_no": 1,
        "submission_id": "alpha-battle-1-001",
        "submitted_at": base_time.isoformat(),
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
    })
    
    # Battle 2: Product Arsenal
    submissions.append({
        "team": "Delta",
        "battle_no": 2,
        "submission_id": "delta-battle-2-001",
        "submitted_at": base_time.isoformat(),
        "time_taken_seconds": 1800,  # 30 minutes
        "total_time_seconds": 3600,
        "company_reference": {
            "company_id": "ezz-steel-001",
            "use_reference_as_primary": True
        },
        "source_link": "https://ezzsteel.com/products",
        "fields": {
            "product_lines": "Rebar, Wire Rod, Hot-Rolled Flat Steel",
            "pricing": "38200 EGP for Rebar",
            "social_presence": "LinkedIn, Facebook, YouTube",
            "influencers": "Company executives and industry leaders"
        },
        "attachments": []
    })
    
    # Battle 3: Funding Fortification
    submissions.append({
        "team": "Alpha",
        "battle_no": 3,
        "submission_id": "alpha-battle-3-001",
        "submitted_at": base_time.isoformat(),
        "time_taken_seconds": 900,  # 15 minutes
        "total_time_seconds": 3600,
        "company_reference": {
            "company_id": "ezz-steel-001",
            "use_reference_as_primary": True
        },
        "source_link": "https://ezzsteel.com/investors",
        "fields": {
            "funding": "2.02 billion USD H1 2024",
            "investors": "Ahmed Ezz (66.4%), Bank of New York Mellon (5.8%)",
            "revenue": "4.7 billion USD full year 2023",
            "citations": "https://ezzsteel.com/financial-reports"
        },
        "attachments": []
    })
    
    # Battle 4: Customer Frontlines
    submissions.append({
        "team": "Delta",
        "battle_no": 4,
        "submission_id": "delta-battle-4-001",
        "submitted_at": base_time.isoformat(),
        "time_taken_seconds": 2100,  # 35 minutes
        "total_time_seconds": 3600,
        "company_reference": {
            "company_id": "ezz-steel-001",
            "use_reference_as_primary": True
        },
        "source_link": "https://ezzsteel.com/customers",
        "fields": {
            "b2c": "Small contractors (30%), Large developers (60%)",
            "b2b": "Medium contractors (25-30%), Large developers (60-65%)",
            "reviews": "3.5/5 average rating",
            "citations": "https://ezzsteel.com/testimonials"
        },
        "attachments": []
    })
    
    # Battle 5: Alliance Forge
    submissions.append({
        "team": "Alpha",
        "battle_no": 5,
        "submission_id": "alpha-battle-5-001",
        "submitted_at": base_time.isoformat(),
        "time_taken_seconds": 1500,  # 25 minutes
        "total_time_seconds": 3600,
        "company_reference": {
            "company_id": "ezz-steel-001",
            "use_reference_as_primary": True
        },
        "source_link": "https://ezzsteel.com/partnerships",
        "fields": {
            "partners": "Strategic partnerships with international companies",
            "suppliers": "International scrap metal brokers, Egyptian natural gas companies",
            "growth": "62% revenue growth H1 2024",
            "expansions": "Capacity increase (200-300M USD), Eco-friendly steel (100-150M USD)",
            "citations": "https://ezzsteel.com/growth-strategy"
        },
        "attachments": []
    })
    
    return submissions


def main():
    """Main example usage."""
    print("🎯 Market Intelligence War Room - Scoring Service Example")
    print("=" * 60)
    
    # Initialize client
    client = ScoringServiceClient()
    
    try:
        # Check service health
        print("\n1. Checking service health...")
        health = client.health_check()
        print(f"✅ Service Status: {health['status']}")
        print(f"   Version: {health['version']}")
        print(f"   Uptime: {health['uptime_seconds']:.1f} seconds")
        
        # Get battle templates
        print("\n2. Getting battle templates...")
        templates = client.get_battle_templates()
        print(f"✅ Found {len(templates['templates'])} battle templates")
        for battle_no, template in templates['templates'].items():
            print(f"   Battle {battle_no}: {template['name']}")
        
        # Get reference data summary
        print("\n3. Getting reference data...")
        reference_data = client.get_reference_data()
        company_name = reference_data['company']['name']
        print(f"✅ Reference company: {company_name}")
        print(f"   Plants: {reference_data['company']['overview']['plants']}")
        print(f"   Capacity: {reference_data['company']['overview']['capacity_million_tons']}M tons")
        
        # Create and grade sample submissions
        print("\n4. Creating sample submissions...")
        submissions = create_sample_submissions()
        print(f"✅ Created {len(submissions)} sample submissions")
        
        # Grade each submission
        print("\n5. Grading submissions...")
        results = []
        
        for i, submission in enumerate(submissions, 1):
            print(f"\n   Battle {submission['battle_no']} - Team {submission['team']}:")
            
            try:
                result = client.grade_submission(submission)
                results.append(result)
                
                print(f"   ✅ Submission ID: {result['submission_id']}")
                print(f"      Raw AI Score: {result['raw_ai_percent']:.1f}/85")
                print(f"      Scaled Score: {result['scaled_battle_percent']:.1f}%")
                print(f"      Battle Points: {result['battle_points_out_of_20']:.1f}/20")
                print(f"      Confidence: {result['confidence']:.2f}")
                print(f"      Escalated: {result['escalated_for_human_review']}")
                
                # Show breakdown
                breakdown = result['breakdown']
                print(f"      Data Accuracy: {breakdown['data_accuracy_raw']:.1f}/60")
                print(f"      Speed: {breakdown['speed_raw']:.1f}/10")
                print(f"      Source Quality: {breakdown['source_raw']:.1f}/15")
                print(f"      Source Credibility: {breakdown['source_credibility']:.2f}")
                
            except Exception as e:
                print(f"   ❌ Error grading submission: {e}")
        
        # Calculate team scores
        print("\n6. Calculating team scores...")
        team_scores = {"Alpha": 0, "Delta": 0}
        
        for result in results:
            team = result['team']
            points = result['battle_points_out_of_20']
            team_scores[team] += points
        
        print(f"✅ Final Team Scores:")
        print(f"   Team Alpha: {team_scores['Alpha']:.1f}/100 points")
        print(f"   Team Delta: {team_scores['Delta']:.1f}/100 points")
        
        if team_scores['Alpha'] > team_scores['Delta']:
            print(f"🏆 Team Alpha wins!")
        elif team_scores['Delta'] > team_scores['Alpha']:
            print(f"🏆 Team Delta wins!")
        else:
            print(f"🤝 It's a tie!")
        
        # Show detailed results
        print("\n7. Detailed Results Summary:")
        print("-" * 60)
        for result in results:
            print(f"Battle {result['battle_no']} - Team {result['team']}:")
            print(f"  Points: {result['battle_points_out_of_20']:.1f}/20")
            print(f"  Confidence: {result['confidence']:.2f}")
            print(f"  Explanation: {result['explain_text']}")
            print()
        
        print("🎉 Example completed successfully!")
        
    except requests.exceptions.ConnectionError:
        print("❌ Error: Could not connect to scoring service.")
        print("   Make sure the service is running on http://localhost:8000")
        print("   Run: python run.py")
    except Exception as e:
        print(f"❌ Error: {e}")


if __name__ == "__main__":
    main()
