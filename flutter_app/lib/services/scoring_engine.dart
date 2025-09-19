import 'dart:math';

class ScoringEngine {
  // Trusted domains for source quality scoring
  static const List<String> trustedDomains = [
    'linkedin.com',
    'crunchbase.com',
    'statista.com',
    'bloomberg.com',
    'reuters.com',
    'wsj.com',
    'ft.com',
    'forbes.com',
    'techcrunch.com',
    'venturebeat.com',
    'pitchbook.com',
    'cbinsights.com',
    'gartner.com',
    'mckinsey.com',
    'deloitte.com',
    'pwc.com',
    'kpmg.com',
    'ey.com',
    'bain.com',
    'bcg.com',
  ];

  // Calculate Levenshtein distance for fuzzy matching
  static int levenshteinDistance(String s1, String s2) {
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    List<List<int>> matrix = List.generate(
      s1.length + 1,
      (i) => List.generate(s2.length + 1, (j) => 0),
    );

    for (int i = 0; i <= s1.length; i++) {
      matrix[i][0] = i;
    }

    for (int j = 0; j <= s2.length; j++) {
      matrix[0][j] = j;
    }

    for (int i = 1; i <= s1.length; i++) {
      for (int j = 1; j <= s2.length; j++) {
        int cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,      // deletion
          matrix[i][j - 1] + 1,      // insertion
          matrix[i - 1][j - 1] + cost, // substitution
        ].reduce(min);
      }
    }

