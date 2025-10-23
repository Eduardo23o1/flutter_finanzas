import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:prueba_tecnica_finanzas_frontend2/core/di/injection.dart';
import 'package:prueba_tecnica_finanzas_frontend2/presentation/widgets/custom_back_header.dart';
import 'package:prueba_tecnica_finanzas_frontend2/presentation/widgets/custom_button.dart';
import 'package:prueba_tecnica_finanzas_frontend2/presentation/widgets/custom_dropdown.dart';
import 'package:prueba_tecnica_finanzas_frontend2/presentation/widgets/custom_text_field.dart';
import '../../domain/models/transaction.dart';
import '../../domain/models/transaction_enums.dart';
import '../blocs/transaction/transaction_bloc.dart';
import '../../core/api/api_client.dart';

class AddTransactionPage extends StatelessWidget {
  final String? transactionId;
  const AddTransactionPage({super.key, this.transactionId});

  @override
  Widget build(BuildContext context) {
    final isEditing = transactionId != null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomBackHeader(
              text:
                  isEditing
                      ? 'Actualiza los datos de tu transacción'
                      : 'Registra una nueva transacción financiera',
              backgroundColor: Colors.blueAccent,
              iconColor: Colors.black,
              textColor: Colors.black,
            ),
            Expanded(child: TransactionForm(transactionId: transactionId)),
          ],
        ),
      ),
    );
  }
}

class TransactionForm extends StatefulWidget {
  final String? transactionId;
  const TransactionForm({super.key, this.transactionId});

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  TransactionType? _selectedType;
  TransactionCategory? _selectedCategory;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.transactionId != null) {
      _loading = true;
      context.read<TransactionBloc>().add(
        FetchTransactionByIdRequested(widget.transactionId!),
      );
    }
  }

  String getUserId() {
    final token = sl<ApiClient>().token;
    if (token == null) return '';
    final payload = Jwt.parseJwt(token);
    return payload['user_id'] ?? '';
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedType == null || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione tipo y categoría')),
      );
      return;
    }

    final tx = Transaction(
      id: widget.transactionId,
      userId: getUserId(),
      amount: double.parse(_amountController.text),
      type: _selectedType!,
      category: _selectedCategory!,
      description: _descriptionController.text,
      date: DateTime.now(),
    );

    final bloc = context.read<TransactionBloc>();
    if (widget.transactionId == null) {
      bloc.add(CreateTransactionRequested(tx));
    } else {
      bloc.add(UpdateTransactionRequested(tx));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (!mounted) return;

        if (state is TransactionLoaded && widget.transactionId != null) {
          setState(() {
            _amountController.text = state.transaction.amount.toStringAsFixed(
              0,
            );
            _selectedType = state.transaction.type;
            _selectedCategory = state.transaction.category;
            _descriptionController.text = state.transaction.description;
            _loading = false;
          });
        }

        if (state is TransactionCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Transacción creada exitosamente'),
              backgroundColor: Colors.green.shade600,
            ),
          );
          context.pop(true);
        }

        if (state is TransactionUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Transacción actualizada correctamente'),
              backgroundColor: Colors.green.shade600,
            ),
          );
          context.pop(state.transaction);
        }

        if (state is TransactionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      },
      child:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : LayoutBuilder(
                builder: (context, constraints) {
                  final double screenWidth = constraints.maxWidth.toDouble();
                  double maxWidth = screenWidth < 600 ? double.infinity : 500;
                  return Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Container(
                        width: maxWidth,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.transactionId == null
                                    ? 'Nueva Transacción'
                                    : 'Editar Transacción',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              const SizedBox(height: 20),
                              CustomTextField(
                                controller: _amountController,
                                label: 'Monto',
                                inputType: InputValidationType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingrese un monto';
                                  }
                                  final parsed = double.tryParse(value);
                                  if (parsed == null || parsed <= 0) {
                                    return 'Ingrese un monto válido';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              CustomDropdown<TransactionType>(
                                value: _selectedType,
                                label: 'Tipo',
                                itemsMap: transactionTypeTranslations,
                                onChanged:
                                    (v) => setState(() => _selectedType = v),
                              ),

                              const SizedBox(height: 16),

                              CustomDropdown<TransactionCategory>(
                                value: _selectedCategory,
                                label: 'Categoría',
                                itemsMap: transactionCategoryTranslations,
                                onChanged:
                                    (v) =>
                                        setState(() => _selectedCategory = v),
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                controller: _descriptionController,
                                label: 'Descripción',
                              ),
                              const SizedBox(height: 25),
                              SizedBox(
                                width: double.infinity,
                                child: CustomButton(
                                  text:
                                      widget.transactionId == null
                                          ? 'Guardar'
                                          : 'Actualizar',
                                  onPressed: _onSubmit,
                                  backgroundColor: Colors.blueGrey,
                                  textColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
