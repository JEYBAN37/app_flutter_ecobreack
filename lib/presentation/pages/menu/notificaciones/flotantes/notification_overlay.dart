import 'package:flutter/material.dart';

class NotificationOverlay {
  static void showPausaActiva(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Image.asset('assets/imagenes/LOGOECOBREACK.png', height: 24),
            const SizedBox(width: 8),
            const Text(
              'EMAS Pausas Activas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0067AC),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Es hora de tu pausa activa de 5 minutos'),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    _showDelayedNotification(context);
                  },
                  child: const Text('Posponer'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    showPausaCompletada(dialogContext);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0067AC),
                  ),
                  child: const Text('Iniciar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static void _showDelayedNotification(BuildContext context) {
    final navigator = Navigator.of(context);

    Future.delayed(const Duration(minutes: 10), () {
      if (navigator.mounted) {
        showPausaActiva(navigator.context);
      } else {
        debugPrint('Navigator context is no longer mounted. Not showing dialog.');
      }
    });
  }

  static void showPausaCompletada(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Image.asset('assets/imagenes/LOGOECOBREACK.png', height: 24),
            const SizedBox(width: 8),
            const Text(
              'EMAS Pausas Activas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0067AC),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('¡Pausa activa completada!'),
            const Text('Estiramiento de cuello - 5 min (3/5 hoy)'),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: 0.6,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor(0.6)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(dialogContext).pushNamed('/historial-notificaciones');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0067AC),
              ),
              child: const Text('Ver registro'),
            ),
          ],
        ),
      ),
    );
  }

  static Color _getProgressColor(double progress) {
    if (progress < 0.4) return Colors.red;
    if (progress < 0.7) return Colors.yellow;
    return const Color(0xFF4CAF50);
  }
}
