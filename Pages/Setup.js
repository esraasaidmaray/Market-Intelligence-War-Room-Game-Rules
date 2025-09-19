import React, { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { createPageUrl } from "@/utils";
import { Player, Match } from "@/entities/all";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { 
  User, 
  Crown, 
  Shield, 
  ArrowRight, 
  Users,
  Target,
  AlertTriangle
} from "lucide-react";
import { motion } from "framer-motion";
import { Alert, AlertDescription } from "@/components/ui/alert";

const COMPANIES = [
  "Apple Inc.",
  "Microsoft Corporation",
  "Amazon.com Inc.",
  "Alphabet Inc. (Google)",
  "Tesla Inc.",
  "Meta Platforms Inc.",
  "Netflix Inc.",
  "Nike Inc.",
  "Coca-Cola Company",
  "McDonald's Corporation",
  "Spotify Technology",
  "Uber Technologies",
  "Airbnb Inc.",
  "Zoom Video Communications",
  "Slack Technologies"
];

const AVATARS = [
  { id: "agent1", name: "Agent Alpha", color: "from-cyan-400 to-blue-500" },
  { id: "agent2", name: "Agent Beta", color: "from-green-400 to-emerald-500" },
  { id: "agent3", name: "Agent Gamma", color: "from-orange-400 to-red-500" },
  { id: "agent4", name: "Agent Delta", color: "from-purple-400 to-pink-500" },
  { id: "agent5", name: "Agent Omega", color: "from-yellow-400 to-orange-500" }
];

export default function Setup() {
  const navigate = useNavigate();
  const [step, setStep] = useState(1);
  const [formData, setFormData] = useState({
    name: "",
    team: "",
    role: "",
    avatar: "agent1",
    company: "",
    matchId: ""
  });
  const [error, setError] = useState("");
  const [isLoading, setIsLoading] = useState(false);

  const handleInputChange = (field, value) => {
    setFormData(prev => ({ ...prev, [field]: value }));
    setError("");
  };

  const validateStep1 = () => {
    if (!formData.name.trim()) {
      setError("Agent name is required");
      return false;
    }
    if (!formData.team) {
      setError("Team selection is required");
      return false;
    }
    if (!formData.role) {
      setError("Role selection is required");
      return false;
    }
    return true;
  };

  const handleNext = () => {
    if (step === 1 && validateStep1()) {
      setStep(2);
    } else if (step === 2 && formData.role === "Leader" && !formData.company) {
      setError("Company selection is required for team leaders");
    } else if (step === 2) {
      setStep(3);
    }
  };

  const handleBack = () => {
    if (step > 1) {
      setStep(step - 1);
    }
  };

  const createMatch = async () => {
    setIsLoading(true);
    try {
      const matchId = `match_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
      
      // Create match
      await Match.create({
        match_id: matchId,
        company: formData.company,
        status: "setup"
      });

      // Create player
      await Player.create({
        name: formData.name,
        team: formData.team,
        role: formData.role,
        avatar: formData.avatar,
        match_id: matchId,
        status: "waiting"
      });

      navigate(createPageUrl(`Lobby?match=${matchId}`));
    } catch (err) {
      setError("Failed to create match. Please try again.");
    }
    setIsLoading(false);
  };

  const joinMatch = async () => {
    if (!formData.matchId.trim()) {
      setError("Match ID is required");
      return;
    }

    setIsLoading(true);
    try {
      // Check if match exists
      const matches = await Match.filter({ match_id: formData.matchId });
      if (matches.length === 0) {
        setError("Match not found. Please check the Match ID.");
        setIsLoading(false);
        return;
      }

      // Create player
      await Player.create({
        name: formData.name,
        team: formData.team,
        role: formData.role,
        avatar: formData.avatar,
        match_id: formData.matchId,
        status: "waiting"
      });

      navigate(createPageUrl(`Lobby?match=${formData.matchId}`));
    } catch (err) {
      setError("Failed to join match. Please try again.");
    }
    setIsLoading(false);
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 via-black to-gray-800 p-4">
      <div className="max-w-2xl mx-auto pt-8">
        {/* Header */}
        <motion.div 
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="text-center mb-8"
        >
          <h1 className="text-3xl md:text-4xl font-bold text-white mb-4">
            Agent Registration
          </h1>
          <p className="text-gray-300">
            Configure your operative profile for the mission
          </p>
        </motion.div>

        {/* Progress Indicator */}
        <div className="flex items-center justify-center mb-8">
          {[1, 2, 3].map((i) => (
            <div key={i} className="flex items-center">
              <div className={`w-8 h-8 rounded-full flex items-center justify-center text-sm font-bold transition-all duration-300 ${
                i <= step 
                  ? "bg-gradient-to-r from-cyan-500 to-blue-600 text-black" 
                  : "bg-gray-700 text-gray-400"
              }`}>
                {i}
              </div>
              {i < 3 && (
                <div className={`w-12 h-0.5 mx-2 transition-all duration-300 ${
                  i < step ? "bg-cyan-500" : "bg-gray-700"
                }`} />
              )}
            </div>
          ))}
        </div>

        <motion.div
          key={step}
          initial={{ opacity: 0, x: 20 }}
          animate={{ opacity: 1, x: 0 }}
          exit={{ opacity: 0, x: -20 }}
        >
          <Card className="bg-gray-800/50 border-gray-700/50 backdrop-blur-sm">
            <CardHeader>
              <CardTitle className="text-white text-xl">
                {step === 1 && "Basic Information"}
                {step === 2 && "Mission Parameters"}
                {step === 3 && "Deploy to Battle"}
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-6">
              {error && (
                <Alert variant="destructive">
                  <AlertTriangle className="h-4 w-4" />
                  <AlertDescription>{error}</AlertDescription>
                </Alert>
              )}

              {/* Step 1: Basic Info */}
              {step === 1 && (
                <>
                  <div className="space-y-2">
                    <Label htmlFor="name" className="text-gray-300">Agent Name</Label>
                    <Input
                      id="name"
                      value={formData.name}
                      onChange={(e) => handleInputChange("name", e.target.value)}
                      placeholder="Enter your codename"
                      className="bg-gray-700/50 border-gray-600 text-white placeholder-gray-400"
                    />
                  </div>

                  <div className="space-y-2">
                    <Label className="text-gray-300">Team Assignment</Label>
                    <div className="grid grid-cols-2 gap-4">
                      <Button
                        variant={formData.team === "Alpha" ? "default" : "outline"}
                        onClick={() => handleInputChange("team", "Alpha")}
                        className={formData.team === "Alpha" 
                          ? "bg-gradient-to-r from-cyan-500 to-blue-600 text-black font-bold" 
                          : "border-cyan-500/30 text-cyan-400 hover:bg-cyan-500/10"
                        }
                      >
                        <Shield className="w-4 h-4 mr-2" />
                        Team Alpha
                      </Button>
                      <Button
                        variant={formData.team === "Delta" ? "default" : "outline"}
                        onClick={() => handleInputChange("team", "Delta")}
                        className={formData.team === "Delta" 
                          ? "bg-gradient-to-r from-orange-500 to-red-600 text-white font-bold" 
                          : "border-orange-500/30 text-orange-400 hover:bg-orange-500/10"
                        }
                      >
                        <Target className="w-4 h-4 mr-2" />
                        Team Delta
                      </Button>
                    </div>
                  </div>

                  <div className="space-y-2">
                    <Label className="text-gray-300">Operational Role</Label>
                    <div className="grid grid-cols-2 gap-4">
                      <Button
                        variant={formData.role === "Leader" ? "default" : "outline"}
                        onClick={() => handleInputChange("role", "Leader")}
                        className={formData.role === "Leader" 
                          ? "bg-gradient-to-r from-yellow-500 to-orange-600 text-black font-bold" 
                          : "border-yellow-500/30 text-yellow-400 hover:bg-yellow-500/10"
                        }
                      >
                        <Crown className="w-4 h-4 mr-2" />
                        Team Leader
                      </Button>
                      <Button
                        variant={formData.role === "Player" ? "default" : "outline"}
                        onClick={() => handleInputChange("role", "Player")}
                        className={formData.role === "Player" 
                          ? "bg-gradient-to-r from-green-500 to-emerald-600 text-black font-bold" 
                          : "border-green-500/30 text-green-400 hover:bg-green-500/10"
                        }
                      >
                        <Users className="w-4 h-4 mr-2" />
                        Operative
                      </Button>
                    </div>
                  </div>

                  <div className="space-y-2">
                    <Label className="text-gray-300">Avatar Selection</Label>
                    <div className="grid grid-cols-5 gap-2">
                      {AVATARS.map((avatar) => (
                        <button
                          key={avatar.id}
                          onClick={() => handleInputChange("avatar", avatar.id)}
                          className={`p-3 rounded-lg border-2 transition-all duration-200 ${
                            formData.avatar === avatar.id
                              ? "border-cyan-500 bg-cyan-500/20"
                              : "border-gray-600 hover:border-gray-500"
                          }`}
                        >
                          <div className={`w-8 h-8 rounded-full bg-gradient-to-r ${avatar.color} mx-auto`} />
                        </button>
                      ))}
                    </div>
                  </div>
                </>
              )}

              {/* Step 2: Mission Parameters */}
              {step === 2 && (
                <>
                  {formData.role === "Leader" && (
                    <div className="space-y-2">
                      <Label htmlFor="company" className="text-gray-300">
                        Target Company (Leaders Only)
                      </Label>
                      <Select
                        value={formData.company}
                        onValueChange={(value) => handleInputChange("company", value)}
                      >
                        <SelectTrigger className="bg-gray-700/50 border-gray-600 text-white">
                          <SelectValue placeholder="Select target company" />
                        </SelectTrigger>
                        <SelectContent className="bg-gray-800 border-gray-600">
                          {COMPANIES.map((company) => (
                            <SelectItem key={company} value={company} className="text-white hover:bg-gray-700">
                              {company}
                            </SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                      <p className="text-sm text-gray-400">
                        Both team leaders must select the same company to proceed
                      </p>
                    </div>
                  )}

                  {formData.role === "Player" && (
                    <div className="text-center py-8">
                      <User className="w-16 h-16 text-cyan-400 mx-auto mb-4" />
                      <h3 className="text-xl font-bold text-white mb-2">Ready for Deployment</h3>
                      <p className="text-gray-300">
                        Your team leader will select the target company and assign you to a sub-team.
                      </p>
                    </div>
                  )}
                </>
              )}

              {/* Step 3: Deploy */}
              {step === 3 && (
                <>
                  <div className="space-y-4">
                    <Button
                      onClick={createMatch}
                      disabled={isLoading}
                      className="w-full bg-gradient-to-r from-cyan-500 to-blue-600 hover:from-cyan-600 hover:to-blue-700 text-black font-bold py-6 text-lg rounded-xl"
                    >
                      {isLoading ? "Creating Mission..." : "Create New Match"}
                    </Button>
                    
                    <div className="relative">
                      <div className="absolute inset-0 flex items-center">
                        <div className="w-full border-t border-gray-600"></div>
                      </div>
                      <div className="relative flex justify-center text-sm">
                        <span className="px-2 bg-gray-800 text-gray-400">or</span>
                      </div>
                    </div>
                    
                    <div className="space-y-3">
                      <Input
                        value={formData.matchId}
                        onChange={(e) => handleInputChange("matchId", e.target.value)}
                        placeholder="Enter Match ID"
                        className="bg-gray-700/50 border-gray-600 text-white placeholder-gray-400"
                      />
                      <Button
                        onClick={joinMatch}
                        disabled={isLoading}
                        variant="outline"
                        className="w-full border-cyan-500/30 text-cyan-400 hover:bg-cyan-500/10 py-6 text-lg rounded-xl"
                      >
                        {isLoading ? "Joining Mission..." : "Join Existing Match"}
                      </Button>
                    </div>
                  </div>
                </>
              )}

              {/* Navigation */}
              <div className="flex justify-between pt-4">
                {step > 1 && (
                  <Button
                    onClick={handleBack}
                    variant="outline"
                    className="border-gray-600 text-gray-300 hover:bg-gray-700"
                  >
                    Back
                  </Button>
                )}
                
                {step < 3 && (
                  <Button
                    onClick={handleNext}
                    className="bg-gradient-to-r from-cyan-500 to-blue-600 hover:from-cyan-600 hover:to-blue-700 text-black font-bold ml-auto"
                  >
                    Next
                    <ArrowRight className="w-4 h-4 ml-2" />
                  </Button>
                )}
              </div>
            </CardContent>
          </Card>
        </motion.div>
      </div>
    </div>
  );
}