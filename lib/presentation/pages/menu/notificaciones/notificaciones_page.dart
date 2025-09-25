import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecoapp/data/repositories/notification_settings_service.dart';

class NotificacionesPage extends StatefulWidget {
  const NotificacionesPage({super.key});

  @override
  State<NotificacionesPage> createState() => _NotificacionesPageState();
}

class _NotificacionesPageState extends State<NotificacionesPage> {
  final NotificationSettingsService _settingsService =
      NotificationSettingsService();
  bool notificacionesActivas = true;
  String frecuenciaSeleccionada = '1';
  bool pausasActivas = true;
  TimeOfDay horaInicio = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay horaFin = const TimeOfDay(hour: 17, minute: 0);
  static const _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _cargarPreferencias();
  }

  Future<void> _cargarPreferencias() async {
    final userId = await _storage.read(key: 'admin_userId') ?? '';
    final prefs = await SharedPreferences.getInstance();
    final settings = await _settingsService.fetchNotificationSettings(userId);
    
    setState(() {
      notificacionesActivas = prefs.getBool('notificacionesActivas') ?? true;
      frecuenciaSeleccionada = prefs.getString('frecuencia') ?? '1';
      pausasActivas = prefs.getBool('pausasActivas') ?? true;
      horaInicio = TimeOfDay(
        hour: prefs.getInt('horaInicio_hour') ?? 8,
        minute: prefs.getInt('horaInicio_minute') ?? 0,
      );
      horaFin = TimeOfDay(
        hour: prefs.getInt('horaFin_hour') ?? 17,
        minute: prefs.getInt('horaFin_minute') ?? 0,
      );
    });
  }

  Future<void> _guardarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificacionesActivas', notificacionesActivas);
    await prefs.setString('frecuencia', frecuenciaSeleccionada);
    await prefs.setBool('pausasActivas', pausasActivas);
    await prefs.setString(
        'horaInicio_hour', horaInicio.hour.toString().padLeft(2, '0'));
    await prefs.setString(
        'horaInicio_minute', horaInicio.minute.toString().padLeft(2, '0'));
    await prefs.setString(
        'horaFin_hour', horaFin.hour.toString().padLeft(2, '0'));
    await prefs.setString(
        'horaFin_minute', horaFin.minute.toString().padLeft(2, '0'));
    final id = await _storage.read(key: 'admin_userId');

    // Actualizar en el servidor
    final success = await _settingsService.updateNotificationSettings(id);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al guardar las preferencias en el servidor'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _seleccionarHora(bool esInicio) async {
    final TimeOfDay? hora = await showTimePicker(
      context: context,
      initialTime: esInicio ? horaInicio : horaFin,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFC6DA23),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF0067AC),
            ),
          ),
          child: child!,
        );
      },
      cancelText: "CANCELAR",
      confirmText: "ACEPTAR",
      hourLabelText: "Hora",
      minuteLabelText: "Minutos",
    );

    if (hora != null) {
      final String hora24 =
          hora.hour.toString().padLeft(2, '0'); // "01" para 1 am
      final String minutos = hora.minute.toString().padLeft(2, '0');

      setState(() {
        if (esInicio) {
          horaInicio = hora;
        } else {
          horaFin = hora;
        }
      });

      // Puedes usar hora24 y minutos aquí según lo necesites
      debugPrint('Hora seleccionada: $hora24:$minutos');

      _guardarPreferencias();
    }
  }

  Future<bool> _showSaveConfirmDialog() async {
    if (!mounted) return false;

    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text(
                'Guardar Cambios',
                style: TextStyle(
                  color: Color(0xFF0067AC),
                  fontFamily: 'HelveticaRounded',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: const Text(
                '¿Deseas guardar los cambios realizados?',
                style: TextStyle(
                  fontFamily: 'HelveticaRounded',
                  fontSize: 16,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text(
                    'NO GUARDAR',
                    style: TextStyle(
                      color: Colors.red,
                      fontFamily: 'HelveticaRounded',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text(
                    'GUARDAR',
                    style: TextStyle(
                      color: Color(0xFF0067AC),
                      fontFamily: 'HelveticaRounded',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<void> _handleSkip() async {
    if (!mounted) return;

    final shouldSave = await _showSaveConfirmDialog();
    if (!mounted) return;

    if (shouldSave) {
      await _guardarPreferencias();
    }
    if (mounted) {
      Navigator.pushNamed(context, '/menu');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
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
                  // Botón de retorno
                  Positioned(
                    left: 8,
                    top: 0,
                    bottom: 0,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                      ),
                      onPressed: _handleSkip,
                    ),
                  ),
                  // Título centrado
                  const Center(
                    child: Text(
                      'Notificaciones',
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
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildCard(
                      title: 'Notificaciones de Pausas Activas',
                      child: Column(
                        children: [
                          SwitchListTile(
                            title: const Text('Activar Notificaciones'),
                            value: notificacionesActivas,
                            onChanged: (bool value) {
                              setState(() {
                                notificacionesActivas = value;
                              });
                              _guardarPreferencias();
                            },
                            activeColor: const Color(0xFF0067AC),
                          ),
                          const Divider(),
                          ListTile(
                            title: const Text('Frecuencia de Notificaciones'),
                            subtitle: DropdownButton<String>(
                              value: frecuenciaSeleccionada,
                              isExpanded: true,
                              onChanged: notificacionesActivas
                                  ? (String? value) {
                                      if (value != null) {
                                        setState(() {
                                          frecuenciaSeleccionada = value;
                                        });
                                        _guardarPreferencias();
                                      }
                                    }
                                  : null,
                              items: const [
                                DropdownMenuItem(
                                  value: '1',
                                  child: Text('Cada hora'),
                                ),
                                DropdownMenuItem(
                                  value: '2',
                                  child: Text('Cada 2 horas'),
                                ),
                                DropdownMenuItem(
                                  value: '3',
                                  child: Text('Cada 3 horas'),
                                ),
                                DropdownMenuItem(
                                  value: '4',
                                  child: Text('Cada 4 horas'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCard(
                      title: 'Horario de Notificaciones',
                      child: Column(
                        children: [
                          SwitchListTile(
                            title: const Text('Pausas Activas'),
                            value: pausasActivas,
                            onChanged: (bool value) {
                              setState(() {
                                pausasActivas = value;
                              });
                              _guardarPreferencias();
                            },
                            activeColor: const Color(0xFF0067AC),
                          ),
                          const Divider(),
                          ListTile(
                            title: const Text(
                              'Hora de inicio',
                              style: TextStyle(
                                color: Color(0xFF0067AC),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: Container(
                              constraints: const BoxConstraints(
                                  maxWidth: 120), // Añadido constraints
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6), // Reducido padding
                              decoration: BoxDecoration(
                                color: const Color(0xFFC6DA23).withAlpha(
                                    26), // Reemplazado withOpacity(0.1)
                                borderRadius: BorderRadius.circular(20),
                                border:
                                    Border.all(color: const Color(0xFFC6DA23)),
                              ),
                              child: Text(
                                horaInicio
                                    .format(context)
                                    .replaceAll('AM', 'a.m.')
                                    .replaceAll('PM', 'p.m.'),
                                style: const TextStyle(
                                  color: Color(0xFF0067AC),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13, // Reducido tamaño de fuente
                                ),
                              ),
                            ),
                            onTap: () => _seleccionarHora(true),
                          ),
                          ListTile(
                            title: const Text(
                              'Hora de fin',
                              style: TextStyle(
                                color: Color(0xFF0067AC),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFC6DA23).withAlpha(
                                    26), // Reemplazado withOpacity(0.1)
                                borderRadius: BorderRadius.circular(20),
                                border:
                                    Border.all(color: const Color(0xFFC6DA23)),
                              ),
                              child: Text(
                                horaFin
                                    .format(context)
                                    .replaceAll('AM', 'a.m.')
                                    .replaceAll('PM', 'p.m.'),
                                style: const TextStyle(
                                  color: Color(0xFF0067AC),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            onTap: () => _seleccionarHora(false),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF0067AC),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.notifications_active,
                  color: Color(0xFFC6DA23), // Verde corporativo
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  // Añadido Expanded aquí
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }
}
