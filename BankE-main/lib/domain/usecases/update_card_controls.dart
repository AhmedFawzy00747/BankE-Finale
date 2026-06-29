import '../repositories/card_repository.dart';

class UpdateCardControlsUseCase {
  final CardRepository repository;

  UpdateCardControlsUseCase(this.repository);

  Future<void> execute(String cardId, {required bool online, required bool atm, required bool international}) {
    return repository.updateCardControls(cardId, online: online, atm: atm, international: international);
  }
}
