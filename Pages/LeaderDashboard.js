import React, { useState, useEffect, useCallback } from "react";
import { useNavigate } from "react-router-dom";
import { createPageUrl } from "@/utils";
import { Player, Match } from "@/entities/all";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Progress } from "@/components/ui/progress";
import { 
  Users, 
  CheckCircle,
  Clock,
  UserCheck,
  Zap,
  Loader2,
  Send,
  Shield,
  Target
} from "lucide-react";
import { motion } from "framer-motion";

const BATTLES = [
  { id: "leadership_recon", name: "Leadership Recon", subTeams: ["A1", "D1"] },
  { id: "product_arsenal", name: "Product Arsenal", subTeams: ["A2", "D2"] },
  { id: "funding_fortification", name: "Funding Fortification", subTeams: ["A3", "D3"] },
  { id: "customer_frontlines", name: "Customer Frontlines", subTeams: ["A4", "D4"] },
  { id: "alliance_forge", name: "Alliance Forge", subTeams: ["A5", "D5"] },
];

export default function LeaderDashboard() {
  const navigate = useNavigate();
  const matchId = new URLSearchParams(window.location.search).get("match");

  const [match, setMatch] = useState(null);
  const [players, setPlayers] = useState([]);
  const [currentPlayer, setCurrentPlayer] = useState(null);
  const [battleStatus, setBattleStatus] = useState({});
  const [redeployPlayer, setRedeployPlayer] = useState(null);
  const [isLoading, setIsLoading] = useState(true);

  const loadDashboardData = useCallback(async () => {
    if (!matchId) return;
    try {
      const matches = await Match.filter({ match_id: matchId });
      setMatch(matches[0]);

      const allPlayers = await Player.filter({ match_id: matchId });
      setPlayers(allPlayers);
      
      const user = allPlayers[allPlayers.length - 1]; // Simplified
      setCurrentPlayer(user);

      // Aggregate battle status
      const status = {};
      // This needs BattleSubmission data, for now we fake it
      BATTLES.forEach(b => status[b.id] = { alpha: 'active', delta: 'active' });
      setBattleStatus(status);

    } catch (err) {
      console.error(err);
    } finally {
      setIsLoading(false);
    }
  }, [matchId]);

  useEffect(() => {
    loadDashboardData();
    const interval = setInterval(loadDashboardData, 5000);
    return () => clearInterval(interval);
  }, [loadDashboardData]);
  
  const getCompletedPlayers = (team) => {
    return players.filter(p => p.team === team && p.status === 'completed' && p.role === 'Player');
  };

  const handleRedeploy = async (player, targetBattleId) => {
    const targetSubTeam = BATTLES.find(b => b.id === targetBattleId).subTeams.find(st => st.startsWith(player.team[0]));
    await Player.update(player.id, {
      sub_team: targetSubTeam,
      status: 'redeployed'
    });
    setRedeployPlayer(null);
    loadDashboardData();
  };

  if (isLoading) {
    return <div className="flex items-center justify-center min-h-screen bg-gray-900 text-white"><Loader2 className="w-8 h-8 animate-spin"/></div>;
  }
  
  return (
    <div className="min-h-screen bg-gray-900 text-white p-4">
      <div className="max-w-7xl mx-auto">
        <h1 className="text-3xl font-bold text-center mb-6">Leader Dashboard</h1>
        
        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
          {/* Battle Status */}
          <div className="lg:col-span-2 space-y-4">
            <h2 className="text-xl font-semibold text-cyan-400">Battle Overview</h2>
            {BATTLES.map(battle => (
              <Card key={battle.id} className="bg-gray-800/50 border-gray-700/50">
                <CardHeader>
                  <CardTitle>{battle.name}</CardTitle>
                </CardHeader>
                <CardContent className="flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <Shield className="text-cyan-400" />
                    <span className="text-sm">Team Alpha ({battle.subTeams[0]})</span>
                  </div>
                  {battleStatus[battle.id]?.alpha === 'completed' ? <CheckCircle className="text-green-400"/> : <Clock className="text-yellow-400"/>}
                </CardContent>
                <CardContent className="flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <Target className="text-orange-400" />
                    <span className="text-sm">Team Delta ({battle.subTeams[1]})</span>
                  </div>
                  {battleStatus[battle.id]?.delta === 'completed' ? <CheckCircle className="text-green-400"/> : <Clock className="text-yellow-400"/>}
                </CardContent>
              </Card>
            ))}
          </div>

          {/* Redeployment Panel */}
          <div>
            <h2 className="text-xl font-semibold text-green-400 mb-4">Redeployment Zone</h2>
            <Card className="bg-gray-800/50 border-gray-700/50">
              <CardHeader>
                <CardTitle className="flex items-center gap-2"><UserCheck /> Available Operatives</CardTitle>
              </CardHeader>
              <CardContent>
                {getCompletedPlayers(currentPlayer?.team).map(player => (
                  <div key={player.id} className="flex justify-between items-center p-2 bg-gray-700/50 rounded mb-2">
                    <span>{player.name}</span>
                    <Button size="sm" onClick={() => setRedeployPlayer(player)}>
                      <Zap className="w-4 h-4 mr-2"/> Redeploy
                    </Button>
                  </div>
                ))}
                {getCompletedPlayers(currentPlayer?.team).length === 0 && <p className="text-sm text-gray-400">No operatives available.</p>}
              </CardContent>
            </Card>
            {redeployPlayer && (
              <Card className="mt-4 bg-gray-800/50 border-cyan-500/50">
                <CardHeader>
                  <CardTitle>Redeploy: {redeployPlayer.name}</CardTitle>
                </CardHeader>
                <CardContent className="space-y-2">
                  <p>Select a battle to assist:</p>
                  {BATTLES.map(battle => (
                    <Button key={battle.id} variant="outline" className="w-full" onClick={() => handleRedeploy(redeployPlayer, battle.id)}>
                      Assist in {battle.name}
                    </Button>
                  ))}
                </CardContent>
              </Card>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}