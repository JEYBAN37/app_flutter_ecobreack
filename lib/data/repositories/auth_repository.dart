import 'dart:async';
import 'dart:convert';
import 'package:ecoapp/data/repositories/notification_settings_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:ecoapp/data/repositories/network/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add this import
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'dart:developer' as developer;

class UserToSave {
  final String password;
  final String name;
  final String lastName;
  final String displayName;
  final String email;
  final String gender;
  final String phoneNumber;
  final int avatarColor;

  UserToSave({
    required this.password,
    required this.name,
    required this.lastName,
    required this.displayName,
    required this.email,
    required this.gender,
    required this.phoneNumber,
    required this.avatarColor,
  });
}

class AuthRepository {
  // Verifica si existe un token guardado en el storage

  final _apiService = ApiService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _backendUrl = "https://backeco-zwl8.onrender.com";
  static const _storage = FlutterSecureStorage();
  final String provisionalEmail = "usuario@prueba.com";
  final String provisionalPassword = "123456";
  final http.Client _client = http.Client();
  final Duration _timeout = const Duration(seconds: 30);
  final NotificationSettingsService _notificationSettingsService =
      NotificationSettingsService();

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
      // Obtener el token de Firebase y guardarlo en local storage
      String? idToken = await userCredential.user?.getIdToken();
      if (idToken != null) {
        await _storage.write(key: 'user_token', value: idToken);
        await _storage.write(key: 'user_email', value: email);
        await _storage.write(key: 'user_password', value: password);
      }

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
  Future<bool> registerUserWithEmailAndPassword(UserToSave user) async {
    try {
      final response = await _apiService.postRequest("admin/users/register", {
        "name": user.name,
        "lastName": user.lastName,
        "displayName": "${user.name} ${user.lastName}",
        "email": user.email,
        "password": user.password,
        "gender": user.gender,
        "phoneNumber": user.phoneNumber,
        "avatarColor": user.avatarColor,
      });

      debugPrint('📡 Respuesta de registro: $response');

      if (response!.contains('Usuario creado correctamente')) {
        bool signInSuccess = await signIn(user.email, user.password);
        final id = await _storage.read(key: 'admin_userId');
        await _notificationSettingsService.createNotificationChannel(id);
        return signInSuccess;
      }
      return false;
    } catch (e) {
      developer.log("Error en registro: $e");
      return false;
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

  String _getOrigin() {
    if (kIsWeb) {
      return 'https://backeco-zwl8.onrender.com';
    }
    return 'https://backeco-zwl8.onrender.com';
  }

  Future<void> requestNotificationPermission() async {
    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ Permiso de notificaciones concedido');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('⚠️ Permiso provisional de notificaciones');
    } else {
      print('❌ Permiso de notificaciones denegado');
    }
  }

  Future<void> setupFCMListeners() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Foreground (cuando la app está abierta)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print(
          '📩 Notificación recibida en foreground: ${message.notification?.title}');
    });

    // Background (cuando la app está en segundo plano y el usuario toca la notificación)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('🚀 Notificación abrió la app: ${message.notification?.title}');
    });

    // Terminated (cuando la app estaba cerrada y se abrió por una notificación)
    RemoteMessage? initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      print(
          '📲 La app se abrió desde notificación: ${initialMessage.notification?.title}');
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      final response = await authenticateAdmin(email, password);
      if (response['status'] == true) {
        final token = response['data']['token'];
        await FirebaseAuth.instance.signInWithCustomToken(token);
        final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
        debugPrint('🔐 Admin authenticated, token obtained: $idToken');
        await _storage.delete(key: 'admin_token');
        await _storage.write(key: 'admin_token', value: idToken);
        // Store credentials for refresh
        await _storage.write(key: 'admin_email', value: email);
        await _storage.write(key: 'admin_password', value: password);
        // Guardar los datos de usuario en el storage como JSON
        await _storage.write(
          key: 'admin_userdata',
          value: jsonEncode(response['data']['userdata']),
        );

        await _storage.write(
          key: 'admin_userId',
          value: response['data']['id'],
        );

        await setupPushNotifications(response['data']['id']);
        debugPrint(
            '✅ Datos de usuario almacenados exitosamente: ${_storage.read(key: 'admin_userdata')}');
        debugPrint('✅ Token almacenado exitosamente');
        return true;
      }
      return false;
    } catch (e) {
      developer.log("Error al iniciar sesión: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>> authenticateAdmin(
    String email,
    String password,
  ) async {
    try {
      debugPrint('🔐 Autenticando admin con email: $email');
      debugPrint('🔐 Intentando autenticar admin en: $_backendUrl/admin/login');

      final response = await _client
          .post(
            Uri.parse('$_backendUrl/admin/login'),
            headers: {
              'Content-Type': 'application/json',
              'Origin': _getOrigin(),
              'Accept': 'application/json',
            },
            body: json.encode({'email': email, 'password': password}),
          )
          .timeout(_timeout);

      debugPrint('📡 Código de respuesta: ${response.statusCode}');
      final responseData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['status'] == true) {
          debugPrint('✅ Autenticación exitosa');
          return responseData;
        }
      }

      throw Exception(responseData['message'] ?? 'Error de autenticación');
    } catch (e, stackTrace) {
      debugPrint('❌ Error en autenticación: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      rethrow;
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

  Future<void> setupPushNotifications(String userId) async {
    // Guardar el token actual
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await FirebaseFirestore.instance.collection('devices').doc(token).set({
        'userId': userId,
        'deviceToken': token,
        'createdAt': FieldValue.serverTimestamp(),
        'platform': 'android',
      });
    }

    // Escuchar si el token cambia (ej: reinstalar app)
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      FirebaseFirestore.instance.collection('devices').doc(newToken).set({
        'userId': userId,
        'deviceToken': newToken,
        'updatedAt': FieldValue.serverTimestamp(),
        'platform': 'android',
      });
    });
  }
}
