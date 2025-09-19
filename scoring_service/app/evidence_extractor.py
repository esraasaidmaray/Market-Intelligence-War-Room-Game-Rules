"""
Evidence extraction service for web scraping and content analysis.
"""
import asyncio
import logging
from typing import List, Dict, Any, Optional, Tuple
from urllib.parse import urlparse
import httpx
from bs4 import BeautifulSoup
import PyPDF2
import pdfplumber
from PIL import Image
import pytesseract
import io
import base64

from .models import EvidenceSnippet

logger = logging.getLogger(__name__)


class EvidenceExtractor:
    """Service for extracting evidence from web sources."""
    
    def __init__(self, timeout: int = 30):
        self.timeout = timeout
        self.client = httpx.AsyncClient(timeout=timeout)
    
    async def extract_evidence(self, url: str, search_terms: List[str]) -> List[EvidenceSnippet]:
        """Extract evidence snippets from a URL for given search terms."""
        try:
            # Determine content type
            content_type = await self._get_content_type(url)
            
            if content_type == "application/pdf":
                return await self._extract_from_pdf(url, search_terms)
            elif content_type.startswith("image/"):
                return await self._extract_from_image(url, search_terms)
            else:
                return await self._extract_from_html(url, search_terms)
        
        except Exception as e:
            logger.error(f"Error extracting evidence from {url}: {e}")
            return []
    
    async def _get_content_type(self, url: str) -> str:
        """Get content type of URL."""
        try:
            response = await self.client.head(url)
            return response.headers.get("content-type", "text/html").split(";")[0]
        except Exception:
            return "text/html"
    
    async def _extract_from_html(self, url: str, search_terms: List[str]) -> List[EvidenceSnippet]:
        """Extract evidence from HTML content."""
        try:
            response = await self.client.get(url)
            response.raise_for_status()
            
            soup = BeautifulSoup(response.content, 'html.parser')
            
            # Remove script and style elements
            for script in soup(["script", "style"]):
                script.decompose()
            
            text_content = soup.get_text()
            snippets = []
            
            for term in search_terms:
                term_snippets = self._find_term_snippets(
                    text_content, term, url, "html"
                )
                snippets.extend(term_snippets)
            
            return snippets
        
        except Exception as e:
            logger.error(f"Error extracting from HTML {url}: {e}")
            return []
    
    async def _extract_from_pdf(self, url: str, search_terms: List[str]) -> List[EvidenceSnippet]:
        """Extract evidence from PDF content."""
        try:
            response = await self.client.get(url)
            response.raise_for_status()
            
            # Try pdfplumber first (better for complex layouts)
            try:
                with pdfplumber.open(io.BytesIO(response.content)) as pdf:
                    text_content = ""
                    for page in pdf.pages:
                        text_content += page.extract_text() or ""
                
                snippets = []
                for term in search_terms:
                    term_snippets = self._find_term_snippets(
                        text_content, term, url, "pdf"
                    )
                    snippets.extend(term_snippets)
                
                return snippets
            
            except Exception:
                # Fallback to PyPDF2
                pdf_file = io.BytesIO(response.content)
                pdf_reader = PyPDF2.PdfReader(pdf_file)
                
                text_content = ""
                for page in pdf_reader.pages:
                    text_content += page.extract_text()
                
                snippets = []
                for term in search_terms:
                    term_snippets = self._find_term_snippets(
                        text_content, term, url, "pdf"
                    )
                    snippets.extend(term_snippets)
                
                return snippets
        
        except Exception as e:
            logger.error(f"Error extracting from PDF {url}: {e}")
            return []
    
    async def _extract_from_image(self, url: str, search_terms: List[str]) -> List[EvidenceSnippet]:
        """Extract evidence from image using OCR."""
        try:
            response = await self.client.get(url)
            response.raise_for_status()
            
            # Convert to PIL Image
            image = Image.open(io.BytesIO(response.content))
            
            # Perform OCR
            text_content = pytesseract.image_to_string(image)
            
            snippets = []
            for term in search_terms:
                term_snippets = self._find_term_snippets(
                    text_content, term, url, "image"
                )
                snippets.extend(term_snippets)
            
            return snippets
        
        except Exception as e:
            logger.error(f"Error extracting from image {url}: {e}")
            return []
    
    def _find_term_snippets(self, text: str, term: str, url: str, content_type: str) -> List[EvidenceSnippet]:
        """Find snippets containing the search term."""
        snippets = []
        
        if not text or not term:
            return snippets
        
        # Normalize text and term for searching
        normalized_text = text.lower()
        normalized_term = term.lower()
        
        # Find all occurrences
        start = 0
        while True:
            pos = normalized_text.find(normalized_term, start)
            if pos == -1:
                break
            
            # Extract context around the term
            context_start = max(0, pos - 100)
            context_end = min(len(text), pos + len(term) + 100)
            
            snippet_text = text[context_start:context_end]
            
            # Create evidence snippet
            snippet = EvidenceSnippet(
                snapshot_path=f"s3://evidence-snapshots/{urlparse(url).netloc}/{hash(url)}.html",
                xpath=f"//text()[contains(., '{term}')]",
                start_offset=pos - context_start,
                end_offset=pos - context_start + len(term),
                text_snippet=snippet_text
            )
            
            snippets.append(snippet)
            start = pos + 1
        
        return snippets
    
    async def close(self):
        """Close the HTTP client."""
        await self.client.aclose()


