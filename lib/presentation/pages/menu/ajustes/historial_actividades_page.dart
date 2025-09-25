import 'package:ecoapp/data/repositories/network/api_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class HistorialActividadesPage extends StatefulWidget {
  const HistorialActividadesPage({super.key});

  @override
  State<HistorialActividadesPage> createState() =>
      _HistorialActividadesPageState();
}

class _HistorialActividadesPageState extends State<HistorialActividadesPage> {
  List<dynamic> _exerciseHistory = [];
  bool _isLoading = true; // <-- Nueva variable de carga

  @override
  void initState() {
    super.initState();
    getHistorial();
  }

  getHistorial() async {
    // Aquí iría la lógica para obtener el historial de actividades
    setState(() {
      _isLoading = true;
    });
    final response = await ApiService().fetchUserHistory();
    if (response != null) {
      setState(() {
        _exerciseHistory = response ?? [];
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF0067AC),
                      ),
                    )
                  : _buildHistorialList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Color(0xFF0067AC),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFC6DA23),
            width: 3.0,
          ),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 8,
            top: 0,
            bottom: 0,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Center(
            child: Text(
              'Historial de Actividades',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'HelveticaRounded',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                // Reemplazado withOpacity(0.1) por withAlpha(26)
                color: const Color(0xFFC6DA23).withAlpha(26),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.sports_gymnastics,
                size: 80,
                color: Color(0xFF0067AC),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No hay actividades registradas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0067AC),
                fontFamily: 'HelveticaRounded',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Aquí podrás ver el historial de todas las actividades que realices.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontFamily: 'HelveticaRounded',
              ),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: null, // Disabled for now
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                side: const BorderSide(
                  color: Color(0xFFC6DA23),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              icon: const Icon(
                Icons.history,
                color: Color(0xFF0067AC),
              ),
              label: const Text(
                'Próximamente',
                style: TextStyle(
                  color: Color(0xFF0067AC),
                  fontFamily: 'HelveticaRounded',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistorialList() {
    if (_exerciseHistory.isEmpty) {
      return _buildEmptyState();
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _exerciseHistory.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final actividad = _exerciseHistory[index];
        final categoria = actividad['categoria'] ?? '';
        final icon = _getCategoriaIcon(categoria);
        final color = _getCategoriaColor(categoria);

        return Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withOpacity(0.18),
              child: Icon(icon, color: color, size: 28),
            ),
            title: Text(
              actividad['nombre'] ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'HelveticaRounded',
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  actividad['plan'] ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    fontFamily: 'HelveticaRounded',
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.timer, size: 16, color: color),
                    const SizedBox(width: 4),
                    Text(
                      '${actividad['tiempo'] ?? 0} min',
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.event, size: 16, color: color),
                    const SizedBox(width: 4),
                    Text(
                      actividad['finalizacion'] ?? '',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

// Iconos y colores por categoría (igual que en progreso)
  IconData _getCategoriaIcon(String categoria) {
    switch (categoria) {
      case 'Visual':
        return Icons.visibility;
      case 'Auditiva':
        return Icons.hearing;
      case 'Cognitiva':
        return Icons.psychology;
      case 'Accesibilidad':
        return Icons.accessibility_new;
      case 'Tren Superior':
        return Icons.accessibility_new;
      case 'Tren Inferior':
        return Icons.directions_walk;
      case 'Movilidad Articular':
      case 'Movilidad':
        return Icons.self_improvement;
      case 'Estiramientos Generales':
        return Icons.extension;
      default:
        return Icons.category;
    }
  }

  Color _getCategoriaColor(String categoria) {
    switch (categoria) {
      case 'Visual':
        return const Color(0xFF4FC3F7); // Azul claro
      case 'Auditiva':
        return const Color(0xFF9575CD); // Morado
      case 'Cognitiva':
        return const Color(0xFFFFB74D); // Naranja
      case 'Accesibilidad':
      case 'Tren Superior':
        return const Color(0xFF1976D2); // Azul fuerte
      case 'Tren Inferior':
        return const Color(0xFFC6DA23); // Verde claro
      case 'Movilidad Articular':
      case 'Movilidad':
        return const Color(0xFF26C6DA); // Turquesa
      case 'Estiramientos Generales':
        return const Color(0xFFFF8A65); // Naranja suave
      default:
        return Colors.grey;
    }
  }
}
