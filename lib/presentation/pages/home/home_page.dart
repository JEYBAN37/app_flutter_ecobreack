import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ecoapp/data/repositories/network/api_service.dart';
import 'custom_clipper.dart';
import 'dart:developer' as developer;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();
  bool _isConnected = false;
  bool _isBlinking = false;
  bool _isCheckingHealth = false;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _checkBackendConnection();
    _timer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _checkBackendConnection(),
    );
  }

  Future<void> _checkBackendConnection() async {
    if (_isCheckingHealth) return;
    _isCheckingHealth = true;

    developer.log('🔍 Iniciando verificación de conexión al backend...',
        name: 'HomePage');

    try {
      final bool isConnected = await _apiService.checkBackendHealth();
      developer.log('🔍 Resultado de checkBackendHealth: $isConnected',
          name: 'HomePage');

      setState(() {
        _isConnected = isConnected;
        _isBlinking = !isConnected;
      });

      if (isConnected) {
        developer.log('✅ Conexión establecida con el backend.',
            name: 'HomePage');
        _timer.cancel(); // Detén el timer si la conexión es exitosa
      } else {
        developer.log('❌ No se pudo conectar al backend.', name: 'HomePage');
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _isBlinking = !_isBlinking;
            });
          }
        });
      }
    } catch (e) {
      developer.log('❌ Error durante la verificación de conexión: $e',
          name: 'HomePage', level: 1000);
    } finally {
      _isCheckingHealth = false;
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF0067AC)),
              SizedBox(width: 8),
              Text(
                "¿Qué es EcoBreak?",
                style: TextStyle(
                  fontFamily: 'HelveticaRounded',
                  color: Color(0xFF0067AC),
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: const Text(
            "EcoBreak es una innovadora aplicación móvil diseñada para mejorar "
            "la salud musculoesquelética de los empleados. Ofrecemos ejercicios "
            "personalizados, consejos ergonómicos y recordatorios programados que "
            "ayudan a prevenir lesiones, fomentar buenas prácticas laborales y "
            "promover el bienestar físico en el entorno de trabajo.",
            style: TextStyle(fontFamily: 'HelveticaRounded', fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                "CERRAR",
                style: TextStyle(
                  fontFamily: 'HelveticaRounded',
                  color: Color(0xFF0067AC),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          ClipPath(
            clipper: CustomShapeClipper(),
            child: Container(
              height: size.height * 0.6,
              decoration: const BoxDecoration(color: Color(0xFF0067AC)),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                SizedBox(
                  height: size.height * 0.5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/imagenes/LOGOECOBREACK.png',
                        height: size.height * 0.25,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: size.height * 0.02),
                      Text(
                        "BIENVENIDOS A ECOBREAK",
                        style: TextStyle(
                          fontFamily: 'HelveticaRounded',
                          color: Colors.white,
                          fontSize: size.width * 0.06,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: size.height * 0.01),
                      Text(
                        "Tu compañero diario para pausas activas",
                        style: TextStyle(
                          fontFamily: 'HelveticaRounded',
                          color: Colors.white70,
                          fontSize: size.width * 0.03,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.08,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildButton(
                          context: context,
                          text: "REGÍSTRATE",
                          route: '/register',
                          color: const Color(0xFF0067AC),
                          icon: Icons.person_add,
                        ),
                        _buildButton(
                          context: context,
                          text: "INICIAR SESIÓN",
                          route: '/login',
                          color: const Color(0xFF0067AC),
                          icon: Icons.login,
                        ),
                        _buildButton(
                          context: context,
                          text: "¿Qué es EcoBreak?",
                          route: '',
                          color: const Color.fromRGBO(76, 175, 80, 1),
                          icon: Icons.info_outline,
                          onPressed: () => _showInfoDialog(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _isConnected
                    ? Colors.green
                    : (_isBlinking ? Colors.red : Colors.transparent),
                shape: BoxShape.circle,
                boxShadow: [
                  if (!_isConnected)
                    BoxShadow(
                      color: Colors.red.withAlpha(128),
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required String text,
    required String route,
    required Color color,
    required IconData icon,
    VoidCallback? onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        onPressed: onPressed ?? () => Navigator.pushNamed(context, route),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'HelveticaRounded',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
