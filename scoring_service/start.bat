@echo off
REM Startup script for the Market Intelligence War Room scoring service

echo 🎯 Starting Market Intelligence War Room - Scoring Service
echo ==========================================================

REM Check if Python is available
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Python is required but not installed.
    pause
    exit /b 1
)

REM Check if virtual environment exists
if not exist "venv" (
    echo 📦 Creating virtual environment...
    python -m venv venv
)

REM Activate virtual environment
echo 🔧 Activating virtual environment...
call venv\Scripts\activate.bat

REM Install dependencies
echo 📥 Installing dependencies...
pip install -r requirements.txt

REM Check if reference data exists
if not exist "data\ezz_steel_reference.json" (
    echo ❌ Reference data not found. Please ensure data\ezz_steel_reference.json exists.
    pause
    exit /b 1
)

REM Run the service
echo 🚀 Starting scoring service...
echo    API Documentation: http://localhost:8000/docs
echo    Health Check: http://localhost:8000/health
echo    Press Ctrl+C to stop
echo.

python run.py
