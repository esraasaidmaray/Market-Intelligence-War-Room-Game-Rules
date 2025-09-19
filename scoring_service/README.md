# Market Intelligence War Room - Scoring Microservice

A production-ready, deterministic, auditable scoring microservice for the Market Intelligence War Room competitive game. This service automatically grades participant submissions against the Ezz Steel reference dataset and live web evidence.

## 🎯 Overview

The scoring microservice implements a comprehensive grading system that evaluates submissions across five battles:

1. **Leadership Recon** - Company founders, executives, and market position
2. **Product Arsenal** - Product lines, pricing, and social presence  
3. **Funding Fortification** - Financial data, investors, and revenue
4. **Customer Frontlines** - Customer segments, reviews, and pain points
5. **Alliance Forge** - Partnerships, suppliers, and growth strategies

## 🏗️ Architecture

### Core Components

- **Scoring Engine**: Deterministic algorithms for data accuracy, speed, and source quality
- **Evidence Extractor**: Web scraping and content analysis with OCR support
- **Reference Data**: Ezz Steel company dataset as ground truth
- **Audit System**: Comprehensive logging and human-in-the-loop escalation

### Scoring Formula

```
Per Battle (0-20 points):
- Data Accuracy: 60% weight (0-60 points)
- Speed: 10% weight (0-10 points) 
- Source Quality: 15% weight (0-15 points)
- Teamwork: 15% weight (handled by mobile app)

Total Score: Sum of 5 battles = 0-100 points
```

## 🚀 Quick Start

### Prerequisites

- Python 3.11+
- Docker and Docker Compose
- Tesseract OCR (for image processing)

### Local Development

1. **Clone and setup**:
   ```bash
   cd scoring_service
   pip install -r requirements.txt
   ```

2. **Run the service**:
   ```bash
   python run.py
   ```

3. **Access the API**:
   - API Documentation: http://localhost:8000/docs
   - Health Check: http://localhost:8000/health

### Docker Deployment

1. **Build and run**:
   ```bash
   docker-compose up -d
   ```

2. **Access services**:
   - Scoring API: http://localhost:8000
   - Redis: localhost:6379
   - MinIO: http://localhost:9001 (admin/admin123)
   - Prometheus: http://localhost:9090
   - Grafana: http://localhost:3000 (admin/admin123)

## 📊 API Reference

### Grade Submission

**POST** `/grade_submission`

Grades a battle submission and returns detailed scoring breakdown.

**Request Body**:
```json
{
  "team": "Alpha",
  "battle_no": 1,
  "submission_id": "sub-001",
  "submitted_at": "2024-01-20T10:30:00Z",
  "time_taken_seconds": 1200,
  "total_time_seconds": 3600,
  "company_reference": {
    "company_id": "ezz-steel-001",
    "use_reference_as_primary": true
  },
  "source_link": "https://ezzsteel.com/about",
  "fields": {
    "founders": "Ezz Steel Company S.A.E.",
    "key_executives": "Hassan Ahmed Nouh",
    "market_share": "55%"
  },
  "attachments": []
}
```

**Response**:
```json
{
  "submission_id": "sub-001",
  "team": "Alpha",
  "battle_no": 1,
  "raw_ai_percent": 64.0,
  "scaled_battle_percent": 75.29,
  "battle_points_out_of_20": 15.05,
  "breakdown": {
    "data_accuracy_raw": 44.0,
    "speed_raw": 8.0,
    "source_raw": 12.0,
    "data_accuracy_details": [...],
    "source_credibility": 0.85,
    "source_verified": true,
    "matched_from_reference": true,
    "reference_company_id": "ezz-steel-001",
    "reference_verified": true
  },
  "diagnostics": {
    "missing_fields": [],
    "evidence_not_found_for": [],
    "fetch_warnings": [],
    "conflict_details": {}
  },
  "escalated_for_human_review": false,
  "confidence": 0.91,
  "explain_text": "Strong data accuracy (44.0/60 points). Fast submission (8.0/10 points). High-quality sources (12.0/15 points). High confidence in scoring accuracy."
}
```

### Other Endpoints

- **GET** `/health` - Health check
- **GET** `/battle_templates` - Battle configuration
- **GET** `/reference_data` - Ezz Steel dataset
- **GET** `/scoring_config` - Scoring parameters
- **POST** `/admin/override_score` - Admin score override

## 🔍 Scoring Details

### Data Accuracy (60 points)

Uses fuzzy matching with field-specific validation:

- **Names**: Token sort ratio ≥90% full credit, 70-90% partial
- **Dates**: ±1 year tolerance for full credit
- **Numbers**: ±5% full credit, ±10% partial credit  
- **Percentages**: ±2% full credit, ±5% partial credit
- **Categories**: 85% similarity threshold

