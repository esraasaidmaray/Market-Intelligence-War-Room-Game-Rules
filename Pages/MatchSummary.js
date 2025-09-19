import React, { useState, useEffect, useCallback } from "react";
import { useNavigate } from "react-router-dom";
import { createPageUrl } from "@/utils";
import { Player, Match, BattleSubmission } from "@/entities/all";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Progress } from "@/components/ui/progress";
import { 
  Trophy, 
  Users, 
  Clock, 
  Target, 
  ArrowLeft,
  BarChart3,
  Medal,
  Zap,
  CheckCircle
} from "lucide-react";
import { motion } from "framer-motion";

export default function MatchSummary() {
  const navigate = useNavigate();
  const matchId = new URLSearchParams(window.location.search).get("match");

  const [match, setMatch] = useState(null);
  const [players, setPlayers] = useState([]);
  const [submissions, setSubmissions] = useState([]);
  const [isLoading, setIsLoading] = useState(true);

  const loadMatchData = useCallback(async () => {
    if (!matchId) return;
    
    try {
      const matches = await Match.filter({ match_id: matchId });
      if (matches.length === 0) {
        navigate(createPageUrl("Matches"));
        return;
      }
      
      setMatch(matches[0]);
      
      const matchPlayers = await Player.filter({ match_id: matchId });
      setPlayers(matchPlayers);
      
      const matchSubmissions = await BattleSubmission.filter({ match_id: matchId });
      setSubmissions(matchSubmissions);
      
    } catch (err) {
      console.error("Failed to load match data:", err);
    } finally {
      setIsLoading(false);
    }
  }, [matchId, navigate]);

  useEffect(() => {
    loadMatchData();
  }, [loadMatchData]);

  const getBattleName = (battleId) => {
    const battleNames = {
      'leadership_recon': 'Leadership Recon',
      'product_arsenal': 'Product Arsenal',
      'funding_fortification': 'Funding Fortification',
      'customer_frontlines': 'Customer Frontlines',
      'alliance_forge': 'Alliance Forge'
    };
    return battleNames[battleId] || battleId;
  };

  const getTeamScore = (team) => {
    const teamSubmissions = submissions.filter(s => s.team === team);
    return teamSubmissions.reduce((total, sub) => total + (sub.scores?.total || 0), 0);
  };

  const getBattleResults = (battleId) => {
    const battleSubmissions = submissions.filter(s => s.battle_id === battleId);
    const alphaSubmission = battleSubmissions.find(s => s.team === "Alpha");
    const deltaSubmission = battleSubmissions.find(s => s.team === "Delta");
    
    return {
      alpha: alphaSubmission?.scores?.total || 0,
      delta: deltaSubmission?.scores?.total || 0,
      winner: alphaSubmission && deltaSubmission 
        ? (alphaSubmission.scores.total > deltaSubmission.scores.total ? "Alpha" : "Delta")
        : null
    };
  };

  const formatDuration = (startTime, duration) => {
    const start = new Date(startTime);
    const end = new Date(start.getTime() + duration * 60000);
    const diff = end - start;
    const minutes = Math.floor(diff / 60000);
    return `${minutes} minutes`;
  };

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-gray-900 via-black to-gray-800 flex items-center justify-center">
        <div className="text-center">
          <Trophy className="w-8 h-8 text-cyan-400 animate-pulse mx-auto mb-4" />
          <p className="text-white">Loading match results...</p>
        </div>
      </div>
    );
  }

  if (!match) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-gray-900 via-black to-gray-800 flex items-center justify-center">
        <Card className="bg-gray-800/50 border-red-500/30">
          <CardContent className="text-center p-6">
            <p className="text-white">Match not found</p>
          </CardContent>
        </Card>
      </div>
    );
  }

  const alphaScore = getTeamScore("Alpha");
  const deltaScore = getTeamScore("Delta");
  const winner = alphaScore > deltaScore ? "Alpha" : "Delta";

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 via-black to-gray-800 p-4">
      <div className="max-w-6xl mx-auto pt-8">
        {/* Header */}
        <motion.div 
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="text-center mb-8"
        >
          <div className="flex items-center justify-between mb-6">
            <Button
              onClick={() => navigate(createPageUrl("Matches"))}
              variant="outline"
              className="border-gray-600 text-gray-300 hover:bg-gray-700"
            >
              <ArrowLeft className="w-4 h-4 mr-2" />
              Back to Matches
            </Button>
            
            <div className="text-center">
              <h1 className="text-3xl md:text-4xl font-bold text-white mb-2">
                Mission Complete
              </h1>
              <p className="text-gray-300">Match ID: {matchId}</p>
            </div>
            
            <div className="w-32" /> {/* Spacer */}
          </div>

          {match.company && (
            <div className="bg-cyan-500/10 border border-cyan-500/20 rounded-lg p-4 max-w-md mx-auto mb-6">
              <p className="text-cyan-400 font-bold">Target Company</p>
              <p className="text-white text-lg">{match.company}</p>
            </div>
          )}
        </motion.div>

        {/* Winner Announcement */}
        <motion.div
          initial={{ opacity: 0, scale: 0.9 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ delay: 0.2 }}
          className="text-center mb-8"
        >
          <Card className={`bg-gradient-to-r ${
            winner === "Alpha" 
              ? "from-cyan-900/50 to-blue-900/50 border-cyan-500/50" 
              : "from-orange-900/50 to-red-900/50 border-orange-500/50"
          }`}>
            <CardContent className="p-8">
              <div className="flex items-center justify-center mb-4">
                <Trophy className={`w-12 h-12 ${
                  winner === "Alpha" ? "text-cyan-400" : "text-orange-400"
                }`} />
              </div>
              <h2 className="text-3xl font-bold text-white mb-2">
                Team {winner} Wins!
              </h2>
              <div className="flex items-center justify-center gap-8 text-2xl font-bold">
                <div className="text-center">
                  <p className="text-cyan-400">Alpha</p>
                  <p className="text-white">{alphaScore}</p>
                </div>
                <div className="text-4xl text-gray-400">vs</div>
                <div className="text-center">
                  <p className="text-orange-400">Delta</p>
                  <p className="text-white">{deltaScore}</p>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* Battle Results */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.4 }}
          className="mb-8"
        >
          <h2 className="text-2xl font-bold text-white mb-6 text-center">
            Battle Breakdown
          </h2>
          
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
            {['leadership_recon', 'product_arsenal', 'funding_fortification', 'customer_frontlines', 'alliance_forge'].map((battleId) => {
              const results = getBattleResults(battleId);
              return (
                <Card key={battleId} className="bg-gray-800/50 border-gray-700/50">
                  <CardHeader>
                    <CardTitle className="text-center text-lg">
                      {getBattleName(battleId)}
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="flex justify-between items-center">
                      <div className="flex items-center gap-2">
                        <div className="w-3 h-3 bg-cyan-400 rounded-full" />
                        <span className="text-cyan-400">Alpha</span>
                      </div>
                      <span className="text-white font-bold">{results.alpha}</span>
                    </div>
                    
                    <div className="flex justify-between items-center">
                      <div className="flex items-center gap-2">
                        <div className="w-3 h-3 bg-orange-400 rounded-full" />
                        <span className="text-orange-400">Delta</span>
                      </div>
                      <span className="text-white font-bold">{results.delta}</span>
                    </div>
                    
                    {results.winner && (
                      <div className="text-center pt-2 border-t border-gray-700">
                        <Badge className={
                          results.winner === "Alpha" 
                            ? "bg-cyan-500/20 text-cyan-400" 
                            : "bg-orange-500/20 text-orange-400"
                        }>
                          {results.winner} Wins
                        </Badge>
                      </div>
                    )}
                  </CardContent>
                </Card>
              );
            })}
          </div>
        </motion.div>

        {/* Team Performance */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.6 }}
          className="grid md:grid-cols-2 gap-8"
        >
          {/* Alpha Team */}
          <Card className="bg-gradient-to-br from-cyan-900/20 to-blue-900/20 border-cyan-500/30">
            <CardHeader>
              <CardTitle className="text-cyan-400 text-xl flex items-center gap-2">
                <Users className="w-5 h-5" />
                Team Alpha Performance
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="text-center">
                <p className="text-4xl font-bold text-white">{alphaScore}</p>
                <p className="text-gray-400">Total Score</p>
              </div>
              
              <div className="space-y-2">
                <h4 className="text-white font-semibold">Operatives</h4>
                {players.filter(p => p.team === "Alpha").map((player) => (
                  <div key={player.id} className="flex items-center justify-between p-2 bg-gray-800/30 rounded">
                    <div className="flex items-center gap-2">
                      <div className="w-6 h-6 bg-gradient-to-r from-cyan-400 to-blue-500 rounded-full" />
                      <span className="text-white text-sm">{player.name}</span>
                    </div>
                    <Badge variant="outline" className="border-cyan-500/30 text-cyan-400 text-xs">
                      {player.sub_team}
                    </Badge>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>

          {/* Delta Team */}
          <Card className="bg-gradient-to-br from-orange-900/20 to-red-900/20 border-orange-500/30">
            <CardHeader>
              <CardTitle className="text-orange-400 text-xl flex items-center gap-2">
                <Users className="w-5 h-5" />
                Team Delta Performance
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="text-center">
                <p className="text-4xl font-bold text-white">{deltaScore}</p>
                <p className="text-gray-400">Total Score</p>
              </div>
              
              <div className="space-y-2">
                <h4 className="text-white font-semibold">Operatives</h4>
                {players.filter(p => p.team === "Delta").map((player) => (
                  <div key={player.id} className="flex items-center justify-between p-2 bg-gray-800/30 rounded">
                    <div className="flex items-center gap-2">
                      <div className="w-6 h-6 bg-gradient-to-r from-orange-400 to-red-500 rounded-full" />
                      <span className="text-white text-sm">{player.name}</span>
                    </div>
                    <Badge variant="outline" className="border-orange-500/30 text-orange-400 text-xs">
                      {player.sub_team}
                    </Badge>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* Match Details */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.8 }}
          className="mt-8 text-center"
        >
          <Card className="bg-gray-800/50 border-gray-700/50 max-w-md mx-auto">
            <CardContent className="p-6">
              <div className="space-y-2 text-sm text-gray-300">
                <div className="flex justify-between">
                  <span>Duration:</span>
                  <span className="text-white">{formatDuration(match.start_time, match.duration_minutes)}</span>
                </div>
                <div className="flex justify-between">
                  <span>Status:</span>
                  <Badge className="bg-green-500/20 text-green-400">
                    <CheckCircle className="w-3 h-3 mr-1" />
                    Completed
                  </Badge>
                </div>
                <div className="flex justify-between">
                  <span>Total Submissions:</span>
                  <span className="text-white">{submissions.length}</span>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>
      </div>
    </div>
  );
}
