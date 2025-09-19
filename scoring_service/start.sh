#!/bin/bash
# Startup script for the Market Intelligence War Room scoring service

echo "🎯 Starting Market Intelligence War Room - Scoring Service"
echo "=========================================================="

# Check if Python is available
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is required but not installed."
    exit 1
fi

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "📦 Creating virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
echo "🔧 Activating virtual environment..."
source venv/bin/activate

# Install dependencies
echo "📥 Installing dependencies..."
pip install -r requirements.txt

# Check if reference data exists
if [ ! -f "data/ezz_steel_reference.json" ]; then
    echo "❌ Reference data not found. Please ensure data/ezz_steel_reference.json exists."
    exit 1
fi

# Run the service
echo "🚀 Starting scoring service..."
echo "   API Documentation: http://localhost:8000/docs"
echo "   Health Check: http://localhost:8000/health"
echo "   Press Ctrl+C to stop"
echo ""

python run.py
