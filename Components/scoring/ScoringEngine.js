
import { CompanyReference } from "@/entities/all";

// Fuzzy string matching utility
const calculateStringSimilarity = (str1, str2) => {
  if (!str1 || !str2) return 0;
  
  const s1 = String(str1).toLowerCase().trim();
  const s2 = String(str2).toLowerCase().trim();
  
  if (s1 === s2) return 100;
  
  // Levenshtein distance
  const matrix = [];
  for (let i = 0; i <= s2.length; i++) {
    matrix[i] = [i];
  }
  for (let j = 0; j <= s1.length; j++) {
    matrix[0][j] = j;
  }
  for (let i = 1; i <= s2.length; i++) {
    for (let j = 1; j <= s1.length; j++) {
      if (s2.charAt(i - 1) === s1.charAt(j - 1)) {
        matrix[i][j] = matrix[i - 1][j - 1];
      } else {
        matrix[i][j] = Math.min(
          matrix[i - 1][j - 1] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j] + 1
        );
      }
    }
  }
  
  const distance = matrix[s2.length][s1.length];
  const similarity = ((Math.max(s1.length, s2.length) - distance) / Math.max(s1.length, s2.length)) * 100;
  return Math.max(0, similarity);
};

// Trusted domain whitelist for source validation
const TRUSTED_DOMAINS = [
  'linkedin.com',
  'crunchbase.com',
  'pitchbook.com',
  'statista.com',
  'ibisworld.com',
  'euromonitor.com',
  'gartner.com',
  'forrester.com',
  'sec.gov',
  'reuters.com',
  'bloomberg.com',
  'techcrunch.com',
  'forbes.com',
  'mckinsey.com',
  'entrepreneur.com',
  'fintechnews.ae',
  'tracxn.com',
  'lucidityinsights.com',
  'fawry.com'
];

const validateSourceQuality = (sources) => {
  if (!sources || sources.length === 0) return 0;
  
  let totalScore = 0;
  sources.forEach(source => {
    let sourceScore = 0;
    
    try {
      const url = new URL(source.url);
      const domain = url.hostname.replace('www.', '');
      
      // Domain trust score (70% of source score)
      if (TRUSTED_DOMAINS.some(trusted => domain.includes(trusted))) {
        sourceScore += 70;
      }
      
      // Citation quality score (30% of source score)
      if (source.description && source.description.length > 10) {
        sourceScore += 30;
      }
      
    } catch (error) {
      sourceScore = 0; // Invalid URL
    }
    
    totalScore += sourceScore;
  });
  
  return sources.length > 0 ? Math.min(100, totalScore / sources.length) : 0;
};

const calculateDataAccuracy = (submissionData, referenceData, battleId) => {
  let totalSimilarity = 0;
  let fieldCount = 0;

  if (!submissionData || !referenceData) return 0;
  
  const battleName = getBattleName(battleId);
  const refBattleData = referenceData[`battle_${battleName}`];
  
  if (!refBattleData) return 0;

  for (const fieldKey in submissionData) {
    const submittedValue = submissionData[fieldKey];
    const referenceValue = getReferenceValue(refBattleData, fieldKey);
    
    if (referenceValue !== null && referenceValue !== undefined) {
      fieldCount++;
      totalSimilarity += calculateStringSimilarity(submittedValue, referenceValue);
    }
  }

  return fieldCount > 0 ? totalSimilarity / fieldCount : 0;
};


const getBattleName = (battleId) => {
  const battleNames = {
    leadership_recon: '1_leadership',
    product_arsenal: '2_products', 
    funding_fortification: '3_funding',
    customer_frontlines: '4_customers',
    alliance_forge: '5_partnerships'
  };
  return battleNames[battleId] || '1_leadership';
};

const getReferenceValue = (referenceData, fieldKey) => {
    const keyMap = {
        // Leadership Recon
        founder_name: 'founders.0.full_name',
        founding_year: 'founders.0.founding_year',
        key_executive_name: 'key_executives.0.name',
        executive_title: 'key_executives.0.title',
        market_share_percentage: 'market_share.company_share_percentage',
        // ... more mappings
    };
    
    const path = keyMap[fieldKey] || fieldKey; // Fallback to direct key
    let current = referenceData;
    const parts = path.split('.');

    for (let i = 0; i < parts.length; i++) {
        const part = parts[i];
        if (current[part] !== undefined) {
            current = current[part];
        } else {
            return null; // Path not found
        }
    }
    return current;
};


const calculateSpeedScore = (timeRemaining, totalTime = 60) => {
  // Speed score based on how much time was remaining when submitted
  return Math.min(100, (timeRemaining / totalTime) * 100);
};

const calculateTeamworkScore = (collaborationData) => {
  let teamworkScore = 0;
  if (!collaborationData) return 25; // Default score if no data
  
  // Chat usage (25%)
  if (collaborationData.chatMessages > 0) {
    teamworkScore += Math.min(25, collaborationData.chatMessages * 2);
  }
  
  // Number of contributors (25%)
  if (collaborationData.contributors > 1) {
    teamworkScore += Math.min(25, (collaborationData.contributors - 1) * 8);
  }
  
  // Leader approval activity (25%)
  if (collaborationData.leaderApprovals > 0) {
    teamworkScore += Math.min(25, collaborationData.leaderApprovals * 5);
  }
  
  // Completion time coordination (25%)
  if (collaborationData.coordinatedSubmission) {
    teamworkScore += 25;
  }
  
  return Math.min(100, teamworkScore);
};

export const calculateFinalScore = async (submission) => {
  try {
    // Get reference data for the company
    const referenceRecords = await CompanyReference.filter({
      company_name: "Fawry for Banking Technology and Electronic Payments S.A.E."
    });
    
    if (referenceRecords.length === 0) {
      throw new Error("Reference data not found");
    }
    
    const referenceData = referenceRecords[0];
    
    // Calculate component scores
    const dataAccuracy = calculateDataAccuracy(
      submission.submission_data,
      referenceData,
      submission.battle_id
    );
    
    const speedScore = calculateSpeedScore(submission.time_remaining);
    
    const sourceQuality = validateSourceQuality(submission.sources);
    
    const teamworkScore = calculateTeamworkScore(
      submission.collaboration_data || {
        chatMessages: 5, // Placeholder
        contributors: 2, // Placeholder
        leaderApprovals: 1, // Placeholder
        coordinatedSubmission: true // Placeholder
      }
    );
    
    // Apply scoring weights: Data Accuracy 60%, Speed 10%, Source Quality 15%, Teamwork 15%
    const finalScore = (
      (dataAccuracy * 0.60) +
      (speedScore * 0.10) +
      (sourceQuality * 0.15) +
      (teamworkScore * 0.15)
    );
    
    return {
      total: Math.round(finalScore),
      breakdown: {
        data_accuracy: Math.round(dataAccuracy),
        speed: Math.round(speedScore),
        source_quality: Math.round(sourceQuality),
        teamwork: Math.round(teamworkScore)
      }
    };
    
  } catch (error) {
    console.error("Error calculating scores:", error);
    return {
      total: 0,
      breakdown: {
        data_accuracy: 0,
        speed: 0,
        source_quality: 0,
        teamwork: 0
      }
    };
  }
};

const getBattleTypeFromId = (battleId) => {
  const battleMap = {
    'leadership_recon': 1,
    'product_arsenal': 2,
    'funding_fortification': 3,
    'customer_frontlines': 4,
    'alliance_forge': 5
  };
  return battleMap[battleId] || 1;
};
