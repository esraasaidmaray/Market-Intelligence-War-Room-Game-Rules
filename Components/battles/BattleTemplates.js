import React from "react";

// Complete Battle template configurations matching the provided Market Intelligence Capture Template
export const BATTLE_TEMPLATES = {
  leadership_recon: {
    name: "Leadership Recon & Market Dominance",
    description: "Intelligence gathering on company founders, key executives, and market positioning",
    fields: [
      // Leadership - Founders Section
      {
        id: "founder1_full_name",
        label: "Founder 1 - Full Name",
        type: "text",
        required: true,
        section: "Leadership - Founders",
        placeholder: "Enter founder's complete name"
      },
      {
        id: "founder1_founding_year",
        label: "Founder 1 - Founding Year",
        type: "number",
        required: true,
        section: "Leadership - Founders",
        placeholder: "YYYY"
      },
      {
        id: "founder1_current_role",
        label: "Founder 1 - Current Role",
        type: "text",
        required: true,
        section: "Leadership - Founders",
        placeholder: "e.g., Founder and CEO"
      },
      {
        id: "founder1_previous_ventures",
        label: "Founder 1 - Previous Ventures",
        type: "textarea",
        required: false,
        section: "Leadership - Founders",
        placeholder: "List any previous companies founded or co-founded"
      },
      {
        id: "founder1_contact_email",
        label: "Founder 1 - Contact Email",
        type: "email",
        required: false,
        section: "Leadership - Founders",
        placeholder: "If publicly available"
      },
      {
        id: "founder1_linkedin_url",
        label: "Founder 1 - LinkedIn URL",
        type: "url",
        required: false,
        section: "Leadership - Founders",
        placeholder: "LinkedIn profile URL"
      },
      {
        id: "founder1_source_link",
        label: "Founder 1 - Source Link",
        type: "url",
        required: true,
        section: "Leadership - Founders",
        placeholder: "Primary source for this information"
      },
      
      // Key Executives Section
      {
        id: "exec1_name",
        label: "Executive 1 - Name",
        type: "text",
        required: true,
        section: "Leadership - Key Executives",
        placeholder: "Name of key executive (not founder)"
      },
      {
        id: "exec1_title",
        label: "Executive 1 - Title",
        type: "text",
        required: true,
        section: "Leadership - Key Executives",
        placeholder: "e.g., Managing Director, CTO"
      },
      {
        id: "exec1_function",
        label: "Executive 1 - Function",
        type: "text",
        required: true,
        section: "Leadership - Key Executives",
        placeholder: "Primary business function"
      },
      {
        id: "exec1_years_with_firm",
        label: "Executive 1 - Years with Firm",
        type: "text",
        required: false,
        section: "Leadership - Key Executives",
        placeholder: "Approximate years with company"
      },
      {
        id: "exec1_linkedin_url",
        label: "Executive 1 - LinkedIn URL",
        type: "url",
        required: false,
        section: "Leadership - Key Executives",
        placeholder: "LinkedIn profile URL"
      },
      {
        id: "exec1_source_link",
        label: "Executive 1 - Source Link",
        type: "url",
        required: true,
        section: "Leadership - Key Executives",
        placeholder: "Primary source for this information"
      },
      
      // Market Share Section
      {
        id: "tam_usd",
        label: "TAM (Total Addressable Market) USD",
        type: "text",
        required: true,
        section: "Market Share - Market Size",
        placeholder: "e.g., 10 Billion"
      },
      {
        id: "sam_usd",
        label: "SAM (Serviceable Addressable Market) USD",
        type: "text",
        required: true,
        section: "Market Share - Market Size",
        placeholder: "e.g., 5 Billion"
      },
      {
        id: "som_usd",
        label: "SOM (Serviceable Obtainable Market) USD",
        type: "text",
        required: true,
        section: "Market Share - Market Size",
        placeholder: "e.g., 1 Billion"
      },
      {
        id: "annual_growth_rate",
        label: "Annual Growth Rate (%)",
        type: "number",
        required: true,
        section: "Market Share - Market Size",
        placeholder: "Annual market growth percentage"
      },
      {
        id: "market_size_source_link",
        label: "Market Size - Source Link",
        type: "url",
        required: true,
        section: "Market Share - Market Size",
        placeholder: "Source for market size data"
      },
      
      // Competitive Position
      {
        id: "competitive_rank",
        label: "Competitive Rank",
        type: "number",
        required: true,
        section: "Market Share - Competitive Position",
        placeholder: "Company rank in market (1, 2, 3, etc.)"
      },
      {
        id: "company_share_percentage",
        label: "Company Market Share (%)",
        type: "number",
        required: true,
        section: "Market Share - Competitive Position",
        placeholder: "Company's market share percentage"
      },
      {
        id: "differentiators",
        label: "Key Differentiators",
        type: "textarea",
        required: true,
        section: "Market Share - Competitive Position",
        placeholder: "What sets this company apart from competitors"
      },
      {
        id: "competitive_source_link",
        label: "Competitive Position - Source Link",
        type: "url",
        required: true,
        section: "Market Share - Competitive Position",
        placeholder: "Source for competitive data"
      },
      
      // Geographic Footprint
      {
        id: "office1_location",
        label: "Office 1 - Location",
        type: "text",
        required: true,
        section: "Geographic Footprint",
        placeholder: "City, Country"
      },
      {
        id: "office1_opened_year",
        label: "Office 1 - Opened Year",
        type: "number",
        required: true,
        section: "Geographic Footprint",
        placeholder: "Year office opened"
      },
      {
        id: "office1_facility_type",
        label: "Office 1 - Facility Type",
        type: "text",
        required: true,
        section: "Geographic Footprint",
        placeholder: "e.g., Headquarters, Regional Office, Store"
      },
      {
        id: "office1_source_link",
        label: "Office 1 - Source Link",
        type: "url",
        required: true,
        section: "Geographic Footprint",
        placeholder: "Source for location data"
      }
    ],
    tools: [
      { name: "LinkedIn Sales Navigator", url: "https://www.linkedin.com/sales/navigator" },
      { name: "Crunchbase", url: "https://www.crunchbase.com" },
      { name: "PitchBook", url: "https://pitchbook.com" },
      { name: "BoardEx", url: "https://www.boardex.com" },
      { name: "ZoomInfo", url: "https://www.zoominfo.com" },
      { name: "Phantombuster", url: "https://phantombuster.com" },
      { name: "RocketReach", url: "https://rocketreach.co" },
      { name: "IBISWorld", url: "https://www.ibisworld.com" },
      { name: "Statista", url: "https://www.statista.com" },
      { name: "Euromonitor", url: "https://www.euromonitor.com" },
      { name: "Gartner", url: "https://www.gartner.com" },
      { name: "Forrester", url: "https://www.forrester.com" },
      { name: "Google Maps", url: "https://maps.google.com" }
    ]
  },

  product_arsenal: {
    name: "Product Arsenal & Social Signals Strike",
    description: "Analysis of company products, services, pricing, and social media presence",
    fields: [
      // Products/Services Section
      {
        id: "product1_name",
        label: "Product 1 - Product Name",
        type: "text",
        required: true,
        section: "Products/Services",
        placeholder: "Name of main product or service"
      },
      {
        id: "product1_type",
        label: "Product 1 - Product Type",
        type: "text",
        required: true,
        section: "Products/Services",
        placeholder: "e.g., Software, Hardware, Service"
      },
      {
        id: "product1_launch_date",
        label: "Product 1 - Launch Date",
        type: "date",
        required: true,
        section: "Products/Services",
        placeholder: "When product was launched"
      },
      {
        id: "product1_category",
        label: "Product 1 - Category",
        type: "text",
        required: true,
        section: "Products/Services",
        placeholder: "e.g., Fintech, E-commerce, SaaS"
      },
      {
        id: "product1_target_segment",
        label: "Product 1 - Target Segment",
        type: "text",
        required: true,
        section: "Products/Services",
        placeholder: "e.g., SMEs, Consumers, Enterprise"
      },
      {
        id: "product1_key_features",
        label: "Product 1 - Key Features",
        type: "textarea",
        required: true,
        section: "Products/Services",
        placeholder: "List main features or capabilities"
      },
      {
        id: "product1_pricing_model",
        label: "Product 1 - Pricing Model",
        type: "text",
        required: true,
        section: "Products/Services",
        placeholder: "e.g., Transaction fees, Subscription, Freemium"
      },
      {
        id: "product1_price",
        label: "Product 1 - Price",
        type: "text",
        required: false,
        section: "Products/Services",
        placeholder: "Specific pricing if available"
      },
      {
        id: "product1_reviews_score",
        label: "Product 1 - Reviews Score",
        type: "number",
        required: false,
        section: "Products/Services",
        placeholder: "Average review score (e.g., 4.5 out of 5)"
      },
      {
        id: "product1_competitors",
        label: "Product 1 - Primary Competitors",
        type: "text",
        required: true,
        section: "Products/Services",
        placeholder: "Main competing products/companies"
      },
      {
        id: "product1_source_link",
        label: "Product 1 - Source Link",
        type: "url",
        required: true,
        section: "Products/Services",
        placeholder: "Primary source for product information"
      },

      // Pricing Changes
      {
        id: "pricing_change1_date",
        label: "Pricing Change 1 - Date",
        type: "date",
        required: false,
        section: "Pricing Changes",
        placeholder: "Date of pricing change"
      },
      {
        id: "pricing_change1_old_price",
        label: "Pricing Change 1 - Old Price",
        type: "text",
        required: false,
        section: "Pricing Changes",
        placeholder: "Previous price"
      },
      {
        id: "pricing_change1_new_price",
        label: "Pricing Change 1 - New Price",
        type: "text",
        required: false,
        section: "Pricing Changes",
        placeholder: "New price"
      },
      {
        id: "pricing_change1_reason",
        label: "Pricing Change 1 - Reason",
        type: "text",
        required: false,
        section: "Pricing Changes",
        placeholder: "Reason for price change"
      },

      // Social Presence
      {
        id: "platform1_name",
        label: "Platform 1 - Platform Name",
        type: "text",
        required: true,
        section: "Social Presence",
        placeholder: "e.g., LinkedIn, Facebook, Twitter"
      },
      {
        id: "platform1_page_link",
        label: "Platform 1 - Page Link",
        type: "url",
        required: true,
        section: "Social Presence",
        placeholder: "URL to company's social media page"
      },
      {
        id: "platform1_followers",
        label: "Platform 1 - Followers",
        type: "number",
        required: true,
        section: "Social Presence",
        placeholder: "Number of followers"
      },
      {
        id: "platform1_engagement_rate",
        label: "Platform 1 - Engagement Rate (%)",
        type: "number",
        required: false,
        section: "Social Presence",
        placeholder: "Average engagement rate"
      },
      {
        id: "platform1_running_ads",
        label: "Platform 1 - Number of Running Ads",
        type: "number",
        required: false,
        section: "Social Presence",
        placeholder: "Current active advertisements"
      },

      // Influencer Partnerships
      {
        id: "influencer1_name",
        label: "Influencer 1 - Name",
        type: "text",
        required: false,
        section: "Influencer Partnerships",
        placeholder: "Influencer's name"
      },
      {
        id: "influencer1_followers",
        label: "Influencer 1 - Total Followers",
        type: "number",
        required: false,
        section: "Influencer Partnerships",
        placeholder: "Total follower count"
      },
      {
        id: "influencer1_platforms",
        label: "Influencer 1 - Platforms",
        type: "text",
        required: false,
        section: "Influencer Partnerships",
        placeholder: "Social platforms they're active on"
      },
      {
        id: "influencer1_campaign",
        label: "Influencer 1 - Campaign",
        type: "text",
        required: false,
        section: "Influencer Partnerships",
        placeholder: "Description of partnership campaign"
      }
    ],
    tools: [
      { name: "Company Website", url: "#" },
      { name: "Trustpilot", url: "https://www.trustpilot.com" },
      { name: "G2", url: "https://www.g2.com" },
      { name: "USPTO Patent Database", url: "https://www.uspto.gov" },
      { name: "SEMrush", url: "https://www.semrush.com" },
      { name: "Social Blade", url: "https://socialblade.com" },
      { name: "BuzzSumo", url: "https://buzzsumo.com" },
      { name: "Meta Ads Library", url: "https://www.facebook.com/ads/library" },
      { name: "Brandwatch", url: "https://www.brandwatch.com" }
    ]
  },

  funding_fortification: {
    name: "Funding Fortification",
    description: "Financial intelligence on funding rounds, investors, revenue, and valuation",
    fields: [
      // Investment Overview
      {
        id: "total_funding_amount",
        label: "Total Funding Amount (USD)",
        type: "text",
        required: true,
        section: "Investment Overview",
        placeholder: "Total funding raised (e.g., 50 Million)"
      },
      {
        id: "total_funding_rounds",
        label: "Number of Funding Rounds",
        type: "number",
        required: true,
        section: "Investment Overview",
        placeholder: "Total number of funding rounds"
      },
      {
        id: "received_investment",
        label: "Has Received Investment?",
        type: "select",
        options: ["Yes", "No"],
        required: true,
        section: "Investment Overview",
        placeholder: "Yes or No"
      },
      {
        id: "investment_source_link",
        label: "Investment Overview - Source Link",
        type: "url",
        required: true,
        section: "Investment Overview",
        placeholder: "Source for investment data"
      },

      // Funding Rounds
      {
        id: "round1_date",
        label: "Round 1 - Date",
        type: "date",
        required: true,
        section: "Funding Rounds",
        placeholder: "Date of funding round"
      },
      {
        id: "round1_series",
        label: "Round 1 - Series",
        type: "text",
        required: true,
        section: "Funding Rounds",
        placeholder: "e.g., Seed, Series A, IPO"
      },
      {
        id: "round1_amount",
        label: "Round 1 - Amount (USD)",
        type: "text",
        required: true,
        section: "Funding Rounds",
        placeholder: "Funding amount"
      },
      {
        id: "round1_investors_count",
        label: "Round 1 - Number of Investors",
        type: "number",
        required: true,
        section: "Funding Rounds",
        placeholder: "Number of participating investors"
      },
      {
        id: "round1_lead_investor",
        label: "Round 1 - Lead Investor",
        type: "text",
        required: true,
        section: "Funding Rounds",
        placeholder: "Name of lead investor"
      },

      {
        id: "round2_date",
        label: "Round 2 - Date",
        type: "date",
        required: false,
        section: "Funding Rounds",
        placeholder: "Date of second funding round"
      },
      {
        id: "round2_series",
        label: "Round 2 - Series",
        type: "text",
        required: false,
        section: "Funding Rounds",
        placeholder: "e.g., Series B, Series C"
      },
      {
        id: "round2_amount",
        label: "Round 2 - Amount (USD)",
        type: "text",
        required: false,
        section: "Funding Rounds",
        placeholder: "Funding amount"
      },

      // Investors
      {
        id: "investor1_name",
        label: "Investor 1 - Name",
        type: "text",
        required: true,
        section: "Investors",
        placeholder: "Investor/VC firm name"
      },
      {
        id: "investor1_type",
        label: "Investor 1 - Type",
        type: "select",
        options: ["VC", "PE", "Angel", "Corporate", "Government"],
        required: true,
        section: "Investors",
        placeholder: "Type of investor"
      },
      {
        id: "investor1_stake",
        label: "Investor 1 - Stake (%)",
        type: "text",
        required: false,
        section: "Investors",
        placeholder: "Ownership percentage if known"
      },
      {
        id: "investor1_source_link",
        label: "Investor 1 - Source Link",
        type: "url",
        required: true,
        section: "Investors",
        placeholder: "Source for investor information"
      },

      {
        id: "investor2_name",
        label: "Investor 2 - Name",
        type: "text",
        required: false,
        section: "Investors",
        placeholder: "Second investor name"
      },
      {
        id: "investor2_type",
        label: "Investor 2 - Type",
        type: "select",
        options: ["VC", "PE", "Angel", "Corporate", "Government"],
        required: false,
        section: "Investors",
        placeholder: "Type of investor"
      },

      // Revenue & Valuation
      {
        id: "revenue_usd",
        label: "Revenue (USD)",
        type: "text",
        required: true,
        section: "Revenue & Valuation",
        placeholder: "Annual revenue if publicly available"
      },
      {
        id: "revenue_growth_rate",
        label: "Revenue Growth Rate (%)",
        type: "number",
        required: true,
        section: "Revenue & Valuation",
        placeholder: "Annual revenue growth percentage"
      },
      {
        id: "latest_valuation",
        label: "Latest Valuation (USD)",
        type: "text",
        required: true,
        section: "Revenue & Valuation",
        placeholder: "Most recent company valuation"
      },
      {
        id: "valuation_source_link",
        label: "Revenue & Valuation - Source Link",
        type: "url",
        required: true,
        section: "Revenue & Valuation",
        placeholder: "Source for financial data"
      }
    ],
    tools: [
      { name: "Crunchbase", url: "https://www.crunchbase.com" },
      { name: "PitchBook", url: "https://pitchbook.com" },
      { name: "SEC Filings", url: "https://www.sec.gov/edgar" },
      { name: "Company Annual Reports", url: "#" },
      { name: "Tracxn", url: "https://tracxn.com" },
      { name: "Reuters", url: "https://www.reuters.com" },
      { name: "Bloomberg", url: "https://www.bloomberg.com" }
    ]
  },

  customer_frontlines: {
    name: "Customer Frontlines",
    description: "Customer segment analysis, reviews, and pain point identification",
    fields: [
      // B2C Segments
      {
        id: "b2c_persona1_age",
        label: "B2C Persona 1 - Age Range",
        type: "text",
        required: true,
        section: "B2C Customer Segments",
        placeholder: "e.g., 18-35, 25-45"
      },
      {
        id: "b2c_persona1_income",
        label: "B2C Persona 1 - Income Level",
        type: "text",
        required: true,
        section: "B2C Customer Segments",
        placeholder: "e.g., Low, Middle, High"
      },
      {
        id: "b2c_persona1_education",
        label: "B2C Persona 1 - Educational Level",
        type: "text",
        required: true,
        section: "B2C Customer Segments",
        placeholder: "e.g., High School, Bachelor's, Graduate"
      },
      {
        id: "b2c_persona1_interests",
        label: "B2C Persona 1 - Interests & Lifestyle",
        type: "textarea",
        required: true,
        section: "B2C Customer Segments",
        placeholder: "Key interests, lifestyle characteristics"
      },
      {
        id: "b2c_persona1_behavior",
        label: "B2C Persona 1 - Behavior",
        type: "textarea",
        required: true,
        section: "B2C Customer Segments",
        placeholder: "Usage patterns, buying behavior"
      },
      {
        id: "b2c_persona1_pain_points",
        label: "B2C Persona 1 - Needs/Pain Points",
        type: "textarea",
        required: true,
        section: "B2C Customer Segments",
        placeholder: "Primary needs and pain points"
      },
      {
        id: "b2c_persona1_location",
        label: "B2C Persona 1 - Location",
        type: "text",
        required: true,
        section: "B2C Customer Segments",
        placeholder: "Geographic location/region"
      },
      {
        id: "b2c_persona1_revenue_share",
        label: "B2C Persona 1 - Revenue Share (%)",
        type: "number",
        required: true,
        section: "B2C Customer Segments",
        placeholder: "Percentage of total revenue"
      },
      {
        id: "b2c_persona1_source_link",
        label: "B2C Persona 1 - Source Link",
        type: "url",
        required: true,
        section: "B2C Customer Segments",
        placeholder: "Source for customer data"
      },

      // B2B Segments
      {
        id: "b2b_segment1_business_size",
        label: "B2B Segment 1 - Business Size",
        type: "text",
        required: true,
        section: "B2B Customer Segments",
        placeholder: "e.g., SME, Mid-market, Enterprise"
      },
      {
        id: "b2b_segment1_industry",
        label: "B2B Segment 1 - Industry",
        type: "text",
        required: true,
        section: "B2B Customer Segments",
        placeholder: "e.g., Retail, Healthcare, Manufacturing"
      },
      {
        id: "b2b_segment1_revenue",
        label: "B2B Segment 1 - Revenue of Targeted Companies",
        type: "text",
        required: true,
        section: "B2B Customer Segments",
        placeholder: "Revenue range of target companies"
      },
      {
        id: "b2b_segment1_technographic",
        label: "B2B Segment 1 - Technographic",
        type: "text",
        required: true,
        section: "B2B Customer Segments",
        placeholder: "Technology stack, digital maturity"
      },
      {
        id: "b2b_segment1_behavior",
        label: "B2B Segment 1 - Behavior",
        type: "textarea",
        required: true,
        section: "B2B Customer Segments",
        placeholder: "Buying behavior, decision-making process"
      },
      {
        id: "b2b_segment1_pain_points",
        label: "B2B Segment 1 - Needs/Pain Points",
        type: "textarea",
        required: true,
        section: "B2B Customer Segments",
        placeholder: "Business needs and pain points"
      },
      {
        id: "b2b_segment1_revenue_share",
        label: "B2B Segment 1 - Revenue Share (%)",
        type: "number",
        required: true,
        section: "B2B Customer Segments",
        placeholder: "Percentage of total revenue"
      },
      {
        id: "b2b_segment1_source_link",
        label: "B2B Segment 1 - Source Link",
        type: "url",
        required: true,
        section: "B2B Customer Segments",
        placeholder: "Source for business customer data"
      },

      // Reviews Overview
      {
        id: "reviews_avg_rating",
        label: "Average Rating",
        type: "number",
        required: true,
        section: "Reviews Overview",
        placeholder: "Average customer rating (e.g., 4.2)"
      },
      {
        id: "reviews_positive_percentage",
        label: "Positive Reviews (%)",
        type: "number",
        required: true,
        section: "Reviews Overview",
        placeholder: "Percentage of positive reviews"
      },
      {
        id: "reviews_negative_percentage",
        label: "Negative Reviews (%)",
        type: "number",
        required: true,
        section: "Reviews Overview",
        placeholder: "Percentage of negative reviews"
      },
      {
        id: "reviews_common_themes",
        label: "Common Review Themes",
        type: "textarea",
        required: true,
        section: "Reviews Overview",
        placeholder: "Most frequently mentioned themes in reviews"
      },
      {
        id: "reviews_source_link",
        label: "Reviews - Source Link",
        type: "url",
        required: true,
        section: "Reviews Overview",
        placeholder: "Source for review data"
      },

      // Pain Points
      {
        id: "pain_point1_description",
        label: "Pain Point 1 - Description",
        type: "textarea",
        required: true,
        section: "Customer Pain Points",
        placeholder: "Detailed description of the pain point"
      },
      {
        id: "pain_point1_impact",
        label: "Pain Point 1 - Impact",
        type: "text",
        required: true,
        section: "Customer Pain Points",
        placeholder: "e.g., High, Medium, Low"
      },
      {
        id: "pain_point1_frequency",
        label: "Pain Point 1 - Frequency",
        type: "text",
        required: true,
        section: "Customer Pain Points",
        placeholder: "How often this issue occurs"
      },
      {
        id: "pain_point1_suggested_fix",
        label: "Pain Point 1 - Suggested Fix",
        type: "textarea",
        required: false,
        section: "Customer Pain Points",
        placeholder: "Potential solutions or improvements"
      },
      {
        id: "pain_point1_source_link",
        label: "Pain Point 1 - Source Link",
        type: "url",
        required: true,
        section: "Customer Pain Points",
        placeholder: "Source identifying this pain point"
      }
    ],
    tools: [
      { name: "Customer Surveys", url: "#" },
      { name: "Trustpilot", url: "https://www.trustpilot.com" },
      { name: "G2", url: "https://www.g2.com" },
      { name: "Google Reviews", url: "https://www.google.com/business" },
      { name: "App Store Reviews", url: "https://www.apple.com/app-store" },
      { name: "Google Play Reviews", url: "https://play.google.com/console" },
      { name: "Customer Interview Tools", url: "#" },
      { name: "Analytics Platforms", url: "#" }
    ]
  },

  alliance_forge: {
    name: "Alliance Forge & Growth Offensive",
    description: "Partnership ecosystem, supply chain analysis, and growth trajectory mapping",
    fields: [
      // Strategic Partners
      {
        id: "partner1_name",
        label: "Strategic Partner 1 - Name",
        type: "text",
        required: true,
        section: "Strategic Partners",
        placeholder: "Name of key strategic partner"
      },
      {
        id: "partner1_type",
        label: "Strategic Partner 1 - Type",
        type: "text",
        required: true,
        section: "Strategic Partners",
        placeholder: "e.g., Technology, Distribution, Joint Venture"
      },
      {
        id: "partner1_region",
        label: "Strategic Partner 1 - Region",
        type: "text",
        required: true,
        section: "Strategic Partners",
        placeholder: "Geographic focus of partnership"
      },
      {
        id: "partner1_start_date",
        label: "Strategic Partner 1 - Start Date",
        type: "date",
        required: true,
        section: "Strategic Partners",
        placeholder: "When partnership began"
      },
      {
        id: "partner1_source_link",
        label: "Strategic Partner 1 - Source Link",
        type: "url",
        required: true,
        section: "Strategic Partners",
        placeholder: "Source for partnership information"
      },

      {
        id: "partner2_name",
        label: "Strategic Partner 2 - Name",
        type: "text",
        required: false,
        section: "Strategic Partners",
        placeholder: "Name of second strategic partner"
      },
      {
        id: "partner2_type",
        label: "Strategic Partner 2 - Type",
        type: "text",
        required: false,
        section: "Strategic Partners",
        placeholder: "Type of partnership"
      },
      {
        id: "partner2_region",
        label: "Strategic Partner 2 - Region",
        type: "text",
        required: false,
        section: "Strategic Partners",
        placeholder: "Geographic focus"
      },

      // Key Suppliers
      {
        id: "supplier1_name",
        label: "Key Supplier 1 - Name",
        type: "text",
        required: true,
        section: "Key Suppliers",
        placeholder: "Name of major supplier"
      },
      {
        id: "supplier1_commodity",
        label: "Key Supplier 1 - Commodity",
        type: "text",
        required: true,
        section: "Key Suppliers",
        placeholder: "e.g., Chips, Raw Materials, Software"
      },
      {
        id: "supplier1_region",
        label: "Key Supplier 1 - Region",
        type: "text",
        required: true,
        section: "Key Suppliers",
        placeholder: "Supplier's geographic location"
      },
      {
        id: "supplier1_contract_value",
        label: "Key Supplier 1 - Contract Value",
        type: "text",
        required: false,
        section: "Key Suppliers",
        placeholder: "Value of supply contract if known"
      },
      {
        id: "supplier1_source_link",
        label: "Key Supplier 1 - Source Link",
        type: "url",
        required: true,
        section: "Key Suppliers",
        placeholder: "Source for supplier information"
      },

      {
        id: "supplier2_name",
        label: "Key Supplier 2 - Name",
        type: "text",
        required: false,
        section: "Key Suppliers",
        placeholder: "Name of second major supplier"
      },
      {
        id: "supplier2_commodity",
        label: "Key Supplier 2 - Commodity",
        type: "text",
        required: false,
        section: "Key Suppliers",
        placeholder: "What they supply"
      },

      // Growth Rates
      {
        id: "growth_period",
        label: "Growth Period",
        type: "text",
        required: true,
        section: "Growth Rates (Past Year)",
        placeholder: "e.g., 2023, Q4 2023, Last 12 months"
      },
      {
        id: "revenue_growth_percentage",
        label: "Revenue Growth (%)",
        type: "number",
        required: true,
        section: "Growth Rates (Past Year)",
        placeholder: "Revenue growth percentage"
      },
      {
        id: "user_growth_percentage",
        label: "User Growth (%)",
        type: "number",
        required: true,
        section: "Growth Rates (Past Year)",
        placeholder: "User base growth percentage"
      },
      {
        id: "growth_source_link",
        label: "Growth Rates - Source Link",
        type: "url",
        required: true,
        section: "Growth Rates (Past Year)",
        placeholder: "Source for growth data"
      },

      // Expansions
      {
        id: "expansion1_type",
        label: "Expansion 1 - Type",
        type: "select",
        options: ["Geographic", "Product", "Market", "Technology"],
        required: true,
        section: "Expansions (Projections)",
        placeholder: "Type of expansion"
      },
      {
        id: "expansion1_region_market",
        label: "Expansion 1 - Region/Market",
        type: "text",
        required: true,
        section: "Expansions (Projections)",
        placeholder: "Target region or market"
      },
      {
        id: "expansion1_date",
        label: "Expansion 1 - Date",
        type: "date",
        required: true,
        section: "Expansions (Projections)",
        placeholder: "Planned or actual expansion date"
      },
      {
        id: "expansion1_investment",
        label: "Expansion 1 - Investment",
        type: "text",
        required: false,
        section: "Expansions (Projections)",
        placeholder: "Investment amount for expansion"
      },
      {
        id: "expansion1_source_link",
        label: "Expansion 1 - Source Link",
        type: "url",
        required: true,
        section: "Expansions (Projections)",
        placeholder: "Source for expansion information"
      },

      {
        id: "expansion2_type",
        label: "Expansion 2 - Type",
        type: "select",
        options: ["Geographic", "Product", "Market", "Technology"],
        required: false,
        section: "Expansions (Projections)",
        placeholder: "Type of second expansion"
      },
      {
        id: "expansion2_region_market",
        label: "Expansion 2 - Region/Market",
        type: "text",
        required: false,
        section: "Expansions (Projections)",
        placeholder: "Second expansion target"
      },
      {
        id: "expansion2_date",
        label: "Expansion 2 - Date",
        type: "date",
        required: false,
        section: "Expansions (Projections)",
        placeholder: "Second expansion date"
      }
    ],
    tools: [
      { name: "Press Releases", url: "#" },
      { name: "Partner Directories", url: "#" },
      { name: "Procurement Portals", url: "#" },
      { name: "BuiltWith", url: "https://builtwith.com" },
      { name: "Company Annual Reports", url: "#" },
      { name: "Google News", url: "https://news.google.com" },
      { name: "Crunchbase", url: "https://www.crunchbase.com" },
      { name: "Industry Reports", url: "#" }
    ]
  }
};

export const getBattleTemplate = (battleId) => {
  return BATTLE_TEMPLATES[battleId] || BATTLE_TEMPLATES.leadership_recon;
};