    return matrix[s1.length][s2.length];
  }

  // Calculate accuracy score based on data quality
  static double calculateAccuracyScore({
    required Map<String, dynamic> submittedData,
    required Map<String, dynamic> referenceData,
    required List<String> requiredFields,
  }) {
    if (submittedData.isEmpty || referenceData.isEmpty) return 0.0;

    double totalScore = 0.0;
    int fieldCount = 0;

    for (String field in requiredFields) {
      if (!submittedData.containsKey(field) || 
          !referenceData.containsKey(field)) continue;

      String submittedValue = submittedData[field]?.toString().toLowerCase().trim() ?? '';
      String referenceValue = referenceData[field]?.toString().toLowerCase().trim() ?? '';

      if (submittedValue.isEmpty || referenceValue.isEmpty) continue;

      fieldCount++;

      // Exact match gets full points
      if (submittedValue == referenceValue) {
        totalScore += 1.0;
        continue;
      }

      // Calculate similarity using Levenshtein distance
      int distance = levenshteinDistance(submittedValue, referenceValue);
      int maxLength = max(submittedValue.length, referenceValue.length);
      
      if (maxLength == 0) continue;

      double similarity = 1.0 - (distance / maxLength);
      
      // Apply threshold - only count if similarity is above 60%
      if (similarity >= 0.6) {
        totalScore += similarity;
      }
    }

    return fieldCount > 0 ? (totalScore / fieldCount) * 100 : 0.0;
  }

  // Calculate speed score based on submission time
  static double calculateSpeedScore({
    required DateTime matchStartTime,
    required DateTime submissionTime,
    required int totalMatchDurationMinutes,
  }) {
    int elapsedMinutes = submissionTime.difference(matchStartTime).inMinutes;
    
    if (elapsedMinutes <= 0) return 100.0;
    if (elapsedMinutes >= totalMatchDurationMinutes) return 0.0;

    // Linear decay from 100% to 0% over the match duration
    double speedScore = 100.0 * (1.0 - (elapsedMinutes / totalMatchDurationMinutes));
    return max(0.0, min(100.0, speedScore));
  }

  // Calculate source quality score based on URL domains
  static double calculateSourceQualityScore({
    required List<String> sources,
  }) {
    if (sources.isEmpty) return 0.0;

    int trustedCount = 0;
    int totalCount = sources.length;

    for (String source in sources) {
      if (source.isEmpty) continue;

      try {
        Uri uri = Uri.parse(source);
        String domain = uri.host.toLowerCase();
        
        // Remove www. prefix if present
        if (domain.startsWith('www.')) {
          domain = domain.substring(4);
        }

        if (trustedDomains.contains(domain)) {
          trustedCount++;
        }
      } catch (e) {
        // Invalid URL, skip
        continue;
      }
    }

    return (trustedCount / totalCount) * 100.0;
  }

  // Calculate teamwork score based on collaboration metrics
  static double calculateTeamworkScore({
    required int totalSubmissions,
    required int playerSubmissions,
    required int teamSize,
    required List<String> collaborationActions,
  }) {
    if (totalSubmissions == 0 || teamSize == 0) return 0.0;

    // Base score from individual contribution
    double contributionScore = (playerSubmissions / totalSubmissions) * 50.0;

    // Bonus for collaboration actions (sharing info, helping teammates, etc.)
    double collaborationBonus = min(30.0, collaborationActions.length * 5.0);

    // Bonus for team efficiency (more submissions per person = better teamwork)
    double efficiencyBonus = min(20.0, (totalSubmissions / teamSize) * 2.0);

    return min(100.0, contributionScore + collaborationBonus + efficiencyBonus);
  }

  // Calculate overall battle score
  static Map<String, double> calculateBattleScore({
    required Map<String, dynamic> submittedData,
    required Map<String, dynamic> referenceData,
    required List<String> requiredFields,
    required List<String> sources,
    required DateTime matchStartTime,
    required DateTime submissionTime,
    required int totalMatchDurationMinutes,
    required int totalSubmissions,
    required int playerSubmissions,
    required int teamSize,
    required List<String> collaborationActions,
  }) {
    double accuracyScore = calculateAccuracyScore(
      submittedData: submittedData,
      referenceData: referenceData,
      requiredFields: requiredFields,
    );

    double speedScore = calculateSpeedScore(
      matchStartTime: matchStartTime,
      submissionTime: submissionTime,
      totalMatchDurationMinutes: totalMatchDurationMinutes,
    );

    double sourceQualityScore = calculateSourceQualityScore(
      sources: sources,
    );

    double teamworkScore = calculateTeamworkScore(
      totalSubmissions: totalSubmissions,
      playerSubmissions: playerSubmissions,
      teamSize: teamSize,
      collaborationActions: collaborationActions,
    );

    // Weighted final score
    double finalScore = (accuracyScore * 0.6) +
                       (speedScore * 0.1) +
                       (sourceQualityScore * 0.15) +
                       (teamworkScore * 0.15);

    return {
      'accuracy': accuracyScore,
      'speed': speedScore,
      'sourceQuality': sourceQualityScore,
      'teamwork': teamworkScore,
      'final': finalScore,
    };
  }

  // Calculate team score for a specific battle
  static double calculateTeamBattleScore({
    required List<Map<String, double>> individualScores,
  }) {
    if (individualScores.isEmpty) return 0.0;

    double totalScore = 0.0;
    for (Map<String, double> score in individualScores) {
      totalScore += score['final'] ?? 0.0;
    }

    return totalScore / individualScores.length;
  }

  // Calculate overall match score
  static Map<String, dynamic> calculateMatchScore({
    required Map<String, List<Map<String, double>>> teamScores,
  }) {
    Map<String, double> teamTotals = {};
    Map<String, List<double>> battleBreakdown = {};

    for (String team in teamScores.keys) {
      List<Map<String, double>> scores = teamScores[team] ?? [];
      double teamTotal = 0.0;
      List<double> battleScores = [];

      for (Map<String, double> score in scores) {
        double battleScore = score['final'] ?? 0.0;
        teamTotal += battleScore;
        battleScores.add(battleScore);
      }

      teamTotals[team] = teamTotal;
      battleBreakdown[team] = battleScores;
    }

    // Determine winner
    String? winner;
    double maxScore = 0.0;
    for (String team in teamTotals.keys) {
      if (teamTotals[team]! > maxScore) {
        maxScore = teamTotals[team]!;
        winner = team;
      }
    }

    return {
      'teamScores': teamTotals,
      'battleBreakdown': battleBreakdown,
      'winner': winner,
      'maxScore': maxScore,
    };
  }

  // Validate battle submission
  static Map<String, dynamic> validateSubmission({
    required Map<String, dynamic> submittedData,
    required List<String> requiredFields,
  }) {
    List<String> missingFields = [];
    List<String> invalidFields = [];

    for (String field in requiredFields) {
      if (!submittedData.containsKey(field) || 
          submittedData[field] == null ||
          submittedData[field].toString().trim().isEmpty) {
        missingFields.add(field);
      }
    }

    // Basic validation for specific field types
    for (String field in submittedData.keys) {
      dynamic value = submittedData[field];
      if (value == null || value.toString().trim().isEmpty) continue;

      // Email validation
      if (field.toLowerCase().contains('email')) {
        if (!_isValidEmail(value.toString())) {
          invalidFields.add('$field (invalid email format)');
        }
      }

      // URL validation
      if (field.toLowerCase().contains('url') || 
          field.toLowerCase().contains('website') ||
          field.toLowerCase().contains('link')) {
        if (!_isValidUrl(value.toString())) {
          invalidFields.add('$field (invalid URL format)');
        }
      }

      // Number validation
      if (field.toLowerCase().contains('revenue') ||
          field.toLowerCase().contains('funding') ||
          field.toLowerCase().contains('employees') ||
          field.toLowerCase().contains('valuation')) {
        if (!_isValidNumber(value.toString())) {
          invalidFields.add('$field (invalid number format)');
        }
      }
    }

    bool isValid = missingFields.isEmpty && invalidFields.isEmpty;

    return {
      'isValid': isValid,
      'missingFields': missingFields,
      'invalidFields': invalidFields,
    };
  }

  // Helper methods for validation
  static bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool _isValidUrl(String url) {
    try {
      Uri.parse(url);
      return true;
    } catch (e) {
      return false;
    }
  }

  static bool _isValidNumber(String number) {
    try {
      double.parse(number.replaceAll(',', '').replaceAll('\$', ''));
      return true;
    } catch (e) {
      return false;
    }
  }
}
