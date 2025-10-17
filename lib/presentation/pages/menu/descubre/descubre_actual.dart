import 'dart:convert';

import 'package:ecoapp/core/categoria_detalle_sheet.dart';
import 'package:ecoapp/core/consultas_actividades.dart';
import 'package:ecoapp/core/tarjeta_categoria.dart';
import 'package:ecoapp/core/utilidades_categorias.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'descubre_rutina_page.dart';
import 'package:ecoapp/core/pause_detector_service.dart';
import 'package:ecoapp/core/route_observer.dart';

class DescubreActual extends StatefulWidget {
  const DescubreActual({super.key});

  @override
  State<DescubreActual> createState() => _DescubreActualState();
}

class _DescubreActualState extends State<DescubreActual> with RouteAware {
  // Clave para guardar progreso diario
  static const String _progresoDiarioKey = 'progreso_diario_actividad';

  // Guarda el id de la última actividad completada y la fecha (yyyy-MM-dd)
  Future<void> guardarProgresoDiario(String actividadId) async {
    final hoy = DateTime.now();
    final fechaStr =
        "${hoy.year.toString().padLeft(4, '0')}-${hoy.month.toString().padLeft(2, '0')}-${hoy.day.toString().padLeft(2, '0')}";
    final data = jsonEncode({'id': actividadId, 'fecha': fechaStr});
    await _storage.write(key: _progresoDiarioKey, value: data);
  }

  // Lee el progreso diario guardado
  Future<String?> leerProgresoDiarioId() async {
    final dataStr = await _storage.read(key: _progresoDiarioKey);
    if (dataStr == null) return null;
    final data = jsonDecode(dataStr);
    final fechaGuardada = data['fecha'] as String?;
    final hoy = DateTime.now();
    final fechaHoy =
        "${hoy.year.toString().padLeft(4, '0')}-${hoy.month.toString().padLeft(2, '0')}-${hoy.day.toString().padLeft(2, '0')}";
    if (fechaGuardada != fechaHoy) {
      // Si es otro día, borra el progreso
      await _storage.delete(key: _progresoDiarioKey);
      return null;
    }
    return data['id'] as String?;
  }

