import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'descubre_rutina_page.dart';
import 'package:ecoapp/core/motion_detector_dialog.dart';
import 'package:ecoapp/core/pause_detector_service.dart';

class DescubrePage extends StatefulWidget {
  const DescubrePage({super.key});

  @override
  State<DescubrePage> createState() => _DescubrePageState();
}

class _DescubrePageState extends State<DescubrePage> {
  late PauseDetectorService _pauseDetector;

  @override
  void initState() {
    super.initState();
    _initializePauseDetector();
  }

  void _initializePauseDetector() {
    _pauseDetector = PauseDetectorService(
      onPauseDetected: (success) {
        if (success && mounted) {
          // Manejar la detección exitosa
        }
      },
      onProgressUpdate: (seconds) {
        if (mounted) {
          // Actualizar UI con el progreso
        }
      },
      onTimeout: () {
        if (mounted) {
          // Manejar timeout
        }
      },
    );
  }

  @override
  void dispose() {
    _pauseDetector.dispose();
    super.dispose();
  }

  // Corrijo los JSON: uso Color y IconData reales, y actualizo los videos
  final List<Map<String, dynamic>> categorias = [
    {
      'nombre': 'Visual',
      'color': const Color(0xFF4FC3F7),
      'descripcion':
          'Ejercicios para reducir la fatiga visual y mejorar la salud ocular en el trabajo.',
      'ejercicios': [
        {
          'nombre': 'Parpadeo consciente',
          'duracion': '01:00',
          'descripcion': 'Cierra y abre los ojos lentamente para humedecerlos.',
          'pasos': [
            'Siéntate cómodo y relaja la vista.',
            'Cierra los ojos durante 2 segundos.',
            'Ábrelos y repite el proceso durante 1 minuto.'
          ],
          'icono': Icons.visibility,
          'videoUrl': 'http://www.youtube.com/watch?v=bPAdWZLiZiE',
        },
        {
          'nombre': 'Enfoque alterno',
          'duracion': '01:00',
          'descripcion':
              'Alterna la mirada entre un objeto cercano y uno lejano.',
          'pasos': [
            'Mira un objeto a 20 cm por 10 segundos.',
            'Luego mira un objeto lejano por 10 segundos.',
            'Repite durante 1 minuto.'
          ],
          'icono': Icons.remove_red_eye,
          'videoUrl': 'http://www.youtube.com/watch?v=Yrh01bWtMxE',
        },
      ],
    },
    {
      'nombre': 'Auditiva',
      'color': const Color(0xFF9575CD),
      'descripcion':
          'Ejercicios para relajar y proteger la audición en ambientes laborales.',
      'ejercicios': [
        {
          'nombre': 'Relajación auditiva',
          'duracion': '01:00',
          'descripcion':
              'Cierra los ojos y concéntrate en los sonidos ambientales.',
          'pasos': [
            'Siéntate en silencio.',
            'Cierra los ojos y respira profundo.',
            'Escucha los sonidos a tu alrededor durante 1 minuto.'
          ],
          'icono': Icons.hearing,
          'videoUrl': 'http://www.youtube.com/watch?v=noQTk4mOmIQ',
        },
        {
          'nombre': 'Masaje auricular',
          'duracion': '01:00',
          'descripcion':
              'Masajea suavemente tus orejas para estimular la circulación.',
          'pasos': [
            'Con los dedos, masajea el lóbulo y la parte superior de la oreja.',
            'Haz movimientos circulares durante 1 minuto.'
          ],
          'icono': Icons.headphones,
          'videoUrl': 'http://www.youtube.com/watch?v=SeLxtsqZo3s',
        },
      ],
    },
    {
      'nombre': 'Cognitiva',
      'color': const Color(0xFFFFB74D),
      'descripcion': 'Ejercicios para estimular la concentración y la memoria.',
      'ejercicios': [
        {
          'nombre': 'Respiración consciente',
          'duracion': '01:00',
          'descripcion': 'Ejercicio de respiración para mejorar la atención.',
          'pasos': [
            'Inhala profundamente por la nariz.',
            'Sostén el aire 3 segundos.',
            'Exhala lentamente por la boca.',
            'Repite durante 1 minuto.'
          ],
          'icono': Icons.psychology,
          'videoUrl': 'http://www.youtube.com/watch?v=1eMFChd4sL8',
        },
        {
          'nombre': 'Secuencia numérica',
          'duracion': '01:00',
          'descripcion': 'Cuenta hacia atrás de 100 en 3 en 3.',
          'pasos': [
            'Comienza en 100.',
            'Resta 3 en cada número y di el resultado en voz baja.',
            'Hazlo durante 1 minuto.'
          ],
          'icono': Icons.numbers,
          'videoUrl': 'http://www.youtube.com/watch?v=hyIiqD2Ob4Y',
        },
      ],
    },
    {
      'nombre': 'Tren Superior',
      'color': const Color(0xFF0067AC),
      'descripcion':
          'Moviliza y estira hombros, cuello y brazos para prevenir molestias.',
      'ejercicios': [
        {
          'nombre': 'Giro de lado a lado',
          'duracion': '01:00',
          'descripcion': 'Gira la cabeza suavemente de un lado a otro.',
          'pasos': [
            'Siéntate derecho.',
            'Gira la cabeza a la derecha, mantén 5 segundos.',
            'Gira a la izquierda, mantén 5 segundos.',
            'Repite durante 1 minuto.'
          ],
          'icono': Icons.rotate_right,
          'videoUrl': 'http://www.youtube.com/watch?v=crlRCrtDzwQ',
        },
      ],
    },
    {
      'nombre': 'Tren Inferior',
      'color': const Color(0xFFC6DA23),
      'descripcion':
          'Ejercicios para piernas y cadera, mejorando la circulación y flexibilidad.',
      'ejercicios': [
        {
          'nombre': 'Elevación de talones',
          'duracion': '01:00',
          'descripcion': 'Eleva los talones para activar la circulación.',
          'pasos': [
            'De pie, eleva los talones y mantén 2 segundos.',
            'Baja lentamente.',
            'Repite durante 1 minuto.'
          ],
          'icono': Icons.directions_walk,
          'videoUrl': 'http://www.youtube.com/watch?v=mobIkpZUQrw',
        },
      ],
    },
    {
      'nombre': 'Movilidad Articular',
      'color': const Color(0xFF26A69A),
      'descripcion':
          'Rutinas para mantener las articulaciones móviles y saludables.',
      'ejercicios': [
        {
          'nombre': 'Círculos de muñeca',
          'duracion': '01:00',
          'descripcion':
              'Haz círculos con las muñecas para mejorar la movilidad.',
          'pasos': [
            'Extiende los brazos al frente.',
            'Haz círculos con ambas muñecas.',
            'Cambia de sentido a los 30 segundos.'
          ],
          'icono': Icons.pan_tool,
          'videoUrl': 'http://www.youtube.com/watch?v=JVzOXD9cCWQ',
        },
      ],
    },
    {
      'nombre': 'Estiramientos Generales',
      'color': const Color(0xFFFF8A65),
      'descripcion': 'Estiramientos globales para relajar todo el cuerpo.',
      'ejercicios': [
        {
          'nombre': 'Estiramiento de cuerpo completo',
          'duracion': '01:00',
          'descripcion': 'Estira brazos y piernas al máximo.',
          'pasos': [
            'De pie, estira los brazos hacia arriba.',
            'Estira las piernas y mantén la posición 10 segundos.',
            'Relaja y repite.'
          ],
          'icono': Icons.self_improvement,
          'videoUrl': 'http://www.youtube.com/watch?v=K_8PuY5m1LI',
        },
      ],
    },
  ];

