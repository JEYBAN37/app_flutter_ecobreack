import 'package:flutter/material.dart';

class HistorialNotificacionesPage extends StatelessWidget {
  const HistorialNotificacionesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _buildHistoryList(),
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
              'Historial de Notificaciones',
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

  Widget _buildHistoryList() {
    final history = {
      'Hoy': [
        {
          'title': 'Pausa activa completada',
          'message': 'Estiramiento de cuello - 5 min (3/5 hoy)',
          'time': '14:30',
          'icon': Icons.check_circle,
          'progress': 0.6,
          'showProgress': true,
        },
        {
          'title': 'Nuevo ejercicio disponible',
          'message': 'Ejercicios para reducir la fatiga visual\nDuración: 3 minutos',
          'time': '13:00',
          'icon': Icons.fitness_center,
          'showProgress': false,
        },
      ],
      'Ayer': [
        {
          'title': 'Resumen semanal de pausas activas',
          'message': 'Operaciones: 75% de cumplimiento\n3 usuarios no realizaron pausas',
          'time': '17:45',
          'icon': Icons.assessment,
          'showProgress': false,
        },
        {
          'title': 'Personaliza tus notificaciones',
          'message': 'Ajusta la frecuencia o desactiva las alertas',
          'time': '11:30',
          'icon': Icons.notifications_active,
          'showProgress': false,
        },
      ],
    };

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final date = history.keys.elementAt(index);
        final notifications = history[date]!;
        return _buildDateSection(date, notifications);
      },
    );
  }

  Widget _buildDateSection(String date, List<Map<String, dynamic>> notifications) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            date,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0067AC),
              fontFamily: 'HelveticaRounded',
            ),
          ),
        ),
        ...notifications.map((notification) => _buildHistoryCard(notification)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> notification) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFC6DA23),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                notification['icon'] as IconData,
                color: Colors.white,
                size: 24,
              ),
            ),
            title: Text(
              notification['title'] as String,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF0067AC),
                fontFamily: 'HelveticaRounded',
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  notification['message'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  notification['time'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          if (notification['showProgress'] == true)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Progreso diario:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: notification['progress'] as double,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getProgressColor(notification['progress'] as double),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.4) return Colors.red;
    if (progress < 0.7) return Colors.yellow;
    return const Color(0xFF4CAF50);
  }
}
