import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:prueba_tecnica_finanzas_frontend2/presentation/blocs/auth/auth_bloc.dart';
import 'package:prueba_tecnica_finanzas_frontend2/presentation/blocs/auth/auth_event.dart';
import 'package:prueba_tecnica_finanzas_frontend2/presentation/blocs/auth/auth_state.dart';
import 'package:prueba_tecnica_finanzas_frontend2/presentation/widgets/custom_button.dart';
import 'package:prueba_tecnica_finanzas_frontend2/presentation/widgets/custom_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRegisterPressed(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      context.read<AuthBloc>().add(
        RegisterRequested(email: email, password: password),
      );
    }
  }

  void _authListener(BuildContext context, AuthState state) {
    if (state is Authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Registro exitoso'),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
      context.replace('/login'); // Evita volver atrás
    } else if (state is AuthError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Text(state.message),
            ],
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Widget _authBuilder(BuildContext context, AuthState state) {
    final loading = state is AuthLoading;
    return _RegisterForm(
      formKey: _formKey,
      emailController: _emailController,
      passwordController: _passwordController,
      isPasswordVisible: _isPasswordVisible,
      onTogglePasswordVisibility: () {
        setState(() => _isPasswordVisible = !_isPasswordVisible);
      },
      onRegisterPressed: () => _onRegisterPressed(context),
      loading: loading,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 600;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? size.width * 0.25 : 24,
            ),
            child: BlocConsumer<AuthBloc, AuthState>(
              listener: _authListener,
              builder: _authBuilder,
            ),
          ),
        ),
      ),
    );
  }
}

class _RegisterForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isPasswordVisible;
  final VoidCallback onTogglePasswordVisibility;
  final VoidCallback onRegisterPressed;
  final bool loading;

  const _RegisterForm({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.isPasswordVisible,
    required this.onTogglePasswordVisibility,
    required this.onRegisterPressed,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Crea tu cuenta',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Regístrate para continuar',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 32),
          Form(
            key: formKey,
            child: Column(
              children: [
                CustomTextField(
                  controller: emailController,
                  label: 'Correo electrónico',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa tu correo';
                    }
                    final emailRegex = RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    );
                    if (!emailRegex.hasMatch(value)) {
                      return 'Correo no válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: passwordController,
                  label: 'Contraseña',
                  isPassword: !isPasswordVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.blueAccent,
                    ),
                    onPressed: onTogglePasswordVisibility,
                  ),
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Mínimo 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                loading
                    ? const CircularProgressIndicator()
                    : CustomButton(
                      text: 'Registrarse',
                      onPressed: onRegisterPressed,
                      backgroundColor: Colors.blueAccent,
                      textColor: Colors.white,
                    ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.go('/login'),
            child: const Text(
              '¿Ya tienes cuenta? Inicia sesión',
              style: TextStyle(color: Colors.blueAccent),
            ),
          ),
        ],
      ),
    );
  }
}
