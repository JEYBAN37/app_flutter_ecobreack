import 'package:ecoapp/core/categoria_detalle_sheet.dart';
import 'package:ecoapp/core/consultas_actividades.dart';
import 'package:ecoapp/core/tarjeta_categoria.dart';
import 'package:ecoapp/core/utilidades_categorias.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'descubre_rutina_page.dart';
import 'package:ecoapp/core/pause_detector_service.dart';
import 'package:ecoapp/core/route_observer.dart';

class DescubrePage extends StatefulWidget {
  final List activities;
  final String title;
  final String idProcess;

  const DescubrePage(
      {super.key,
      required this.activities,
      required this.title,
      required this.idProcess});

  @override
  State<DescubrePage> createState() => _DescubrePageState();
}

class _DescubrePageState extends State<DescubrePage> with RouteAware {
  List get activities => widget.activities;
  late PauseDetectorService _pauseDetector;
  String get title => widget.title;
  String get idProcess => widget.idProcess;
  List fetchedActivities = [];
  bool _isLoading = true; // <-- Añade esta variable
  final Set<String> _ejerciciosCompletados = {};
  String nombrePlan = '';
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

  void _loadActivities() async {
    try {
      final result = await ConsultasActividades().cargarActividades(activities);
      fetchedActivities = await UtilidadesCategorias.agruparPorTituloIconoSync(
          result, idProcess);

      nombrePlan = result[0]['nombre'] ?? 'Plan del Día';
      debugPrint('Actividades agrupadas: $fetchedActivities');
      setState(() {
        fetchedActivities = fetchedActivities;
        _isLoading = false; // <-- Actualiza el estado de carga
      });
    } catch (e) {
      debugPrint('Error al cargar actividades: $e');
    }
  }

  void _initializePauseDetector() {
    _pauseDetector = PauseDetectorService();
  }

  

  void _showCategoriaDetalle(categoria) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CategoriaDetalleSheet(categoria: categoria),
    );
  }

  String formatDuration(dynamic duracion) {
    if (duracion is int) {
      final min = (duracion ~/ 60).toString().padLeft(2, '0');
      final sec = (duracion % 60).toString().padLeft(2, '0');
      return '$min:$sec';
    }
    return duracion.toString();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                  // Header mejorado
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
                                              'Plan Asignado',
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
                  // Resto del contenido
                  Expanded(
                    child: fetchedActivities.isEmpty
                        ? const Center(
                            child: Text(
                              'No hay actividades disponibles.',
                              style: TextStyle(fontSize: 18),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                            itemCount: fetchedActivities.length,
                            itemBuilder: (context, index) {
                              final cat = fetchedActivities[index];
                              return TarjetaCategoria.construir(
                                  cat, index, _showCategoriaDetalle);
                            },
                          ),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0067AC), Color(0xFF0085DC)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0067AC).withAlpha(76),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              elevation: 0,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
                side: BorderSide(
                  color: Color(0xFFC6DA23),
                  width: 3.0,
                ),
              ),
            ),
            onPressed: () {
              if (fetchedActivities.isNotEmpty) {
                final firstCategory = fetchedActivities.firstWhere(
                  (cat) => cat['estado'] == true,
                  orElse: () => [],
                );

                if (firstCategory.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No hay categorías activas disponibles.'),
                    ),
                  );
                  return;
                }

                debugPrint('Iniciando rutina con actividades: $firstCategory');
                final ejercicios = firstCategory['ejercicios'] as List;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DescubreRutinaPage(
                      categoria: firstCategory,
                      ejercicios: ejercicios
                          .map((ej) => {
                                ...ej,
                                'categoria': firstCategory['nombre'],
                                'color': firstCategory['color'],
                              })
                          .toList(),
                          salir: false,
                    ),
                  ),
                );
              }
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.play_circle_filled, color: Colors.white, size: 28),
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
    );
  }
}
