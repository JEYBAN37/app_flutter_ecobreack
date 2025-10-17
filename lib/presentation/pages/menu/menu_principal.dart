import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:ecoapp/data/repositories/auth_repository.dart';
import 'package:ecoapp/data/repositories/network/api_service.dart';
import 'package:ecoapp/presentation/pages/menu/ajustes/calibration_screen.dart';
import 'package:flutter/material.dart';
import 'package:ecoapp/presentation/pages/menu/widgetsM/custom_bottom_bar.dart';
import 'package:ecoapp/core/route_observer.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuPrincipal extends StatefulWidget {
  const MenuPrincipal({super.key});

  @override
  State<MenuPrincipal> createState() => _MenuPrincipalState();
}

class _MenuPrincipalState extends State<MenuPrincipal> with RouteAware {
  final _storage = const FlutterSecureStorage();
  final authRepository = AuthRepository();
  final _apiService = ApiService();
  late Future<Map<String, dynamic>?> _userFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    // Se llama cuando regresas a esta pantalla
    setState(() {
      _userFuture = _getUserData();
    });
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _userFuture = _getUserData();
  }

  Future<Map<String, dynamic>?> _getUserData() async {
    final baseUrl = await _apiService.resolveBaseUrl();
    final token = await _storage.read(key: 'admin_token');
    try {
      final response = await Dio().get(
        '$baseUrl/admin/users/',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      print('Respuesta del backend: ${response}');
      await _storage.write(
        key: 'admin_userdata',
        value: jsonEncode(response.data['data']),
      );
      final userDataString = await _storage.read(key: 'admin_userdata');
      print('UserData guardado: $userDataString');
      if (userDataString != null) {
        return jsonDecode(userDataString) as Map<String, dynamic>;
      }
    } catch (e) {

      final pw = await _storage.read(key: 'admin_password');
      final em = await _storage.read(key: 'admin_email');
      if (pw == null || em == null) {
        // Si no hay credenciales guardadas, navega al login
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
        return null;
      }
      await _storage.delete(key: 'admin_token');
      await authRepository.signIn((await em)!, (await pw)!);
      debugPrint('relogin after error: $e');
      return _getUserData();
    }
    return null;
  }

  Future<bool> _checkCalibration() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("isCalibrated") ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (bool didPop, result) async {
        if (didPop) return;
        final shouldExit = await _showExitDialog(context);
        if (context.mounted && shouldExit) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.topLeft,
              colors: [
                Color.fromARGB(255, 255, 255, 255),
                Color.fromARGB(255, 255, 255, 255),
              ],
            ),
          ),
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    Positioned(
                      right: 0,
                      top: 0,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 300,
                        child: CustomPaint(
                          size: Size(MediaQuery.of(context).size.width, 200),
                          painter: HeaderPaintDiagonal(),
                        ),
                      ),
                    ),
                    Center(
                      child: FutureBuilder<bool>(
                        future: _checkCalibration(),
                        builder: (context, calibrationSnapshot) {
                          if (calibrationSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          if (calibrationSnapshot.hasError) {
                            return const Text('Error al cargar calibración');
                          }
                          final isCalibrated =
                              calibrationSnapshot.data ?? false;
                          if (!isCalibrated) {
                            return const CalibrationScreen();
                          }
                          return FutureBuilder<Map<String, dynamic>?>(
                            future: _userFuture,
                            builder: (context, userSnapshot) {
                              final displayName =
                                  userSnapshot.data?['name'] ?? '';
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 40),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ShaderMask(
                                        shaderCallback: (Rect bounds) {
                                          return const LinearGradient(
                                            colors: [
                                              Color(0xFF0067AC),
                                              Color(0xFF0085DC)
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ).createShader(bounds);
                                        },
                                        child: const Text(
                                          '¡Bienvenido',
                                          style: TextStyle(
                                            fontSize: 26,
                                            fontWeight: FontWeight.bold,
                                            color: Colors
                                                .white, // This color will be replaced by the shader
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      ShaderMask(
                                        shaderCallback: (Rect bounds) {
                                          return const LinearGradient(
                                            colors: [
                                              Color(0xFF0067AC),
                                              Color(0xFF0085DC)
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ).createShader(bounds);
                                        },
                                        child: Text(
                                          '$displayName!',
                                          style: const TextStyle(
                                            fontSize: 26,
                                            fontWeight: FontWeight.bold,
                                            color: Colors
                                                .white, // This color will be replaced by the shader
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Text(
                                    '¿Preparado para comenzar?',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 23, 155, 41),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width: 300,
                                    height: 300,
                                    child: Center(
                                      child: Image.asset(
                                        'assets/imagenes/LOGOECOBREACK.png',
                                        width: 300,
                                        height: 300,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  Image.asset(
                                    'assets/imagenes/logo_emas.png',
                                    height: 70,
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const CustomBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _showExitDialog(BuildContext context) async {
    final result = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("¿Estás seguro que quieres salir?"),
            content: Image.asset(
              'assets/imagenes/icons/salir.png',
              width: 80,
              height: 80,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (context.mounted) {
                    Navigator.pushNamed(context, '/inicio');
                    Navigator.of(context).pop(false);
                  }
                },
                child: const Text(
                  "Permanecer",
                  style: TextStyle(color: Color(0xFF0067AC)),
                ),
              ),
              TextButton(
                onPressed: () {
                  if (context.mounted) {
                    Navigator.of(context).pop(true);
                  }
                },
                child: const Text(
                  "Salir",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;
    return result;
  }
}

class HeaderPaintDiagonal extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0067AC), Color(0xFF0085DC)],
      ).createShader(Rect.fromLTWH(-size.width * 0.3, -size.height * 0.3,
          size.width * 1.6, size.height * 1.6))
      ..style = PaintingStyle.fill
      ..strokeWidth = 5;

    final borderPaint = Paint()
      ..color = const Color(0xFFC6DA23)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0;

    final path = Path();
    path.lineTo(0, size.height * 0.40);
    path.lineTo(size.width, size.height * 0.28);
    path.lineTo(size.width, 0);

    canvas.drawPath(path, paint);
    final borderPath = Path()
      ..moveTo(0, size.height * 0.40)
      ..lineTo(size.width, size.height * 0.28);
    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
