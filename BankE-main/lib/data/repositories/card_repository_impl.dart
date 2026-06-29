import '../../domain/entities/card_entity.dart';
import '../../domain/repositories/card_repository.dart';
import '../datasources/account_data_source.dart';

class CardRepositoryImpl implements CardRepository {
  final AccountDataSource dataSource;

  CardRepositoryImpl({required this.dataSource});

  @override
  Future<List<CardEntity>> getCards(String accountId) async {
    return await dataSource.fetchCards(accountId);
  }

  @override
  Future<void> addCard(String accountId, CardEntity card) async {
    int expiryMonth = 12;
    int expiryYear = 2030;
    final parts = card.expiryDate.split('/');
    if (parts.length == 2) {
      expiryMonth = int.tryParse(parts[0]) ?? 12;
      expiryYear = int.tryParse(parts[1]) ?? 2030;
      if (expiryYear < 100) {
        expiryYear += 2000;
      }
    }

    await dataSource.addCard(
      accountId: accountId,
      cardHolderName: card.cardHolderName,
      cardNumber: card.cardNumber,
      expiryMonth: expiryMonth,
      expiryYear: expiryYear,
      cvv: card.cvv,
      cardType: card.cardType,
      isVirtual: card.isVirtual,
    );
  }

  @override
  Future<void> freezeCard(String cardId, bool freeze) async {
    await dataSource.toggleCardFreeze(cardId);
  }

  @override
  Future<void> deleteCard(String cardId) async {
    await dataSource.deleteCard(cardId);
  }

  @override
  Future<void> updateCardControls(String cardId, {required bool online, required bool atm, required bool international}) async {
    await dataSource.updateCardControls(cardId, online, atm, international);
  }

  @override
  Future<void> changeCardPin(String cardId, String pin) async {
    await dataSource.changeCardPin(cardId, pin);
  }
}
