class NudgeAnalysis {
  final String message;
  final String level;
  final double spendingRate;

  const NudgeAnalysis({
    required this.message,
    required this.level,
    required this.spendingRate,
  });
}

class NudgeAIService {
  // This is deliberately separated from the UI.
  //
  // Later you can connect:
  // - Gemini API
  // - OpenAI API
  // - Claude API
  // - Local AI model
  //
  // without rebuilding the transaction system.

  static NudgeAnalysis analyse({
    required List<Map<String, dynamic>> transactions,
    required double balance,
    required double monthlyBudget,
  }) {
    double monthlySpending = 0;

    final now = DateTime.now();

    for (final transaction in transactions) {
      if (transaction['type'] != 'expense') continue;

      final date = DateTime.tryParse(
        transaction['date']?.toString() ?? '',
      );

      if (date == null) continue;

      if (date.year == now.year &&
          date.month == now.month) {
        monthlySpending +=
            (transaction['amount'] as num).toDouble();
      }
    }

    double rate = 0;

    if (monthlyBudget > 0) {
      rate = monthlySpending / monthlyBudget;
    }

    if (monthlySpending == 0) {
      return const NudgeAnalysis(
        message:
            'No spending yet. Your wallet is behaving 😌',
        level: 'good',
        spendingRate: 0,
      );
    }

    if (monthlyBudget > 0 && rate >= 1) {
      return NudgeAnalysis(
        message:
            'Bro 💀 you crossed your monthly budget. Time to chill the spending.',
        level: 'danger',
        spendingRate: rate,
      );
    }

    if (monthlyBudget > 0 && rate >= 0.8) {
      return NudgeAnalysis(
        message:
            'You are already at ${(rate * 100).toStringAsFixed(0)}% of your budget 👀',
        level: 'warning',
        spendingRate: rate,
      );
    }

    if (monthlySpending > 5000) {
      return NudgeAnalysis(
        message:
            'Money is leaving the account a little too confidently 💸',
        level: 'warning',
        spendingRate: rate,
      );
    }

    return NudgeAnalysis(
      message:
          'Looking good. Keep your spending under control 🔥',
      level: 'good',
      spendingRate: rate,
    );
  }
}
