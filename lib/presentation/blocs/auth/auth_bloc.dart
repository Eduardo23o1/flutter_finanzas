import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prueba_tecnica_finanzas_frontend2/core/utils/constants.dart';
import 'package:prueba_tecnica_finanzas_frontend2/domain/repositories/auth_repository.dart';
import 'package:prueba_tecnica_finanzas_frontend2/presentation/blocs/auth/auth_event.dart';
import 'package:prueba_tecnica_finanzas_frontend2/presentation/blocs/auth/auth_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final token = await authRepository.register(event.email, event.password);

      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(kTokenKey, token);

        emit(Authenticated());
      } else {
        emit(AuthError('Error al registrar usuario'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final token = await authRepository.login(event.email, event.password);

      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(kTokenKey, token);

        emit(Authenticated());
      } else {
        emit(AuthError('Email o contraseña incorrectos'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
