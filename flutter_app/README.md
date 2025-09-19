# Market Intelligence War Room - Flutter Mobile App

A multiplayer, gamified, real-time mobile game for market intelligence competition, built with Flutter.

## 🎯 Game Overview

The Market Intelligence War Room is an intense 60-minute competitive intelligence game where two teams (Alpha and Delta) battle across five concurrent intelligence missions. Players research real companies using professional tools and submit intelligence data for scoring.

## 🚀 Features

### Core Gameplay
- **Two Teams**: Alpha vs Delta with 4-6 players each
- **Five Concurrent Battles**: Leadership Recon, Product Arsenal, Funding Fortification, Customer Frontlines, Alliance Forge
- **Real-Time Competition**: 60-minute global timer with live scoring
- **Professional Research Tools**: Integration with LinkedIn, Crunchbase, Statista, and more
- **Comprehensive Scoring**: Accuracy (60%), Speed (10%), Source Quality (15%), Teamwork (15%)

### Mobile-First Design
- **Responsive UI**: Optimized for mobile devices with touch-friendly controls
- **Dark Cyber Theme**: Immersive visual design with animated backgrounds
- **Real-Time Updates**: Live battle progress and team coordination
- **Offline Capability**: Core functionality works without internet connection

### Team Roles
- **Leaders**: Strategic oversight, team coordination, redeployment management
- **Operatives**: Field research, data collection, battle execution

## 🏗️ Technical Architecture

### Flutter Stack
- **Framework**: Flutter 3.0+
- **State Management**: Provider pattern
- **Navigation**: GoRouter
- **Animations**: Flutter Animate
- **UI Components**: Custom widgets with Material Design
- **Theming**: Dark cyber aesthetic with custom color palette

### Project Structure
```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── player.dart
│   ├── match.dart
│   ├── battle_submission.dart
│   └── company_reference.dart
├── providers/                # State management
│   ├── game_provider.dart
│   ├── player_provider.dart
│   └── match_provider.dart
├── services/                 # Business logic
│   ├── game_service.dart
│   └── scoring_engine.dart
├── screens/                  # App screens
│   ├── home_screen.dart
│   ├── setup_screen.dart
│   ├── lobby_screen.dart
│   ├── battle_screen.dart
│   ├── leader_dashboard_screen.dart
│   ├── matches_screen.dart
│   └── match_summary_screen.dart
├── widgets/                  # Reusable UI components
│   ├── cyber_background.dart
│   ├── gradient_button.dart
│   ├── feature_card.dart
│   ├── step_indicator.dart
│   ├── avatar_selector.dart
│   ├── team_card.dart
│   ├── battle_preview.dart
│   ├── battle_timer.dart
│   ├── battle_form.dart
│   ├── tools_panel.dart
│   ├── team_info_panel.dart
│   └── redeployment_panel.dart
└── theme/
    └── app_theme.dart        # App theming
```

## 🎮 Game Flow

### 1. Setup Phase
- **Player Registration**: Name, team selection (Alpha/Delta), role (Leader/Operative)
- **Avatar Selection**: Choose from cyber-themed avatars
- **Match Creation**: Create new match or join existing one
- **Company Selection**: Choose target company for intelligence gathering

### 2. Lobby Phase
- **Team Formation**: Leaders assign operatives to sub-teams
- **Battle Assignment**: Distribute five battles across team members
- **Ready Check**: All players must confirm readiness
- **Match Start**: Begin 60-minute intelligence mission

### 3. Battle Phase
- **Research**: Use integrated tools to gather intelligence
- **Data Entry**: Fill out battle-specific forms with findings
- **Collaboration**: Share information with teammates
- **Submission**: Submit completed intelligence for scoring

### 4. Scoring & Results
- **Automatic Scoring**: Real-time calculation based on multiple factors
- **Live Updates**: See scores as battles are completed
- **Match Summary**: Detailed breakdown of performance
- **Leaderboard**: Track team and individual performance

## 🏆 Scoring System

### Accuracy Score (60% weight)
- **Fuzzy Matching**: Uses Levenshtein distance for intelligent comparison
- **Field Validation**: Ensures data completeness and format
- **Reference Comparison**: Matches against verified company data

### Speed Score (10% weight)
- **Submission Time**: Earlier submissions earn higher scores
- **Linear Decay**: Score decreases over match duration
- **Real-Time Calculation**: Updated as players submit

### Source Quality Score (15% weight)
- **Trusted Domains**: Validates against professional sources
- **URL Validation**: Ensures legitimate research sources
- **Quality Weighting**: Premium sources earn higher scores

### Teamwork Score (15% weight)
- **Contribution**: Individual participation in team efforts
- **Collaboration**: Sharing information and helping teammates
- **Efficiency**: Team productivity and coordination

## 🛠️ Development Setup

