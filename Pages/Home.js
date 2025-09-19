import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import { createPageUrl } from "@/utils";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { 
  Zap, 
  Users, 
  Timer, 
  Target, 
  Trophy,
  Play,
  PlusCircle,
  ArrowRight,
  Shield
} from "lucide-react";
import { motion } from "framer-motion";

export default function Home() {
  const navigate = useNavigate();
  const [selectedAction, setSelectedAction] = useState(null);

  const features = [
    {
      icon: Users,
      title: "Team Battles",
      description: "5 concurrent 3v3 battles between Alpha and Delta teams",
      color: "from-cyan-400 to-blue-500"
    },
    {
      icon: Timer,
      title: "60-Minute Matches",
      description: "Race against time to gather market intelligence",
      color: "from-green-400 to-emerald-500"
    },
    {
      icon: Target,
      title: "Real Research",
      description: "Use actual tools like LinkedIn, Crunchbase, and Statista",
      color: "from-orange-400 to-red-500"
    },
    {
      icon: Trophy,
      title: "Competitive Scoring",
      description: "Accuracy, speed, sources, and teamwork all matter",
      color: "from-purple-400 to-pink-500"
    }
  ];

  const battleTypes = [
    { name: "Leadership Recon", description: "Founder & executive intelligence" },
    { name: "Product Arsenal", description: "Product portfolio analysis" },
    { name: "Market Dominance", description: "Market share & positioning" },
    { name: "Financial Intel", description: "Funding & revenue insights" },
    { name: "Digital Footprint", description: "Social & digital presence" }
  ];

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 via-black to-gray-800 p-4">
      <div className="max-w-6xl mx-auto">
        {/* Hero Section */}
        <motion.div 
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="text-center mb-12 pt-8"
        >
          <div className="inline-flex items-center gap-2 bg-cyan-500/10 px-4 py-2 rounded-full border border-cyan-500/20 mb-6">
            <Shield className="w-4 h-4 text-cyan-400" />
            <span className="text-cyan-400 text-sm font-medium">CLASSIFIED MISSION</span>
          </div>
          
          <h1 className="text-4xl md:text-6xl font-bold text-white mb-6 leading-tight">
            Market Intelligence
            <span className="block bg-gradient-to-r from-cyan-400 to-blue-500 bg-clip-text text-transparent">
              War Room
            </span>
          </h1>
          
          <p className="text-xl text-gray-300 mb-8 max-w-2xl mx-auto leading-relaxed">
            Compete in real-time market research battles. Gather intelligence, 
            make strategic decisions, and outmaneuver the competition.
          </p>
          
          {/* Action Buttons */}
          <div className="flex flex-col sm:flex-row gap-4 justify-center items-center">
            <Button
              onClick={() => navigate(createPageUrl("Setup"))}
              className="bg-gradient-to-r from-cyan-500 to-blue-600 hover:from-cyan-600 hover:to-blue-700 text-black font-bold px-8 py-6 text-lg rounded-xl transition-all duration-300 transform hover:scale-105 shadow-lg shadow-cyan-500/25"
            >
              <Play className="w-6 h-6 mr-2" />
              Start Mission
            </Button>
            
            <Button
              onClick={() => navigate(createPageUrl("Matches"))}
              variant="outline"
              className="border-cyan-500/30 text-cyan-400 hover:bg-cyan-500/10 px-8 py-6 text-lg rounded-xl transition-all duration-300"
            >
              <Trophy className="w-6 h-6 mr-2" />
              View Matches
            </Button>
          </div>
        </motion.div>

        {/* Features Grid */}
        <motion.div 
          initial={{ opacity: 0, y: 40 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2 }}
          className="grid md:grid-cols-2 lg:grid-cols-4 gap-6 mb-12"
        >
          {features.map((feature, index) => (
            <Card key={index} className="bg-gray-800/50 border-gray-700/50 backdrop-blur-sm hover:bg-gray-800/70 transition-all duration-300">
              <CardHeader className="text-center pb-3">
                <div className={`w-12 h-12 rounded-xl bg-gradient-to-r ${feature.color} p-3 mx-auto mb-3`}>
                  <feature.icon className="w-6 h-6 text-white" />
                </div>
                <CardTitle className="text-white text-lg">{feature.title}</CardTitle>
              </CardHeader>
              <CardContent>
                <p className="text-gray-300 text-center text-sm leading-relaxed">
                  {feature.description}
                </p>
              </CardContent>
            </Card>
          ))}
        </motion.div>

        {/* Battle Types */}
        <motion.div 
          initial={{ opacity: 0, y: 40 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.4 }}
          className="mb-12"
        >
          <h2 className="text-3xl font-bold text-white text-center mb-8">
            Battle Categories
          </h2>
          
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-4">
            {battleTypes.map((battle, index) => (
              <motion.div
                key={index}
                whileHover={{ scale: 1.02 }}
                className="bg-gray-800/40 border border-gray-700/50 rounded-xl p-6 backdrop-blur-sm hover:border-cyan-500/30 transition-all duration-300"
              >
                <h3 className="text-cyan-400 font-bold text-lg mb-2">{battle.name}</h3>
                <p className="text-gray-300 text-sm">{battle.description}</p>
              </motion.div>
            ))}
          </div>
        </motion.div>

        {/* How It Works */}
        <motion.div 
          initial={{ opacity: 0, y: 40 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.6 }}
          className="text-center"
        >
          <h2 className="text-3xl font-bold text-white mb-8">Mission Protocol</h2>
          
          <div className="grid md:grid-cols-3 gap-8">
            <div className="flex flex-col items-center">
              <div className="w-16 h-16 rounded-full bg-gradient-to-r from-cyan-500 to-blue-600 flex items-center justify-center text-black font-bold text-xl mb-4">
                1
              </div>
              <h3 className="text-white font-bold text-lg mb-2">Form Teams</h3>
              <p className="text-gray-300 text-sm">
                Join Alpha or Delta team, assign roles and sub-teams
              </p>
            </div>
            
            <div className="flex flex-col items-center">
              <div className="w-16 h-16 rounded-full bg-gradient-to-r from-green-500 to-emerald-600 flex items-center justify-center text-black font-bold text-xl mb-4">
                2
              </div>
              <h3 className="text-white font-bold text-lg mb-2">Execute Missions</h3>
              <p className="text-gray-300 text-sm">
                Research targets using real intelligence tools
              </p>
            </div>
            
            <div className="flex flex-col items-center">
              <div className="w-16 h-16 rounded-full bg-gradient-to-r from-orange-500 to-red-600 flex items-center justify-center text-black font-bold text-xl mb-4">
                3
              </div>
              <h3 className="text-white font-bold text-lg mb-2">Victory</h3>
              <p className="text-gray-300 text-sm">
                Score based on accuracy, speed, and teamwork
              </p>
            </div>
          </div>
        </motion.div>
      </div>
    </div>
  );
}