class Loan {
  final String loanId;
  final String userId;
  final String borrowerId;
  
  // Financial Details
  final double principalAmount;
  final double interestRate;
  final String interestRateType; // 'monthly' or 'yearly'
  final String paymentFrequency; // 'daily', 'monthly', 'quarterly'
  
  // Fund Source Tracking
  final String fundSource; // 'self_funded' or 'borrowed'
  final String transactionMode; // 'cash' or 'bank'
  final double? costOfCapital;
  
  // Source Buyout Tracking
  final String? originalFundSource;
  final DateTime? sourceConvertedAt;
  final String? sourceConversionNotes;
  
  // Dates
  final DateTime loanStartDate;
  final DateTime dueDate;
  
  // Status
  final String status; // 'active', 'paid', 'overdue', 'defaulted'
  
  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Borrower Info (denormalized for convenience)
  final String borrowerName;
  final String? borrowerPhone;

  Loan({
    required this.loanId,
    required this.userId,
    required this.borrowerId,
    required this.principalAmount,
    required this.interestRate,
    required this.interestRateType,
    required this.paymentFrequency,
    required this.fundSource,
    required this.transactionMode,
    this.costOfCapital,
    this.originalFundSource,
    this.sourceConvertedAt,
    this.sourceConversionNotes,
    required this.loanStartDate,
    required this.dueDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.borrowerName,
    this.borrowerPhone,
  });

  /// Calculate interest accrued from loan start date to now
  double calculateInterest({DateTime? endDate}) {
    endDate ??= DateTime.now();
    
    // Calculate days elapsed
    int daysDifference = endDate.difference(loanStartDate).inDays;
    
    // Convert rate to decimal
    double rateDecimal = interestRate / 100;
    
    // Calculate time periods based on rate type
    double timePeriods;
    if (interestRateType == 'yearly') {
      timePeriods = daysDifference / 365.0;
    } else if (interestRateType == 'monthly') {
      timePeriods = daysDifference / 30.0;
    } else {
      throw ArgumentError('Invalid interest rate type: $interestRateType');
    }
    
    // Simple Interest: I = P × r × t
    return principalAmount * rateDecimal * timePeriods;
  }

  /// Calculate total amount due (Principal + Interest)
  double getTotalDue({DateTime? endDate}) {
    return principalAmount + calculateInterest(endDate: endDate);
  }

  /// Check if loan is overdue
  bool isOverdue() {
    return DateTime.now().isAfter(dueDate) && status == 'active';
  }

  /// Calculate net profit (for borrowed funds)
  double calculateNetProfit() {
    double totalInterestEarned = calculateInterest();
    
    if (originalFundSource == 'borrowed' && sourceConvertedAt != null) {
      // Calculate interest paid to lender up to conversion date
      double interestPaidToLender = _calculateInterestUpToDate(sourceConvertedAt!);
      return totalInterestEarned - interestPaidToLender;
    } else if (fundSource == 'borrowed' && costOfCapital != null) {
      // Still borrowed, calculate ongoing cost
      double interestPaidToLender = principalAmount * 
          (costOfCapital! / 100) * 
          (DateTime.now().difference(loanStartDate).inDays / 
           (interestRateType == 'yearly' ? 365.0 : 30.0));
      return totalInterestEarned - interestPaidToLender;
    } else {
      // Self-funded from start
      return totalInterestEarned;
    }
  }

  double _calculateInterestUpToDate(DateTime date) {
    int daysDifference = date.difference(loanStartDate).inDays;
    double rateDecimal = (costOfCapital ?? 0) / 100;
    double timePeriods = daysDifference / (interestRateType == 'yearly' ? 365.0 : 30.0);
    return principalAmount * rateDecimal * timePeriods;
  }

  /// Get card color based on transaction mode
  String getCardColor() {
    return transactionMode == 'cash' ? 'blue' : 'green';
  }

  /// Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'loan_id': loanId,
      'user_id': userId,
      'borrower_id': borrowerId,
      'principal_amount': principalAmount,
      'interest_rate': interestRate,
      'interest_rate_type': interestRateType,
      'payment_frequency': paymentFrequency,
      'fund_source': fundSource,
      'transaction_mode': transactionMode,
      'cost_of_capital': costOfCapital,
      'original_fund_source': originalFundSource,
      'source_converted_at': sourceConvertedAt?.toIso8601String(),
      'source_conversion_notes': sourceConversionNotes,
      'loan_start_date': loanStartDate.toIso8601String(),
      'due_date': dueDate.toIso8601String(),
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create from Map (database retrieval)
  factory Loan.fromMap(Map<String, dynamic> map, {String? borrowerName, String? borrowerPhone}) {
    return Loan(
      loanId: map['loan_id'],
      userId: map['user_id'],
      borrowerId: map['borrower_id'],
      principalAmount: map['principal_amount'],
      interestRate: map['interest_rate'],
      interestRateType: map['interest_rate_type'],
      paymentFrequency: map['payment_frequency'],
      fundSource: map['fund_source'],
      transactionMode: map['transaction_mode'],
      costOfCapital: map['cost_of_capital'],
      originalFundSource: map['original_fund_source'],
      sourceConvertedAt: map['source_converted_at'] != null 
          ? DateTime.parse(map['source_converted_at']) 
          : null,
      sourceConversionNotes: map['source_conversion_notes'],
      loanStartDate: DateTime.parse(map['loan_start_date']),
      dueDate: DateTime.parse(map['due_date']),
      status: map['status'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      borrowerName: borrowerName ?? 'Unknown',
      borrowerPhone: borrowerPhone,
    );
  }

  /// Create a copy with updated fields
  Loan copyWith({
    String? loanId,
    String? userId,
    String? borrowerId,
    double? principalAmount,
    double? interestRate,
    String? interestRateType,
    String? paymentFrequency,
    String? fundSource,
    String? transactionMode,
    double? costOfCapital,
    String? originalFundSource,
    DateTime? sourceConvertedAt,
    String? sourceConversionNotes,
    DateTime? loanStartDate,
    DateTime? dueDate,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? borrowerName,
    String? borrowerPhone,
  }) {
    return Loan(
      loanId: loanId ?? this.loanId,
      userId: userId ?? this.userId,
      borrowerId: borrowerId ?? this.borrowerId,
      principalAmount: principalAmount ?? this.principalAmount,
      interestRate: interestRate ?? this.interestRate,
      interestRateType: interestRateType ?? this.interestRateType,
      paymentFrequency: paymentFrequency ?? this.paymentFrequency,
      fundSource: fundSource ?? this.fundSource,
      transactionMode: transactionMode ?? this.transactionMode,
      costOfCapital: costOfCapital ?? this.costOfCapital,
      originalFundSource: originalFundSource ?? this.originalFundSource,
      sourceConvertedAt: sourceConvertedAt ?? this.sourceConvertedAt,
      sourceConversionNotes: sourceConversionNotes ?? this.sourceConversionNotes,
      loanStartDate: loanStartDate ?? this.loanStartDate,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      borrowerName: borrowerName ?? this.borrowerName,
      borrowerPhone: borrowerPhone ?? this.borrowerPhone,
    );
  }
}
