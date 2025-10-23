import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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
    _loadTransactions();
  }

  void _loadTransactions() {
    _bloc.add(FetchTransactionsRequested());
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    if (!mounted) return;
    context.go('/login');
  }

  Future<void> _navigateToAddOrEdit(String? transactionId) async {
    final updated = await context.push<bool>(
      '/add-transaction',
      extra: transactionId,
    );

    if (updated == true && mounted) {
      _loadTransactions();
    }
  }

  Future<void> _navigateToDetail(Transaction tx) async {
    final updatedTransaction = await context.push<Transaction>(
      '/transaction-detail',
      extra: tx,
    );

    if (updatedTransaction != null && mounted) {
      _loadTransactions(); // Dispara FetchTransactionsRequested()
    }
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

          Widget content = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomIconButton(
                label: 'Agregar',
                icon: Icons.add,
                backgroundColor: Colors.blueAccent,
                onPressed: () => _navigateToAddOrEdit(null),
              ),
              const SizedBox(height: 16),
              TransactionFilterChips(
                selectedType: selectedType,
                onSelected: (value) {
                  setState(() {
                    selectedType = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BlocConsumer<TransactionBloc, TransactionState>(
                  bloc: _bloc,
                  listener: (context, state) {
                    if (!mounted) return;

                    if (state is TransactionError) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(state.message)));
                    }
                  },
                  builder: (context, state) {
                    List<Transaction> currentList = [];
                    if (state is TransactionListSuccess) {
                      currentList = state.transactions;
                    }

                    final filteredTransactions =
                        selectedType == null
                            ? currentList
                            : currentList
                                .where((tx) => tx.type == selectedType)
                                .toList();

                    if (state is TransactionLoading &&
                        filteredTransactions.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

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
                  },
                ),
              ),
            ],
          );

          // Pantallas anchas
          if (isWide) {
            content = Row(
              children: [
                Container(
                  width: 300,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CustomIconButton(
                        label: 'Agregar',
                        icon: Icons.add,
                        backgroundColor: Colors.blueAccent,
                        onPressed: () => _navigateToAddOrEdit(null),
                      ),
                      const SizedBox(height: 20),
                      TransactionFilterChips(
                        selectedType: selectedType,
                        onSelected: (value) {
                          setState(() {
                            selectedType = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1, color: Colors.grey),
                Expanded(
                  child: BlocBuilder<TransactionBloc, TransactionState>(
                    bloc: _bloc,
                    builder: (context, state) {
                      List<Transaction> currentList = [];
                      if (state is TransactionListSuccess) {
                        currentList = state.transactions;
                      }

                      final filteredTransactions =
                          selectedType == null
                              ? currentList
                              : currentList
                                  .where((tx) => tx.type == selectedType)
                                  .toList();

                      if (filteredTransactions.isEmpty) {
                        return const Center(
                          child: Text('No hay transacciones'),
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
