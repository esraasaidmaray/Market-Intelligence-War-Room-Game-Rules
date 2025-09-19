import React, { useState, useEffect, useCallback } from "react";
import { useNavigate } from "react-router-dom";
import { createPageUrl } from "@/utils";
import { Player, Match, BattleSubmission, CompanyReference } from "@/entities/all";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Progress } from "@/components/ui/progress";
import { Separator } from "@/components/ui/separator";
import { 
  Clock,
  Send,
  Users,
  Target,
  BookOpen,
  AlertTriangle,
  CheckCircle,
  Loader2,
  ExternalLink
} from "lucide-react";
import { motion } from "framer-motion";
import { getBattleTemplate } from "../components/battles/BattleTemplates";
import { calculateFinalScore } from "../components/scoring/ScoringEngine";

// Battle Timer Component
const BattleTimer = ({ startTime, duration }) => {
  const [remaining, setRemaining] = useState(duration * 60);

  useEffect(() => {
    if (!startTime) return;

    const interval = setInterval(() => {
      const start = new Date(startTime).getTime();
      const now = new Date().getTime();
      const elapsed = Math.floor((now - start) / 1000);
      const timeLeft = (duration * 60) - elapsed;
      setRemaining(timeLeft > 0 ? timeLeft : 0);
    }, 1000);

    return () => clearInterval(interval);
  }, [startTime, duration]);

  const minutes = Math.floor(remaining / 60);
  const seconds = remaining % 60;
  
  const isUrgent = remaining < 300; // Last 5 minutes

  return (
    <div className={`flex items-center gap-2 font-mono text-lg ${isUrgent ? 'text-red-400' : 'text-white'}`}>
      <Clock className={`w-5 h-5 ${isUrgent ? 'animate-pulse' : ''}`} />
      <span>{String(minutes).padStart(2, '0')}:{String(seconds).padStart(2, '0')}</span>
    </div>
  );
};

