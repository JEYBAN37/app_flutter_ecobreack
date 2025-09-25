import 'package:ecoapp/presentation/pages/menu/notificaciones/app_notification.dart';
import 'package:ecoapp/presentation/pages/menu/notificaciones/notification_storage.dart';
import 'package:flutter/material.dart';

class NotificationHistoryScreen extends StatefulWidget {
  const NotificationHistoryScreen({super.key});

  @override
  State<NotificationHistoryScreen> createState() =>
      HistorialNotificacionesPage();
}


class HistorialNotificacionesPage extends State<NotificationHistoryScreen> {
  List<AppNotification> _notifs = [];

  HistorialNotificacionesPage();

  @override
  void initState() {
    super.initState();
    _loadNotifs();
  }

    Future<void> _loadNotifs() async {
    final list = await NotificationStorage.loadNotifications();
    setState(() => _notifs = list);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _buildHistoryList(_notifs),
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

Widget _buildHistoryList(List<AppNotification> notifs) {
  // Agrupar por día (Hoy, Ayer, etc.)
  final Map<String, List<AppNotification>> grouped = {};

  for (final n in notifs) {
    final now = DateTime.now();
    String key;

    if (n.date.year == now.year &&
        n.date.month == now.month &&
        n.date.day == now.day) {
      key = "Hoy";
    } else if (n.date.year == now.year &&
        n.date.month == now.month &&
        n.date.day == now.day - 1) {
      key = "Ayer";
    } else {
      key =
          "${n.date.day}/${n.date.month}/${n.date.year}"; // otras fechas con formato dd/mm/yyyy
    }

    grouped.putIfAbsent(key, () => []).add(n);
  }

  return ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: grouped.length,
    itemBuilder: (context, index) {
      final date = grouped.keys.elementAt(index);
      final notifications = grouped[date]!;
      return _buildDateSection(date, notifications);
    },
  );
}

Widget _buildDateSection(String date, List<AppNotification> notifications) {
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
      ...notifications.map((n) => _buildHistoryCard(n)),
      const SizedBox(height: 16),
    ],
  );
}

Widget _buildHistoryCard(AppNotification n) {
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
          color: const Color(0xFFC6DA23),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.notifications,
          color: Colors.white,
          size: 24,
        ),
      ),
      title: Text(
        n.title,
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
            n.body,
            style: const TextStyle(fontSize: 14, height: 1.3),
          ),
          const SizedBox(height: 8),
          Text(
            "${n.date.hour}:${n.date.minute.toString().padLeft(2, '0')}",
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



  Color _getProgressColor(double progress) {
    if (progress < 0.4) return Colors.red;
    if (progress < 0.7) return Colors.yellow;
    return const Color(0xFF4CAF50);
  }
}
