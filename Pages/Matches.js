import React, { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { createPageUrl } from "@/utils";
import { Match, Player } from "@/entities/all";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { 
  Trophy, 
  Users, 
  Clock,
  Play,
  Eye,
  ArrowRight,
  TrendingUp,
  Target
} from "lucide-react";
import { motion } from "framer-motion";
import { format } from "date-fns";

export default function Matches() {
  const navigate = useNavigate();
  const [matches, setMatches] = useState([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    loadMatches();
  }, []);

  const loadMatches = async () => {
    try {
      const allMatches = await Match.list("-created_date");
      setMatches(allMatches);
    } catch (error) {
      console.error("Error loading matches:", error);
    }
    setIsLoading(false);
  };

  const getMatchStatus = (match) => {
    switch (match.status) {
      case "setup":
        return { label: "Setting Up", color: "bg-yellow-500/20 text-yellow-400 border-yellow-500/30" };
      case "waiting_for_leaders":
        return { label: "Waiting", color: "bg-blue-500/20 text-blue-400 border-blue-500/30" };
      case "active":
        return { label: "Active", color: "bg-green-500/20 text-green-400 border-green-500/30" };
      case "completed":
        return { label: "Completed", color: "bg-gray-500/20 text-gray-400 border-gray-500/30" };
      default:
        return { label: "Unknown", color: "bg-gray-500/20 text-gray-400 border-gray-500/30" };
    }
  };

  const getMatchWinner = (match) => {
    if (match.status !== "completed") return null;
    if (match.alpha_score > match.delta_score) return "Alpha";
    if (match.delta_score > match.alpha_score) return "Delta";
    return "Tie";
  };

  const getTimeAgo = (dateString) => {
    const date = new Date(dateString);
    const now = new Date();
    const diffInHours = Math.floor((now - date) / (1000 * 60 * 60));
    
    if (diffInHours < 1) return "Less than 1 hour ago";
    if (diffInHours < 24) return `${diffInHours} hour${diffInHours > 1 ? 's' : ''} ago`;
    
    const diffInDays = Math.floor(diffInHours / 24);
    return `${diffInDays} day${diffInDays > 1 ? 's' : ''} ago`;
  };

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
            Mission Archives
          </h1>
          <p className="text-gray-300 mb-6">
            Review past battles and ongoing operations
          </p>
          
          <Button
            onClick={() => navigate(createPageUrl("Setup"))}
            className="bg-gradient-to-r from-cyan-500 to-blue-600 hover:from-cyan-600 hover:to-blue-700 text-black font-bold"
          >
            <Play className="w-5 h-5 mr-2" />
            Start New Mission
          </Button>
        </motion.div>

        {/* Stats Overview */}
        <div className="grid md:grid-cols-4 gap-6 mb-8">
          <Card className="bg-gray-800/50 border-gray-700/50">
            <CardContent className="p-6 text-center">
              <Trophy className="w-8 h-8 text-yellow-400 mx-auto mb-2" />
              <p className="text-2xl font-bold text-white">
                {matches.filter(m => m.status === "completed").length}
              </p>
              <p className="text-sm text-gray-400">Completed Missions</p>
            </CardContent>
          </Card>
          
          <Card className="bg-gray-800/50 border-gray-700/50">
            <CardContent className="p-6 text-center">
              <Users className="w-8 h-8 text-cyan-400 mx-auto mb-2" />
              <p className="text-2xl font-bold text-white">{matches.length}</p>
              <p className="text-sm text-gray-400">Total Matches</p>
            </CardContent>
          </Card>
          
          <Card className="bg-gray-800/50 border-gray-700/50">
            <CardContent className="p-6 text-center">
              <Clock className="w-8 h-8 text-green-400 mx-auto mb-2" />
              <p className="text-2xl font-bold text-white">
                {matches.filter(m => m.status === "active").length}
              </p>
              <p className="text-sm text-gray-400">Active Missions</p>
            </CardContent>
          </Card>
          
          <Card className="bg-gray-800/50 border-gray-700/50">
            <CardContent className="p-6 text-center">
              <Target className="w-8 h-8 text-orange-400 mx-auto mb-2" />
              <p className="text-2xl font-bold text-white">
                {new Set(matches.map(m => m.company)).size}
              </p>
              <p className="text-sm text-gray-400">Companies Analyzed</p>
            </CardContent>
          </Card>
        </div>

        {/* Matches List */}
        <div className="space-y-4">
          {isLoading ? (
            <div className="text-center py-8">
              <Clock className="w-8 h-8 text-cyan-400 animate-pulse mx-auto mb-4" />
              <p className="text-white">Loading mission data...</p>
            </div>
          ) : matches.length === 0 ? (
            <Card className="bg-gray-800/50 border-gray-700/50">
              <CardContent className="text-center py-12">
                <Trophy className="w-12 h-12 text-gray-400 mx-auto mb-4" />
                <p className="text-white text-lg mb-2">No missions found</p>
                <p className="text-gray-400 mb-4">Start your first intelligence operation</p>
                <Button
                  onClick={() => navigate(createPageUrl("Setup"))}
                  className="bg-gradient-to-r from-cyan-500 to-blue-600 hover:from-cyan-600 hover:to-blue-700 text-black font-bold"
                >
                  Create Mission
                </Button>
              </CardContent>
            </Card>
          ) : (
            matches.map((match, index) => {
              const status = getMatchStatus(match);
              const winner = getMatchWinner(match);
              
              return (
                <motion.div
                  key={match.id}
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: index * 0.1 }}
                >
                  <Card className="bg-gray-800/50 border-gray-700/50 hover:bg-gray-800/70 transition-all duration-300">
                    <CardContent className="p-6">
                      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                        <div className="flex-1">
                          <div className="flex items-center gap-3 mb-2">
                            <h3 className="text-white font-bold text-lg">
                              {match.company || "Target Not Set"}
                            </h3>
                            <Badge className={status.color}>
                              {status.label}
                            </Badge>
                            {winner && (
                              <Badge className={
                                winner === "Alpha" 
                                  ? "bg-cyan-500/20 text-cyan-400 border-cyan-500/30"
                                  : winner === "Delta"
                                  ? "bg-orange-500/20 text-orange-400 border-orange-500/30"  
                                  : "bg-gray-500/20 text-gray-400 border-gray-500/30"
                              }>
                                {winner === "Tie" ? "Draw" : `Team ${winner} Won`}
                              </Badge>
                            )}
                          </div>
                          
                          <div className="flex flex-wrap gap-4 text-sm text-gray-400">
                            <span>Match ID: {match.match_id}</span>
                            <span>{getTimeAgo(match.created_date)}</span>
                            {match.status === "completed" && (
                              <span className="flex items-center gap-1">
                                <TrendingUp className="w-4 h-4" />
                                Final Score: {match.alpha_score || 0} - {match.delta_score || 0}
                              </span>
                            )}
                          </div>
                        </div>
                        
                        <div className="flex items-center gap-3">
                          {match.status === "active" && (
                            <Button
                              onClick={() => navigate(createPageUrl(`Battle?match=${match.match_id}`))}
                              className="bg-green-600 hover:bg-green-700 text-white"
                            >
                              <Play className="w-4 h-4 mr-2" />
                              Rejoin
                            </Button>
                          )}
                          
                          {match.status === "setup" && (
                            <Button
                              onClick={() => navigate(createPageUrl(`Lobby?match=${match.match_id}`))}
                              variant="outline"
                              className="border-cyan-500/30 text-cyan-400 hover:bg-cyan-500/10"
                            >
                              <Users className="w-4 h-4 mr-2" />
                              Join Lobby
                            </Button>
                          )}
                          
                          <Button
                            onClick={() => navigate(createPageUrl(`MatchDetails?match=${match.match_id}`))}
                            variant="outline"
                            className="border-gray-600 text-gray-300 hover:bg-gray-700"
                          >
                            <Eye className="w-4 h-4 mr-2" />
                            Details
                          </Button>
                        </div>
                      </div>
                    </CardContent>
                  </Card>
                </motion.div>
              );
            })
          )}
        </div>
      </div>
    </div>
  );
}