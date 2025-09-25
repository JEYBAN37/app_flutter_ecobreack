import 'package:ecoapp/core/info_box.dart';
import 'package:ecoapp/core/motion_detector_dialog.dart';
import 'package:ecoapp/presentation/pages/menu/descubre/descubre_rutina_page.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CategoriaDetalleSheet extends StatefulWidget {
  final Map categoria;
  const CategoriaDetalleSheet({super.key, required this.categoria});

  @override
  State<CategoriaDetalleSheet> createState() => _CategoriaDetalleSheetState();
}

class _CategoriaDetalleSheetState extends State<CategoriaDetalleSheet> {
  VideoPlayerController? _driveVideoController;

  static const List<String> categoriasMovimiento = [
    'Tren Superior',
    'Tren Inferior',
    'Movilidad Articular',
    'Estiramientos Generales',
  ];

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

  void _initDriveVideoController() {
    // You may need to pass the correct ejercicio here
    // For demonstration, using the first ejercicio
    final ejercicios = widget.categoria['ejercicios'] as List;
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _initDriveVideoController();
    });
  }

  Future<void> _comenzarRutina(
      BuildContext context, List ejercicios, Map categoria) async {
    if (ejercicios.isEmpty) return;
    /*if (requiereSensor) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => MotionDetectorDialog(
          activityTitle: ejercicios[0]['nombre'],
          activityCategory: categoria['nombre'],
          instructions: List<String>.from(ejercicios[0]['pasos']),
        ),
      );
    }*/
    if (!context.mounted) return;
    Navigator.of(context).pop();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DescubreRutinaPage(
          categoria: categoria,
          ejercicios: ejercicios
              .map((ej) => {
                    ...ej,
                    'categoria': categoria['nombre'],
                    'color': categoria['color'],
                  })
              .toList(),
              salir: false,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoria = widget.categoria;
    final ejercicios = categoria['ejercicios'] as List;
    // Calcular duración total en minutos
    int duracionTotal = ejercicios.fold(0, (sum, ej) {
      final dur = ej['duracion'];
      if (dur == null) return sum + 1;
      if (dur is int) return sum + dur;
      if (dur is String) {
        final parsed = int.tryParse(dur);
        return sum + (parsed ?? 1);
      }
      return sum + 1;
    });
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [categoria['color'], categoria['color'].withAlpha(204)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categoria['nombre'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  categoria['descripcion'],
                  style: const TextStyle(color: Colors.white70, fontSize: 17),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    InfoBox(
                      label: 'Ejercicios',
                      value: ejercicios.length.toString(),
                      icon: Icons.fitness_center,
                    ),
                    const SizedBox(width: 18),
                    InfoBox(
                      label: 'Segundos',
                      value: duracionTotal.toString(),
                      icon: Icons.timer,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 28),
            child: Text(
              'Ejercicios',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              itemCount: ejercicios.length,
              itemBuilder: (context, i) {
                final ej = ejercicios[i];
                final estado = ej['estado'];
                debugPrint('Estado del ejercicio ${ej['nombre']}: $estado');
                final videoId = ej['videoUrl'];
                return Card(
                  margin: const EdgeInsets.only(bottom: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  elevation: 3,
                  child: ListTile(
                    leading: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: estado ? categoria['color'] : Colors.grey,
                          child: Icon(ej['icono'], color: Colors.white),
                        ),
                        Positioned(
                          right: -18,
                          top: -18,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: categoria['color'].withAlpha(60),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              '#${i + 1}',
                              style: TextStyle(
                                color: categoria['color'],
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    title: Text(
                      ej['nombre'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(_duracionEnSegundos(ej['duracion'])),
                    trailing: IconButton(
                      icon: const Icon(Icons.play_circle_fill,
                          color: Color(0xFF0067AC), size: 32),
                      onPressed: () => _showEjercicioDetalle(
                          context, categoria, {...ej, 'videoUrl': videoId}),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0067AC),
                  elevation: 6,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  shadowColor: const Color(0xFF0067AC).withAlpha(102),
                ),
                onPressed: () =>
                    _comenzarRutina(context, ejercicios, categoria),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow, color: Colors.white, size: 28),
                    SizedBox(width: 10),
                    Text(
                      'Comenzar rutina',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEjercicioDetalle(BuildContext context, categoria, ejercicio) {
    final icono = ejercicio['icono'];
    final videoId = ejercicio['videoUrl'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: categoria['color'],
              child: Icon(icono, color: Colors.white),
            ),
            const SizedBox(width: 14),
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
                  // Modifica el tamaño del cuadro del video aquí
                  child: Container(
                    width: double.infinity, // Ocupa todo el ancho disponible
                    height: 220, // Altura fija, puedes ajustar este valor
                    child: _driveVideoController != null &&
                            _driveVideoController!.value.isInitialized
                        ? AspectRatio(
                            aspectRatio:
                                _driveVideoController!.value.aspectRatio,
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                VideoPlayer(_driveVideoController!),
                                VideoProgressIndicator(
                                  _driveVideoController!,
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
                                      setState(() {
                                        if (_driveVideoController!
                                            .value.isPlaying) {
                                          _driveVideoController!.pause();
                                        } else {
                                          _driveVideoController!.play();
                                        }
                                      });
                                    },
                                    child: Icon(
                                      _driveVideoController!.value.isPlaying
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
              Text(
                ejercicio['descripcion'],
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text('Pasos:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...List.generate(
                (ejercicio['pasos'] as List).length,
                (i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Text('${i + 1}. ${(ejercicio['pasos'] as List)[i]}'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: categoria['color'],
              textStyle:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  String _getYoutubeId(String url) {
    final uri = Uri.parse(url);
    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.first;
    } else if (uri.host.contains('youtube.com')) {
      return uri.queryParameters['v'] ?? '';
    }
    return '';
  }
}
