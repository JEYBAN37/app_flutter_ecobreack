import 'dart:convert';
import 'package:ecoapp/data/repositories/process_group_repository.dart';
import 'package:flutter/material.dart';
import 'package:ecoapp/presentation/pages/menu/descubre/descubre_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActividadesPage extends StatefulWidget {
  const ActividadesPage({super.key});

  @override
  State<ActividadesPage> createState() => _ActividadesPageState();
}

class _ActividadesPageState extends State<ActividadesPage> {
  final Set<String> _actividadesCompletadas = {};
  late List activities = [];
  final ProcessGroupRepository _processGroupRepository =
      ProcessGroupRepository();
  late SharedPreferences _prefs;
  late dynamic _processGroupResponse;
  static const _storage = FlutterSecureStorage();
  bool _isLoading = true; // <-- Nueva variable

  @override
  void initState() {
    super.initState();
    _loadProcessesGroup();
  }

  Future<Map<String, dynamic>?> _getUserData() async {
    final userDataString = await _storage.read(key: 'admin_userdata');
    debugPrint(userDataString);
    if (userDataString != null) {
      return jsonDecode(userDataString) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> _loadProcessesGroup() async {
    setState(() {
      _isLoading = true;
    });
    final userData = await _getUserData();
    final groupId = userData?['groupId'] ?? '';
    if (groupId.isEmpty) {
      setState(() {
        _isLoading = false; // <-- Oculta loader si no hay groupId
        _processGroupResponse = null;
      });
    } else {
      _processGroupResponse =
          await _processGroupRepository.fetchProcessGroups(groupId);
      debugPrint('Response: $_processGroupResponse');

      _prefs = await SharedPreferences.getInstance();
    }
    setState(() {
      _actividadesCompletadas.addAll(
        _prefs.getStringList('actividades_completadas') ?? ['1', '2'],
      );
      _isLoading = false; // <-- Oculta loader al terminar
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
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF0067AC),
                ),
              )
            : (_processGroupResponse == null ||
                    (_processGroupResponse?['plans'] == null ||
                        (_processGroupResponse?['plans'] as List).isEmpty))
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.info_outline,
                              color: Color(0xFF0085DC), size: 60),
                          const SizedBox(height: 20),
                          const Text(
                            'No tienes planes asignados aún.',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0085DC),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _processGroupResponse?['description'] != null
                                ? (_processGroupResponse!['description'])
                                    .split(' ')
                                    .map((word) => word.isNotEmpty
                                        ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
                                        : '')
                                    .join(' ')
                                : 'Explora las actividades disponibles',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: [
                      // Header estilizado
                      _buildHeader(),

                      // Contenido principal
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          child: Column(
                            children: [
                              const Center(
                                child: Text(
                                  'Planes de Pausa',
                                  style: TextStyle(
                                    fontSize: 38,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0085DC),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Divider entre el título y las tarjetas de actividades
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Divider(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  thickness: 0,
                                ),
                              ),
                              _buildActividadesCard(),
                              const SizedBox(height: 20),
                              // Divider entre las tarjetas y la descripción
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Divider(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  thickness: 0,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 5, left: 20, right: 20),
                                child: Center(
                                  child: Text(
                                    _processGroupResponse?['description'] !=
                                            null
                                        ? (_processGroupResponse![
                                                'description'])
                                            .split(' ')
                                            .map((word) => word.isNotEmpty
                                                ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
                                                : '')
                                            .join(' ')
                                        : 'Explora las actividades disponibles',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
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
    final exercises = _processGroupResponse?['plans'] as List? ?? [];
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: exercises.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: 20), // Más espacio entre tarjetas
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        final categoriasAsignadas = (exercise['categories'] as List?) ?? [];
        final numActivades = categoriasAsignadas.length;

        String nombrePlan;
        if (categoriasAsignadas.isNotEmpty) {
          final firstCat = categoriasAsignadas[0];
          if (firstCat is Map && firstCat.containsKey('name')) {
            nombrePlan = firstCat['name'] as String? ?? 'N/A';
          } else if (firstCat is String) {
            nombrePlan = firstCat;
          } else {
            nombrePlan = 'N/A';
          }
        } else {
          nombrePlan = 'N/A';
        }
        return Container(
          decoration: BoxDecoration(
// Fondo transparente
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          constraints: const BoxConstraints(
            minHeight: 110, // Altura mínima igual para todas las tarjetas
          ),
          child: _buildActividadItem(
            exercise['nombre'] != null
                ? (exercise['nombre'] as String)
                    .split(' ')
                    .map((word) => word.isNotEmpty
                        ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
                        : '')
                    .join(' ')
                : '',
            (exercise['fechaFin'] != null &&
                    exercise['fechaFin'] is String &&
                    exercise['fechaFin'].length >= 10)
                ? exercise['fechaFin'].substring(0, 10)
                : exercise['fechaFin'] ?? '',
            exercise['description'] ?? '',
            _processGroupResponse['color'] != null
                ? Color(_processGroupResponse['color'])
                : const Color.fromARGB(255, 31, 44, 32),
            categoriasAsignadas,
            Icons.fitness_center,
            idProcess: exercise['id'],
            onComplete: () => _marcarComoCompletada(exercise['id']),
          ),
        );
      },
    );
  }

  Widget _buildActividadItem(
    String titulo,
    String subtitulo,
    String activities,
    Color color,
    List listActivities,
    IconData icono, {
    bool isCompleted = false,
    required String idProcess,
    VoidCallback? onComplete,
  }) {
    return Material(
      borderRadius: BorderRadius.circular(15),
      elevation: 10,
      shadowColor: Colors.black.withAlpha(20),
      color: const Color.fromARGB(255, 255, 255, 255),
      child: InkWell(
        onTap: isCompleted
            ? null
            : () async {
                final result = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => DescubrePage(
                        activities: listActivities,
                        title: titulo,
                        idProcess: idProcess),
                  ),
                );
                if (result == true && onComplete != null) {
                  onComplete();
                }
              },
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black
                  .withAlpha(20), // Usa el color recibido como borde
              width: 1,
            ),
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Icon(icono, color: const Color(0xFF0085DC), size: 55),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0085DC),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.today,
                            color: Color(0xFFC6DA23), size: 20),
                        const SizedBox(width: 6),
                        Text(
                          'Finaliza: $subtitulo',
                          style: TextStyle(
                            fontSize: 12,
                            color: isCompleted ? Colors.grey : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      activities,
                      style: TextStyle(
                        fontSize: 12,
                        color: isCompleted ? Colors.grey : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              if (isCompleted)
                const Icon(Icons.check_circle,
                    color: Color.fromARGB(255, 255, 255, 255), size: 24)
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
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DescubrePage(
                      activities: activities,
                      title: 'titulo',
                      idProcess: 'idProcess')),
            );
          },
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_circle_filled, color: Colors.white, size: 28),
              SizedBox(width: 12),
              Text(
                'Comenzar Plan',
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
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 85,
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
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment:
                    CrossAxisAlignment.center, // Centra verticalmente
                children: [
                  const Icon(
                    Icons.sports_gymnastics,
                    color: Colors.white,
                    size: 60,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Tu grupo de Trabajo',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                            fontFamily: 'HelveticaRounded',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _processGroupResponse?['name'] != null
                              ? (_processGroupResponse!['name'] as String)
                                  .split(' ')
                                  .map((word) => word.isNotEmpty
                                      ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
                                      : '')
                                  .join(' ')
                              : 'Sin Nombre',
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
    );
  }
}
