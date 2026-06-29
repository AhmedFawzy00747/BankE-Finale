import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/card/card_bloc.dart';
import '../../bloc/card/card_event.dart';
import '../../bloc/card/card_state.dart';
import '../../widgets/card_widget.dart';
import '../../../core/constants/app_constants.dart';
import 'add_card_screen.dart';

class CardManagementScreen extends StatefulWidget {
  const CardManagementScreen({Key? key}) : super(key: key);

  @override
  _CardManagementScreenState createState() => _CardManagementScreenState();
}

class _CardManagementScreenState extends State<CardManagementScreen> {
  List<dynamic> _cards = [];

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  void _loadCards() {
    context.read<CardBloc>().add(const LoadCardsEvent(AppConstants.currentAccountId));
  }

  void _navigateToAddCard() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddCardScreen()),
    ).then((_) {
      if (mounted) {
        _loadCards();
      }
    });
  }

  void _showDeleteConfirmation(BuildContext context, String cardId) {
    final cardBloc = context.read<CardBloc>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Card'),
        content: const Text('Are you sure you want to delete this card?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              cardBloc.add(DeleteCardEvent(cardId, AppConstants.currentAccountId));
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToAddCard,
          ),
        ],
      ),
      body: BlocConsumer<CardBloc, CardState>(
        listener: (context, state) {
          if (state is CardOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is CardError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message, style: const TextStyle(color: Colors.white)),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        buildWhen: (previous, current) =>
            current is CardLoading || current is CardsLoaded || current is CardError,
        builder: (context, state) {
          if (state is CardsLoaded) {
            _cards = state.cards;
          }

          if (state is CardLoading && _cards.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_cards.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.credit_card_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No cards found', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _navigateToAddCard,
                    child: const Text('Add a Card'),
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                itemCount: _cards.length,
                itemBuilder: (context, index) {
                  final card = _cards[index];
                  return CardWidget(
                    card: card,
                    onFreezeToggle: () {
                      context.read<CardBloc>().add(
                            FreezeCardEvent(card.id, !card.isFrozen, AppConstants.currentAccountId),
                          );
                    },
                    onDelete: () {
                      _showDeleteConfirmation(context, card.id);
                    },
                  );
                },
              ),
              if (state is CardLoading)
                Container(
                  color: Colors.black.withValues(alpha: 0.15),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }
}
