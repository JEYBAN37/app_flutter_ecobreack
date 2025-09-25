// app_notification.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppNotification {
  final String title;
  final String body;
  final DateTime date;

  AppNotification({
    required this.title,
    required this.body,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        "title": title,
        "body": body,
        "date": date.toIso8601String(),
      };

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        title: json["title"],
        body: json["body"],
        date: DateTime.parse(json["date"]),
      );

  /// Devuelve true si la hora actual está dentro del rango permitido para mostrar notificaciones
  static Future<bool> isDentroHorarioPermitido() async {
    final prefs = await SharedPreferences.getInstance();
    final int inicioHour = prefs.getInt('horaInicio_hour') ?? 8;
    final int inicioMinute = prefs.getInt('horaInicio_minute') ?? 0;
    final int finHour = prefs.getInt('horaFin_hour') ?? 17;
    final int finMinute = prefs.getInt('horaFin_minute') ?? 0;

    final now = TimeOfDay.now();
    final inicio = TimeOfDay(hour: inicioHour, minute: inicioMinute);
    final fin = TimeOfDay(hour: finHour, minute: finMinute);

    bool isAfterInicio = now.hour > inicio.hour ||
        (now.hour == inicio.hour && now.minute >= inicio.minute);
    bool isBeforeFin = now.hour < fin.hour ||
        (now.hour == fin.hour && now.minute <= fin.minute);

    // Si el rango no cruza medianoche
    if (inicio.hour < fin.hour ||
        (inicio.hour == fin.hour && inicio.minute < fin.minute)) {
      return isAfterInicio && isBeforeFin;
    } else {
      // Si el rango cruza medianoche (ej: 22:00 a 06:00)
      return isAfterInicio || isBeforeFin;
    }
  }
}
