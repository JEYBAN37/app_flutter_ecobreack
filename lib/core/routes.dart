import 'package:ecoapp/presentation/pages/menu/ajustes/calibration_screen.dart';
import 'package:ecoapp/presentation/pages/menu/descubre/descubre_actual.dart';
import 'package:flutter/material.dart';

// Pages imports
import '../presentation/pages/home/home_page.dart';
import '../presentation/pages/auth/registro/register_page.dart';
import '../presentation/pages/auth/login_page.dart';
import '../presentation/pages/auth/forgot_password_page.dart';
import '../presentation/pages/menu/menu_principal.dart';
import '../presentation/pages/menu/usuario/usuario_page.dart';
import '../presentation/pages/menu/ajustes/ajustes.dart';
import '../presentation/pages/menu/notificaciones/notificaciones_page.dart';
import '../presentation/pages/menu/notificaciones/notificacion_lista_page.dart';
import '../presentation/pages/menu/notificaciones/historial_notificaciones_page.dart';
import '../presentation/pages/menu/ajustes/edit_perfil.dart';
import '../presentation/pages/menu/ajustes/historial_actividades_page.dart';
import '../presentation/pages/menu/progreso/progreso_page.dart';
import '../presentation/pages/menu/actividades/actividades_page.dart';
import '../presentation/pages/menu/descubre/descubre_page.dart';

/// Route names as constants
class Routes {
  static const String home = '/';
  static const String register = '/register';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String menu = '/menu';
  static const String usuario = '/usuario';
  static const String ajustes = '/ajustes';
  static const String perfil = '/perfil';
  static const String notificaciones = '/notificaciones';
  static const String historialActividades = '/historial-actividades';
  static const String historialNotificaciones = '/historial-notificaciones';
  static const String notificacionesLista = '/notificaciones-lista';
  static const String actividades = '/actividades';
  static const String progreso = '/progreso';
  static const String descubre = '/descubre';
  static const String calibracionSensores = '/calibracion-sensores';
}

/// App routes map
Map<String, Widget Function(BuildContext)> get appRoutes => {
      Routes.home: (context) => const HomePage(),
      Routes.register: (context) => const RegisterPage(),
      Routes.login: (context) => const LoginPage(),
      Routes.forgotPassword: (context) => const ForgotPasswordPage(),
      Routes.menu: (context) => const MenuPrincipal(),
      Routes.usuario: (context) => const UsuarioPage(),
      Routes.ajustes: (context) => const AjustesPage(),
      Routes.perfil: (context) => const EditPerfilPage(),
      Routes.notificaciones: (context) => const NotificacionesPage(),
      Routes.historialActividades: (context) =>
          const HistorialActividadesPage(),
      Routes.historialNotificaciones: (context) =>
          const NotificationHistoryScreen(),
      Routes.notificacionesLista: (context) => const NotificacionListaPage(),
      Routes.actividades: (context) => const ActividadesPage(),
      Routes.progreso: (context) => const ProgresoPage(),
      Routes.descubre: (context) => const DescubreActual(),
      Routes.calibracionSensores: (context) => const CalibrationScreen(),
    };
