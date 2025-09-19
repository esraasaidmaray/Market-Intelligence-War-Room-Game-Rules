# Market Intelligence War Room

A multiplayer, gamified, real-time mobile game built with React, TypeScript, and Tailwind CSS that simulates market intelligence competitions between two teams (Alpha and Delta) in five concurrent battles.

## 🎯 Game Overview

The Market Intelligence War Room is an educational game that teaches market intelligence research and decision-making under time pressure. Teams compete to gather accurate and timely intelligence using real research tools while filling out comprehensive Market Intelligence Capture Templates.

### Core Features

- **Two Teams**: Alpha and Delta, with sub-teams (A1-A5 for Alpha, D1-D5 for Delta)
- **Five Concurrent Battles**: Leadership Recon, Product Arsenal, Funding Fortification, Customer Frontlines, and Alliance Forge
- **60-Minute Global Timer**: Teams race against time to complete all battles
- **Real Research Tools**: Integration with LinkedIn, Crunchbase, Statista, and other intelligence platforms
- **Comprehensive Scoring**: Based on data accuracy (60%), speed (10%), source quality (15%), and teamwork (15%)
- **Mobile-First Design**: Optimized for mobile devices with responsive layouts
- **Real-Time Updates**: Live progress tracking and team coordination

## 🚀 Quick Start

### Prerequisites

- Node.js 18+ 
- npm or yarn

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd market-intelligence-war-room
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Start the development server**
   ```bash
   npm run dev
   ```

4. **Open your browser**
   Navigate to `http://localhost:3000`

## 🎮 How to Play

### 1. Setup Phase
- **Create or Join Match**: Players can create new matches or join existing ones using Match IDs
- **Team Assignment**: Players choose between Team Alpha or Team Delta
- **Role Selection**: Players select either Leader or Operative roles
- **Company Selection**: Team leaders select the target company for research
- **Sub-Team Assignment**: Leaders assign operatives to specific battles (A1-A5, D1-D5)

### 2. Battle Phase
- **Concurrent Battles**: All five battles run simultaneously for 60 minutes
- **Research & Data Entry**: Teams use suggested tools to gather intelligence and fill out templates
- **Real-Time Collaboration**: Teams can coordinate and share information
- **Submission**: Teams submit completed templates for scoring

### 3. Scoring & Results
- **Automatic Scoring**: System compares submissions against reference data
- **Multi-Factor Evaluation**: Accuracy, speed, source quality, and teamwork all contribute to final scores
- **Battle Results**: Individual battle winners and overall team victory
- **Match Summary**: Comprehensive results and performance analytics

## 🏗️ Technical Architecture

### Frontend Stack
- **React 18**: Modern React with hooks and functional components
- **TypeScript**: Type-safe development
- **Tailwind CSS**: Utility-first styling with custom cyber theme
- **Framer Motion**: Smooth animations and transitions
- **React Router**: Client-side routing
- **Lucide React**: Beautiful, customizable icons

### Key Components

#### Pages
- **Home**: Landing page with mission briefing
- **Setup**: Player registration and team assignment
- **Lobby**: Pre-game coordination and sub-team assignment
- **Battle**: Main gameplay interface with capture templates
- **Leader Dashboard**: Real-time battle monitoring and player redeployment
- **Matches**: Match history and management
- **Match Summary**: Post-game results and analytics

#### Core Systems
- **Battle Templates**: Comprehensive intelligence capture forms
- **Scoring Engine**: Multi-factor evaluation system with fuzzy matching
- **Entity Management**: Mock database for players, matches, and submissions
- **Real-Time Updates**: Polling-based live updates

## 🎨 Design System

### Theme
- **Cyber Aesthetic**: Dark theme with neon accents
- **Mobile-First**: Responsive design optimized for mobile screens
- **Accessibility**: High contrast, semantic HTML, screen reader support

### Color Palette
- **Primary**: Cyan/Blue gradients for Team Alpha
- **Secondary**: Orange/Red gradients for Team Delta
- **Accents**: Yellow for leaders, Green for success states
- **Background**: Dark grays and blacks with subtle patterns

## 🔧 Configuration

### Environment Variables
Create a `.env` file in the root directory:

```env
VITE_APP_NAME=Market Intelligence War Room
VITE_APP_VERSION=1.0.0
VITE_API_URL=http://localhost:3001
```

### Customization
- **Battle Templates**: Modify `Components/battles/BattleTemplates.js`
- **Scoring Weights**: Adjust in `Components/scoring/ScoringEngine.js`
- **Company Data**: Update `data/sample_company_reference.json`
- **UI Components**: Customize in `components/ui/`

## 📱 Mobile Optimization

The game is designed mobile-first with:
- Touch-optimized interfaces
- Responsive layouts for all screen sizes
- Gesture-friendly navigation
- Optimized performance for mobile devices
- PWA capabilities for app-like experience

## 🧪 Testing

### Running Tests
```bash
npm run test
```

### Linting
```bash
npm run lint
```

### Build for Production
```bash
npm run build
```

## 🚀 Deployment

### Vercel (Recommended)
1. Connect your GitHub repository to Vercel
2. Configure build settings:
   - Build Command: `npm run build`
   - Output Directory: `dist`
3. Deploy automatically on push to main branch

### Netlify
1. Connect repository to Netlify
2. Set build command: `npm run build`
3. Set publish directory: `dist`

### Manual Deployment
1. Build the project: `npm run build`
2. Upload the `dist` folder to your web server
3. Configure server to serve `index.html` for all routes

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Battle Template Design**: Based on comprehensive market intelligence research methodologies
- **Scoring Algorithm**: Inspired by real-world intelligence evaluation standards
- **UI/UX Design**: Cyber-themed aesthetic with military intelligence inspiration
- **Educational Value**: Designed to teach practical market research skills

## 📞 Support

For support, email support@intelligencewarroom.com or create an issue in the repository.

---

**Ready to deploy your intelligence operation? Start the mission and lead your team to victory!** 🎯
