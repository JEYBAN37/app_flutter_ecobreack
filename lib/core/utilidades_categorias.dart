import 'package:ecoapp/core/consultas_actividades.dart';
import 'package:ecoapp/core/utilidades_iconos.dart';
import 'package:ecoapp/data/repositories/network/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class UtilidadesCategorias {
  static const _storage = FlutterSecureStorage();
  static Map<String, dynamic> configPorIcono(String iconName) {
    switch (iconName) {
      case 'Icons.visibility':
      case 'Icons.remove_red_eye':
        return {
          'nombre': 'Visual',
          'color': const Color(0xFF4FC3F7),
          'descripcion':
              'Ejercicios para reducir la fatiga visual y mejorar la salud ocular en el trabajo.',
        };
      case 'Icons.hearing':
      case 'Icons.headphones':
        return {
          'nombre': 'Auditiva',
          'color': const Color(0xFF9575CD),
          'descripcion':
              'Ejercicios para relajar y proteger la audición en ambientes laborales.',
        };
      case 'Icons.psychology':
      case 'Icons.numbers':
        return {
          'nombre': 'Psicológico',
          'color': const Color(0xFFFFB74D),
          'descripcion':
              'Ejercicios para estimular la concentración y la memoria.',
        };
      case 'Icons.accessibility_new':
        return {
          'nombre': 'Accesibilidad',
          'color': const Color(0xFF0067AC),
          'descripcion':
              'Moviliza y estira hombros, cuello y brazos para prevenir molestias.',
        };
      case 'Icons.directions_walk':
        return {
          'nombre': 'Movilidad',
          'color': const Color(0xFFC6DA23),
          'descripcion':
              'Ejercicios para piernas y cadera, mejorando la circulación y flexibilidad.',
        };
      case 'Icons.self_improvement':
        return {
          'nombre': 'Mejora Personal',
          'color': const Color(0xFF26A69A),
          'descripcion':
              'Rutinas para mantener las articulaciones móviles y saludables.',
        };
      default:
        return {
          'nombre': 'General',
          'color': const Color(0xFFBDBDBD),
          'descripcion': 'Ejercicios generales.',
        };
    }
  }

  static Future<dynamic> agruparPorTituloIconoSync(
      List fetchedActivities, String idProcess) async {
    final categorias = {};

    String? grupoId;
    final adminUserData = await _storage.read(key: 'admin_userdata');
    final userData = jsonDecode(adminUserData ?? '{}') as Map<String, dynamic>;

    // id usuario
    final userId = await _storage.read(key: 'admin_userId');

    // id grupo usuario
    grupoId = userData['groupId'];
    final grupoUsuario = grupoId;

    // id plan de pausa
    final proceso = idProcess;

    final apiService = ApiService();
    final actividadesRealizadas =
        await apiService.loadActivityComplete(userId, proceso, grupoUsuario);

    for (final plan in fetchedActivities) {
      for (final ejercicio in plan['ejercicios']) {
        final catConf = configPorIcono(ejercicio['icono']);
        final nombreCat = catConf['nombre'];

        debugPrint('[DEBUG] Ejercicio: $actividadesRealizadas');

        final categoria = catConf['id'];
        if (!categorias.containsKey(nombreCat)) {
          categorias[nombreCat] = {
            'nombre': nombreCat,
            'color': catConf['color'],
            'descripcion': catConf['descripcion'],
            'estado': true, // Por defecto, la categoría no está completada
            'ejercicios': [],
          };
        }

        // Verifica si el ejercicio está en actividadesRealizadas por id
        bool estadoEjercicio = true;
        final actividadesList = actividadesRealizadas['data'] ?? [];
        if (actividadesList.isNotEmpty) {
          final existe = actividadesList.contains(ejercicio['id']);
          if (existe) estadoEjercicio = false;
        }

        categorias[nombreCat]!['ejercicios'].add({
          'id': ejercicio['id'],
          'nombre': ejercicio['nombre'],
          'duracion': ejercicio['duracion'],
          'descripcion': ejercicio['descripcion'],
          'pasos': ejercicio['pasos'],
          'icono': UtilidadesIconos.obtenerIcono(ejercicio['icono']),
          'videoUrl': ejercicio['videoUrl'],
          'sensorEnabled': ejercicio['sensorEnabled'] ?? false,
          'estado': estadoEjercicio,
          'grupoId': grupoUsuario,
          'planDePausa': proceso,
          'userId': userId,
        });
      }
    }

    // Si todos los ejercicios de una categoría están completados, el estado de la categoría es true
    categorias.forEach((nombreCat, catData) {
      final ejercicios = catData['ejercicios'] as List;
      // Si todos los ejercicios están en estado false, la categoría es false
      final todosIncompletos = ejercicios.isNotEmpty &&
          ejercicios.every((ej) => (ej['estado'] ?? false) == false);
      catData['estado'] = !todosIncompletos;
    });
    return categorias.values.toList();
  }
}
