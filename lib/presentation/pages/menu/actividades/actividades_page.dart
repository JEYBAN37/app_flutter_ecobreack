import 'package:flutter/material.dart';
import 'package:ecoapp/presentation/pages/menu/descubre/descubre_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActividadesPage extends StatefulWidget {
  const ActividadesPage({super.key});

  @override
  State<ActividadesPage> createState() => _ActividadesPageState();
}

class _ActividadesPageState extends State<ActividadesPage> {
  final Set<String> _actividadesCompletadas = {};
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _actividadesCompletadas.addAll(
        _prefs.getStringList('actividades_completadas') ?? [],
      );
    });
  }

  Future<void> _marcarComoCompletada(String actividad) async {
    setState(() {
      _actividadesCompletadas.add(actividad);
    });
    await _prefs.setStringList(
      'actividades_completadas',
      _actividadesCompletadas.toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      body: SafeArea(
        child: Column(
          children: [
            // Header estilizado
            Container(
              width: double.infinity,
              height: 80,
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              decoration: BoxDecoration(
                color: const Color(0xFF0067AC),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF26A69A).withAlpha(77),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.fitness_center,
                              color: Colors.white,
                              size: 32,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Actividades',
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
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(51),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.white, size: 20),
                              const SizedBox(width: 6),
                              Text(
                                '${_actividadesCompletadas.length}/7',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
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

            // Contenido principal
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildActividadesCard(),
                    const SizedBox(height: 20),
                    _buildBotonRealizar(),
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Explora las actividades disponibles',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActividadesCard() {
    final actividades = [
      {
        'titulo': 'Ejercicios Visuales',
        'subtitulo': 'Reduce la fatiga visual',
        'color': const Color(0xFF4FC3F7),
        'icono': Icons.visibility,
        'id': 'visual',
      },
      {
        'titulo': 'Ejercicios Auditivos',
        'subtitulo': 'Protege tu audición',
        'color': const Color(0xFF9575CD),
        'icono': Icons.hearing,
        'id': 'auditivo',
      },
      {
        'titulo': 'Ejercicios Cognitivos',
        'subtitulo': 'Mejora tu concentración',
        'color': const Color(0xFFFFB74D),
        'icono': Icons.psychology,
        'id': 'cognitivo',
      },
      {
        'titulo': 'Ejercicios Físicos',
        'subtitulo': 'Mantén tu cuerpo activo',
        'color': const Color(0xFF26A69A),
        'icono': Icons.fitness_center,
        'id': 'fisico',
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(actividades.length * 2 - 1, (index) {
          if (index.isOdd) {
            return _buildDivider();
          }
          final actividadIndex = index ~/ 2;
          final actividad = actividades[actividadIndex];
          final isCompleted = _actividadesCompletadas.contains(actividad['id']);
          
          return _buildActividadItem(
            actividad['titulo'] as String,
            actividad['subtitulo'] as String,
            actividad['color'] as Color,
            actividad['icono'] as IconData,
            isCompleted: isCompleted,
            onComplete: () => _marcarComoCompletada(actividad['id'] as String),
          );
        }),
      ),
    );
  }

  Widget _buildActividadItem(
    String titulo,
    String subtitulo,
    Color color,
    IconData icono, {
    bool isCompleted = false,
    VoidCallback? onComplete,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isCompleted ? null : () async {
          final result = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const DescubrePage()),
          );
          if (result == true && onComplete != null) {
            onComplete();
          }
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isCompleted ? color.withAlpha(77) : color,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icono, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isCompleted ? Colors.grey : Colors.black87,
                      ),
                    ),
                    Text(
                      subtitulo,
                      style: TextStyle(
                        fontSize: 14,
                        color: isCompleted ? Colors.grey : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              if (isCompleted)
                const Icon(Icons.check_circle, color: Colors.green, size: 24)
              else
                const Icon(Icons.arrow_forward_ios, color: Colors.black26),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 1,
      color: Colors.black.withAlpha(12),
    );
  }

  Widget _buildBotonRealizar() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0067AC),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFC6DA23), width: 2),
          ),
          elevation: 8,
          shadowColor: const Color(0xFF26A69A).withAlpha(100),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DescubrePage()),
          );
        },
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.play_circle_filled, size: 28),
            SizedBox(width: 12),
            Text(
              'Realizar Actividades',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'HelveticaRounded',
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
