class CompanyReference {
  final String id;
  final String companyName;
  final String companyDescription;
  final LeadershipData battle1Leadership;
  final ProductsData battle2Products;
  final FundingData battle3Funding;
  final CustomersData battle4Customers;
  final PartnershipsData battle5Partnerships;
  final DateTime createdAt;

  CompanyReference({
    required this.id,
    required this.companyName,
    required this.companyDescription,
    required this.battle1Leadership,
    required this.battle2Products,
    required this.battle3Funding,
    required this.battle4Customers,
    required this.battle5Partnerships,
    required this.createdAt,
  });

  factory CompanyReference.fromJson(Map<String, dynamic> json) {
    return CompanyReference(
      id: json['id'] ?? '',
      companyName: json['company_name'] ?? '',
      companyDescription: json['company_description'] ?? '',
      battle1Leadership: LeadershipData.fromJson(json['battle_1_leadership'] ?? {}),
      battle2Products: ProductsData.fromJson(json['battle_2_products'] ?? {}),
      battle3Funding: FundingData.fromJson(json['battle_3_funding'] ?? {}),
      battle4Customers: CustomersData.fromJson(json['battle_4_customers'] ?? {}),
      battle5Partnerships: PartnershipsData.fromJson(json['battle_5_partnerships'] ?? {}),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_name': companyName,
      'company_description': companyDescription,
      'battle_1_leadership': battle1Leadership.toJson(),
      'battle_2_products': battle2Products.toJson(),
      'battle_3_funding': battle3Funding.toJson(),
      'battle_4_customers': battle4Customers.toJson(),
      'battle_5_partnerships': battle5Partnerships.toJson(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class LeadershipData {
  final List<Founder> founders;
  final List<KeyExecutive> keyExecutives;
  final MarketShare marketShare;
  final List<GeographicFootprint> geographicFootprint;

  LeadershipData({
    this.founders = const [],
    this.keyExecutives = const [],
    required this.marketShare,
    this.geographicFootprint = const [],
  });

  factory LeadershipData.fromJson(Map<String, dynamic> json) {
    return LeadershipData(
      founders: (json['founders'] as List<dynamic>?)
          ?.map((founder) => Founder.fromJson(founder))
          .toList() ?? [],
      keyExecutives: (json['key_executives'] as List<dynamic>?)
          ?.map((exec) => KeyExecutive.fromJson(exec))
          .toList() ?? [],
      marketShare: MarketShare.fromJson(json['market_share'] ?? {}),
      geographicFootprint: (json['geographic_footprint'] as List<dynamic>?)
          ?.map((footprint) => GeographicFootprint.fromJson(footprint))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'founders': founders.map((f) => f.toJson()).toList(),
      'key_executives': keyExecutives.map((e) => e.toJson()).toList(),
      'market_share': marketShare.toJson(),
      'geographic_footprint': geographicFootprint.map((g) => g.toJson()).toList(),
    };
  }
}

class Founder {
  final String fullName;
  final String foundingYear;
  final String currentRole;
  final String? previousVentures;
  final String? linkedinUrl;
  final String? notes;

  Founder({
    required this.fullName,
    required this.foundingYear,
    required this.currentRole,
    this.previousVentures,
    this.linkedinUrl,
    this.notes,
  });

  factory Founder.fromJson(Map<String, dynamic> json) {
    return Founder(
      fullName: json['full_name'] ?? '',
      foundingYear: json['founding_year'] ?? '',
      currentRole: json['current_role'] ?? '',
      previousVentures: json['previous_ventures'],
      linkedinUrl: json['linkedin_url'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'founding_year': foundingYear,
      'current_role': currentRole,
      'previous_ventures': previousVentures,
      'linkedin_url': linkedinUrl,
      'notes': notes,
    };
  }
}

class KeyExecutive {
  final String name;
  final String title;
  final String function;
  final String? yearsWithFirm;
  final String? linkedinUrl;
  final String? notes;

  KeyExecutive({
    required this.name,
    required this.title,
    required this.function,
    this.yearsWithFirm,
    this.linkedinUrl,
    this.notes,
  });

  factory KeyExecutive.fromJson(Map<String, dynamic> json) {
    return KeyExecutive(
      name: json['name'] ?? '',
      title: json['title'] ?? '',
      function: json['function'] ?? '',
      yearsWithFirm: json['years_with_firm'],
      linkedinUrl: json['linkedin_url'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'title': title,
      'function': function,
      'years_with_firm': yearsWithFirm,
      'linkedin_url': linkedinUrl,
      'notes': notes,
    };
  }
}

class MarketShare {
  final String tamUsd;
  final String samUsd;
  final String somUsd;
  final String annualGrowthRate;
  final int competitiveRank;
  final String companySharePercentage;
  final String differentiators;

  MarketShare({
    required this.tamUsd,
    required this.samUsd,
    required this.somUsd,
    required this.annualGrowthRate,
    required this.competitiveRank,
    required this.companySharePercentage,
    required this.differentiators,
  });

  factory MarketShare.fromJson(Map<String, dynamic> json) {
    return MarketShare(
      tamUsd: json['tam_usd'] ?? '',
      samUsd: json['sam_usd'] ?? '',
      somUsd: json['som_usd'] ?? '',
      annualGrowthRate: json['annual_growth_rate'] ?? '',
      competitiveRank: json['competitive_rank'] ?? 0,
      companySharePercentage: json['company_share_percentage'] ?? '',
      differentiators: json['differentiators'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tam_usd': tamUsd,
      'sam_usd': samUsd,
      'som_usd': somUsd,
      'annual_growth_rate': annualGrowthRate,
      'competitive_rank': competitiveRank,
      'company_share_percentage': companySharePercentage,
      'differentiators': differentiators,
    };
  }
}

class GeographicFootprint {
  final String location;
  final String openedYear;
  final String facilityType;
  final String? notes;

  GeographicFootprint({
    required this.location,
    required this.openedYear,
    required this.facilityType,
    this.notes,
  });

  factory GeographicFootprint.fromJson(Map<String, dynamic> json) {
    return GeographicFootprint(
      location: json['location'] ?? '',
      openedYear: json['opened_year'] ?? '',
      facilityType: json['facility_type'] ?? '',
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'opened_year': openedYear,
      'facility_type': facilityType,
      'notes': notes,
    };
  }
}

class ProductsData {
  final List<ProductLine> productLines;
  final List<SocialPresence> socialPresence;

  ProductsData({
    this.productLines = const [],
    this.socialPresence = const [],
  });

  factory ProductsData.fromJson(Map<String, dynamic> json) {
    return ProductsData(
      productLines: (json['product_lines'] as List<dynamic>?)
          ?.map((product) => ProductLine.fromJson(product))
          .toList() ?? [],
      socialPresence: (json['social_presence'] as List<dynamic>?)
          ?.map((social) => SocialPresence.fromJson(social))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_lines': productLines.map((p) => p.toJson()).toList(),
      'social_presence': socialPresence.map((s) => s.toJson()).toList(),
    };
  }
}

class ProductLine {
  final String productName;
  final String productType;
  final String launchDate;
  final String category;
  final String targetSegment;
  final String keyFeatures;
  final String pricingModel;
  final String? reviewsScore;
  final String? primaryCompetitors;

  ProductLine({
    required this.productName,
    required this.productType,
    required this.launchDate,
    required this.category,
    required this.targetSegment,
    required this.keyFeatures,
    required this.pricingModel,
    this.reviewsScore,
    this.primaryCompetitors,
  });

  factory ProductLine.fromJson(Map<String, dynamic> json) {
    return ProductLine(
      productName: json['product_name'] ?? '',
      productType: json['product_type'] ?? '',
      launchDate: json['launch_date'] ?? '',
      category: json['category'] ?? '',
      targetSegment: json['target_segment'] ?? '',
      keyFeatures: json['key_features'] ?? '',
      pricingModel: json['pricing_model'] ?? '',
      reviewsScore: json['reviews_score'],
      primaryCompetitors: json['primary_competitors'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_name': productName,
      'product_type': productType,
      'launch_date': launchDate,
      'category': category,
      'target_segment': targetSegment,
      'key_features': keyFeatures,
      'pricing_model': pricingModel,
      'reviews_score': reviewsScore,
      'primary_competitors': primaryCompetitors,
    };
  }
}

class SocialPresence {
  final String platformName;
  final String pageLink;
  final String followers;
  final String? engagementRate;
  final String? runningAds;

  SocialPresence({
    required this.platformName,
    required this.pageLink,
    required this.followers,
    this.engagementRate,
    this.runningAds,
  });

  factory SocialPresence.fromJson(Map<String, dynamic> json) {
    return SocialPresence(
      platformName: json['platform_name'] ?? '',
      pageLink: json['page_link'] ?? '',
      followers: json['followers'] ?? '',
      engagementRate: json['engagement_rate'],
      runningAds: json['running_ads'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'platform_name': platformName,
      'page_link': pageLink,
      'followers': followers,
      'engagement_rate': engagementRate,
      'running_ads': runningAds,
    };
  }
}

class FundingData {
  final TotalFunding totalFunding;
  final List<FundingRound> fundingRounds;
  final List<Investor> investors;
  final RevenueValuation revenueValuation;

  FundingData({
    required this.totalFunding,
    this.fundingRounds = const [],
    this.investors = const [],
    required this.revenueValuation,
  });

  factory FundingData.fromJson(Map<String, dynamic> json) {
    return FundingData(
      totalFunding: TotalFunding.fromJson(json['total_funding'] ?? {}),
      fundingRounds: (json['funding_rounds'] as List<dynamic>?)
          ?.map((round) => FundingRound.fromJson(round))
          .toList() ?? [],
      investors: (json['investors'] as List<dynamic>?)
          ?.map((investor) => Investor.fromJson(investor))
          .toList() ?? [],
      revenueValuation: RevenueValuation.fromJson(json['revenue_valuation'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_funding': totalFunding.toJson(),
      'funding_rounds': fundingRounds.map((r) => r.toJson()).toList(),
      'investors': investors.map((i) => i.toJson()).toList(),
      'revenue_valuation': revenueValuation.toJson(),
    };
  }
}

class TotalFunding {
  final String amountUsd;
  final int numberOfRounds;

  TotalFunding({
    required this.amountUsd,
    required this.numberOfRounds,
  });

  factory TotalFunding.fromJson(Map<String, dynamic> json) {
    return TotalFunding(
      amountUsd: json['amount_usd'] ?? '',
      numberOfRounds: json['number_of_rounds'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount_usd': amountUsd,
      'number_of_rounds': numberOfRounds,
    };
  }
}

class FundingRound {
  final String date;
  final String series;
  final String amountUsd;
  final int numberOfInvestors;
  final String? leadInvestor;
  final String? notes;

  FundingRound({
    required this.date,
    required this.series,
    required this.amountUsd,
    required this.numberOfInvestors,
    this.leadInvestor,
    this.notes,
  });

  factory FundingRound.fromJson(Map<String, dynamic> json) {
    return FundingRound(
      date: json['date'] ?? '',
      series: json['series'] ?? '',
      amountUsd: json['amount_usd'] ?? '',
      numberOfInvestors: json['number_of_investors'] ?? 0,
      leadInvestor: json['lead_investor'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'series': series,
      'amount_usd': amountUsd,
      'number_of_investors': numberOfInvestors,
      'lead_investor': leadInvestor,
      'notes': notes,
    };
  }
}

class Investor {
  final String name;
  final String type;
  final String? stakePercentage;
  final String? notes;

  Investor({
    required this.name,
    required this.type,
    this.stakePercentage,
    this.notes,
  });

  factory Investor.fromJson(Map<String, dynamic> json) {
    return Investor(
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      stakePercentage: json['stake_percentage'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'stake_percentage': stakePercentage,
      'notes': notes,
    };
  }
}

class RevenueValuation {
  final String revenueUsd;
  final String growthRate;
  final String latestValuationUsd;
  final String? notes;

  RevenueValuation({
    required this.revenueUsd,
    required this.growthRate,
    required this.latestValuationUsd,
    this.notes,
  });

  factory RevenueValuation.fromJson(Map<String, dynamic> json) {
    return RevenueValuation(
      revenueUsd: json['revenue_usd'] ?? '',
      growthRate: json['growth_rate'] ?? '',
      latestValuationUsd: json['latest_valuation_usd'] ?? '',
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'revenue_usd': revenueUsd,
      'growth_rate': growthRate,
      'latest_valuation_usd': latestValuationUsd,
      'notes': notes,
    };
  }
}

class CustomersData {
  final List<B2CSegment> b2cSegments;
  final List<B2BSegment> b2bSegments;
  final ReviewsOverview reviewsOverview;
  final List<PainPoint> painPoints;

  CustomersData({
    this.b2cSegments = const [],
    this.b2bSegments = const [],
    required this.reviewsOverview,
    this.painPoints = const [],
  });

  factory CustomersData.fromJson(Map<String, dynamic> json) {
    return CustomersData(
      b2cSegments: (json['b2c_segments'] as List<dynamic>?)
          ?.map((segment) => B2CSegment.fromJson(segment))
          .toList() ?? [],
      b2bSegments: (json['b2b_segments'] as List<dynamic>?)
          ?.map((segment) => B2BSegment.fromJson(segment))
          .toList() ?? [],
      reviewsOverview: ReviewsOverview.fromJson(json['reviews_overview'] ?? {}),
      painPoints: (json['pain_points'] as List<dynamic>?)
          ?.map((pain) => PainPoint.fromJson(pain))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'b2c_segments': b2cSegments.map((s) => s.toJson()).toList(),
      'b2b_segments': b2bSegments.map((s) => s.toJson()).toList(),
      'reviews_overview': reviewsOverview.toJson(),
      'pain_points': painPoints.map((p) => p.toJson()).toList(),
    };
  }
}

class B2CSegment {
  final String ageRange;
  final String incomeLevel;
  final String educationalLevel;
  final String interestsLifestyle;
  final String behavior;
  final String needsPainPoints;
  final String location;
  final String revenueSharePercentage;

  B2CSegment({
    required this.ageRange,
    required this.incomeLevel,
    required this.educationalLevel,
    required this.interestsLifestyle,
    required this.behavior,
    required this.needsPainPoints,
    required this.location,
    required this.revenueSharePercentage,
  });

  factory B2CSegment.fromJson(Map<String, dynamic> json) {
    return B2CSegment(
      ageRange: json['age_range'] ?? '',
      incomeLevel: json['income_level'] ?? '',
      educationalLevel: json['educational_level'] ?? '',
      interestsLifestyle: json['interests_lifestyle'] ?? '',
      behavior: json['behavior'] ?? '',
      needsPainPoints: json['needs_pain_points'] ?? '',
      location: json['location'] ?? '',
      revenueSharePercentage: json['revenue_share_percentage'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'age_range': ageRange,
      'income_level': incomeLevel,
      'educational_level': educationalLevel,
      'interests_lifestyle': interestsLifestyle,
      'behavior': behavior,
      'needs_pain_points': needsPainPoints,
      'location': location,
      'revenue_share_percentage': revenueSharePercentage,
    };
  }
}

class B2BSegment {
  final String businessSize;
  final String industry;
  final String revenueOfTargetedCompany;
  final String technographic;
  final String behavior;
  final String needsPainPoints;
  final String revenueSharePercentage;

  B2BSegment({
    required this.businessSize,
    required this.industry,
    required this.revenueOfTargetedCompany,
    required this.technographic,
    required this.behavior,
    required this.needsPainPoints,
    required this.revenueSharePercentage,
  });

  factory B2BSegment.fromJson(Map<String, dynamic> json) {
    return B2BSegment(
      businessSize: json['business_size'] ?? '',
      industry: json['industry'] ?? '',
      revenueOfTargetedCompany: json['revenue_of_targeted_company'] ?? '',
      technographic: json['technographic'] ?? '',
      behavior: json['behavior'] ?? '',
      needsPainPoints: json['needs_pain_points'] ?? '',
      revenueSharePercentage: json['revenue_share_percentage'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'business_size': businessSize,
      'industry': industry,
      'revenue_of_targeted_company': revenueOfTargetedCompany,
      'technographic': technographic,
      'behavior': behavior,
      'needs_pain_points': needsPainPoints,
      'revenue_share_percentage': revenueSharePercentage,
    };
  }
}

class ReviewsOverview {
  final String avgRating;
  final String positivePercentage;
  final String negativePercentage;
  final String commonThemes;

  ReviewsOverview({
    required this.avgRating,
    required this.positivePercentage,
    required this.negativePercentage,
    required this.commonThemes,
  });

  factory ReviewsOverview.fromJson(Map<String, dynamic> json) {
    return ReviewsOverview(
      avgRating: json['avg_rating'] ?? '',
      positivePercentage: json['positive_percentage'] ?? '',
      negativePercentage: json['negative_percentage'] ?? '',
      commonThemes: json['common_themes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'avg_rating': avgRating,
      'positive_percentage': positivePercentage,
      'negative_percentage': negativePercentage,
      'common_themes': commonThemes,
    };
  }
}

class PainPoint {
  final String description;
  final String impact;
  final String frequency;
  final String? suggestedFix;

  PainPoint({
    required this.description,
    required this.impact,
    required this.frequency,
    this.suggestedFix,
  });

  factory PainPoint.fromJson(Map<String, dynamic> json) {
    return PainPoint(
      description: json['description'] ?? '',
      impact: json['impact'] ?? '',
      frequency: json['frequency'] ?? '',
      suggestedFix: json['suggested_fix'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'impact': impact,
      'frequency': frequency,
      'suggested_fix': suggestedFix,
    };
  }
}

class PartnershipsData {
  final List<StrategicPartner> strategicPartners;
  final List<KeySupplier> keySuppliers;
  final List<GrowthRate> growthRates;
  final List<Expansion> expansions;

  PartnershipsData({
    this.strategicPartners = const [],
    this.keySuppliers = const [],
    this.growthRates = const [],
    this.expansions = const [],
  });

  factory PartnershipsData.fromJson(Map<String, dynamic> json) {
    return PartnershipsData(
      strategicPartners: (json['strategic_partners'] as List<dynamic>?)
          ?.map((partner) => StrategicPartner.fromJson(partner))
          .toList() ?? [],
      keySuppliers: (json['key_suppliers'] as List<dynamic>?)
          ?.map((supplier) => KeySupplier.fromJson(supplier))
          .toList() ?? [],
      growthRates: (json['growth_rates'] as List<dynamic>?)
          ?.map((rate) => GrowthRate.fromJson(rate))
          .toList() ?? [],
      expansions: (json['expansions'] as List<dynamic>?)
          ?.map((expansion) => Expansion.fromJson(expansion))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'strategic_partners': strategicPartners.map((p) => p.toJson()).toList(),
      'key_suppliers': keySuppliers.map((s) => s.toJson()).toList(),
      'growth_rates': growthRates.map((r) => r.toJson()).toList(),
      'expansions': expansions.map((e) => e.toJson()).toList(),
    };
  }
}

class StrategicPartner {
  final String name;
  final String type;
  final String region;
  final String startDate;
  final String? notes;

  StrategicPartner({
    required this.name,
    required this.type,
    required this.region,
    required this.startDate,
    this.notes,
  });

  factory StrategicPartner.fromJson(Map<String, dynamic> json) {
    return StrategicPartner(
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      region: json['region'] ?? '',
      startDate: json['start_date'] ?? '',
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'region': region,
      'start_date': startDate,
      'notes': notes,
    };
  }
}

class KeySupplier {
  final String name;
  final String commodity;
  final String region;
  final String? contractValue;

  KeySupplier({
    required this.name,
    required this.commodity,
    required this.region,
    this.contractValue,
  });

  factory KeySupplier.fromJson(Map<String, dynamic> json) {
    return KeySupplier(
      name: json['name'] ?? '',
      commodity: json['commodity'] ?? '',
      region: json['region'] ?? '',
      contractValue: json['contract_value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'commodity': commodity,
      'region': region,
      'contract_value': contractValue,
    };
  }
}

class GrowthRate {
  final String period;
  final String revenueGrowthPercentage;
  final String userGrowthPercentage;

  GrowthRate({
    required this.period,
    required this.revenueGrowthPercentage,
    required this.userGrowthPercentage,
  });

  factory GrowthRate.fromJson(Map<String, dynamic> json) {
    return GrowthRate(
      period: json['period'] ?? '',
      revenueGrowthPercentage: json['revenue_growth_percentage'] ?? '',
      userGrowthPercentage: json['user_growth_percentage'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'revenue_growth_percentage': revenueGrowthPercentage,
      'user_growth_percentage': userGrowthPercentage,
    };
  }
}

class Expansion {
  final String type;
  final String regionMarket;
  final String date;
  final String? investment;
  final String? notes;

  Expansion({
    required this.type,
    required this.regionMarket,
    required this.date,
    this.investment,
    this.notes,
  });

  factory Expansion.fromJson(Map<String, dynamic> json) {
    return Expansion(
      type: json['type'] ?? '',
      regionMarket: json['region_market'] ?? '',
      date: json['date'] ?? '',
      investment: json['investment'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'region_market': regionMarket,
      'date': date,
      'investment': investment,
      'notes': notes,
    };
  }
}