class EvidenceCache:
    """Cache for evidence snippets to avoid re-fetching."""
    
    def __init__(self, ttl_seconds: int = 3600):
        self.cache = {}
        self.ttl_seconds = ttl_seconds
    
    def get(self, url: str, search_terms: List[str]) -> Optional[List[EvidenceSnippet]]:
        """Get cached evidence."""
        cache_key = f"{url}:{':'.join(sorted(search_terms))}"
        if cache_key in self.cache:
            entry = self.cache[cache_key]
            if entry['timestamp'] + self.ttl_seconds > asyncio.get_event_loop().time():
                return entry['snippets']
            else:
                del self.cache[cache_key]
        return None
    
    def set(self, url: str, search_terms: List[str], snippets: List[EvidenceSnippet]):
        """Cache evidence."""
        cache_key = f"{url}:{':'.join(sorted(search_terms))}"
        self.cache[cache_key] = {
            'snippets': snippets,
            'timestamp': asyncio.get_event_loop().time()
        }
    
    def clear(self):
        """Clear cache."""
        self.cache.clear()


class EvidenceValidator:
    """Validate evidence quality and relevance."""
    
    def __init__(self):
        self.trusted_domains = [
            "ezzsteel.com",
            "linkedin.com",
            "crunchbase.com",
            "reuters.com",
            "bloomberg.com",
            "wsj.com",
            "ft.com",
            "sec.gov",
            "edgar.sec.gov"
        ]
    
    def validate_evidence(self, snippets: List[EvidenceSnippet], url: str) -> Dict[str, Any]:
        """Validate evidence quality and return validation results."""
        validation = {
            "is_trusted_domain": self._is_trusted_domain(url),
            "snippet_count": len(snippets),
            "total_text_length": sum(len(s.text_snippet) for s in snippets),
            "average_snippet_length": 0,
            "quality_score": 0.0
        }
        
        if snippets:
            validation["average_snippet_length"] = validation["total_text_length"] / len(snippets)
            validation["quality_score"] = self._calculate_quality_score(snippets, url)
        
        return validation
    
    def _is_trusted_domain(self, url: str) -> bool:
        """Check if URL is from a trusted domain."""
        try:
            domain = urlparse(url).netloc.lower()
            return any(trusted in domain for trusted in self.trusted_domains)
        except Exception:
            return False
    
    def _calculate_quality_score(self, snippets: List[EvidenceSnippet], url: str) -> float:
        """Calculate quality score for evidence snippets."""
        if not snippets:
            return 0.0
        
        # Base score from domain trust
        domain_score = 1.0 if self._is_trusted_domain(url) else 0.5
        
        # Length score (prefer longer, more contextual snippets)
        avg_length = sum(len(s.text_snippet) for s in snippets) / len(snippets)
        length_score = min(1.0, avg_length / 200.0)  # Normalize to 200 chars
        
        # Count score (prefer more snippets)
        count_score = min(1.0, len(snippets) / 5.0)  # Normalize to 5 snippets
        
        # Weighted average
        quality_score = (domain_score * 0.4) + (length_score * 0.3) + (count_score * 0.3)
        
        return min(1.0, quality_score)
