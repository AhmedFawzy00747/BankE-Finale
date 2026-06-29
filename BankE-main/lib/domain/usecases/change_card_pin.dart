import '../repositories/card_repository.dart';

class ChangeCardPinUseCase {
  final CardRepository repository;

  ChangeCardPinUseCase(this.repository);

  Future<void> execute(String cardId, String pin) {
    return repository.changeCardPin(cardId, pin);
  }
}
