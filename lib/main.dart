import 'dart:io';
import 'package:ecoapp/presentation/pages/menu/notificaciones/app_notification.dart';
import 'package:ecoapp/presentation/pages/menu/notificaciones/notification_storage.dart';
import 'package:ecoapp/presentation/pages/menu/notificaciones/notification_utils.dart'
    as notificationUtils;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/route_observer.dart';
import 'package:ecoapp/data/repositories/auth_repository.dart';
import 'package:ecoapp/presentation/pages/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'firebase_options.dart';
import 'core/routes.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'dart:developer' as developer;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final notif = AppNotification(
    title: message.notification?.title ?? 'Sin título',
    body: message.notification?.body ?? 'Sin cuerpo',
    date: DateTime.now(),
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  debugPrint('Manejador en segundo plano: $notif');
  await NotificationStorage.saveNotification(notif);

  final dentroHorario = await notificationUtils.isDentroHorarioPermitido();
  if (dentroHorario) {
    debugPrint('Notificación mostrada al usuario (dentro del horario)');
    // Mostrar notificación local solo si está dentro del horario
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'default_channel',
      'Notificaciones',
      channelDescription: 'Canal para notificaciones EcoBreak',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      notif.date.millisecondsSinceEpoch ~/ 1000,
      notif.title,
      notif.body,
      platformChannelSpecifics,
    );
  } else {
    debugPrint(
        'Notificación filtrada: solo guardada en historial (fuera de horario)');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  AuthRepository().requestNotificationPermission();
  AuthRepository().setupFCMListeners();
  runApp(const AppInitializer());
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  late Future<void> _firebaseInit;

  @override
  void initState() {
    super.initState();
    _firebaseInit = _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Inicializar Firebase App Check
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.debug,
        appleProvider: AppleProvider.debug,
      );

      developer.log('✅ Firebase y App Check inicializados correctamente');
    } catch (e) {
      developer.log('❌ Error al inicializar Firebase: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _firebaseInit,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: SplashScreen(),
          );
        }
        return const MyApp();
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [routeObserver],
      debugShowCheckedModeBanner: false,
      title: 'EcoBreak App',
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      initialRoute: Routes.home,
      routes: appRoutes,
      onGenerateRoute: (settings) {
        // Fallback for undefined routes
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(child: Text('Ruta no encontrada')),
          ),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
