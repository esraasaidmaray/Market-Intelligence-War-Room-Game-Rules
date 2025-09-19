
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
        // Leadership Recon - Founders
        founder1_full_name: 'founders.0.full_name',
        founder1_founding_year: 'founders.0.founding_year',
        founder1_current_role: 'founders.0.current_role',
        founder1_previous_ventures: 'founders.0.previous_ventures',
        founder1_linkedin_url: 'founders.0.linkedin_url',
        
        // Leadership Recon - Key Executives
        exec1_name: 'key_executives.0.name',
        exec1_title: 'key_executives.0.title',
        exec1_function: 'key_executives.0.function',
        exec1_years_with_firm: 'key_executives.0.years_with_firm',
        exec1_linkedin_url: 'key_executives.0.linkedin_url',
        
        // Leadership Recon - Market Share
        tam_usd: 'market_share.tam_usd',
        sam_usd: 'market_share.sam_usd',
        som_usd: 'market_share.som_usd',
        annual_growth_rate: 'market_share.annual_growth_rate',
        competitive_rank: 'market_share.competitive_rank',
        company_share_percentage: 'market_share.company_share_percentage',
        differentiators: 'market_share.differentiators',
        
        // Leadership Recon - Geographic Footprint
        office1_location: 'geographic_footprint.0.location',
        office1_opened_year: 'geographic_footprint.0.opened_year',
        office1_facility_type: 'geographic_footprint.0.facility_type',
        
        // Product Arsenal - Products
        product1_name: 'product_lines.0.product_name',
        product1_type: 'product_lines.0.product_type',
        product1_launch_date: 'product_lines.0.launch_date',
        product1_category: 'product_lines.0.category',
        product1_target_segment: 'product_lines.0.target_segment',
        product1_key_features: 'product_lines.0.key_features',
        product1_pricing_model: 'product_lines.0.pricing_model',
        product1_reviews_score: 'product_lines.0.reviews_score',
        product1_competitors: 'product_lines.0.primary_competitors',
        
        // Product Arsenal - Social Presence
        platform1_name: 'social_presence.0.platform_name',
        platform1_page_link: 'social_presence.0.page_link',
        platform1_followers: 'social_presence.0.followers',
        platform1_engagement_rate: 'social_presence.0.engagement_rate',
        platform1_running_ads: 'social_presence.0.running_ads',
        
        // Funding Fortification - Investment Overview
        total_funding_amount: 'total_funding.amount_usd',
        total_funding_rounds: 'total_funding.number_of_rounds',
        received_investment: 'total_funding.number_of_rounds > 0 ? "Yes" : "No"',
        
        // Funding Fortification - Funding Rounds
        round1_date: 'funding_rounds.0.date',
        round1_series: 'funding_rounds.0.series',
        round1_amount: 'funding_rounds.0.amount_usd',
        round1_investors_count: 'funding_rounds.0.number_of_investors',
        round1_lead_investor: 'funding_rounds.0.lead_investor',
        
        // Funding Fortification - Investors
        investor1_name: 'investors.0.name',
        investor1_type: 'investors.0.type',
        investor1_stake: 'investors.0.stake_percentage',
        
        // Funding Fortification - Revenue & Valuation
        revenue_usd: 'revenue_valuation.revenue_usd',
        revenue_growth_rate: 'revenue_valuation.growth_rate',
        latest_valuation: 'revenue_valuation.latest_valuation_usd',
        
        // Customer Frontlines - B2C Segments
        b2c_persona1_age: 'b2c_segments.0.age_range',
        b2c_persona1_income: 'b2c_segments.0.income_level',
        b2c_persona1_education: 'b2c_segments.0.educational_level',
        b2c_persona1_interests: 'b2c_segments.0.interests_lifestyle',
        b2c_persona1_behavior: 'b2c_segments.0.behavior',
        b2c_persona1_pain_points: 'b2c_segments.0.needs_pain_points',
        b2c_persona1_location: 'b2c_segments.0.location',
        b2c_persona1_revenue_share: 'b2c_segments.0.revenue_share_percentage',
        
        // Customer Frontlines - B2B Segments
        b2b_segment1_business_size: 'b2b_segments.0.business_size',
        b2b_segment1_industry: 'b2b_segments.0.industry',
        b2b_segment1_revenue: 'b2b_segments.0.revenue_of_targeted_company',
        b2b_segment1_technographic: 'b2b_segments.0.technographic',
        b2b_segment1_behavior: 'b2b_segments.0.behavior',
        b2b_segment1_pain_points: 'b2b_segments.0.needs_pain_points',
        b2b_segment1_revenue_share: 'b2b_segments.0.revenue_share_percentage',
        
        // Customer Frontlines - Reviews
        reviews_avg_rating: 'reviews_overview.avg_rating',
        reviews_positive_percentage: 'reviews_overview.positive_percentage',
        reviews_negative_percentage: 'reviews_overview.negative_percentage',
        reviews_common_themes: 'reviews_overview.common_themes',
        
        // Customer Frontlines - Pain Points
        pain_point1_description: 'pain_points.0.description',
        pain_point1_impact: 'pain_points.0.impact',
        pain_point1_frequency: 'pain_points.0.frequency',
        pain_point1_suggested_fix: 'pain_points.0.suggested_fix',
        
        // Alliance Forge - Strategic Partners
        partner1_name: 'strategic_partners.0.name',
        partner1_type: 'strategic_partners.0.type',
        partner1_region: 'strategic_partners.0.region',
        partner1_start_date: 'strategic_partners.0.start_date',
        
        // Alliance Forge - Key Suppliers
        supplier1_name: 'key_suppliers.0.name',
        supplier1_commodity: 'key_suppliers.0.commodity',
        supplier1_region: 'key_suppliers.0.region',
        supplier1_contract_value: 'key_suppliers.0.contract_value',
        
        // Alliance Forge - Growth Rates
        growth_period: 'growth_rates.0.period',
        revenue_growth_percentage: 'growth_rates.0.revenue_growth_percentage',
        user_growth_percentage: 'growth_rates.0.user_growth_percentage',
        
        // Alliance Forge - Expansions
        expansion1_type: 'expansions.0.type',
        expansion1_region_market: 'expansions.0.region_market',
        expansion1_date: 'expansions.0.date',
        expansion1_investment: 'expansions.0.investment',
    };
    
    const path = keyMap[fieldKey];
    if (!path) return null;
    
    // Handle special cases
    if (path.includes('> 0')) {
        const basePath = path.split('> 0')[0].trim();
        const value = getNestedValue(referenceData, basePath);
        return value > 0 ? "Yes" : "No";
    }
    
    return getNestedValue(referenceData, path);
};

const getNestedValue = (obj, path) => {
    let current = obj;
    const parts = path.split('.');

    for (let i = 0; i < parts.length; i++) {
        const part = parts[i];
        if (current && current[part] !== undefined) {
            current = current[part];
        } else {
            return null;
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
