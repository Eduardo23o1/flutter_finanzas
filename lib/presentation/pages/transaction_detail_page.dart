import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:prueba_tecnica_finanzas_frontend2/domain/models/transaction.dart';
import 'package:prueba_tecnica_finanzas_frontend2/domain/models/transaction_category_extension.dart';
import 'package:prueba_tecnica_finanzas_frontend2/domain/models/transaction_enums.dart';
import 'package:prueba_tecnica_finanzas_frontend2/presentation/blocs/transaction/transaction_bloc.dart';
import 'package:prueba_tecnica_finanzas_frontend2/presentation/widgets/custom_back_header.dart';
import 'package:prueba_tecnica_finanzas_frontend2/presentation/widgets/custom_icon_button.dart';
import 'package:prueba_tecnica_finanzas_frontend2/presentation/widgets/transaction_card_detail.dart';

/// Extensiones para traducción y iconos
extension TransactionTypeExtension on TransactionType {
  String get label => transactionTypeTranslations[this] ?? name;
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

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transacción eliminada correctamente')),
    );

    context.pop(_currentTransaction);
  }

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
              leading: Icon(_currentTransaction.category.icon),
              title: const Text('Categoría'),
              subtitle: Text(_currentTransaction.category.label),
            ),
          ],
        ),
      ),
    );
  }

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
