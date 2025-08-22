import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ecoapp/data/repositories/network/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add this import
import 'dart:developer' as developer;

class AuthRepository {
  final _apiService = ApiService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _backendUrl = "http://localhost:4300/auth";
  final String provisionalEmail = "usuario@prueba.com";
  final String provisionalPassword = "123456";

  // Registrar usuario en Firebase
  Future<User?> registerUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } catch (e) {
      developer.log("Error al registrar en Firebase: $e");
      return null;
    }
  }

  // Iniciar sesión en Firebase
  Future<User?> loginUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      developer.log("Error al iniciar sesión: $e");
      return null;
    }
  }

  // Enviar Token a NestJS para validación
  Future<String> verifyTokenWithBackend() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return "No hay usuario autenticado";

      String? token = await user.getIdToken();
      final response = await http.post(
        Uri.parse("$_backendUrl/verify"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"token": token}),
      );

      return response.statusCode == 200
          ? "Token válido en backend"
          : "Token inválido en backend";
    } catch (e) {
      developer.log("Error en verificación de token: $e");
      return "Error en verificación";
    }
  }

  // Registrar usuario con datos adicionales
  Future<String> registerUserWithEmailAndPassword(
    String email,
    String password, {
    required String name,
    required String lastName,
    required String gender,
    required int avatarColor,
  }) async {
    try {
      final response = await _apiService.postRequest("auth/register", {
        "name": name,
        "lastName": lastName,
        "email": email,
        "password": password,
        "gender": gender,
        "avatarColor": avatarColor,
      });

      return response?['message'] ?? "Registro exitoso";
    } catch (e) {
      developer.log("Error en registro: $e");
      return "Error al registrar: $e";
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      developer.log("Error al cerrar sesión: $e");
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user != null;
    } catch (e) {
      developer.log("Error al iniciar sesión: $e");
      return false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Agregar método para recuperación de contraseña
  Future<String> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return "Se ha enviado un correo de recuperación. Revisa tu bandeja de entrada.";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return "No hay un usuario registrado con este correo.";
      }
      return "Ocurrió un error. Intenta de nuevo más tarde.";
    } catch (e) {
      return "Ocurrió un error inesperado. Intenta de nuevo más tarde.";
    }
  }
}
