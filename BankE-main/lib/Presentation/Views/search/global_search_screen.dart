import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../bloc/search/search_bloc.dart';
import '../../bloc/search/search_event.dart';
import '../../bloc/search/search_state.dart';

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({Key? key}) : super(key: key);

  @override
  _GlobalSearchScreenState createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    if (query.trim().isNotEmpty) {
      context.read<SearchBloc>().add(PerformSearchEvent(query.trim()));
    } else {
      context.read<SearchBloc>().add(const ClearSearchEvent());
    }
  }

  void _onScroll() {
    final searchBloc = context.read<SearchBloc>();
    final state = searchBloc.state;
    if (state is SearchLoaded && state.hasMore) {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        searchBloc.add(PerformSearchEvent(state.query, isLoadMore: true));
      }
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'transaction':
        return Icons.swap_horiz_rounded;
      case 'beneficiary':
        return Icons.person_outline_rounded;
      case 'bill':
        return Icons.receipt_long_rounded;
      case 'notification':
        return Icons.notifications_none_rounded;
      case 'card':
        return Icons.credit_card_rounded;
      default:
        return Icons.search_rounded;
    }
  }

  Color _getTypeColor(BuildContext context, String type) {
    final theme = Theme.of(context);
    switch (type.toLowerCase()) {
      case 'transaction':
        return Colors.green;
      case 'beneficiary':
        return Colors.blue;
      case 'bill':
        return Colors.orange;
      case 'notification':
        return Colors.purple;
      case 'card':
        return theme.primaryColor;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Global Search'),
      ),
      body: Column(
        children: [
          // Search Input Field
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search transactions, cards, bills, beneficiaries...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<SearchBloc>().add(const ClearSearchEvent());
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onChanged: _onSearch,
            ),
          ),

          // Results list
          Expanded(
            child: BlocBuilder<SearchBloc, SearchState>(
              builder: (context, state) {
                if (state is SearchInitial) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_rounded, size: 70, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'Type something to start searching...',
                          style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                if (state is SearchLoading && !state.isLoadMore) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is SearchLoaded) {
                  final results = state.results;
                  if (results.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off_rounded, size: 70, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            'No results found for "${state.query}"',
                            style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: results.length + (state.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == results.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final item = results[index];
                      final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(item.date.toLocal());
                      final typeIcon = _getTypeIcon(item.type);
                      final typeColor = _getTypeColor(context, item.type);

                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: typeColor.withValues(alpha: 0.1),
                            child: Icon(typeIcon, color: typeColor),
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: typeColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  item.type,
                                  style: TextStyle(color: typeColor, fontWeight: FontWeight.bold, fontSize: 10),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(item.subtitle, style: const TextStyle(fontSize: 13)),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    dateStr,
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                  if (item.extraInfo != null)
                                    Text(
                                      item.extraInfo!,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: item.extraInfo!.toLowerCase() == 'credit' || item.extraInfo!.toLowerCase() == 'active'
                                            ? Colors.green
                                            : Colors.grey,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }

                if (state is SearchError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Search failed: ${state.message}'),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => _onSearch(_searchController.text),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
