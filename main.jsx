import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App.js'
import './index.css'

// Import the sample company reference data and initialize it
import { companyReferenceEntity } from './Entities/all.js'

// Sample company reference data
const sampleData = {
  "company_name": "Fawry for Banking Technology and Electronic Payments S.A.E.",
  "company_description": "Egypt's leading provider of electronic payment solutions and digital financial services",
  "battle_1_leadership": {
    "founders": [
      {
        "full_name": "Ashraf Sabry",
        "founding_year": "2008",
        "current_role": "Founder and CEO",
        "previous_ventures": "Previously worked at IBM and other technology companies",
        "linkedin_url": "https://linkedin.com/in/ashraf-sabry",
        "notes": "Leading digital transformation in Egypt's financial sector"
      }
    ],
    "key_executives": [
      {
        "name": "Ahmed El Sobky",
        "title": "Chief Operating Officer",
        "function": "Operations",
        "years_with_firm": "8",
        "linkedin_url": "https://linkedin.com/in/ahmed-el-sobky",
        "notes": "Oversees day-to-day operations and business development"
      }
    ],
    "market_share": {
      "tam_usd": "15 Billion",
      "sam_usd": "3 Billion",
      "som_usd": "500 Million",
      "annual_growth_rate": "25",
      "competitive_rank": 1,
      "company_share_percentage": "45",
      "differentiators": "First-mover advantage in Egypt, comprehensive payment ecosystem, strong government partnerships"
    },
    "geographic_footprint": [
      {
        "location": "Cairo, Egypt",
        "opened_year": "2008",
        "facility_type": "Headquarters",
        "notes": "Main corporate headquarters and technology center"
      }
    ]
  },
  "battle_2_products": {
    "product_lines": [
      {
        "product_name": "Fawry Plus",
        "product_type": "Mobile Payment App",
        "launch_date": "2019",
        "category": "Fintech",
        "target_segment": "Consumers",
        "key_features": "Bill payments, mobile top-ups, online shopping, peer-to-peer transfers",
        "pricing_model": "Transaction fees",
        "reviews_score": "4.2",
        "primary_competitors": "Vodafone Cash, Orange Money, Etisalat Cash"
      }
    ],
    "social_presence": [
      {
        "platform_name": "Facebook",
        "page_link": "https://facebook.com/FawryOfficial",
        "followers": "2.5M",
        "engagement_rate": "3.5",
        "running_ads": "15"
      }
    ]
  },
  "battle_3_funding": {
    "total_funding": {
      "amount_usd": "100 Million",
      "number_of_rounds": 3
    },
    "funding_rounds": [
      {
        "date": "2019",
        "series": "Series C",
        "amount_usd": "50 Million",
        "number_of_investors": 5,
        "lead_investor": "Helios Investment Partners",
        "notes": "Used for regional expansion and technology development"
      }
    ],
    "investors": [
      {
        "name": "Helios Investment Partners",
        "type": "PE",
        "stake_percentage": "35",
        "notes": "Lead investor with significant stake"
      }
    ],
    "revenue_valuation": {
      "revenue_usd": "150 Million",
      "growth_rate": "30",
      "latest_valuation_usd": "800 Million",
      "notes": "Strong growth trajectory with expanding market presence"
    }
  },
  "battle_4_customers": {
    "b2c_segments": [
      {
        "age_range": "25-45",
        "income_level": "Middle to High",
        "educational_level": "Bachelor's and above",
        "interests_lifestyle": "Tech-savvy, urban professionals, digital natives",
        "behavior": "Frequent mobile app users, prefer digital transactions",
        "needs_pain_points": "Need for convenient payment solutions, security concerns",
        "location": "Urban Egypt",
        "revenue_share_percentage": "60"
      }
    ],
    "b2b_segments": [
      {
        "business_size": "SME to Enterprise",
        "industry": "Retail, Telecom, Utilities",
        "revenue_of_targeted_company": "10M - 100M USD",
        "technographic": "Digital-first businesses with online presence",
        "behavior": "Seek integrated payment solutions for customer convenience",
        "needs_pain_points": "Need for reliable payment infrastructure, compliance requirements",
        "revenue_share_percentage": "40"
      }
    ],
    "reviews_overview": {
      "avg_rating": "4.1",
      "positive_percentage": "78",
      "negative_percentage": "22",
      "common_themes": "Convenience, reliability, user-friendly interface, occasional technical issues"
    },
    "pain_points": [
      {
        "description": "Occasional app crashes during peak usage times",
        "impact": "Medium",
        "frequency": "Weekly",
        "suggested_fix": "Improve server capacity and app stability"
      }
    ]
  },
  "battle_5_partnerships": {
    "strategic_partners": [
      {
        "name": "Vodafone Egypt",
        "type": "Technology",
        "region": "Egypt",
        "start_date": "2018",
        "notes": "Mobile payment integration and customer acquisition"
      }
    ],
    "key_suppliers": [
      {
        "name": "IBM",
        "commodity": "Technology Infrastructure",
        "region": "Global",
        "contract_value": "20 Million USD"
      }
    ],
    "growth_rates": [
      {
        "period": "2023",
        "revenue_growth_percentage": "30",
        "user_growth_percentage": "45"
      }
    ],
    "expansions": [
      {
        "type": "Geographic",
        "region_market": "Saudi Arabia",
        "date": "2024",
        "investment": "25 Million USD",
        "notes": "Planned expansion into Saudi market"
      }
    ]
  }
};

// Initialize sample data
async function initializeSampleData() {
  try {
    // Check if we already have data
    const existingData = await companyReferenceEntity.getAll();
    if (existingData.length === 0) {
      await companyReferenceEntity.create(sampleData);
      console.log('Sample company reference data initialized');
    }
  } catch (error) {
    console.error('Failed to initialize sample data:', error);
  }
}

// Initialize the app
async function initializeApp() {
  await initializeSampleData();
  
  ReactDOM.createRoot(document.getElementById('root')).render(
    <React.StrictMode>
      <App />
    </React.StrictMode>,
  )
}

initializeApp();
