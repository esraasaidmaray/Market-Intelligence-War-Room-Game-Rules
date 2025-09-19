# Market Intelligence War Room - Scoring Service Deployment Guide

## 🚀 Quick Start

### Option 1: Local Development

1. **Prerequisites**:
   - Python 3.11+
   - pip package manager

2. **Setup**:
   ```bash
   cd scoring_service
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   pip install -r requirements.txt
   ```

3. **Run**:
   ```bash
   python run.py
   ```

4. **Access**:
   - API: http://localhost:8000
   - Docs: http://localhost:8000/docs
   - Health: http://localhost:8000/health

### Option 2: Docker

1. **Build and run**:
   ```bash
   cd scoring_service
   docker-compose up -d
   ```

2. **Access services**:
   - Scoring API: http://localhost:8000
   - Redis: localhost:6379
   - MinIO: http://localhost:9001
   - Prometheus: http://localhost:9090
   - Grafana: http://localhost:3000

### Option 3: Production Deployment

1. **Environment setup**:
   ```bash
   export DATABASE_URL="postgresql://user:pass@host:5432/scoring"
   export REDIS_URL="redis://host:6379"
   export S3_BUCKET="your-evidence-bucket"
   export ADMIN_KEY="your-secure-admin-key"
   ```

2. **Deploy with Docker**:
   ```bash
   docker-compose -f docker-compose.prod.yml up -d
   ```

## 📊 Testing

### Run Tests
```bash
# Unit tests
pytest tests/

# With coverage
pytest --cov=app tests/

# Integration tests
pytest tests/test_integration.py -v
```

### Example Usage
```bash
python example_usage.py
```

## 🔧 Configuration

### Environment Variables
- `HOST`: Server host (default: 0.0.0.0)
- `PORT`: Server port (default: 8000)
- `DEBUG`: Debug mode (default: false)
- `DATABASE_URL`: Database connection string
- `REDIS_URL`: Redis connection string
- `S3_BUCKET`: S3 bucket for evidence storage
- `ADMIN_KEY`: Admin authentication key
- `LOG_LEVEL`: Logging level (default: INFO)

### Battle Configuration
Edit `app/models.py` to modify:
- Field weights per battle
- Required fields
- Field types and validation rules
- Scoring thresholds

## 📈 Monitoring

### Health Checks
- **Liveness**: `GET /health`
- **Readiness**: Database and Redis connectivity
- **Metrics**: Prometheus metrics on port 9090

### Logging
- Structured JSON logs
- Request/response logging
- Error tracking
- Performance metrics

### Dashboards
- Grafana dashboards available
- Real-time scoring metrics
- Team performance trends
- System health monitoring

## 🛡️ Security

### Authentication
- Admin endpoints require API key
- JWT tokens for user authentication
- Rate limiting per team

### Data Protection
- PII redaction in logs
- Encrypted evidence storage
- Audit trail for all operations

### Network Security
- CORS configuration
- HTTPS in production
- Firewall rules for admin endpoints

## 🔄 Maintenance

### Updates
1. Pull latest code
2. Update dependencies: `pip install -r requirements.txt`
3. Run migrations (if applicable)
4. Restart services

### Backup
- Database backups
- Evidence storage backups
- Configuration backups

### Scaling
- Horizontal scaling with load balancer
- Redis clustering for cache
- Database read replicas

## 🆘 Troubleshooting

### Common Issues

1. **Service won't start**:
   - Check Python version (3.11+)
   - Verify dependencies installed
   - Check port availability

2. **Scoring errors**:
   - Verify reference data exists
   - Check field validation rules
   - Review error logs

3. **Performance issues**:
   - Monitor Redis cache hit rates
   - Check database connections
   - Review evidence extraction logs

### Debug Mode
```bash
export DEBUG=true
python run.py
```

### Logs
```bash
# Docker logs
docker-compose logs -f scoring-service

# Application logs
tail -f logs/scoring-service.log
```

## 📞 Support

- **Documentation**: `/docs` endpoint
- **Health Status**: `/health` endpoint
- **Metrics**: Prometheus/Grafana
- **Logs**: Structured JSON logs

---

**Ready to deploy the ultimate scoring system?** 🎯

Follow this guide to get your Market Intelligence War Room scoring service up and running!