// Field Renderer Component
const FieldRenderer = ({ field, value, onChange }) => {
  const commonProps = {
    id: field.id,
    value: value || '',
    onChange: (e) => onChange(field.id, e.target.value),
    className: "bg-gray-700/50 border-gray-600 text-white placeholder-gray-400"
  };

  switch (field.type) {
    case 'textarea':
      return (
        <Textarea
          {...commonProps}
          placeholder={field.placeholder}
          rows={3}
        />
      );
    case 'select':
      return (
        <Select value={value || ''} onValueChange={(val) => onChange(field.id, val)}>
          <SelectTrigger className="bg-gray-700/50 border-gray-600 text-white">
            <SelectValue placeholder={field.placeholder} />
          </SelectTrigger>
          <SelectContent className="bg-gray-800 border-gray-600">
            {field.options?.map((option) => (
              <SelectItem key={option} value={option} className="text-white hover:bg-gray-700">
                {option}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
      );
    default:
      return (
        <Input
          {...commonProps}
          type={field.type}
          placeholder={field.placeholder}
        />
      );
  }
};

// Main Battle Page Component
export default function Battle() {
  const navigate = useNavigate();
  const matchId = new URLSearchParams(window.location.search).get("match");

  const [match, setMatch] = useState(null);
  const [currentPlayer, setCurrentPlayer] = useState(null);
  const [battleTemplate, setBattleTemplate] = useState(null);
  const [formData, setFormData] = useState({});
  const [submission, setSubmission] = useState(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState("");

  const loadBattleData = useCallback(async () => {
    if (!matchId) {
      navigate(createPageUrl("Setup"));
      return;
    }
    
    try {
      // Fetch match details
      const matches = await Match.filter({ match_id: matchId });
      if (!matches.length || matches[0].status !== 'active') {
        navigate(createPageUrl(`Lobby?match=${matchId}`));
        return;
      }
      setMatch(matches[0]);

      // Fetch current player (simplified for demo)
      const users = await Player.filter({ match_id: matchId });
      const user = users[users.length - 1];
      setCurrentPlayer(user);
      
      // Determine battle based on sub-team assignment
      const battleMap = {
        'A1': 'leadership_recon', 'D1': 'leadership_recon',
        'A2': 'product_arsenal', 'D2': 'product_arsenal', 
        'A3': 'funding_fortification', 'D3': 'funding_fortification',
        'A4': 'customer_frontlines', 'D4': 'customer_frontlines',
        'A5': 'alliance_forge', 'D5': 'alliance_forge'
      };
      const battleId = battleMap[user.sub_team] || 'leadership_recon';
      const template = getBattleTemplate(battleId);
      setBattleTemplate(template);

      // Initialize form data with empty fields from template
      const initialFormData = template.fields.reduce((acc, field) => {
        acc[field.id] = '';
        return acc;
      }, {});

      // Fetch or initialize submission draft
      const submissions = await BattleSubmission.filter({ 
        match_id: matchId, 
        battle_id: battleId, 
        team: user.team,
        sub_team: user.sub_team 
      });
      if (submissions.length > 0) {
        setSubmission(submissions[0]);
        setFormData(submissions[0].submission_data || initialFormData);
      } else {
        setFormData(initialFormData);
      }
      
    } catch (err) {
      setError("Failed to load battle data.");
      console.error(err);
    } finally {
      setIsLoading(false);
    }
  }, [matchId, navigate]);

  useEffect(() => {
    loadBattleData();
    const interval = setInterval(loadBattleData, 5000); // Poll for updates
    return () => clearInterval(interval);
  }, [loadBattleData]);

  const handleInputChange = (fieldId, value) => {
    setFormData(prev => ({ ...prev, [fieldId]: value }));
  };

  const allFieldsFilled = () => {
    if (!battleTemplate) return false;
    return battleTemplate.fields
      .filter(field => field.required)
      .every(field => formData[field.id] && String(formData[field.id]).trim() !== '');
  };

  const getProgressPercentage = () => {
    if (!battleTemplate) return 0;
    const requiredFields = battleTemplate.fields.filter(field => field.required);
    const filledFields = requiredFields.filter(field => 
      formData[field.id] && String(formData[field.id]).trim() !== ''
    );
    return Math.round((filledFields.length / requiredFields.length) * 100);
  };

  const handleSubmit = async () => {
    if (!allFieldsFilled()) {
      setError("All required fields must be completed before submission.");
      return;
    }

    setIsSubmitting(true);
    setError("");

    try {
      const timeRemaining = Math.floor(((new Date(match.start_time).getTime() + match.duration_minutes * 60000) - Date.now()) / 60000);

      const submissionData = {
        match_id: matchId,
        battle_id: battleTemplate.id,
        team: currentPlayer.team,
        sub_team: currentPlayer.sub_team,
        submission_data: formData,
        submitted_at: new Date().toISOString(),
        time_remaining: timeRemaining,
        sources: [] // Will be extracted from source_link fields
      };

      // Extract source links from form data for scoring
      const sources = [];
      Object.keys(formData).forEach(key => {
        if (key.includes('source_link') && formData[key]) {
          sources.push({
            url: formData[key],
            description: `Source for ${key.replace('_source_link', '')}`,
            quality_score: 0 // Will be calculated by scoring engine
          });
        }
      });
      submissionData.sources = sources;

      // Score the submission
      const scores = await calculateFinalScore(submissionData);
      
      let finalSubmission;
      if (submission) {
        // Update existing submission
        finalSubmission = await BattleSubmission.update(submission.id, { ...submissionData, scores });
      } else {
        // Create new submission
        finalSubmission = await BattleSubmission.create({ ...submissionData, scores });
      }
      
      setSubmission(finalSubmission);
      await Player.update(currentPlayer.id, { status: "completed" });
      
    } catch (err) {
      setError("Failed to submit and score data.");
      console.error(err);
    } finally {
      setIsSubmitting(false);
    }
  };

  // Group fields by section
  const groupedFields = battleTemplate?.fields.reduce((acc, field) => {
    const section = field.section || 'General';
    if (!acc[section]) acc[section] = [];
    acc[section].push(field);
    return acc;
  }, {}) || {};

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-screen bg-gray-900 text-white">
        <Loader2 className="w-8 h-8 animate-spin" />
        <p className="ml-4">Entering Battle Room...</p>
      </div>
    );
  }

  if (currentPlayer?.status === 'completed' || submission?.submitted_at) {
    return (
        <div className="flex flex-col items-center justify-center min-h-screen bg-gray-900 text-white p-4">
            <motion.div initial={{opacity: 0, scale: 0.8}} animate={{opacity: 1, scale: 1}} className="text-center">
                <CheckCircle className="w-16 h-16 text-green-400 mx-auto mb-6"/>
                <h1 className="text-3xl font-bold text-cyan-400 mb-2">Mission Accomplished</h1>
                <p className="text-gray-300 mb-8">Intelligence submitted successfully. Awaiting redeployment orders from command.</p>
                <Card className="bg-gray-800/50 border-gray-700/50 max-w-sm mx-auto">
                    <CardHeader>
                        <CardTitle className="text-center text-cyan-400">Battle Score</CardTitle>
                    </CardHeader>
                    <CardContent className="text-center">
                        <p className="text-5xl font-bold text-white mb-4">{submission?.scores?.total || 0}</p>
                        <div className="grid grid-cols-2 gap-2 text-sm">
                            <div>
                                <p className="text-gray-400">Data Accuracy</p>
                                <p className="text-white font-semibold">{submission?.scores?.breakdown?.data_accuracy || 0}%</p>
                            </div>
                            <div>
                                <p className="text-gray-400">Speed</p>
                                <p className="text-white font-semibold">{submission?.scores?.breakdown?.speed || 0}%</p>
                            </div>
                            <div>
                                <p className="text-gray-400">Sources</p>
                                <p className="text-white font-semibold">{submission?.scores?.breakdown?.source_quality || 0}%</p>
                            </div>
                            <div>
                                <p className="text-gray-400">Teamwork</p>
                                <p className="text-white font-semibold">{submission?.scores?.breakdown?.teamwork || 0}%</p>
                            </div>
                        </div>
                    </CardContent>
                </Card>
            </motion.div>
        </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-900 text-white p-4">
      <div className="grid lg:grid-cols-4 gap-6 max-w-7xl mx-auto">
        {/* Left Pane: Capture Template */}
        <div className="lg:col-span-3">
          <Card className="bg-gray-800/50 border-gray-700/50">
            <CardHeader className="flex flex-row items-center justify-between">
              <div>
                <CardTitle className="text-cyan-400 text-xl">{battleTemplate?.name}</CardTitle>
                <p className="text-sm text-gray-400">{battleTemplate?.description}</p>
                <div className="mt-2">
                  <div className="flex items-center gap-2 mb-1">
                    <span className="text-xs text-gray-400">Progress:</span>
                    <span className="text-xs text-white font-semibold">{getProgressPercentage()}%</span>
                  </div>
                  <Progress value={getProgressPercentage()} className="w-32 h-2" />
                </div>
              </div>
              <div className="text-right">
                {match && <BattleTimer startTime={match.start_time} duration={match.duration_minutes} />}
                <p className="text-xs text-gray-400 mt-1">Sub-Team: {currentPlayer?.sub_team}</p>
              </div>
            </CardHeader>
            <CardContent className="max-h-[75vh] overflow-y-auto">
              {error && (
                <div className="mb-4 p-3 bg-red-500/10 border border-red-500/30 rounded-lg">
                  <p className="text-red-400 text-sm flex items-center">
                    <AlertTriangle className="w-4 h-4 mr-2"/>
                    {error}
                  </p>
                </div>
              )}

              {/* Render fields grouped by section */}
              {Object.entries(groupedFields).map(([sectionName, fields]) => (
                <div key={sectionName} className="mb-8">
                  <h3 className="text-lg font-semibold text-cyan-400 mb-4 flex items-center">
                    <Target className="w-5 h-5 mr-2" />
                    {sectionName}
                  </h3>
                  
                  <div className="space-y-4 pl-4">
                    {fields.map(field => (
                      <div key={field.id} className="space-y-2">
                        <Label htmlFor={field.id} className="text-gray-300 flex items-center">
                          {field.label} 
                          {field.required && <span className="text-red-400 ml-1">*</span>}
                        </Label>
                        <FieldRenderer 
                          field={field}
                          value={formData[field.id]}
                          onChange={handleInputChange}
                        />
                      </div>
                    ))}
                  </div>
                  
                  {sectionName !== Object.keys(groupedFields)[Object.keys(groupedFields).length - 1] && (
                    <Separator className="mt-6 bg-gray-700" />
                  )}
                </div>
              ))}

              <div className="sticky bottom-0 bg-gray-800/90 backdrop-blur-sm p-4 -mx-6 -mb-6 border-t border-gray-700">
                <Button 
                  onClick={handleSubmit} 
                  disabled={!allFieldsFilled() || isSubmitting}
                  className="w-full bg-gradient-to-r from-cyan-500 to-blue-600 hover:from-cyan-600 hover:to-blue-700 text-black font-bold py-6 text-lg"
                >
                  {isSubmitting ? (
                    <>
                      <Loader2 className="w-6 h-6 animate-spin mr-2" />
                      Submitting & Scoring...
                    </>
                  ) : (
                    <>
                      <Send className="w-6 h-6 mr-2" />
                      Submit Intelligence ({getProgressPercentage()}%)
                    </>
                  )}
                </Button>
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Right Pane: Tools & Team Info */}
        <div className="space-y-6">
          {/* Suggested Tools */}
          <Card className="bg-gray-800/50 border-gray-700/50">
            <CardHeader>
              <CardTitle className="text-orange-400 flex items-center gap-2 text-lg">
                <BookOpen className="w-5 h-5" />
                Suggested Tools
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-2">
                {battleTemplate?.tools.map(tool => (
                  <a
                    key={tool.name}
                    href={tool.url}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="flex items-center gap-2 p-2 rounded-lg text-blue-400 hover:text-blue-300 hover:bg-gray-700/30 transition-all duration-200"
                  >
                    <ExternalLink className="w-4 h-4" />
                    <span className="text-sm">{tool.name}</span>
                  </a>
                ))}
              </div>
            </CardContent>
          </Card>

          {/* Team Info */}
          <Card className="bg-gray-800/50 border-gray-700/50">
            <CardHeader>
              <CardTitle className="text-green-400 flex items-center gap-2 text-lg">
                <Users className="w-5 h-5" />
                Battle Info
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-3">
              <div>
                <p className="text-gray-400 text-sm">Team</p>
                <p className="text-white font-semibold">{currentPlayer?.team}</p>
              </div>
              <div>
                <p className="text-gray-400 text-sm">Sub-Team</p>
                <p className="text-white font-semibold">{currentPlayer?.sub_team}</p>
              </div>
              <div>
                <p className="text-gray-400 text-sm">Operative</p>
                <p className="text-white font-semibold">{currentPlayer?.name}</p>
              </div>
              <div>
                <p className="text-gray-400 text-sm">Target Company</p>
                <p className="text-white font-semibold">{match?.company}</p>
              </div>
            </CardContent>
          </Card>

          {/* Quick Tips */}
          <Card className="bg-gray-800/50 border-gray-700/50">
            <CardHeader>
              <CardTitle className="text-purple-400 text-lg">Intelligence Tips</CardTitle>
            </CardHeader>
            <CardContent>
              <ul className="space-y-2 text-sm text-gray-300">
                <li>• Use multiple sources to verify data</li>
                <li>• Check official company websites first</li>
                <li>• Look for recent press releases</li>
                <li>• Cross-reference financial data</li>
                <li>• Save all source links for validation</li>
              </ul>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}