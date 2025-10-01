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

    return Column(
      children: [
        _buildHeader(), // Header fijo arriba
        Expanded(
          child: FutureBuilder<Map<String, dynamic>>(
            future: _statsData,
            builder: (context, snapshot) {
              if (!mounted) return const SizedBox.shrink();

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError ||
                  !snapshot.hasData ||
                  snapshot.data!.containsKey("error")) {
                final errorMessage = snapshot.data?["error"] ??
                    "No se pudieron cargar las estadísticas";
                return Center(child: Text(errorMessage));
              }

              var stats = snapshot.data!;
              final double total = stats['total_activities'] is int
                  ? (stats['total_activities'] as int).toDouble()
                  : (stats['total_activities'] as double?) ?? 0.0;

              final double completed = stats['activities_done'] is int
                  ? (stats['activities_done'] as int).toDouble()
                  : (stats['activities_done'] as double?) ?? 0.0;

              // Convertir el tiempo de segundos a minutos
              final double timeSeconds = stats['total_time'] is int
                  ? (stats['total_time'] as int).toDouble()
                  : (stats['total_time'] as double?) ?? 0.0;
              final double time = timeSeconds / 60;

              final double notCompleted =
                  (total - completed) < 0 ? 0 : (total - completed);

              final double porcentaje = completed / 500.0;
              final double porcentajeNo =
                  total > 0 ? notCompleted / total : 0.0;
              final double porcentajeTiempo =
                  time / 10950; // 1440 minutos en un día

              return Container(
                color: const Color.fromARGB(255, 255, 255, 255),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ...todo el contenido estadístico aquí...
                      const Padding(
                        padding: EdgeInsets.only(top: 50.0),
                        child: Text(
                          'Estadísticas',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF186188),
                            fontFamily: 'HelveticaRounded',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 18.0),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 12.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F9E6),
                          borderRadius: BorderRadius.circular(12.0),
                          border:
                              Border.all(color: Color(0xFF9ACA60), width: 1.2),
                        ),
                        child: const Text(
                          'Meta: 1 hora de rutina diaria por un año',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF186188),
                            fontFamily: 'HelveticaRounded',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      RingStat(
                        label: 'Actividades\nRealizadas',
                        value: completed.toStringAsFixed(0),
                        percent: porcentaje,
                        color: const Color(0xFF9ACA60),
                        valueStyle: const TextStyle(
                          fontSize: 33,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'HelveticaRounded',
                          color: Color(0xFF186188),
                        ),
                        labelStyle: const TextStyle(
                          fontSize: 13,
                          fontFamily: 'HelveticaRounded',
                          color: Color(0xFF9ACA60),
                          fontWeight: FontWeight.w500,
                        ),
                        radius: 80.0,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          RingStat(
                            label: 'Programadas',
                            value: total.toStringAsFixed(0),
                            percent: 1.0,
                            color: const Color(0xFFD0EA4A),
                            valueStyle: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'HelveticaRounded',
                              color: Color(0xFF186188),
                            ),
                            labelStyle: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'HelveticaRounded',
                              color: Color(0xFF186188),
                            ),
                          ),
                          RingStat(
                            label: 'Tiempo',
                            value: '${time.toStringAsFixed(0)} min',
                            percent: porcentajeTiempo.clamp(0.0, 1.0),
                            color: const Color(0xFF186188),
                            valueStyle: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'HelveticaRounded',
                              color: Color.fromARGB(255, 179, 231, 7),
                            ),
                            labelStyle: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'HelveticaRounded',
                              color: Color.fromARGB(255, 179, 231, 7),
                            ),
                          ),
                          RingStat(
                            label: 'No\nRealizadas',
                            value: notCompleted.toStringAsFixed(0),
                            percent: porcentajeNo,
                            color: const Color(0xFFD0EA4A),
                            valueStyle: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'HelveticaRounded',
                              color: Color(0xFF186188),
                            ),
                            labelStyle: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'HelveticaRounded',
                              color: Color(0xFF186188),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0067AC), Color(0xFF0085DC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFC6DA23),
            width: 3.0,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Text(
                  'Tus Estasdísticas',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'HelveticaRounded',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
      ),
    );
  }
}
