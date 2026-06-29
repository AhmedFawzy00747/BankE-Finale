class CardEntity {
  final String id;
  final String cardNumber; // e.g., "1234567890123456"
  final String cardHolderName;
  final String expiryDate; // e.g., "12/25"
  final String cvv;
  final bool isFrozen;
  final bool isVirtual;
  final String cardType; // "Credit" or "Debit"
  final String pin;
  final bool onlinePaymentsEnabled;
  final bool atmWithdrawalsEnabled;
  final bool internationalTransactionsEnabled;

  // Test fields
  final String? cardNickname;
  final String? cardColor;
  final String? billingAddress;
  final String? country;
  final String? zipCode;

  const CardEntity({
    required this.id,
    required this.cardNumber,
    required this.cardHolderName,
    required this.expiryDate,
    required this.cvv,
    required this.isFrozen,
    required this.isVirtual,
    required this.cardType,
    this.pin = '1234',
    this.onlinePaymentsEnabled = true,
    this.atmWithdrawalsEnabled = true,
    this.internationalTransactionsEnabled = true,
    this.cardNickname,
    this.cardColor,
    this.billingAddress,
    this.country,
    this.zipCode,
  });

  CardEntity copyWith({
    String? id,
    String? cardNumber,
    String? cardHolderName,
    String? expiryDate,
    String? cvv,
    bool? isFrozen,
    bool? isVirtual,
    String? cardType,
    String? pin,
    bool? onlinePaymentsEnabled,
    bool? atmWithdrawalsEnabled,
    bool? internationalTransactionsEnabled,
    String? cardNickname,
    String? cardColor,
    String? billingAddress,
    String? country,
    String? zipCode,
  }) {
    return CardEntity(
      id: id ?? this.id,
      cardNumber: cardNumber ?? this.cardNumber,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      expiryDate: expiryDate ?? this.expiryDate,
      cvv: cvv ?? this.cvv,
      isFrozen: isFrozen ?? this.isFrozen,
      isVirtual: isVirtual ?? this.isVirtual,
      cardType: cardType ?? this.cardType,
      pin: pin ?? this.pin,
      onlinePaymentsEnabled: onlinePaymentsEnabled ?? this.onlinePaymentsEnabled,
      atmWithdrawalsEnabled: atmWithdrawalsEnabled ?? this.atmWithdrawalsEnabled,
      internationalTransactionsEnabled:
          internationalTransactionsEnabled ?? this.internationalTransactionsEnabled,
      cardNickname: cardNickname ?? this.cardNickname,
      cardColor: cardColor ?? this.cardColor,
      billingAddress: billingAddress ?? this.billingAddress,
      country: country ?? this.country,
      zipCode: zipCode ?? this.zipCode,
    );
  }
}