  List fetchedActivities = [];
  bool _isLoading = true; // <-- Añade esta variable
  final Set<String> _ejerciciosCompletados = {};
  static const _storage = FlutterSecureStorage();
  String nombrePlan = 'No tienes Plan Asignado';
  VideoPlayerController? _driveVideoController;
  @override
  void initState() {
    super.initState();
    _loadActivities();
    _initializePauseDetector();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  Future<void> _comenzarRutina(
      BuildContext context, List ejercicios, Map categoria) async {
    if (ejercicios.isEmpty) return;
    if (!context.mounted) return;
    Navigator.of(context).pop();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DescubreRutinaPage(
          categoria: categoria,
          ejercicios: ejercicios,
          salir: true, // <-- NO sobrescribas color aquí
        ),
      ),
    );
  }

  void _initDriveVideoController() {
    // You may need to pass the correct ejercicio here
    // For demonstration, using the first ejercicio
    final ejercicios = fetchedActivities[0]['ejercicios'] as List;
    if (ejercicios.isEmpty) return;
    final ejercicio = ejercicios[0];
    if (ejercicio.containsKey('videoUrl') && ejercicio['videoUrl'] != null) {
      final driveId = ejercicio['videoUrl'] as String;
      final url = 'https://drive.google.com/uc?export=download&id=$driveId';
      debugPrint('Inicializando video desde URL: $url');
      _driveVideoController?.dispose();
      _driveVideoController = VideoPlayerController.network(url)
        ..initialize().then((_) {
          setState(() {});
          _driveVideoController?.play(); // <-- Reproduce automáticamente
          _driveVideoController?.addListener(() {
            if (_driveVideoController!.value.position >=
                    _driveVideoController!.value.duration &&
                _driveVideoController!.value.isInitialized) {
              _driveVideoController!.seekTo(Duration.zero);
              _driveVideoController!.play();
            }
          });
        });
    } else {
      _driveVideoController?.dispose();
      _driveVideoController = null;
    }
  }

  String _duracionEnSegundos(dynamic duracion) {
    if (duracion == null) return 'Duración: 1 seg';
    // Si es int y menor a 100, asumimos que ya está en minutos
    if (duracion is int) {
      if (duracion < 100) return 'Duración: $duracion seg';
      // Si es mayor, asumimos que está en segundos
      final minutos = (duracion / 60).ceil();
      return 'Duración: ${minutos == 0 ? 1 : minutos} seg';
    }
    if (duracion is String) {
      final parsed = int.tryParse(duracion);
      if (parsed != null) {
        if (parsed < 100) return 'Duración: $parsed seg';
        final minutos = (parsed / 60).ceil();
        return 'Duración: ${minutos == 0 ? 1 : minutos} seg';
      }
    }
    return 'Duración: 1 min';
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Se llama cuando regresas a esta pantalla
    setState(() {
      _isLoading = true;
    });
    _loadActivities();
  }

  void _initializePauseDetector() {}

  String formatDuration(dynamic duracion) {
    if (duracion is int) {
      final min = (duracion ~/ 60).toString().padLeft(2, '0');
      final sec = (duracion % 60).toString().padLeft(2, '0');
      return '$min:$sec';
    }
    return duracion.toString();
  }

  Future<Map<String, dynamic>?> _getUserData() async {
    final userDataString = await _storage.read(key: 'admin_userdata');
    if (userDataString != null) {
      return jsonDecode(userDataString) as Map<String, dynamic>;
    }
    return null;
  }

  Future<String?> userId() async {
    return await _storage.read(key: 'admin_userId');
  }

  void _loadActivities() async {
    try {
      final userData = await _getUserData();
      final groupId = userData?['groupId'] ?? '';
      var result =
          await ConsultasActividades().cargarActividadReciente(groupId);

      debugPrint(
          'Recent Activity Result: ${result['categorias'][0]['nombre']}');

      bool encontrado = false;
      final Set<String> planesVisitados = {};
      while (!encontrado) {
        // Evita bucles infinitos por planes repetidos
        final planId = result['proceso']?.toString() ?? '';
        if (planesVisitados.contains(planId)) {
          debugPrint('Bucle detectado, no hay más planes nuevos.');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('No hay categorías activas disponibles.')),
          );
          break;
        }
        planesVisitados.add(planId);

        fetchedActivities =
            await UtilidadesCategorias.agruparPorTituloIconoSync(
                result['categorias'], result['proceso'] ?? '');

        // Leer progreso diario
        final String? ultimaActividadId = await leerProgresoDiarioId();
        if (ultimaActividadId != null && ultimaActividadId.isNotEmpty) {
          int idx = fetchedActivities
              .indexWhere((cat) => cat['id']?.toString() == ultimaActividadId);
          if (idx != -1 && idx + 1 < fetchedActivities.length) {
            fetchedActivities = fetchedActivities.sublist(idx + 1);
          }
        }

        nombrePlan = fetchedActivities.isNotEmpty
            ? result['categorias'][0]['nombre'] ?? 'Plan del Día'
            : 'Plan del Día';

        final actividadesActivas =
            fetchedActivities.where((cat) => cat['estado'] == true).toList();

        if (actividadesActivas.isNotEmpty) {
          fetchedActivities = actividadesActivas;
          nombrePlan = result['categorias'][0]['nombre'] ?? 'Plan del Día';
          encontrado = true;
        } else {
          // Si no hay actividades activas, intenta traer el siguiente plan
          final user = await userId();
          await ConsultasActividades().guardarPlanReciente(
              user ?? '', result['proceso'] ?? '', groupId);
          result = await ConsultasActividades()
              .cargarPlanReciente(user ?? '', groupId);

          // Si el nuevo plan tampoco tiene categorías, sal del bucle
          if (result['categorias'] == null ||
              (result['categorias'] as List).isEmpty) {
            debugPrint('No hay más planes disponibles.');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('No hay categorías activas disponibles.')),
            );
            break;
          }
        }
      }

      setState(() {
        fetchedActivities = fetchedActivities;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error al cargar actividades: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Aplana todos los ejercicios de todas las categorías en una sola lista
    final List<Map> allEjercicios = [
      for (final cat in fetchedActivities)
        for (final ej in (cat['ejercicios'] as List))
          {
            ...ej,
            'categoria': cat['nombre'],
            'color': cat['color'],
            // Usa el estado del ejercicio, no el de la categoría:
            'estado': ej['estado'],
          }
    ];

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF1A1A2E)
          : const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF0067AC),
                ),
              )
            : Column(
                children: [
                  // Header (igual que antes)
                  Container(
                    width: double.infinity,
                    height: 85,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0067AC), Color(0xFF0085DC)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: const Border(
                        bottom: BorderSide(
                          color: Color(0xFFC6DA23),
                          width: 3.0,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF26A69A).withAlpha(77),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Stack(
                        children: [
                          Positioned(
                            right: -20,
                            top: -20,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(26),
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.stairs,
                                        color: Colors.white,
                                        size: 60,
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Text(
                                              'Plan Proximo a Vencer',
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 15,
                                                fontFamily: 'HelveticaRounded',
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              nombrePlan,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'HelveticaRounded',
                                                letterSpacing: 0.0,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Listado plano de ejercicios
                  Expanded(
                    child: allEjercicios.isEmpty
                        ? const Center(
                            child: Text(
                              'No hay ejercicios disponibles.',
                              style: TextStyle(fontSize: 18),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                            itemCount: allEjercicios.length,
                            itemBuilder: (context, i) {
                              final ej = allEjercicios[i];
                              return Card(
                                color: isDark
                                    ? const Color(0xFF16213E)
                                    : const Color.fromARGB(255, 255, 255, 255),
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 2,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: ej['estado'] == true
                                        ? ej['color']
                                        : Colors.grey,
                                    child:
                                        Icon(ej['icono'], color: Colors.white),
                                  ),
                                  title: Text(
                                    ej['nombre'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle:
                                      Text(_duracionEnSegundos(ej['duracion'])),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.play_circle_fill,
                                        color: Color(0xFF0067AC), size: 28),
                                    onPressed: () => _showEjercicioDetalle(
                                        context, {'color': ej['color']}, ej),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 8.0),
                    child: GestureDetector(
                      onTap: allEjercicios.isEmpty ||
                              allEjercicios.every((ej) => ej['estado'] == false)
                          ? null
                          : () => _comenzarRutina(
                                context,
                                allEjercicios,
                                {
                                  'nombre': 'Rutina Completa',
                                  'color': const Color(0xFF0067AC),
                                  'estado': false,
                                },
                              ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: allEjercicios.isEmpty
                              ? const Color.fromARGB(255, 255, 255, 255)
                              : const Color(0xFF0067AC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFC6DA23),
                            width: 3.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF26A69A).withAlpha(77),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 32),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_circle_filled,
                                color: Colors.white, size: 28),
                            SizedBox(width: 12),
                            Text(
                              'Comenzar Rutina',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'HelveticaRounded',
                                letterSpacing: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
      ),
      // Puedes quitar el bottomNavigationBar si ya no tiene sentido en este flujo
    );
  }

  void _showEjercicioDetalle(BuildContext context, categoria, ejercicio) {
    VideoPlayerController? localVideoController;

    Future<void> _initDriveVideoControllerLocal() async {
      if (ejercicio.containsKey('videoUrl') && ejercicio['videoUrl'] != null) {
        final driveId = ejercicio['videoUrl'] as String;
        final url = 'https://drive.google.com/uc?export=download&id=$driveId';
        debugPrint('Inicializando video desde URL: $url');
        localVideoController?.dispose();
        localVideoController = VideoPlayerController.network(url);
        await localVideoController!.initialize();
        localVideoController!.play();
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          if (localVideoController == null) {
            _initDriveVideoControllerLocal().then((_) {
              setModalState(() {});
            });
          }
          final pasos = (ejercicio['pasos'] ?? []) as List;
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
            title: Row(
              children: [
                CircleAvatar(
                  backgroundColor: categoria['color'],
                  child: Icon(ejercicio['icono'], color: Colors.white),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    ejercicio['nombre'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (ejercicio['videoUrl'] != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        child: (localVideoController != null &&
                                localVideoController!.value.isInitialized)
                            ? AspectRatio(
                                aspectRatio:
                                    localVideoController!.value.aspectRatio,
                                child: Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    VideoPlayer(localVideoController!),
                                    VideoProgressIndicator(
                                      localVideoController!,
                                      allowScrubbing: true,
                                      colors: VideoProgressColors(
                                        playedColor: categoria['color'],
                                        bufferedColor:
                                            categoria['color'].withAlpha(80),
                                        backgroundColor: Colors.black12,
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 10,
                                      right: 10,
                                      child: FloatingActionButton(
                                        mini: true,
                                        backgroundColor: categoria['color'],
                                        onPressed: () {
                                          setModalState(() {
                                            if (localVideoController!
                                                .value.isPlaying) {
                                              localVideoController!.pause();
                                            } else {
                                              localVideoController!.play();
                                            }
                                          });
                                        },
                                        child: Icon(
                                          localVideoController!.value.isPlaying
                                              ? Icons.pause
                                              : Icons.play_arrow,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Center(
                                child: CircularProgressIndicator(
                                    color: categoria['color']),
                              ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    ejercicio['descripcion'] ?? '',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  const Text('Pasos:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  ...List.generate(
                    pasos.length,
                    (i) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Text('${i + 1}. ${pasos[i]}'),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: categoria['color'],
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                onPressed: () {
                  localVideoController?.dispose();
                  Navigator.of(context).pop();
                },
                child: const Text('Cerrar'),
              ),
            ],
          );
        },
      ),
    );
  }
}
