#!/usr/bin/env python3
"""
Simple test script to verify Flutter app structure and dependencies.
"""
import os
import json
import subprocess
import sys
from pathlib import Path


def check_file_exists(file_path, description):
    """Check if a file exists and print status."""
    if os.path.exists(file_path):
        print(f"✅ {description}: {file_path}")
        return True
    else:
        print(f"❌ {description}: {file_path} - NOT FOUND")
        return False


def check_directory_exists(dir_path, description):
    """Check if a directory exists and print status."""
    if os.path.isdir(dir_path):
        print(f"✅ {description}: {dir_path}")
        return True
    else:
        print(f"❌ {description}: {dir_path} - NOT FOUND")
        return False


def check_pubspec_yaml():
    """Check pubspec.yaml file and dependencies."""
    pubspec_path = "pubspec.yaml"
    if not os.path.exists(pubspec_path):
        print("❌ pubspec.yaml not found")
        return False
    
    print("✅ pubspec.yaml found")
    
    try:
        with open(pubspec_path, 'r', encoding='utf-8') as f:
            content = f.read()
            
        # Check for required dependencies
        required_deps = [
            'go_router',
            'provider',
            'flutter_animate',
            'url_launcher',
            'intl',
            'uuid'
        ]
        
        print("\n📦 Checking dependencies:")
        for dep in required_deps:
            if dep in content:
                print(f"  ✅ {dep}")
            else:
                print(f"  ❌ {dep} - MISSING")
        
        return True
    except Exception as e:
        print(f"❌ Error reading pubspec.yaml: {e}")
        return False


def check_dart_files():
    """Check for essential Dart files."""
    essential_files = [
        ("lib/main.dart", "Main application file"),
        ("lib/models/player.dart", "Player model"),
        ("lib/models/match.dart", "Match model"),
        ("lib/models/battle_submission.dart", "Battle submission model"),
        ("lib/models/company_reference.dart", "Company reference model"),
        ("lib/providers/game_provider.dart", "Game provider"),
        ("lib/providers/player_provider.dart", "Player provider"),
        ("lib/providers/match_provider.dart", "Match provider"),
        ("lib/services/game_service.dart", "Game service"),
        ("lib/theme/app_theme.dart", "App theme"),
        ("lib/screens/home_screen.dart", "Home screen"),
        ("lib/screens/setup_screen.dart", "Setup screen"),
        ("lib/screens/lobby_screen.dart", "Lobby screen"),
        ("lib/screens/battle_screen.dart", "Battle screen"),
        ("lib/screens/leader_dashboard_screen.dart", "Leader dashboard screen"),
        ("lib/screens/matches_screen.dart", "Matches screen"),
        ("lib/screens/match_summary_screen.dart", "Match summary screen"),
    ]
    
    print("\n📱 Checking Dart files:")
    all_found = True
    for file_path, description in essential_files:
        if not check_file_exists(file_path, description):
            all_found = False
    
    return all_found


def check_widget_files():
    """Check for widget files."""
    widget_files = [
        ("lib/widgets/cyber_background.dart", "Cyber background widget"),
        ("lib/widgets/gradient_button.dart", "Gradient button widget"),
        ("lib/widgets/feature_card.dart", "Feature card widget"),
        ("lib/widgets/step_indicator.dart", "Step indicator widget"),
        ("lib/widgets/avatar_selector.dart", "Avatar selector widget"),
        ("lib/widgets/team_card.dart", "Team card widget"),
        ("lib/widgets/battle_preview.dart", "Battle preview widget"),
        ("lib/widgets/battle_timer.dart", "Battle timer widget"),
        ("lib/widgets/battle_form.dart", "Battle form widget"),
        ("lib/widgets/tools_panel.dart", "Tools panel widget"),
        ("lib/widgets/team_info_panel.dart", "Team info panel widget"),
        ("lib/widgets/redeployment_panel.dart", "Redeployment panel widget"),
    ]
    
    print("\n🎨 Checking widget files:")
    all_found = True
    for file_path, description in widget_files:
        if not check_file_exists(file_path, description):
            all_found = False
    
    return all_found


def check_flutter_installation():
    """Check if Flutter is installed."""
    try:
        result = subprocess.run(['flutter', '--version'], 
                              capture_output=True, text=True, timeout=10)
        if result.returncode == 0:
            print("✅ Flutter is installed")
            print(f"   Version: {result.stdout.split()[1]}")
            return True
        else:
            print("❌ Flutter is not working properly")
            return False
    except (subprocess.TimeoutExpired, FileNotFoundError):
        print("❌ Flutter is not installed or not in PATH")
        print("   Install from: https://flutter.dev/docs/get-started/install")
        return False


def check_dependencies():
    """Check if dependencies are installed."""
    try:
        result = subprocess.run(['flutter', 'pub', 'get'], 
                              capture_output=True, text=True, timeout=30)
        if result.returncode == 0:
            print("✅ Dependencies installed successfully")
            return True
        else:
            print("❌ Error installing dependencies")
            print(f"   Error: {result.stderr}")
            return False
    except (subprocess.TimeoutExpired, FileNotFoundError):
        print("❌ Cannot run 'flutter pub get'")
        return False


def main():
    """Main test function."""
    print("🎯 Market Intelligence War Room - Flutter App Test")
    print("=" * 60)
    
    # Check if we're already in flutter_app directory
    if os.path.exists("pubspec.yaml"):
        print("✅ Already in flutter_app directory")
    elif os.path.exists("../flutter_app"):
        print("📁 Moving to flutter_app directory")
        os.chdir("../flutter_app")
    else:
        print("❌ flutter_app directory not found")
        print("   Make sure you're in the correct directory")
        return False
    print(f"📁 Working directory: {os.getcwd()}")
    
    # Check Flutter installation
    print("\n🔧 Checking Flutter installation:")
    flutter_ok = check_flutter_installation()
    
    # Check pubspec.yaml
    print("\n📋 Checking project configuration:")
    pubspec_ok = check_pubspec_yaml()
    
    # Check Dart files
    dart_ok = check_dart_files()
    
    # Check widget files
    widget_ok = check_widget_files()
    
    # Check dependencies
    if flutter_ok:
        print("\n📦 Checking dependencies:")
        deps_ok = check_dependencies()
    else:
        deps_ok = False
    
    # Summary
    print("\n" + "=" * 60)
    print("📊 TEST SUMMARY")
    print("=" * 60)
    
    tests = [
        ("Flutter Installation", flutter_ok),
        ("Project Configuration", pubspec_ok),
        ("Dart Files", dart_ok),
        ("Widget Files", widget_ok),
        ("Dependencies", deps_ok),
    ]
    
    passed = 0
    for test_name, result in tests:
        status = "✅ PASS" if result else "❌ FAIL"
        print(f"{test_name:20} {status}")
        if result:
            passed += 1
    
    print(f"\nOverall: {passed}/{len(tests)} tests passed")
    
    if passed == len(tests):
        print("\n🎉 All tests passed! Your Flutter app is ready to test.")
        print("\n🚀 Next steps:")
        print("   1. Run: flutter run -d chrome (for web testing)")
        print("   2. Run: flutter run (for mobile testing)")
        print("   3. Run: flutter test (for unit testing)")
    else:
        print("\n⚠️  Some tests failed. Please fix the issues above.")
        print("\n🔧 Common fixes:")
        print("   1. Install Flutter: https://flutter.dev/docs/get-started/install")
        print("   2. Add Flutter to PATH")
        print("   3. Run: flutter doctor")
        print("   4. Run: flutter pub get")
    
    return passed == len(tests)


if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
