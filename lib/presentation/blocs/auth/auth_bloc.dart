import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prueba_tecnica_finanzas_frontend2/domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final token = await authRepository.login(event.email, event.password);
        if (token != null) {
          emit(Authenticated());
        } else {
          emit(AuthError('Email o contraseña incorrectos'));
        }
      } catch (e) {
        emit(AuthError('Error al iniciar sesión'));
      }
    });
  }
}