### Speed Score (10 points)

Tiered scoring based on submission time:

| Time Range | Score |
|------------|-------|
| 0-10 min   | 10/10 |
| 11-20 min  | 8/10  |
| 21-30 min  | 6/10  |
| 31-40 min  | 4/10  |
| 41-50 min  | 2/10  |
| 51-60 min  | 1/10  |
| 60+ min    | 0/10  |

### Source Quality (15 points)

Credibility scoring by domain type:

- **SEC Filings**: 95%
- **Company Domain**: 90%
- **News Sources**: 85%
- **Crunchbase**: 80%
- **LinkedIn**: 75%
- **Blogs**: 50%
- **Social Media**: 40%
- **Unknown**: 30%

## 🛡️ Security & Compliance

### Data Protection
- PII redaction in logs
- Encrypted evidence storage
- ACL-protected admin endpoints
- Audit trail for all operations

### Rate Limiting
- 100 requests per hour per team
- Configurable quotas
- Graceful degradation

### Human-in-the-Loop
Automatic escalation for:
- Confidence < 75%
- Source credibility < 50%
- Missing evidence for ≥2 fields
- Major data conflicts

## 📈 Monitoring & Observability

### Metrics (Prometheus)
- Request latency and throughput
- Scoring accuracy distribution
- Evidence extraction success rates
- Cache hit ratios
- Error rates by endpoint

### Logging (Structured JSON)
- All submissions and scores
- Evidence extraction details
- Admin actions and overrides
- Performance metrics
- Error traces

### Dashboards (Grafana)
- Real-time scoring metrics
- Team performance trends
- System health monitoring
- Evidence quality analysis

## 🧪 Testing

### Run Tests
```bash
# Unit tests
pytest tests/

# With coverage
pytest --cov=app tests/

# Integration tests
pytest tests/integration/
```

### Test Coverage
- Scoring algorithms (100%)
- Evidence extraction (95%)
- API endpoints (90%)
- Error handling (85%)

## 🔧 Configuration

### Environment Variables
```bash
# API Settings
HOST=0.0.0.0
PORT=8000
DEBUG=false

# Database
DATABASE_URL=sqlite:///./scoring.db

# Redis
REDIS_URL=redis://localhost:6379

# Storage
S3_BUCKET=evidence-snapshots
S3_REGION=us-east-1

# Security
ADMIN_KEY=your-secure-admin-key
JWT_SECRET=your-jwt-secret

# Scoring
CONFIDENCE_THRESHOLD=0.75
SOURCE_CREDIBILITY_THRESHOLD=0.50
```

### Battle Templates
Each battle has configurable field weights and validation rules:

```yaml
Battle 1 - Leadership Recon:
  founders: 12.0
  key_executives: 18.0
  market_share: 20.0
  geographic_footprint: 10.0

Battle 2 - Product Arsenal:
  product_lines: 30.0
  pricing: 15.0
  social_presence: 20.0
  influencers: 15.0
```

## 🚀 Production Deployment

### Docker Compose
```bash
# Production deployment
docker-compose -f docker-compose.prod.yml up -d

# Scale services
docker-compose up -d --scale scoring-service=3
```

### Kubernetes
```bash
# Apply manifests
kubectl apply -f k8s/

# Monitor deployment
kubectl get pods -l app=scoring-service
```

### Health Checks
- **Liveness**: `/health` endpoint
- **Readiness**: Database and Redis connectivity
- **Startup**: Reference data loading

## 📚 Reference Data

The Ezz Steel dataset includes:

- **Company Overview**: Description, capacity, market share
- **Leadership**: Founders, executives, ownership structure
- **Market Position**: TAM/SAM/SOM, competitive ranking
- **Products**: Steel lines, pricing, specifications
- **Financials**: Revenue, funding, investors, valuation
- **Customers**: B2B/B2C segments, reviews, pain points
- **Partnerships**: Suppliers, strategic alliances
- **Growth**: Recent growth, expansion plans

## 🤝 Contributing

### Development Setup
1. Fork the repository
2. Create feature branch
3. Install dependencies: `pip install -r requirements.txt`
4. Run tests: `pytest`
5. Submit pull request

### Code Standards
- Black for formatting
- isort for imports
- flake8 for linting
- mypy for type checking

## 📄 License

MIT License - see LICENSE file for details.

## 🆘 Support

- **Issues**: GitHub Issues
- **Documentation**: `/docs` endpoint
- **Monitoring**: Grafana dashboards
- **Logs**: Structured JSON logs

---

**Ready to score the ultimate intelligence competition?** 🎯

Deploy the scoring microservice and let the Market Intelligence War Room battles begin!
