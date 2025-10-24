import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:prueba_tecnica_finanzas_frontend2/domain/models/transaction_enums.dart';
import 'package:prueba_tecnica_finanzas_frontend2/presentation/blocs/transaction/transaction_bloc.dart';
import 'package:prueba_tecnica_finanzas_frontend2/domain/models/transaction.dart';
import '../mocks/mocks.mocks.dart';

void main() {
  late MockTransactionRepository mockRepository;
  late TransactionBloc bloc;

  setUp(() {
    mockRepository = MockTransactionRepository();
    bloc = TransactionBloc(repository: mockRepository);
  });

  tearDown(() {
    bloc.close();
  });

  final testTransaction = Transaction(
    id: '1',
    userId: 'user123',
    amount: 100.0,
    type: TransactionType.income,
    category: TransactionCategory.salary,
    description: 'Salario mensual',
    date: DateTime.now(),
  );

  final updatedTransaction = Transaction(
    id: '1',
    userId: 'user123',
    amount: 200.0,
    type: TransactionType.income,
    category: TransactionCategory.salary,
    description: 'Salario actualizado',
    date: DateTime.now(),
  );

  final transactionList = [testTransaction];

  // =================================
  // CREAR TRANSACCIÓN
  // =================================
  blocTest<TransactionBloc, TransactionState>(
    'emite [TransactionLoading, TransactionCreated] al crear una transacción',
    build: () {
      when(
        mockRepository.createTransaction(any),
      ).thenAnswer((_) async => testTransaction);
      return bloc;
    },
    act: (bloc) => bloc.add(CreateTransactionRequested(testTransaction)),
    expect: () => [TransactionLoading(), TransactionCreated(testTransaction)],
    verify: (_) {
      verify(mockRepository.createTransaction(testTransaction)).called(1);
    },
  );

  // =================================
  // ACTUALIZAR TRANSACCIÓN
  // =================================
  blocTest<TransactionBloc, TransactionState>(
    'emite [TransactionLoading, TransactionUpdated] al actualizar una transacción',
    build: () {
      when(
        mockRepository.updateTransaction(any),
      ).thenAnswer((_) async => updatedTransaction);
      return bloc;
    },
    act: (bloc) => bloc.add(UpdateTransactionRequested(updatedTransaction)),
    expect:
        () => [TransactionLoading(), TransactionUpdated(updatedTransaction)],
    verify: (_) {
      verify(mockRepository.updateTransaction(updatedTransaction)).called(1);
    },
  );

  // =================================
  // LISTAR TRANSACCIONES
  // =================================
  blocTest<TransactionBloc, TransactionState>(
    'emite [TransactionLoading, TransactionListSuccess] al obtener transacciones',
    build: () {
      when(
        mockRepository.getTransactions(),
      ).thenAnswer((_) async => transactionList);
      return bloc;
    },
    act: (bloc) => bloc.add(FetchTransactionsRequested()),
    expect:
        () => [TransactionLoading(), TransactionListSuccess(transactionList)],
    verify: (_) {
      verify(mockRepository.getTransactions()).called(1);
    },
  );

  // =================================
  // ELIMINAR TRANSACCIÓN
  // =================================
  blocTest<TransactionBloc, TransactionState>(
    'emite [TransactionLoading, TransactionDeleted] al eliminar una transacción',
    build: () {
      when(
        mockRepository.deleteTransaction(testTransaction.id!),
      ).thenAnswer((_) async => true);
      return bloc;
    },
    act: (bloc) => bloc.add(DeleteTransactionRequested(testTransaction.id!)),
    expect:
        () => [TransactionLoading(), TransactionDeleted(testTransaction.id!)],
    verify: (_) {
      verify(mockRepository.deleteTransaction(testTransaction.id!)).called(1);
    },
  );

  // =================================
  // OBTENER TRANSACCIÓN POR ID
  // =================================
  blocTest<TransactionBloc, TransactionState>(
    'emite [TransactionLoading, TransactionLoaded] al obtener transacción por id',
    build: () {
      when(
        mockRepository.getTransactionById(testTransaction.id!),
      ).thenAnswer((_) async => testTransaction);
      return bloc;
    },
    act: (bloc) => bloc.add(FetchTransactionByIdRequested(testTransaction.id!)),
    expect: () => [TransactionLoading(), TransactionLoaded(testTransaction)],
    verify: (_) {
      verify(mockRepository.getTransactionById(testTransaction.id!)).called(1);
    },
  );
}