  // Lleva el control de ejercicios completados
  final Set<String> _ejerciciosCompletados = {};

  void _showCategoriaDetalle(Map<String, dynamic> categoria) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CategoriaDetalleSheet(categoria: categoria),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filtra las categorías y ejercicios para mostrar solo los no completados
    final categoriasPendientes = categorias
        .map((cat) {
          final ejerciciosPendientes = (cat['ejercicios'] as List)
              .where((ej) => !_ejerciciosCompletados.contains(ej['nombre']))
              .toList();
          return {
            ...cat,
            'ejercicios': ejerciciosPendientes,
          };
        })
        .where((cat) => (cat['ejercicios'] as List).isNotEmpty)
        .toList();

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF6F8FC),
      body: SafeArea(
        child: Column(
          children: [
            // Header mejorado
            Container(
              width: double.infinity,
              height: 80,
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              decoration: BoxDecoration(
                color: const Color(0xFF0067AC),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF26A69A)
                        .withAlpha(77), // Cambiado de withOpacity a withAlpha
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Fondo decorativo
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(
                            26), // Cambiado de withOpacity a withAlpha
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                  // Contenido
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.explore,
                              color: Colors.white,
                              size: 32,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Descubre',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'HelveticaRounded',
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => Navigator.of(context).maybePop(),
                              borderRadius: BorderRadius.circular(12),
                              child: const Padding(
                                padding: EdgeInsets.all(8),
                                child: Icon(
                                  Icons.close_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Resto del contenido
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                itemCount: categoriasPendientes.length,
                itemBuilder: (context, index) {
                  final cat = categoriasPendientes[index];
                  return _buildCategoriaCard(cat, index);
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
              colors: [Color(0xFF0067AC), Color(0xFF26A69A)],
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
                side: BorderSide(color: Color(0xFFC6DA23), width: 2),
              ),
            ),
            onPressed: () async {
              // Junta solo los ejercicios pendientes
              final allEjercicios = <Map<String, dynamic>>[];
              for (final cat in categoriasPendientes) {
                for (final ej in (cat['ejercicios'] as List)) {
                  allEjercicios.add({
                    ...ej,
                    'categoria': cat['nombre'],
                    'color': cat['color'],
                  });
                }
              }
              if (allEjercicios.isEmpty) return;
              // Espera el resultado de la rutina
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => DescubreRutinaPage(
                    categoria: const {
                      'nombre': 'Plan del Día',
                      'color': Color(0xFF0067AC)
                    },
                    ejercicios: allEjercicios,
                  ),
                ),
              );
              // Marca los ejercicios como completados al volver
              if (!context.mounted) return;
              setState(() {
                for (final ej in allEjercicios) {
                  _ejerciciosCompletados.add(ej['nombre']);
                }
              });
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

  Widget _buildCategoriaCard(Map<String, dynamic> cat, int index) {
    return GestureDetector(
      onTap: () => _showCategoriaDetalle(cat),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: cat['color'],
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.category, color: Colors.white, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          cat['nombre'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'HelveticaRounded',
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Colors.white),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cat['descripcion'],
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: cat['color'].withAlpha(60),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '#${index + 1}',
                  style: TextStyle(
                    color: cat['color'],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoriaDetalleSheet extends StatelessWidget {
  final Map<String, dynamic> categoria;
  const _CategoriaDetalleSheet({required this.categoria});

  static const List<String> categoriasMovimiento = [
    'Tren Superior',
    'Tren Inferior',
    'Movilidad Articular',
    'Estiramientos Generales',
  ];

  @override
  Widget build(BuildContext context) {
    final ejercicios = categoria['ejercicios'] as List;
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
                    _InfoBox(
                      label: 'Ejercicios',
                      value: ejercicios.length.toString(),
                      icon: Icons.fitness_center,
                    ),
                    const SizedBox(width: 18),
                    _InfoBox(
                      label: 'Minutos',
                      value: (ejercicios.length).toString(),
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
                          backgroundColor: categoria['color'],
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
                    subtitle: Text(ej['duracion']),
                    trailing: IconButton(
                      icon: const Icon(Icons.play_circle_fill,
                          color: Color(0xFF0067AC), size: 32),
                      onPressed: () =>
                          _showEjercicioDetalle(context, categoria, ej),
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
                onPressed: () async {
                  if (ejercicios.isEmpty) return;
                  final primerEjercicio = ejercicios[0];
                  final requiereSensor =
                      categoriasMovimiento.contains(categoria['nombre']);
                  if (requiereSensor) {
                    await showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (ctx) => MotionDetectorDialog(
                        activityTitle: primerEjercicio['nombre'],
                        activityCategory: categoria['nombre'],
                        instructions:
                            List<String>.from(primerEjercicio['pasos']),
                      ),
                    );
                  }
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => DescubreRutinaPage(
                        categoria: categoria,
                        ejercicios: [
                          {
                            ...primerEjercicio,
                            'categoria': categoria['nombre'],
                            'color': categoria['color'],
                          }
                        ],
                      ),
                    ),
                  );
                },
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

  void _showEjercicioDetalle(BuildContext context,
      Map<String, dynamic> categoria, Map<String, dynamic> ejercicio) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: categoria['color'],
              child: Icon(ejercicio['icono'], color: Colors.white),
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
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      showDialog(
                        context: context,
                        builder: (context) => _VideoDialog(
                          videoUrl: ejercicio['videoUrl'],
                          color: categoria['color'],
                        ),
                      );
                    },
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: 180,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.network(
                              'https://img.youtube.com/vi/${_getYoutubeId(ejercicio['videoUrl'])}/0.jpg',
                              width: double.infinity,
                              height: 180,
                              fit: BoxFit.cover,
                            ),
                            Container(
                              color: Colors.black26,
                              child: const Icon(Icons.play_circle_fill,
                                  color: Colors.white, size: 60),
                            ),
                          ],
                        ),
                      ),
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

class _VideoDialog extends StatefulWidget {
  final String videoUrl;
  final Color color;
  const _VideoDialog({required this.videoUrl, required this.color});

  @override
  State<_VideoDialog> createState() => _VideoDialogState();
}

class _VideoDialogState extends State<_VideoDialog> {
  YoutubePlayerController? _controller;
  bool _videoError = false;

  @override
  void initState() {
    super.initState();
    String url = widget.videoUrl.replaceFirst('http://', 'https://');
    String? videoId = YoutubePlayer.convertUrlToId(url);
    if (videoId == null || videoId.isEmpty) {
      _videoError = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {});
      });
    } else {
      _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      contentPadding: const EdgeInsets.all(8),
      content: _videoError
          ? const SizedBox(
              width: 300,
              child: Text(
                'No se pudo cargar el video. URL inválida.',
                style: TextStyle(color: Colors.white, fontSize: 18),
                textAlign: TextAlign.center,
              ),
            )
          : SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              child: YoutubePlayer(
                controller: _controller!,
                showVideoProgressIndicator: true,
                progressIndicatorColor: widget.color,
              ),
            ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: widget.color),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _InfoBox(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
