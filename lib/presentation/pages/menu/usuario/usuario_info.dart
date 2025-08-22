import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ecoapp/data/repositories/network/api_service.dart';

class UsuarioInfo extends StatefulWidget {
  const UsuarioInfo({super.key});

  @override
  UsuarioInfoState createState() => UsuarioInfoState();
}

class UsuarioInfoState extends State<UsuarioInfo> {
  late Future<Map<String, dynamic>> _userData;
  bool hasNotifications = true;

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    debugPrint("Current user: ${currentUser?.email ?? 'No user'}");
    _userData = fetchUserData();
    printFirebaseToken();
  }

  Future<Map<String, dynamic>> fetchUserData() async {
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      debugPrint("TOKEN in fetchUserData: $token");

      if (token == null) {
        debugPrint("⚠️ No token available - user not authenticated");
        return {"error": "Usuario no autenticado"};
      }

      final apiService = ApiService();
      final baseUrl = await apiService.resolveBaseUrl();
      debugPrint("Using baseUrl: $baseUrl");

      final response = await Dio().get(
        '$baseUrl/user',
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );
      debugPrint("Response received: ${response.statusCode}");
      return response.data;
    } catch (e) {
      debugPrint("❌ Error fetching user data: $e");
      return {"error": "Error al obtener datos del usuario"};
    }
  }

  void printFirebaseToken() async {
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      debugPrint("TOKEN: $token");
    } catch (e) {
      debugPrint("Error getting token: $e");
    }
  }

  IconData _getGenderIcon(String gender) {
    switch (gender.toLowerCase()) {
      case 'masculino':
        return Icons.face;
      case 'femenino':
        return Icons.face_3;
      default:
        return Icons.face_4;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _userData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.containsKey("error")) {
          return const Center(child: Text("No se pudo cargar el usuario"));
        }

        var userData = snapshot.data!;
        Color avatarColor =
            Color(int.parse(userData['avatarColor'] ?? '0xFF0067AC'));

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0067AC),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFC6DA23),
                    width: 3.0,
                  ),
                ),
              ),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: Icon(
                      userData['gender']?.toLowerCase() == 'masculino'
                          ? Icons.male
                          : userData['gender']?.toLowerCase() == 'femenino'
                              ? Icons.female
                              : Icons.transgender,
                      size: 28,
                    ),
                    color: Colors.white,
                    onPressed: () {},
                  ),
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications),
                        color: Colors.white,
                        onPressed: () {
                          Navigator.pushNamed(context, '/notificaciones-lista');
                        },
                      ),
                      if (hasNotifications)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Text(
                              '1',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromRGBO(0, 0, 0, 0.05)
                          .withAlpha((0.1 * 255).toInt()),
                      blurRadius: 20,
                      spreadRadius: 5,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.grey.withAlpha((0.1 * 255).toInt()),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: avatarColor,
                      radius: 45,
                      child: Icon(
                        _getGenderIcon(userData['gender'] ?? 'otro'),
                        color: Colors.white,
                        size: 45,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "${userData['name']} ${userData['lastName']}",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0067AC),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            userData['email'] ?? '',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }
}
