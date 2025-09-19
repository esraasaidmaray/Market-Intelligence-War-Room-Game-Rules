"""
Tests for the evidence extractor.
"""
import pytest
from unittest.mock import AsyncMock, patch
from app.evidence_extractor import EvidenceExtractor, EvidenceCache, EvidenceValidator
from app.models import EvidenceSnippet


@pytest.fixture
def evidence_extractor():
    """Evidence extractor instance for testing."""
    return EvidenceExtractor(timeout=10)


@pytest.fixture
def evidence_cache():
    """Evidence cache instance for testing."""
    return EvidenceCache(ttl_seconds=60)


@pytest.fixture
def evidence_validator():
    """Evidence validator instance for testing."""
    return EvidenceValidator()


class TestEvidenceExtractor:
    """Test cases for the evidence extractor."""
    
    @pytest.mark.asyncio
    async def test_extract_evidence_html(self, evidence_extractor):
        """Test extracting evidence from HTML content."""
        with patch.object(evidence_extractor, '_get_content_type', return_value="text/html"):
            with patch.object(evidence_extractor, '_extract_from_html') as mock_extract:
                mock_extract.return_value = [
                    EvidenceSnippet(
                        snapshot_path="s3://test/snapshot.html",
                        xpath="//text()[contains(., 'test')]",
                        start_offset=10,
                        end_offset=20,
                        text_snippet="This is a test snippet"
                    )
                ]
                
                snippets = await evidence_extractor.extract_evidence(
                    "https://example.com", ["test"]
                )
                
                assert len(snippets) == 1
                assert snippets[0].text_snippet == "This is a test snippet"
                mock_extract.assert_called_once()
    
    @pytest.mark.asyncio
    async def test_extract_evidence_pdf(self, evidence_extractor):
        """Test extracting evidence from PDF content."""
        with patch.object(evidence_extractor, '_get_content_type', return_value="application/pdf"):
            with patch.object(evidence_extractor, '_extract_from_pdf') as mock_extract:
                mock_extract.return_value = [
                    EvidenceSnippet(
                        snapshot_path="s3://test/snapshot.pdf",
                        xpath="//text()[contains(., 'pdf')]",
                        start_offset=5,
                        end_offset=15,
                        text_snippet="PDF content test"
                    )
                ]
                
                snippets = await evidence_extractor.extract_evidence(
                    "https://example.com/document.pdf", ["pdf"]
                )
                
                assert len(snippets) == 1
                assert snippets[0].text_snippet == "PDF content test"
                mock_extract.assert_called_once()
    
    @pytest.mark.asyncio
    async def test_extract_evidence_image(self, evidence_extractor):
        """Test extracting evidence from image content."""
        with patch.object(evidence_extractor, '_get_content_type', return_value="image/png"):
            with patch.object(evidence_extractor, '_extract_from_image') as mock_extract:
                mock_extract.return_value = [
                    EvidenceSnippet(
                        snapshot_path="s3://test/snapshot.png",
                        xpath="//text()[contains(., 'image')]",
                        start_offset=0,
                        end_offset=10,
                        text_snippet="Image OCR text"
                    )
                ]
                
                snippets = await evidence_extractor.extract_evidence(
                    "https://example.com/image.png", ["image"]
                )
                
                assert len(snippets) == 1
                assert snippets[0].text_snippet == "Image OCR text"
                mock_extract.assert_called_once()
    
    @pytest.mark.asyncio
    async def test_extract_evidence_error_handling(self, evidence_extractor):
        """Test error handling in evidence extraction."""
        with patch.object(evidence_extractor, '_get_content_type', side_effect=Exception("Network error")):
            snippets = await evidence_extractor.extract_evidence(
                "https://invalid-url.com", ["test"]
            )
            
            assert snippets == []
    
    def test_find_term_snippets(self, evidence_extractor):
        """Test finding term snippets in text."""
        text = "This is a test document with multiple test occurrences. Another test here."
        snippets = evidence_extractor._find_term_snippets(
            text, "test", "https://example.com", "html"
        )
        
        assert len(snippets) == 3  # Should find 3 occurrences
        assert all("test" in snippet.text_snippet.lower() for snippet in snippets)
        assert all(snippet.snapshot_path.startswith("s3://") for snippet in snippets)
    
    def test_find_term_snippets_no_matches(self, evidence_extractor):
        """Test finding term snippets when no matches exist."""
        text = "This document has no matches for the search term."
        snippets = evidence_extractor._find_term_snippets(
            text, "nonexistent", "https://example.com", "html"
        )
        
        assert len(snippets) == 0
    
    def test_find_term_snippets_empty_text(self, evidence_extractor):
        """Test finding term snippets with empty text."""
        snippets = evidence_extractor._find_term_snippets(
            "", "test", "https://example.com", "html"
        )
        
        assert len(snippets) == 0
    
    @pytest.mark.asyncio
    async def test_close(self, evidence_extractor):
        """Test closing the evidence extractor."""
        await evidence_extractor.close()
        # Should not raise any exceptions


