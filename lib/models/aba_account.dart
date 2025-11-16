class ABAAccount {
  final String accountName;
  final String accountNumber;
  final String currency;

  ABAAccount({
    required this.accountName,
    required this.accountNumber,
    required this.currency,
  });

  Map<String, dynamic> toJson() {
    return {
      'accountName': accountName,
      'accountNumber': accountNumber,
      'currency': currency,
    };
  }
}
