"""
Deterministic scoring engine for the Market Intelligence War Room game.
"""
import json
import re
from typing import Dict, List, Any, Optional, Tuple
from datetime import datetime
from rapidfuzz import fuzz
from unidecode import unidecode
import logging

from .models import (
    GradeSubmissionRequest, GradeSubmissionResponse, Breakdown, 
    FieldAccuracyDetail, Diagnostics, BattleTemplate, ScoringConfig,
    EvidenceSnippet
)

logger = logging.getLogger(__name__)


class ScoringEngine:
    """Deterministic scoring engine for battle submissions."""
    
    def __init__(self, reference_data: Dict[str, Any], config: ScoringConfig):
        self.reference_data = reference_data
        self.config = config
        self.battle_templates = {
            1: BattleTemplate(
                battle_number=1, name="Leadership Recon",
                field_weights={"founders": 12.0, "key_executives": 18.0, "market_share": 20.0, "geographic_footprint": 10.0},
                required_fields=["founders", "key_executives", "market_share"],
                field_types={"founders": "name", "key_executives": "name", "market_share": "percentage", "geographic_footprint": "category"}
            ),
            2: BattleTemplate(
                battle_number=2, name="Product Arsenal",
                field_weights={"product_lines": 30.0, "pricing": 15.0, "social_presence": 20.0, "influencers": 15.0},
                required_fields=["product_lines", "pricing", "social_presence"],
                field_types={"product_lines": "category", "pricing": "number", "social_presence": "category", "influencers": "name"}
            ),
            3: BattleTemplate(
                battle_number=3, name="Funding Fortification",
                field_weights={"funding": 40.0, "investors": 20.0, "revenue": 25.0, "citations": 15.0},
                required_fields=["funding", "investors", "revenue"],
                field_types={"funding": "number", "investors": "name", "revenue": "number", "citations": "url"}
            ),
            4: BattleTemplate(
                battle_number=4, name="Customer Frontlines",
                field_weights={"b2c": 25.0, "b2b": 25.0, "reviews": 25.0, "citations": 25.0},
                required_fields=["b2c", "b2b", "reviews"],
                field_types={"b2c": "category", "b2b": "category", "reviews": "number", "citations": "url"}
            ),
            5: BattleTemplate(
                battle_number=5, name="Alliance Forge",
                field_weights={"partners": 25.0, "suppliers": 20.0, "growth": 25.0, "expansions": 15.0, "citations": 15.0},
                required_fields=["partners", "suppliers", "growth"],
                field_types={"partners": "name", "suppliers": "name", "growth": "percentage", "expansions": "category", "citations": "url"}
            )
        }
    
    def normalize_text(self, text: str) -> str:
        """Normalize text for comparison."""
        if not text:
            return ""
        # Convert to lowercase, remove diacritics, strip whitespace
        normalized = unidecode(str(text).lower().strip())
        # Remove extra whitespace and punctuation
        normalized = re.sub(r'[^\w\s]', ' ', normalized)
        normalized = re.sub(r'\s+', ' ', normalized)
        return normalized.strip()
    
    def calculate_name_similarity(self, submitted: str, reference: str) -> float:
        """Calculate similarity between names using token_sort_ratio."""
        if not submitted or not reference:
            return 0.0
        
        norm_submitted = self.normalize_text(submitted)
        norm_reference = self.normalize_text(reference)
        
        if norm_submitted == norm_reference:
            return 1.0
        
        similarity = fuzz.token_sort_ratio(norm_submitted, norm_reference) / 100.0
        
        if similarity >= self.config.name_similarity_threshold:
            return 1.0
        elif similarity >= self.config.name_partial_threshold:
            return similarity
        else:
            return 0.0
    
    def calculate_date_similarity(self, submitted: str, reference: str) -> float:
        """Calculate similarity between dates."""
        if not submitted or not reference:
            return 0.0
        
        try:
            # Extract year from submitted date
            submitted_year = self.extract_year(submitted)
            reference_year = self.extract_year(reference)
            
            if not submitted_year or not reference_year:
                return 0.0
            
            year_diff = abs(submitted_year - reference_year)
            if year_diff <= self.config.date_tolerance_years:
                return 1.0
            else:
                return 0.0
        except Exception:
            return 0.0
    
    def extract_year(self, date_str: str) -> Optional[int]:
        """Extract year from date string."""
        # Try various date formats
        patterns = [
            r'\b(19|20)\d{2}\b',  # 4-digit year
            r'\b\d{1,2}/\d{1,2}/(19|20)\d{2}\b',  # MM/DD/YYYY
            r'\b(19|20)\d{2}-\d{1,2}-\d{1,2}\b',  # YYYY-MM-DD
        ]
        
        for pattern in patterns:
            match = re.search(pattern, str(date_str))
            if match:
                year_str = match.group(1) + match.group(2) if len(match.groups()) > 1 else match.group(0)
                return int(year_str)
        
        return None
    
    def calculate_numeric_similarity(self, submitted: str, reference: str) -> float:
        """Calculate similarity between numeric values."""
        if not submitted or not reference:
            return 0.0
        
        try:
            # Extract numeric values
            sub_num = self.extract_number(submitted)
            ref_num = self.extract_number(reference)
            
            if sub_num is None or ref_num is None or ref_num == 0:
                return 0.0
            
            # Calculate percentage difference
            diff_percent = abs(sub_num - ref_num) / ref_num * 100
            
            if diff_percent <= self.config.numeric_tolerance_percent:
                return 1.0
            elif diff_percent <= self.config.numeric_partial_tolerance_percent:
                return 1.0 - (diff_percent - self.config.numeric_tolerance_percent) / (self.config.numeric_partial_tolerance_percent - self.config.numeric_tolerance_percent) * 0.5
            else:
                return 0.0
        except Exception:
            return 0.0
    
    def extract_number(self, text: str) -> Optional[float]:
        """Extract numeric value from text."""
        if not text:
            return None
        
        # Remove common currency symbols and formatting
        cleaned = re.sub(r'[,$€£¥]', '', str(text))
        cleaned = re.sub(r'[^\d.-]', ' ', cleaned)
        
        # Find first number
        numbers = re.findall(r'-?\d+\.?\d*', cleaned)
        if numbers:
            return float(numbers[0])
        
        return None
    
    def calculate_percentage_similarity(self, submitted: str, reference: str) -> float:
        """Calculate similarity between percentage values."""
        if not submitted or not reference:
            return 0.0
        
        try:
            sub_pct = self.extract_percentage(submitted)
            ref_pct = self.extract_percentage(reference)
            
            if sub_pct is None or ref_pct is None:
                return 0.0
            
            diff = abs(sub_pct - ref_pct)
            
            if diff <= self.config.percentage_tolerance:
                return 1.0
            elif diff <= self.config.percentage_partial_tolerance:
                return 1.0 - (diff - self.config.percentage_tolerance) / (self.config.percentage_partial_tolerance - self.config.percentage_tolerance) * 0.5
            else:
                return 0.0
        except Exception:
            return 0.0
    
    def extract_percentage(self, text: str) -> Optional[float]:
        """Extract percentage value from text."""
        if not text:
            return None
        
        # Look for percentage patterns
        patterns = [
            r'(\d+\.?\d*)\s*%',  # 50%
            r'(\d+\.?\d*)\s*percent',  # 50 percent
        ]
        
        for pattern in patterns:
            match = re.search(pattern, str(text).lower())
            if match:
                return float(match.group(1))
        
        return None
    
    def calculate_category_similarity(self, submitted: str, reference: str) -> float:
        """Calculate similarity between category values."""
        if not submitted or not reference:
            return 0.0
        
        norm_submitted = self.normalize_text(submitted)
        norm_reference = self.normalize_text(reference)
        
        if norm_submitted == norm_reference:
            return 1.0
        
        similarity = fuzz.token_sort_ratio(norm_submitted, norm_reference) / 100.0
        
        if similarity >= self.config.category_similarity_threshold:
            return 1.0
        else:
            return 0.0
    
    def calculate_field_similarity(self, field_name: str, field_type: str, submitted: str, reference: str) -> float:
        """Calculate similarity based on field type."""
        if field_type == "name":
            return self.calculate_name_similarity(submitted, reference)
        elif field_type == "date":
            return self.calculate_date_similarity(submitted, reference)
        elif field_type == "number":
            return self.calculate_numeric_similarity(submitted, reference)
        elif field_type == "percentage":
            return self.calculate_percentage_similarity(submitted, reference)
        elif field_type == "category":
            return self.calculate_category_similarity(submitted, reference)
        else:
            # Default to name similarity
            return self.calculate_name_similarity(submitted, reference)
    
    def find_reference_value(self, field_name: str, battle_template: BattleTemplate) -> Optional[Any]:
        """Find reference value for a field in the reference dataset."""
        try:
            # Map field names to reference data paths
            field_mapping = {
                "founders": ["leadership_and_ownership", "founders", "company"],
                "key_executives": ["leadership_and_ownership", "key_executives"],
                "market_share": ["market", "competitive_position", "market_share", "overall"],
                "geographic_footprint": ["market", "geographic_footprint"],
                "product_lines": ["products", "lines"],
                "pricing": ["products", "lines"],
                "social_presence": ["social_presence", "platforms"],
                "influencers": ["social_presence", "platforms"],
                "funding": ["funding", "revenue", "h1_2024_usd_billion"],
                "investors": ["funding", "investors"],
                "revenue": ["funding", "revenue"],
                "citations": ["social_presence", "platforms"],
                "b2c": ["customers", "b2c"],
                "b2b": ["customers", "b2b"],
                "reviews": ["customers", "reviews"],
                "partners": ["partnerships_and_supply_chain", "strategic_partners"],
                "suppliers": ["partnerships_and_supply_chain", "key_suppliers"],
                "growth": ["growth", "recent_growth"],
                "expansions": ["growth", "expansions"]
            }
            
            if field_name not in field_mapping:
                return None
            
            path = field_mapping[field_name]
            value = self.reference_data
            
            for key in path:
                if isinstance(value, dict) and key in value:
                    value = value[key]
                else:
                    return None
            
            return value
        except Exception as e:
            logger.warning(f"Error finding reference value for {field_name}: {e}")
            return None
    
    def calculate_speed_score(self, time_taken_seconds: int, total_time_seconds: int) -> float:
        """Calculate speed score based on time taken."""
        time_taken_minutes = time_taken_seconds / 60.0
        
        # Use tiered scoring
        for tier in self.config.speed_tiers:
            if time_taken_minutes <= tier["max_minutes"]:
                return tier["score"]
        
        # Fallback to linear calculation
        time_left_ratio = max(0, (total_time_seconds - time_taken_seconds) / total_time_seconds)
        return time_left_ratio * 10.0
    
    def calculate_source_credibility(self, source_url: str) -> float:
        """Calculate source credibility score."""
        if not source_url:
            return 0.0
        
        domain = self.extract_domain(source_url)
        if not domain:
            return self.config.source_credibility_scores["unknown"]
        
        # Check for specific domain patterns
        if any(filing in domain for filing in ["sec.gov", "edgar", "filings"]):
            return self.config.source_credibility_scores["filings"]
        elif "ezzsteel" in domain:
            return self.config.source_credibility_scores["company_domain"]
        elif any(news in domain for news in ["reuters.com", "bloomberg.com", "wsj.com", "ft.com"]):
            return self.config.source_credibility_scores["reuters_bloomberg"]
        elif "crunchbase" in domain:
            return self.config.source_credibility_scores["crunchbase"]
        elif "linkedin" in domain:
            return self.config.source_credibility_scores["linkedin"]
        elif any(blog in domain for blog in ["blog", "medium", "substack"]):
            return self.config.source_credibility_scores["blogs"]
        elif any(social in domain for social in ["facebook", "twitter", "instagram", "youtube"]):
            return self.config.source_credibility_scores["social_media"]
        else:
            return self.config.source_credibility_scores["unknown"]
    
    def extract_domain(self, url: str) -> str:
        """Extract domain from URL."""
        try:
            from urllib.parse import urlparse
            parsed = urlparse(url)
            return parsed.netloc.lower()
        except Exception:
            return ""
    
    def grade_submission(self, request: GradeSubmissionRequest) -> GradeSubmissionResponse:
        """Grade a battle submission."""
        battle_template = self.battle_templates[request.battle_no]
        
        # Calculate data accuracy
        data_accuracy_raw, accuracy_details = self.calculate_data_accuracy(
            request.fields, battle_template
        )
        
        # Calculate speed score
        speed_raw = self.calculate_speed_score(
            request.time_taken_seconds, request.total_time_seconds
        )
        
        # Calculate source score
        source_raw, source_credibility, source_verified = self.calculate_source_score(
            request.source_link, request.company_reference
        )
        
        # Calculate raw AI percent (0-85)
        raw_ai_percent = data_accuracy_raw + speed_raw + source_raw
        
        # Scale to 0-100
        scaled_battle_percent = (raw_ai_percent / 85.0) * 100.0
        
        # Convert to points out of 20
        battle_points_out_of_20 = (scaled_battle_percent / 100.0) * 20.0
        
        # Determine if matched from reference
        matched_from_reference = (
            request.company_reference is not None and 
            request.company_reference.use_reference_as_primary
        )
        
        # Calculate confidence
        confidence = self.calculate_confidence(
            data_accuracy_raw, speed_raw, source_raw, len(accuracy_details)
        )
        
        # Check if escalation needed
        escalated = self.should_escalate(confidence, source_credibility, accuracy_details)
        
        # Generate explanation
        explain_text = self.generate_explanation(
            data_accuracy_raw, speed_raw, source_raw, confidence, escalated
        )
        
        # Create diagnostics
        diagnostics = Diagnostics(
            missing_fields=self.find_missing_fields(request.fields, battle_template),
            evidence_not_found_for=self.find_evidence_not_found(accuracy_details),
            fetch_warnings=[],
            conflict_details={}
        )
        
        return GradeSubmissionResponse(
            submission_id=request.submission_id,
            team=request.team,
            battle_no=request.battle_no,
            raw_ai_percent=raw_ai_percent,
            scaled_battle_percent=scaled_battle_percent,
            battle_points_out_of_20=battle_points_out_of_20,
            breakdown=Breakdown(
                data_accuracy_raw=data_accuracy_raw,
                speed_raw=speed_raw,
                source_raw=source_raw,
                data_accuracy_details=accuracy_details,
                source_credibility=source_credibility,
                source_verified=source_verified,
                matched_from_reference=matched_from_reference,
                reference_company_id=request.company_reference.company_id if request.company_reference else None,
                reference_verified=matched_from_reference
            ),
            diagnostics=diagnostics,
            escalated_for_human_review=escalated,
            confidence=confidence,
            explain_text=explain_text
        )
    
    def calculate_data_accuracy(self, fields: Dict[str, Any], battle_template: BattleTemplate) -> Tuple[float, List[FieldAccuracyDetail]]:
        """Calculate data accuracy score and details."""
        total_score = 0.0
        details = []
        
        for field_name, weight in battle_template.field_weights.items():
            field_type = battle_template.field_types.get(field_name, "name")
            submitted_value = str(fields.get(field_name, ""))
            
            # Find reference value
            reference_value = self.find_reference_value(field_name, battle_template)
            
            if reference_value is None:
                # No reference data found
                details.append(FieldAccuracyDetail(
                    field=field_name,
                    submitted=submitted_value,
                    found_in_source=False,
                    match_score=0.0,
                    weight=weight,
                    contribution=0.0
                ))
                continue
            
            # Calculate similarity
            if isinstance(reference_value, list):
                # Handle list values (e.g., key_executives)
                best_match = 0.0
                for ref_item in reference_value:
                    if isinstance(ref_item, dict):
                        # Extract name or title for comparison
                        ref_text = ref_item.get("name", ref_item.get("title", ""))
                    else:
                        ref_text = str(ref_item)
                    
                    similarity = self.calculate_field_similarity(
                        field_name, field_type, submitted_value, ref_text
                    )
                    best_match = max(best_match, similarity)
                
                match_score = best_match
            else:
                match_score = self.calculate_field_similarity(
                    field_name, field_type, submitted_value, str(reference_value)
                )
            
            contribution = weight * match_score
            total_score += contribution
            
            details.append(FieldAccuracyDetail(
                field=field_name,
                submitted=submitted_value,
                found_in_source=True,
                match_score=match_score,
                weight=weight,
                contribution=contribution
            ))
        
        return total_score, details
    
    def calculate_source_score(self, source_url: Optional[str], company_reference: Optional[Any]) -> Tuple[float, float, bool]:
        """Calculate source score."""
        if company_reference and company_reference.use_reference_as_primary:
            return 15.0, 1.0, True
        
        if not source_url:
            return 0.0, 0.0, False
        
        credibility = self.calculate_source_credibility(str(source_url))
        source_raw = credibility * 15.0
        
        return source_raw, credibility, True
    
    def calculate_confidence(self, data_accuracy: float, speed: float, source: float, field_count: int) -> float:
        """Calculate overall confidence score."""
        # Base confidence from scores
        base_confidence = (data_accuracy + speed + source) / 85.0
        
        # Adjust for field coverage
        field_coverage = min(1.0, field_count / 5.0)  # Assume 5 fields is full coverage
        
        # Weighted average
        confidence = (base_confidence * 0.8) + (field_coverage * 0.2)
        
        return min(1.0, max(0.0, confidence))
    
    def should_escalate(self, confidence: float, source_credibility: float, accuracy_details: List[FieldAccuracyDetail]) -> bool:
        """Determine if submission should be escalated for human review."""
        if confidence < self.config.confidence_threshold:
            return True
        
        if source_credibility < self.config.source_credibility_threshold:
            return True
        
        missing_evidence_count = sum(1 for detail in accuracy_details if not detail.found_in_source)
        if missing_evidence_count >= self.config.max_missing_fields:
            return True
        
        return False
    
    def find_missing_fields(self, fields: Dict[str, Any], battle_template: BattleTemplate) -> List[str]:
        """Find missing required fields."""
        missing = []
        for field in battle_template.required_fields:
            if field not in fields or not fields[field]:
                missing.append(field)
        return missing
    
    def find_evidence_not_found(self, accuracy_details: List[FieldAccuracyDetail]) -> List[str]:
        """Find fields where evidence was not found."""
        return [detail.field for detail in accuracy_details if not detail.found_in_source]
    
    def generate_explanation(self, data_accuracy: float, speed: float, source: float, confidence: float, escalated: bool) -> str:
        """Generate human-readable explanation."""
        explanation_parts = []
        
        # Data accuracy explanation
        if data_accuracy >= 50:
            explanation_parts.append(f"Strong data accuracy ({data_accuracy:.1f}/60 points)")
        elif data_accuracy >= 30:
            explanation_parts.append(f"Moderate data accuracy ({data_accuracy:.1f}/60 points)")
        else:
            explanation_parts.append(f"Weak data accuracy ({data_accuracy:.1f}/60 points)")
        
        # Speed explanation
        if speed >= 8:
            explanation_parts.append(f"Fast submission ({speed:.1f}/10 points)")
        elif speed >= 5:
            explanation_parts.append(f"Moderate speed ({speed:.1f}/10 points)")
        else:
            explanation_parts.append(f"Slow submission ({speed:.1f}/10 points)")
        
        # Source explanation
        if source >= 12:
            explanation_parts.append(f"High-quality sources ({source:.1f}/15 points)")
        elif source >= 8:
            explanation_parts.append(f"Moderate source quality ({source:.1f}/15 points)")
        else:
            explanation_parts.append(f"Low source quality ({source:.1f}/15 points)")
        
        # Confidence and escalation
        if escalated:
            explanation_parts.append("Escalated for human review due to low confidence or missing evidence.")
        elif confidence >= 0.8:
            explanation_parts.append("High confidence in scoring accuracy.")
        else:
            explanation_parts.append("Moderate confidence in scoring accuracy.")
        
        return ". ".join(explanation_parts) + "."
