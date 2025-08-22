import 'package:flutter/material.dart';

class NotificacionListaPage extends StatelessWidget {
  const NotificacionListaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _buildNotificationList(),
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
              'Mis Notificaciones',
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

  Widget _buildNotificationList() {
    // Simulación de datos de notificaciones
    final notifications = [
      {
        'title': 'Pausa Activa',
        'message': 'Es hora de tu pausa activa programada',
        'time': '10:30 AM',
        'icon': Icons.accessibility_new,
        'isNew': true,
      },
      {
        'title': 'Recordatorio',
        'message': 'No olvides realizar tus ejercicios diarios',
        'time': 'Ayer',
        'icon': Icons.fitness_center,
        'isNew': false,
      },
      // Agregar más notificaciones aquí
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildNotificationCard(notification);
      },
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: notification['isNew'] 
                ? const Color(0xFFC6DA23) 
                : const Color(0xFF0067AC),
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
    );
  }
}
