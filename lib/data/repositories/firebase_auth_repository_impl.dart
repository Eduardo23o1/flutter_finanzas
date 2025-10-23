import 'package:firebase_auth/firebase_auth.dart';
import 'package:prueba_tecnica_finanzas_frontend2/domain/repositories/auth_repository.dart';

class FirebaseAuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Future<String?> login(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return await userCredential.user?.getIdToken();
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleFirebaseError(e));
    }
  }

  @override
  Future<String?> register(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return await userCredential.user?.getIdToken();
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleFirebaseError(e));
    }
  }

  String _handleFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'El correo ya está registrado.';
      case 'invalid-email':
        return 'El correo no es válido.';
      case 'weak-password':
        return 'La contraseña es demasiado débil.';
      default:
        return 'Ocurrió un error: ${e.message}';
    }
  }
}
