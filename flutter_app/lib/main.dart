import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';

import 'providers/game_provider.dart';
import 'providers/player_provider.dart';
import 'providers/match_provider.dart';
import 'screens/home_screen.dart';
import 'screens/setup_screen.dart';
import 'screens/lobby_screen.dart';
import 'screens/battle_screen.dart';
import 'screens/leader_dashboard_screen.dart';
import 'screens/matches_screen.dart';
import 'screens/match_summary_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MarketIntelligenceWarRoomApp());
}

class MarketIntelligenceWarRoomApp extends StatelessWidget {
  const MarketIntelligenceWarRoomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
        ChangeNotifierProvider(create: (_) => MatchProvider()),
      ],
      child: MaterialApp.router(
        title: 'Market Intelligence War Room',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: _router,
      ),
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/setup',
      builder: (context, state) => const SetupScreen(),
    ),
    GoRoute(
      path: '/lobby',
      builder: (context, state) {
        final matchId = state.uri.queryParameters['match'] ?? '';
        return LobbyScreen(matchId: matchId);
      },
    ),
    GoRoute(
      path: '/battle',
      builder: (context, state) {
        final matchId = state.uri.queryParameters['match'] ?? '';
        return BattleScreen(matchId: matchId);
      },
    ),
    GoRoute(
      path: '/leader-dashboard',
      builder: (context, state) {
        final matchId = state.uri.queryParameters['match'] ?? '';
        return LeaderDashboardScreen(matchId: matchId);
      },
    ),
    GoRoute(
      path: '/matches',
      builder: (context, state) => const MatchesScreen(),
    ),
    GoRoute(
      path: '/match-summary',
      builder: (context, state) {
        final matchId = state.uri.queryParameters['match'] ?? '';
        return MatchSummaryScreen(matchId: matchId);
      },
    ),
  ],
);
