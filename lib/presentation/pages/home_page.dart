import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:prueba_tecnica_finanzas_frontend2/core/utils/constants.dart';
import 'package:prueba_tecnica_finanzas_frontend2/presentation/widgets/custom_app_bar.dart';
import 'package:prueba_tecnica_finanzas_frontend2/presentation/widgets/custom_icon_button.dart';
import 'package:prueba_tecnica_finanzas_frontend2/presentation/widgets/transaction_card.dart';
import 'package:prueba_tecnica_finanzas_frontend2/presentation/widgets/transaction_filter_chips.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prueba_tecnica_finanzas_frontend2/domain/models/transaction.dart';
import 'package:prueba_tecnica_finanzas_frontend2/domain/models/transaction_enums.dart';
import '../blocs/transaction/transaction_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TransactionBloc _bloc;
  TransactionType? selectedType;
  final formatter = NumberFormat.currency(locale: 'es_CO', symbol: '\$');

  @override
  void initState() {
    super.initState();
    _bloc = context.read<TransactionBloc>();
  }

  /// Filtra la lista de transacciones según el tipo seleccionado
  List<Transaction> _getFilteredTransactions(List<Transaction> transactions) {
    if (selectedType == null) return transactions;
    return transactions.where((tx) => tx.type == selectedType).toList();
  }

  /// Helper para mostrar SnackBars
  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(kTokenKey);
    if (!mounted) return;
    context.go('/login');
  }

  Future<void> _navigateToAddOrEdit(String? transactionId) async {
    final updated = await context.push<bool>(
      '/add-transaction',
      extra: transactionId,
    );
    if (updated == true && mounted) {
      _bloc.add(FetchTransactionsRequested()); // Recargar lista si hubo cambios
    }
  }

  Future<void> _navigateToDetail(Transaction tx) async {
    final updatedTransaction = await context.push<Transaction>(
      '/transaction-detail',
      extra: tx,
    );
    if (updatedTransaction != null && mounted) {
      _bloc.add(FetchTransactionsRequested());
    }
  }

  /// Botones y filtros repetidos en pantallas anchas
  Widget _sidePanel() {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: CustomIconButton(
                  label: 'Agregar',
                  icon: Icons.add,
                  backgroundColor: Colors.blueAccent,
                  onPressed: () => _navigateToAddOrEdit(null),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomIconButton(
                  label: 'Estadísticas',
                  icon: Icons.bar_chart,
                  backgroundColor: Colors.green,
                  onPressed: () => context.go('/statistics'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TransactionFilterChips(
            selectedType: selectedType,
            onSelected: (value) => setState(() => selectedType = value),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Mis Transacciones',
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: _logout,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 800;

          Widget transactionList(List<Transaction> currentList) {
            final filteredTransactions = _getFilteredTransactions(currentList);

            if (filteredTransactions.isEmpty) {
              return const Center(
                child: Text('No hay transacciones para mostrar'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredTransactions.length,
              itemBuilder: (context, index) {
                final tx = filteredTransactions[index];
                return TransactionCard(
                  transaction: tx,
                  onTap: () => _navigateToDetail(tx),
                );
              },
            );
          }

          Widget content = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: CustomIconButton(
                      label: 'Agregar',
                      icon: Icons.add,
                      backgroundColor: Colors.blueAccent,
                      onPressed: () => _navigateToAddOrEdit(null),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomIconButton(
                      label: 'Estadísticas',
                      icon: Icons.bar_chart,
                      backgroundColor: Colors.green,
                      onPressed: () => context.go('/statistics'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TransactionFilterChips(
                selectedType: selectedType,
                onSelected: (value) => setState(() => selectedType = value),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BlocConsumer<TransactionBloc, TransactionState>(
                  bloc: _bloc,
                  listener: (context, state) {
                    if (state is TransactionError) _showMessage(state.message);
                  },
                  builder: (context, state) {
                    List<Transaction> currentList = [];
                    if (state is TransactionListSuccess)
                      currentList = state.transactions;

                    if (state is TransactionLoading && currentList.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        _bloc.add(FetchTransactionsRequested());
                      },
                      child: transactionList(currentList),
                    );
                  },
                ),
              ),
            ],
          );

          if (isWide) {
            content = Row(
              children: [
                _sidePanel(),
                const VerticalDivider(width: 1, color: Colors.grey),
                Expanded(
                  child: BlocBuilder<TransactionBloc, TransactionState>(
                    bloc: _bloc,
                    builder: (context, state) {
                      List<Transaction> currentList = [];
                      if (state is TransactionListSuccess)
                        currentList = state.transactions;
                      if (state is TransactionLoading && currentList.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return RefreshIndicator(
                        onRefresh: () async {
                          _bloc.add(FetchTransactionsRequested());
                        },
                        child: transactionList(currentList),
                      );
                    },
                  ),
                ),
              ],
            );
          }

          return Padding(padding: const EdgeInsets.all(16), child: content);
        },
      ),
    );
  }
}