class TestEvidenceCache:
    """Test cases for the evidence cache."""
    
    def test_get_missing_key(self, evidence_cache):
        """Test getting a missing cache key."""
        result = evidence_cache.get("https://example.com", ["test"])
        assert result is None
    
    def test_set_and_get(self, evidence_cache):
        """Test setting and getting cache values."""
        snippets = [
            EvidenceSnippet(
                snapshot_path="s3://test/snapshot.html",
                xpath="//text()[contains(., 'test')]",
                start_offset=10,
                end_offset=20,
                text_snippet="Test snippet"
            )
        ]
        
        evidence_cache.set("https://example.com", ["test"], snippets)
        result = evidence_cache.get("https://example.com", ["test"])
        
        assert result == snippets
    
    def test_cache_expiration(self, evidence_cache):
        """Test cache expiration."""
        snippets = [
            EvidenceSnippet(
                snapshot_path="s3://test/snapshot.html",
                xpath="//text()[contains(., 'test')]",
                start_offset=10,
                end_offset=20,
                text_snippet="Test snippet"
            )
        ]
        
        evidence_cache.set("https://example.com", ["test"], snippets)
        
        # Simulate time passing by manually setting timestamp to past
        cache_key = "https://example.com:test"
        evidence_cache.cache[cache_key]["timestamp"] = 0
        
        result = evidence_cache.get("https://example.com", ["test"])
        assert result is None
    
    def test_clear(self, evidence_cache):
        """Test clearing the cache."""
        snippets = [
            EvidenceSnippet(
                snapshot_path="s3://test/snapshot.html",
                xpath="//text()[contains(., 'test')]",
                start_offset=10,
                end_offset=20,
                text_snippet="Test snippet"
            )
        ]
        
        evidence_cache.set("https://example.com", ["test"], snippets)
        assert len(evidence_cache.cache) == 1
        
        evidence_cache.clear()
        assert len(evidence_cache.cache) == 0


class TestEvidenceValidator:
    """Test cases for the evidence validator."""
    
    def test_is_trusted_domain(self, evidence_validator):
        """Test trusted domain detection."""
        assert evidence_validator._is_trusted_domain("https://ezzsteel.com/about") == True
        assert evidence_validator._is_trusted_domain("https://linkedin.com/company/ezzsteel") == True
        assert evidence_validator._is_trusted_domain("https://reuters.com/article") == True
        assert evidence_validator._is_trusted_domain("https://unknown-site.com") == False
        assert evidence_validator._is_trusted_domain("invalid-url") == False
    
    def test_validate_evidence(self, evidence_validator):
        """Test evidence validation."""
        snippets = [
            EvidenceSnippet(
                snapshot_path="s3://test/snapshot.html",
                xpath="//text()[contains(., 'test')]",
                start_offset=10,
                end_offset=20,
                text_snippet="This is a test snippet with some content"
            ),
            EvidenceSnippet(
                snapshot_path="s3://test/snapshot.html",
                xpath="//text()[contains(., 'test')]",
                start_offset=30,
                end_offset=40,
                text_snippet="Another test snippet"
            )
        ]
        
        validation = evidence_validator.validate_evidence(
            snippets, "https://ezzsteel.com/about"
        )
        
        assert validation["is_trusted_domain"] == True
        assert validation["snippet_count"] == 2
        assert validation["total_text_length"] > 0
        assert validation["average_snippet_length"] > 0
        assert 0 <= validation["quality_score"] <= 1
    
    def test_validate_evidence_empty_snippets(self, evidence_validator):
        """Test validation with empty snippets."""
        validation = evidence_validator.validate_evidence(
            [], "https://example.com"
        )
        
        assert validation["is_trusted_domain"] == False
        assert validation["snippet_count"] == 0
        assert validation["total_text_length"] == 0
        assert validation["average_snippet_length"] == 0
        assert validation["quality_score"] == 0.0
    
    def test_calculate_quality_score(self, evidence_validator):
        """Test quality score calculation."""
        # High quality snippets from trusted domain
        high_quality_snippets = [
            EvidenceSnippet(
                snapshot_path="s3://test/snapshot.html",
                xpath="//text()[contains(., 'test')]",
                start_offset=10,
                end_offset=20,
                text_snippet="This is a very long and detailed test snippet with lots of context and information that should score highly"
            )
        ]
        
        score = evidence_validator._calculate_quality_score(
            high_quality_snippets, "https://ezzsteel.com/about"
        )
        
        assert score > 0.8  # Should be high quality
        
        # Low quality snippets from untrusted domain
        low_quality_snippets = [
            EvidenceSnippet(
                snapshot_path="s3://test/snapshot.html",
                xpath="//text()[contains(., 'test')]",
                start_offset=10,
                end_offset=20,
                text_snippet="Short"
            )
        ]
        
        score = evidence_validator._calculate_quality_score(
            low_quality_snippets, "https://unknown-blog.com"
        )
        
        assert score < 0.5  # Should be lower quality
