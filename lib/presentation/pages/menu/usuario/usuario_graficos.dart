import 'package:flutter/material.dart';
import 'package:ecoapp/data/repositories/network/api_service.dart';
import 'package:ecoapp/widgets/ring_stat.dart'; // Importa tu widget personalizado RingStat

class UsuarioGraficos extends StatefulWidget {
  const UsuarioGraficos({super.key});

  @override
  UsuarioGraficosState createState() => UsuarioGraficosState();
}

class UsuarioGraficosState extends State<UsuarioGraficos> {
  final ApiService _apiService = ApiService();
  Future<Map<String, dynamic>>? _statsData;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    if (mounted) {
      setState(() {
        _statsData = fetchUserStats();
      });
    }
  }

  @override
  void dispose() {
    _statsData = null;
    super.dispose();
  }

  Future<Map<String, dynamic>> fetchUserStats() async {
    try {
      debugPrint('Iniciando solicitud a /user/stats');
      final response = await _apiService.getStats();

      if (response != null && !response.containsKey("error")) {
        debugPrint('Datos recibidos exitosamente');
        return response;
      } else {
        debugPrint('Error en la respuesta: ${response?["error"]}');
        return {
          "error": response?["error"] ?? "Error al obtener estadísticas",
          "activities_done": 0,
          "total_activities": 0,
          "total_time": 0,
        };
      }
    } catch (e) {
      debugPrint('Exception durante la solicitud: $e');
      return {
        "error": "Error de conexión: $e",
        "activities_done": 0,
        "total_activities": 0,
        "total_time": 0,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_statsData == null) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<Map<String, dynamic>>(
      future: _statsData,
      builder: (context, snapshot) {
        if (!mounted) return const SizedBox.shrink();

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data!.containsKey("error")) {
          final errorMessage =
              snapshot.data?["error"] ?? "No se pudieron cargar las estadísticas";
          return Center(child: Text(errorMessage));
        }

        var stats = snapshot.data!;
        final double total = stats['total_activities'] is int
            ? (stats['total_activities'] as int).toDouble()
            : (stats['total_activities'] as double?) ?? 0.0;

        final double completed = stats['activities_done'] is int
            ? (stats['activities_done'] as int).toDouble()
            : (stats['activities_done'] as double?) ?? 0.0;

        final double time = stats['total_time'] is int
            ? (stats['total_time'] as int).toDouble()
            : (stats['total_time'] as double?) ?? 0.0;

        final double notCompleted = total - completed;

        final double porcentaje = total > 0 ? completed / total : 0.0;
        final double porcentajeNo = total > 0 ? notCompleted / total : 0.0;

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RingStat(
                label: 'ACTIVIDADES\nREALIZADAS',
                value: completed.toStringAsFixed(0),
                percent: porcentaje,
                color: const Color(0xFF9ACA60), // Verde claro
                valueStyle: const TextStyle(
                  fontSize: 33, // Larger font size
                  fontWeight: FontWeight.bold,
                  fontFamily: 'HelveticaRounded',
                  color: Color(0xFF186188), // Azul oscuro
                ),
                labelStyle: const TextStyle(
                  fontSize: 13, // Larger font size
                  fontFamily: 'HelveticaRounded',
                  color: Color(0xFF9ACA60), // Verde claro
                  fontWeight: FontWeight.w500,
                ),
                radius: 80.0, // Larger radius
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  RingStat(
                    label: 'TOTAL',
                    value: total.toStringAsFixed(0),
                    percent: 1.0,
                    color: const Color(0xFFD0EA4A), // Verde lima
                    valueStyle: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'HelveticaRounded',
                      color: Color(0xFF186188), // Azul oscuro
                    ),
                    labelStyle: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'HelveticaRounded',
                      color: Color(0xFF186188), // Azul oscuro
                    ),
                  ),
                  RingStat(
                    label: 'TIEMPO',
                    value: '${time.toStringAsFixed(0)} min',
                    percent: 1.0,
                    color: const Color(0xFF186188), // Azul oscuro
                    valueStyle: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'HelveticaRounded',
                      color: Color.fromARGB(255, 179, 231, 7), // Beige claro
                    ),
                    labelStyle: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'HelveticaRounded',
                      color: Color.fromARGB(255, 179, 231, 7), // Beige claro
                    ),
                  ),
                  RingStat(
                    label: 'NO\nREALIZADAS',
                    value: notCompleted.toStringAsFixed(0),
                    percent: porcentajeNo,
                    color: const Color(0xFFD0EA4A), // Verde lima
                    valueStyle: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'HelveticaRounded',
                      color: Color(0xFF186188), // Azul oscuro
                    ),
                    labelStyle: const TextStyle(
                      fontSize: 9,
                      fontFamily: 'HelveticaRounded',
                      color: Color(0xFF186188), // Azul oscuro
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
