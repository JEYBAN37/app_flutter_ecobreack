import 'package:ecoapp/presentation/pages/menu/notificaciones/app_notification.dart';
import 'package:ecoapp/presentation/pages/menu/notificaciones/notification_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  void initNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final notif = message.notification;
      if (notif != null && notif.title != null && notif.title!.isNotEmpty) {
        // Solo guardar si tiene título válido
        await NotificationStorage.saveNotification(
          AppNotification(
            title: notif.title!,
            body: notif.body ?? "",
            date: DateTime.now(),
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      final notif = message.notification;
      if (notif != null && notif.title != null && notif.title!.isNotEmpty) {
        // Solo guardar si tiene título válido
        await NotificationStorage.saveNotification(
          AppNotification(
            title: notif.title!,
            body: notif.body ?? "",
            date: DateTime.now(),
          ),
        );
      }
    });
  }
}
