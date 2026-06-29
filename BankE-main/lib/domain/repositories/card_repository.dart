import '../../domain/entities/card_entity.dart';

abstract class CardRepository {
  Future<List<CardEntity>> getCards(String accountId);
  Future<void> addCard(String accountId, CardEntity card);
  Future<void> freezeCard(String cardId, bool freeze);
  Future<void> deleteCard(String cardId);
  Future<void> updateCardControls(String cardId, {required bool online, required bool atm, required bool international});
  Future<void> changeCardPin(String cardId, String pin);
}
