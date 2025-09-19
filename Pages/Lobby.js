
import React, { useState, useEffect, useCallback } from "react";
import { useNavigate } from "react-router-dom";
import { createPageUrl } from "@/utils";
import { Player, Match } from "@/entities/all";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { 
  Users, 
  Crown, 
  Clock,
  CheckCircle,
  AlertTriangle,
  Play,
  Copy,
  RefreshCw
} from "lucide-react";
import { motion, AnimatePresence } from "framer-motion";
import { Alert, AlertDescription } from "@/components/ui/alert";

const SUB_TEAMS = {
  Alpha: ["A1", "A2", "A3", "A4", "A5"],
  Delta: ["D1", "D2", "D3", "D4", "D5"]
};

const BATTLE_NAMES = [
  "Leadership Recon",
  "Product Arsenal", 
  "Market Dominance",
  "Financial Intel",
  "Digital Footprint"
];

export default function Lobby() {
  const navigate = useNavigate();
  const [currentMatch, setCurrentMatch] = useState(null);
  const [players, setPlayers] = useState([]);
  const [currentPlayer, setCurrentPlayer] = useState(null);
  const [error, setError] = useState("");
  const [isLoading, setIsLoading] = useState(true);
  const [copied, setCopied] = useState(false);

  const matchId = new URLSearchParams(window.location.search).get("match");

  const loadMatchData = useCallback(async () => {
    try {
      const matches = await Match.filter({ match_id: matchId });
      if (matches.length === 0) {
        setError("Match not found");
        return;
      }
      
      setCurrentMatch(matches[0]);
      
      const matchPlayers = await Player.filter({ match_id: matchId });
      setPlayers(matchPlayers);
      
      // Find current user's player record
      // NOTE: This logic assumes the 'current user' is the last player in the list.
      // In a real application, this would typically involve authenticating a user
      // and finding their specific player record for the match.
      const user = await Player.filter({ match_id: matchId }); 
      setCurrentPlayer(user[user.length - 1]); // Get the most recent player record
      
      setIsLoading(false);
    } catch (err) {
      console.error("Failed to load match data:", err);
      setError("Failed to load match data. Please try again.");
      setIsLoading(false);
    }
  }, [matchId]); // matchId is a dependency because it's used inside loadMatchData

  useEffect(() => {
    if (!matchId) {
      navigate(createPageUrl("Setup"));
      return;
    }
    loadMatchData();
    const interval = setInterval(loadMatchData, 2000); // Refresh every 2 seconds
    return () => clearInterval(interval);
  }, [matchId, navigate, loadMatchData]); // Added navigate and loadMatchData to dependencies

  const copyMatchId = () => {
    navigator.clipboard.writeText(matchId);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const toggleReady = async () => {
    if (!currentPlayer || currentPlayer.role !== "Leader") return;
    
    try {
      const field = currentPlayer.team === "Alpha" ? "alpha_leader_ready" : "delta_leader_ready";
      const newValue = !currentMatch[field];
      
      await Match.update(currentMatch.id, {
        [field]: newValue
      });
      
      loadMatchData();
    } catch (err) {
      console.error("Failed to update ready status:", err);
      setError("Failed to update ready status");
    }
  };

  const assignSubTeam = async (player, subTeam) => {
    if (!currentPlayer || currentPlayer.role !== "Leader" || currentPlayer.team !== player.team) return;
    
    try {
      await Player.update(player.id, {
        sub_team: subTeam,
        status: "assigned"
      });
      
      loadMatchData();
    } catch (err) {
      console.error("Failed to assign sub-team:", err);
      setError("Failed to assign sub-team");
    }
  };

  const getAvailableSubTeams = (team) => {
    const usedSubTeams = players
      .filter(p => p.team === team && p.sub_team)
      .map(p => p.sub_team);
    
    return SUB_TEAMS[team].filter(subTeam => !usedSubTeams.includes(subTeam));
  };

  const startMatch = async () => {
    if (!currentMatch.alpha_leader_ready || !currentMatch.delta_leader_ready) {
      setError("Both team leaders must be ready");
      return;
    }
    
    try {
      await Match.update(currentMatch.id, {
        status: "active",
        start_time: new Date().toISOString()
      });
      
      navigate(createPageUrl(`Battle?match=${matchId}`));
    } catch (err) {
      console.error("Failed to start match:", err);
      setError("Failed to start match");
    }
  };

  const getTeamPlayers = (team) => {
    return players.filter(p => p.team === team);
  };

  const getTeamLeader = (team) => {
    return players.find(p => p.team === team && p.role === "Leader");
  };

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-gray-900 via-black to-gray-800 flex items-center justify-center">
        <div className="text-center">
          <RefreshCw className="w-8 h-8 text-cyan-400 animate-spin mx-auto mb-4" />
          <p className="text-white">Loading mission briefing...</p>
        </div>
      </div>
    );
  }

  if (!currentMatch) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-gray-900 via-black to-gray-800 flex items-center justify-center">
        <Card className="bg-gray-800/50 border-red-500/30">
          <CardContent className="text-center p-6">
            <AlertTriangle className="w-8 h-8 text-red-500 mx-auto mb-4" />
            <p className="text-white">Mission not found</p>
          </CardContent>
        </Card>
      </div>
    );
  }

  const alphaPlayers = getTeamPlayers("Alpha");
  const deltaPlayers = getTeamPlayers("Delta");
  const alphaLeader = getTeamLeader("Alpha");
  const deltaLeader = getTeamLeader("Delta");
  const isCurrentPlayerLeader = currentPlayer?.role === "Leader";
  const allPlayersAssigned = players.filter(p => p.role === "Player").every(p => p.sub_team);
  const canStart = currentMatch.alpha_leader_ready && currentMatch.delta_leader_ready && isCurrentPlayerLeader && allPlayersAssigned;

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 via-black to-gray-800 p-4">
      <div className="max-w-6xl mx-auto pt-8">
        {/* Header */}
        <motion.div 
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="text-center mb-8"
        >
          <h1 className="text-3xl md:text-4xl font-bold text-white mb-4">
            Mission Briefing Room
          </h1>
          
          <div className="flex items-center justify-center gap-4 mb-4">
            <div className="bg-gray-800/50 px-4 py-2 rounded-lg border border-gray-700/50">
              <span className="text-gray-400 text-sm">Match ID: </span>
              <span className="text-cyan-400 font-mono">{matchId}</span>
              <Button
                onClick={copyMatchId}
                size="sm"
                variant="ghost"
                className="ml-2 text-gray-400 hover:text-white"
              >
                <Copy className="w-4 h-4" />
              </Button>
            </div>
            {copied && <span className="text-green-400 text-sm">Copied!</span>}
          </div>

          {currentMatch.company && (
            <div className="bg-cyan-500/10 border border-cyan-500/20 rounded-lg p-4 max-w-md mx-auto">
              <p className="text-cyan-400 font-bold">Target Company</p>
              <p className="text-white text-lg">{currentMatch.company}</p>
            </div>
          )}
        </motion.div>

        {error && (
          <Alert variant="destructive" className="mb-6 max-w-2xl mx-auto">
            <AlertTriangle className="h-4 w-4" />
            <AlertDescription>{error}</AlertDescription>
          </Alert>
        )}

        {/* Teams Layout */}
        <div className="grid lg:grid-cols-2 gap-8 mb-8">
          {/* Team Alpha */}
          <motion.div
            initial={{ opacity: 0, x: -20 }}
            animate={{ opacity: 1, x: 0 }}
          >
            <Card className="bg-gradient-to-br from-cyan-900/20 to-blue-900/20 border-cyan-500/30">
              <CardHeader className="text-center">
                <CardTitle className="text-cyan-400 text-2xl flex items-center justify-center gap-2">
                  <Users className="w-6 h-6" />
                  Team Alpha
                  {currentMatch.alpha_leader_ready && (
                    <CheckCircle className="w-5 h-5 text-green-400" />
                  )}
                </CardTitle>
              </CardHeader>
              <CardContent>
                {alphaLeader && (
                  <div className="mb-4 p-3 bg-yellow-500/10 border border-yellow-500/30 rounded-lg">
                    <div className="flex items-center gap-2">
                      <Crown className="w-5 h-5 text-yellow-400" />
                      <span className="text-white font-bold">{alphaLeader.name}</span>
                      <Badge className="bg-yellow-500/20 text-yellow-400">Leader</Badge>
                    </div>
                  </div>
                )}
                
                <div className="space-y-2">
                  <h4 className="text-white font-semibold">Operatives ({alphaPlayers.length})</h4>
                  {alphaPlayers.filter(p => p.role === "Player").map((player) => (
                    <div key={player.id} className="flex items-center justify-between gap-2 p-2 bg-gray-800/30 rounded">
                      <div className="flex items-center gap-2">
                        <div className="w-8 h-8 bg-gradient-to-r from-cyan-400 to-blue-500 rounded-full" />
                        <span className="text-white">{player.name}</span>
                      </div>
                      <div className="flex items-center gap-2">
                        {player.sub_team ? (
                          <Badge variant="outline" className="border-cyan-500/30 text-cyan-400">
                            {player.sub_team}
                          </Badge>
                        ) : (
                          isCurrentPlayerLeader && currentPlayer.team === "Alpha" && (
                            <select
                              onChange={(e) => assignSubTeam(player, e.target.value)}
                              className="text-xs bg-gray-700 text-white rounded px-2 py-1"
                            >
                              <option value="">Assign...</option>
                              {getAvailableSubTeams("Alpha").map(subTeam => (
                                <option key={subTeam} value={subTeam}>{subTeam}</option>
                              ))}
                            </select>
                          )
                        )}
                      </div>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          </motion.div>

          {/* Team Delta */}
          <motion.div
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
          >
            <Card className="bg-gradient-to-br from-orange-900/20 to-red-900/20 border-orange-500/30">
              <CardHeader className="text-center">
                <CardTitle className="text-orange-400 text-2xl flex items-center justify-center gap-2">
                  <Users className="w-6 h-6" />
                  Team Delta
                  {currentMatch.delta_leader_ready && (
                    <CheckCircle className="w-5 h-5 text-green-400" />
                  )}
                </CardTitle>
              </CardHeader>
              <CardContent>
                {deltaLeader && (
                  <div className="mb-4 p-3 bg-yellow-500/10 border border-yellow-500/30 rounded-lg">
                    <div className="flex items-center gap-2">
                      <Crown className="w-5 h-5 text-yellow-400" />
                      <span className="text-white font-bold">{deltaLeader.name}</span>
                      <Badge className="bg-yellow-500/20 text-yellow-400">Leader</Badge>
                    </div>
                  </div>
                )}
                
                <div className="space-y-2">
                  <h4 className="text-white font-semibold">Operatives ({deltaPlayers.length})</h4>
                  {deltaPlayers.filter(p => p.role === "Player").map((player) => (
                    <div key={player.id} className="flex items-center justify-between gap-2 p-2 bg-gray-800/30 rounded">
                      <div className="flex items-center gap-2">
                        <div className="w-8 h-8 bg-gradient-to-r from-orange-400 to-red-500 rounded-full" />
                        <span className="text-white">{player.name}</span>
                      </div>
                      <div className="flex items-center gap-2">
                        {player.sub_team ? (
                          <Badge variant="outline" className="border-orange-500/30 text-orange-400">
                            {player.sub_team}
                          </Badge>
                        ) : (
                          isCurrentPlayerLeader && currentPlayer.team === "Delta" && (
                            <select
                              onChange={(e) => assignSubTeam(player, e.target.value)}
                              className="text-xs bg-gray-700 text-white rounded px-2 py-1"
                            >
                              <option value="">Assign...</option>
                              {getAvailableSubTeams("Delta").map(subTeam => (
                                <option key={subTeam} value={subTeam}>{subTeam}</option>
                              ))}
                            </select>
                          )
                        )}
                      </div>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          </motion.div>
        </div>

        {/* Battle Layout Preview */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3 }}
          className="mb-8"
        >
          <h2 className="text-2xl font-bold text-white text-center mb-6">Battle Configuration</h2>
          <div className="grid md:grid-cols-5 gap-4">
            {BATTLE_NAMES.map((battle, index) => (
              <Card key={index} className="bg-gray-800/30 border-gray-700/50">
                <CardContent className="p-4 text-center">
                  <h4 className="text-white font-semibold text-sm mb-2">{battle}</h4>
                  <div className="text-xs text-gray-400">
                    {SUB_TEAMS.Alpha[index]} vs {SUB_TEAMS.Delta[index]}
                  </div>
                  <div className="text-xs text-gray-500 mt-1">3v3</div>
                </CardContent>
              </Card>
            ))}
          </div>
        </motion.div>

        {/* Control Panel */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.5 }}
          className="text-center"
        >
          <Card className="bg-gray-800/50 border-gray-700/50 max-w-md mx-auto">
            <CardContent className="p-6">
              {isCurrentPlayerLeader ? (
                <div className="space-y-4">
                  <Button
                    onClick={toggleReady}
                    variant={currentMatch[`${currentPlayer.team.toLowerCase()}_leader_ready`] ? "default" : "outline"}
                    className={
                      currentMatch[`${currentPlayer.team.toLowerCase()}_leader_ready`]
                        ? "bg-green-600 hover:bg-green-700 text-white"
                        : "border-green-500/30 text-green-400 hover:bg-green-500/10"
                    }
                  >
                    <CheckCircle className="w-4 h-4 mr-2" />
                    {currentMatch[`${currentPlayer.team.toLowerCase()}_leader_ready`] ? "Ready!" : "Mark Ready"}
                  </Button>
                  
                  {canStart && (
                    <Button
                      onClick={startMatch}
                      className="w-full bg-gradient-to-r from-green-500 to-emerald-600 hover:from-green-600 hover:to-emerald-700 text-white font-bold py-6 text-lg"
                    >
                      <Play className="w-6 h-6 mr-2" />
                      LAUNCH MISSION
                    </Button>
                  )}
                  
                  {!canStart && currentMatch.alpha_leader_ready && currentMatch.delta_leader_ready && (
                    <p className="text-gray-400 text-sm">
                      {allPlayersAssigned ? "Waiting for team leaders to start the mission..." : "All players must be assigned to sub-teams before starting"}
                    </p>
                  )}
                </div>
              ) : (
                <div className="text-center">
                  <Clock className="w-8 h-8 text-yellow-400 mx-auto mb-3" />
                  <h3 className="text-white font-semibold mb-2">Standby for Orders</h3>
                  <p className="text-gray-400 text-sm">
                    Waiting for team leaders to configure and start the mission
                  </p>
                </div>
              )}
            </CardContent>
          </Card>
        </motion.div>
      </div>
    </div>
  );
}
