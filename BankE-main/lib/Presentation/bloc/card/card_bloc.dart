import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/add_card.dart';
import '../../../domain/usecases/get_cards.dart';
import '../../../domain/usecases/freeze_card.dart';
import '../../../domain/usecases/delete_card.dart';
import '../../../domain/usecases/update_card_controls.dart';
import '../../../domain/usecases/change_card_pin.dart';
import 'card_event.dart';
import 'card_state.dart';

class CardBloc extends Bloc<CardEvent, CardState> {
  final GetCardsUseCase getCardsUseCase;
  final AddCardUseCase addCardUseCase;
  final FreezeCardUseCase freezeCardUseCase;
  final DeleteCardUseCase deleteCardUseCase;
  final UpdateCardControlsUseCase updateCardControlsUseCase;
  final ChangeCardPinUseCase changeCardPinUseCase;

  CardBloc({
    required this.getCardsUseCase,
    required this.addCardUseCase,
    required this.freezeCardUseCase,
    required this.deleteCardUseCase,
    required this.updateCardControlsUseCase,
    required this.changeCardPinUseCase,
  }) : super(CardInitial()) {
    on<LoadCardsEvent>(_onLoadCards);
    on<AddCardEvent>(_onAddCard);
    on<FreezeCardEvent>(_onFreezeCard);
    on<DeleteCardEvent>(_onDeleteCard);
    on<UpdateCardControlsEvent>(_onUpdateCardControls);
    on<ChangeCardPinEvent>(_onChangeCardPin);
  }

  Future<void> _onLoadCards(LoadCardsEvent event, Emitter<CardState> emit) async {
    emit(CardLoading());
    try {
      final cards = await getCardsUseCase.execute(event.accountId);
      emit(CardsLoaded(cards));
    } catch (e) {
      emit(CardError(e.toString()));
    }
  }

  Future<void> _onAddCard(AddCardEvent event, Emitter<CardState> emit) async {
    emit(CardLoading());
    try {
      await addCardUseCase.execute(event.accountId, event.card);
      emit(const CardOperationSuccess('Card added successfully'));
      add(LoadCardsEvent(event.accountId));
    } catch (e) {
      emit(CardError(e.toString()));
    }
  }

  Future<void> _onFreezeCard(FreezeCardEvent event, Emitter<CardState> emit) async {
    emit(CardLoading());
    try {
      await freezeCardUseCase.execute(event.cardId, event.freeze);
      emit(CardOperationSuccess(event.freeze ? 'Card frozen' : 'Card unfrozen'));
      add(LoadCardsEvent(event.accountId));
    } catch (e) {
      emit(CardError(e.toString()));
    }
  }

  Future<void> _onDeleteCard(DeleteCardEvent event, Emitter<CardState> emit) async {
    emit(CardLoading());
    try {
      await deleteCardUseCase.execute(event.cardId);
      emit(const CardOperationSuccess('Card deleted successfully'));
      add(LoadCardsEvent(event.accountId));
    } catch (e) {
      emit(CardError(e.toString()));
    }
  }

  Future<void> _onUpdateCardControls(UpdateCardControlsEvent event, Emitter<CardState> emit) async {
    emit(CardLoading());
    try {
      await updateCardControlsUseCase.execute(
        event.cardId,
        online: event.online,
        atm: event.atm,
        international: event.international,
      );
      emit(const CardOperationSuccess('Card controls updated successfully'));
      add(LoadCardsEvent(event.accountId));
    } catch (e) {
      emit(CardError(e.toString()));
    }
  }

  Future<void> _onChangeCardPin(ChangeCardPinEvent event, Emitter<CardState> emit) async {
    emit(CardLoading());
    try {
      await changeCardPinUseCase.execute(event.cardId, event.pin);
      emit(const CardOperationSuccess('Card PIN changed successfully'));
      add(LoadCardsEvent(event.accountId));
    } catch (e) {
      emit(CardError(e.toString()));
    }
  }
}
