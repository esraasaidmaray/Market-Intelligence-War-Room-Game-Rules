import React, { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { createPageUrl } from "@/utils";
import { Match } from "@/entities/all";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { 
  Trophy, 
  Clock, 
  Users, 
  Target, 
  Plus,
  Play,
  Eye,
  Calendar,
  Timer
} from "lucide-react";
import { motion } from "framer-motion";

export default function Matches() {
  const navigate = useNavigate();
  const [matches, setMatches] = useState([]);
  const [isLoading, setIsLoading] = useState(true);

  const loadMatches = async () => {
    try {
      const allMatches = await Match.getAll();
      setMatches(allMatches);
    } catch (err) {
      console.error("Failed to load matches:", err);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    loadMatches();
  }, []);

  const getStatusColor = (status) => {
    switch (status) {
      case "setup": return "bg-yellow-500/20 text-yellow-400";
      case "waiting_for_leaders": return "bg-blue-500/20 text-blue-400";
      case "active": return "bg-green-500/20 text-green-400";
      case "completed": return "bg-purple-500/20 text-purple-400";
      default: return "bg-gray-500/20 text-gray-400";
    }
  };

  const getStatusText = (status) => {
    switch (status) {
      case "setup": return "Setup";
      case "waiting_for_leaders": return "Waiting";
      case "active": return "Active";
      case "completed": return "Completed";
      default: return "Unknown";
    }
  };

  const formatDate = (dateString) => {
    if (!dateString) return "Not started";
    const date = new Date(dateString);
    return date.toLocaleDateString() + " " + date.toLocaleTimeString();
  };

  const getMatchDuration = (match) => {
    if (!match.start_time) return "Not started";
    const start = new Date(match.start_time);
    const end = new Date(start.getTime() + match.duration_minutes * 60000);
    const now = new Date();
    
    if (now < end && match.status === "active") {
      const remaining = Math.max(0, Math.floor((end - now) / 60000));
      return `${remaining} min remaining`;
    }
    
    return `${match.duration_minutes} min`;
  };

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-gray-900 via-black to-gray-800 flex items-center justify-center">
        <div className="text-center">
          <Trophy className="w-8 h-8 text-cyan-400 animate-pulse mx-auto mb-4" />
          <p className="text-white">Loading matches...</p>
        </div>
      </div>
    );
  }

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
            View and manage all intelligence operations
          </p>
          
          <Button
            onClick={() => navigate(createPageUrl("Setup"))}
            className="bg-gradient-to-r from-cyan-500 to-blue-600 hover:from-cyan-600 hover:to-blue-700 text-black font-bold px-8 py-3"
          >
            <Plus className="w-5 h-5 mr-2" />
            Create New Mission
          </Button>
        </motion.div>

        {/* Matches Grid */}
        <motion.div 
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2 }}
          className="grid md:grid-cols-2 lg:grid-cols-3 gap-6"
        >
          {matches.length === 0 ? (
            <div className="col-span-full text-center py-12">
              <Target className="w-16 h-16 text-gray-600 mx-auto mb-4" />
              <h3 className="text-xl font-semibold text-gray-400 mb-2">No Missions Yet</h3>
              <p className="text-gray-500 mb-6">
                Create your first intelligence operation to get started
              </p>
              <Button
                onClick={() => navigate(createPageUrl("Setup"))}
                className="bg-gradient-to-r from-cyan-500 to-blue-600 hover:from-cyan-600 hover:to-blue-700 text-black font-bold"
              >
                <Play className="w-4 h-4 mr-2" />
                Start First Mission
              </Button>
            </div>
          ) : (
            matches.map((match) => (
              <Card key={match.id} className="bg-gray-800/50 border-gray-700/50 hover:bg-gray-800/70 transition-all duration-300">
                <CardHeader>
                  <div className="flex items-center justify-between mb-2">
                    <CardTitle className="text-white text-lg">
                      Mission #{match.match_id.slice(-8)}
                    </CardTitle>
                    <Badge className={getStatusColor(match.status)}>
                      {getStatusText(match.status)}
                    </Badge>
                  </div>
                  
                  {match.company && (
                    <div className="bg-cyan-500/10 border border-cyan-500/20 rounded-lg p-3">
                      <p className="text-cyan-400 text-sm font-medium">Target</p>
                      <p className="text-white text-sm">{match.company}</p>
                    </div>
                  )}
                </CardHeader>
                
                <CardContent className="space-y-4">
                  <div className="space-y-2 text-sm">
                    <div className="flex items-center gap-2 text-gray-400">
                      <Calendar className="w-4 h-4" />
                      <span>Started: {formatDate(match.start_time)}</span>
                    </div>
                    
                    <div className="flex items-center gap-2 text-gray-400">
                      <Timer className="w-4 h-4" />
                      <span>Duration: {getMatchDuration(match)}</span>
                    </div>
                    
                    <div className="flex items-center gap-2 text-gray-400">
                      <Users className="w-4 h-4" />
                      <span>Teams: Alpha vs Delta</span>
                    </div>
                  </div>
                  
                  {match.alpha_score !== undefined && match.delta_score !== undefined && (
                    <div className="bg-gray-700/50 rounded-lg p-3">
                      <div className="flex justify-between items-center mb-2">
                        <span className="text-cyan-400 font-semibold">Alpha</span>
                        <span className="text-white font-bold">{match.alpha_score}</span>
                      </div>
                      <div className="flex justify-between items-center">
                        <span className="text-orange-400 font-semibold">Delta</span>
                        <span className="text-white font-bold">{match.delta_score}</span>
                      </div>
                    </div>
                  )}
                  
                  <div className="flex gap-2">
                    {match.status === "completed" ? (
                      <Button
                        onClick={() => navigate(createPageUrl(`MatchSummary?match=${match.match_id}`))}
                        variant="outline"
                        className="flex-1 border-cyan-500/30 text-cyan-400 hover:bg-cyan-500/10"
                      >
                        <Eye className="w-4 h-4 mr-2" />
                        View Results
                      </Button>
                    ) : match.status === "active" ? (
                      <Button
                        onClick={() => navigate(createPageUrl(`Battle?match=${match.match_id}`))}
                        className="flex-1 bg-gradient-to-r from-green-500 to-emerald-600 hover:from-green-600 hover:to-emerald-700 text-white font-bold"
                      >
                        <Play className="w-4 h-4 mr-2" />
                        Join Battle
                      </Button>
                    ) : (
                      <Button
                        onClick={() => navigate(createPageUrl(`Lobby?match=${match.match_id}`))}
                        variant="outline"
                        className="flex-1 border-gray-600 text-gray-300 hover:bg-gray-700"
                      >
                        <Users className="w-4 h-4 mr-2" />
                        Join Lobby
                      </Button>
                    )}
                  </div>
                </CardContent>
              </Card>
            ))
          )}
        </motion.div>

        {/* Quick Stats */}
        {matches.length > 0 && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.4 }}
            className="mt-12 grid md:grid-cols-3 gap-6"
          >
            <Card className="bg-gradient-to-br from-cyan-900/20 to-blue-900/20 border-cyan-500/30">
              <CardContent className="p-6 text-center">
                <Trophy className="w-8 h-8 text-cyan-400 mx-auto mb-3" />
                <p className="text-3xl font-bold text-white">{matches.length}</p>
                <p className="text-gray-400">Total Missions</p>
              </CardContent>
            </Card>
            
            <Card className="bg-gradient-to-br from-green-900/20 to-emerald-900/20 border-green-500/30">
              <CardContent className="p-6 text-center">
                <Clock className="w-8 h-8 text-green-400 mx-auto mb-3" />
                <p className="text-3xl font-bold text-white">
                  {matches.filter(m => m.status === "completed").length}
                </p>
                <p className="text-gray-400">Completed</p>
              </CardContent>
            </Card>
            
            <Card className="bg-gradient-to-br from-orange-900/20 to-red-900/20 border-orange-500/30">
              <CardContent className="p-6 text-center">
                <Target className="w-8 h-8 text-orange-400 mx-auto mb-3" />
                <p className="text-3xl font-bold text-white">
                  {matches.filter(m => m.status === "active").length}
                </p>
                <p className="text-gray-400">Active</p>
              </CardContent>
            </Card>
          </motion.div>
        )}
      </div>
    </div>
  );
}