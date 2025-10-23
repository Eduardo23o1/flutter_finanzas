import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:prueba_tecnica_finanzas_frontend2/domain/models/transaction.dart';
import 'package:prueba_tecnica_finanzas_frontend2/domain/models/transaction_enums.dart';
import 'package:prueba_tecnica_finanzas_frontend2/presentation/blocs/transaction/transaction_bloc.dart';
import 'package:prueba_tecnica_finanzas_frontend2/presentation/widgets/custom_back_header.dart';
import 'package:prueba_tecnica_finanzas_frontend2/presentation/widgets/custom_icon_button.dart';
import 'package:prueba_tecnica_finanzas_frontend2/presentation/widgets/transaction_card_detail.dart';

/// Helper Extensions para traducir enums
extension TransactionTypeExtension on TransactionType {
  String get label => this == TransactionType.income ? 'Ingreso' : 'Gasto';
}

extension TransactionCategoryExtension on TransactionCategory {
  String get label {
    switch (this) {
      case TransactionCategory.food:
        return 'Comida';
      case TransactionCategory.transport:
        return 'Transporte';
      case TransactionCategory.entertainment:
        return 'Entretenimiento';
      case TransactionCategory.shopping:
        return 'Compras';
      case TransactionCategory.health:
        return 'Salud';
      case TransactionCategory.education:
        return 'Educación';
      case TransactionCategory.salary:
        return 'Salario';
      case TransactionCategory.other:
        return 'Otros';
    }
  }

  IconData get icon {
    switch (this) {
      case TransactionCategory.food:
        return Icons.restaurant;
      case TransactionCategory.transport:
        return Icons.directions_bus;
      case TransactionCategory.entertainment:
        return Icons.movie;
      case TransactionCategory.shopping:
        return Icons.shopping_bag;
      case TransactionCategory.health:
        return Icons.local_hospital;
      case TransactionCategory.education:
        return Icons.school;
      case TransactionCategory.salary:
        return Icons.attach_money;
      case TransactionCategory.other:
        return Icons.more_horiz;
    }
  }
}

class TransactionDetailPage extends StatefulWidget {
  final Transaction transaction;

  const TransactionDetailPage({super.key, required this.transaction});

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  late Transaction _currentTransaction;
  late final TransactionBloc _bloc;

  @override
  void initState() {
    super.initState();
    _currentTransaction = widget.transaction;
    _bloc = context.read<TransactionBloc>();
  }

  String get formattedDate => DateFormat(
    'EEEE, dd MMMM yyyy HH:mm',
    'es_CO',
  ).format(_currentTransaction.date);

  /// Confirmar eliminación
  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Confirmar eliminación'),
            content: const Text(
              '¿Está seguro que desea eliminar esta transacción?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    if (_currentTransaction.id == null) return;

    _bloc.add(DeleteTransactionRequested(_currentTransaction.id!));

    // Escuchar cambios de estado para mostrar SnackBar de éxito/error
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transacción eliminada correctamente')),
    );

    context.pop(_currentTransaction);
  }

  /// Editar transacción
  Future<void> _editTransaction() async {
    final updatedTransaction = await context.push<Transaction>(
      '/add-transaction',
      extra: _currentTransaction.id,
    );

    if (updatedTransaction != null && mounted) {
      setState(() => _currentTransaction = updatedTransaction);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transacción actualizada correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  /// Card de información adicional
  Widget _buildInfoCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: const Text('Descripción'),
              subtitle: Text(
                _currentTransaction.description.isNotEmpty
                    ? _currentTransaction.description
                    : 'Sin descripción',
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.calendar_today_outlined),
              title: const Text('Fecha'),
              subtitle: Text(formattedDate),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.category_outlined),
              title: const Text('Categoría'),
              subtitle: Text(_currentTransaction.category.label),
            ),
          ],
        ),
      ),
    );
  }

  /// Botones de acción
  Widget _buildActions() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: [
        CustomIconButton(
          label: 'Editar',
          icon: Icons.edit,
          backgroundColor: Colors.blueAccent,
          onPressed: _editTransaction,
        ),
        CustomIconButton(
          label: 'Eliminar',
          icon: Icons.delete,
          backgroundColor: Colors.redAccent,
          iconColor: Colors.white,
          onPressed: _confirmDelete,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final contentWidth =
              constraints.maxWidth < 600
                  ? double.infinity
                  : constraints.maxWidth < 1000
                  ? constraints.maxWidth * 0.7
                  : 600.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: SizedBox(
                width: contentWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 25),
                    CustomBackHeader(
                      text: "Detalle de Transacción",
                      backgroundColor: Colors.blueAccent,
                      iconColor: Colors.black,
                      textColor: Colors.black,
                      onBack: () => context.pop(_currentTransaction),
                    ),
                    const SizedBox(height: 20),
                    TransactionCardDetail(transaction: _currentTransaction),
                    const SizedBox(height: 30),
                    _buildInfoCard(),
                    const SizedBox(height: 30),
                    _buildActions(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