### Prerequisites
- Flutter SDK 3.0 or higher
- Dart SDK 3.0 or higher
- Android Studio or VS Code with Flutter extensions
- Android device or emulator for testing

### Installation
1. Clone the repository
2. Navigate to the Flutter app directory:
   ```bash
   cd flutter_app
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

### Dependencies
- `provider`: State management
- `go_router`: Navigation
- `flutter_animate`: Animations
- `url_launcher`: External link handling
- `intl`: Internationalization
- `uuid`: Unique identifier generation

## 📱 Mobile Features

### Responsive Design
- **Adaptive Layout**: Works on phones and tablets
- **Touch Optimization**: Large buttons and touch targets
- **Gesture Support**: Swipe, tap, and pinch gestures
- **Orientation Support**: Portrait and landscape modes

### Performance
- **Efficient Rendering**: Optimized widget tree and animations
- **Memory Management**: Proper disposal of resources
- **Smooth Animations**: 60fps animations with Flutter Animate
- **Fast Navigation**: Instant screen transitions

### Offline Capability
- **Local Storage**: Core data stored locally
- **Sync on Connect**: Updates when internet available
- **Graceful Degradation**: Works without internet connection
- **Data Persistence**: Maintains state across app restarts

## 🎨 UI/UX Design

### Visual Theme
- **Dark Cyber Aesthetic**: Black backgrounds with neon accents
- **Color Palette**: Cyan, orange, green, and red highlights
- **Typography**: Monospace fonts for technical feel
- **Icons**: Lucide icons for consistency

### Animations
- **Page Transitions**: Smooth slide and fade effects
- **Loading States**: Animated progress indicators
- **Micro-interactions**: Button presses and form feedback
- **Background Effects**: Animated cyber grid

### Accessibility
- **High Contrast**: Clear text and button visibility
- **Large Text**: Readable font sizes
- **Touch Targets**: Minimum 44px touch areas
- **Screen Reader**: Proper semantic labels

## 🔧 Configuration

### Environment Setup
- **API Endpoints**: Configure backend services
- **Feature Flags**: Enable/disable specific features
- **Debug Mode**: Development vs production settings
- **Logging**: Configure logging levels and outputs

### Customization
- **Theme Colors**: Modify color palette in `app_theme.dart`
- **Battle Templates**: Update battle configurations
- **Scoring Weights**: Adjust scoring algorithm parameters
- **UI Components**: Customize widget appearances

## 🚀 Deployment

### Android
1. Build release APK:
   ```bash
   flutter build apk --release
   ```
2. Sign and distribute through Google Play Store

### iOS
1. Build iOS app:
   ```bash
   flutter build ios --release
   ```
2. Archive and upload to App Store Connect

### Web (Optional)
1. Build web version:
   ```bash
   flutter build web
   ```
2. Deploy to web hosting service

## 📊 Analytics & Monitoring

### Performance Metrics
- **App Performance**: Frame rates and memory usage
- **User Engagement**: Screen time and interaction patterns
- **Error Tracking**: Crash reports and error logs
- **Usage Statistics**: Feature adoption and user flows

### Game Analytics
- **Match Statistics**: Completion rates and scores
- **Player Behavior**: Research patterns and collaboration
- **Team Performance**: Win rates and efficiency metrics
- **Content Analysis**: Most researched companies and topics

## 🔒 Security & Privacy

### Data Protection
- **Local Storage**: Sensitive data stored securely
- **Encryption**: Data encrypted at rest and in transit
- **Privacy Controls**: User consent for data collection
- **GDPR Compliance**: European data protection standards

### Authentication
- **Player Identity**: Secure player identification
- **Match Access**: Controlled access to game sessions
- **Data Validation**: Input sanitization and validation
- **Rate Limiting**: Prevent abuse and spam

## 🤝 Contributing

### Development Guidelines
- **Code Style**: Follow Dart/Flutter conventions
- **Testing**: Write unit and widget tests
- **Documentation**: Document public APIs and complex logic
- **Version Control**: Use meaningful commit messages

### Pull Request Process
1. Fork the repository
2. Create feature branch
3. Make changes with tests
4. Submit pull request
5. Code review and merge

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- **Flutter Team**: For the amazing framework
- **Community**: For open-source packages and inspiration
- **Design**: Cyber aesthetic inspired by modern tech interfaces
- **Game Design**: Competitive intelligence concepts from industry

## 📞 Support

For support, questions, or feedback:
- **Issues**: Create GitHub issues for bugs and features
- **Discussions**: Use GitHub discussions for questions
- **Email**: Contact the development team
- **Documentation**: Check the wiki for detailed guides

---

**Ready to enter the Market Intelligence War Room?** 🚀

Download the app, join a team, and prove your intelligence gathering skills in the ultimate competitive research challenge!
