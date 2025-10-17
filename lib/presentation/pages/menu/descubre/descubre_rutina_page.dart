import 'dart:math';

import 'package:ecoapp/data/repositories/network/api_service.dart';
import 'package:flutter/material.dart';
import 'package:ecoapp/core/services/tts_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'package:ecoapp/presentation/pages/menu/menu_principal.dart';
import 'package:ecoapp/core/pause_detector_service.dart';
import 'package:ecoapp/core/motion_detector_dialog.dart';
import 'package:lottie/lottie.dart';
import 'package:sensors_plus/sensors_plus.dart';

class DescubreRutinaPage extends StatefulWidget {
  final Map categoria;
  final List ejercicios;
  bool salir = false;
  DescubreRutinaPage(
      {super.key,
      required this.categoria,
      required this.ejercicios,
      this.salir = false});

  @override
  State<DescubreRutinaPage> createState() => _DescubreRutinaPageState();
}

class _DescubreRutinaPageState extends State<DescubreRutinaPage> {
  int _cronometroSegundos = 0;
  Timer? _cronometroTimer;
  bool _ejercicioTerminado = false;
  bool _rutinaFinalizada = false;
  String? motivoSeleccionado;
  static const _storage = FlutterSecureStorage();
  final apiService = ApiService();
  PauseDetectorService? _pauseDetectorService;
  List<Map<String, dynamic>> _sensorData = [];
  late int _currentIndex = _ejercicioActual();
  late TTSService _tts;
  bool _showMotivation = false;
  bool _isDetecting = false;
  bool _showKeyPoints = false;
  bool _timerStarted = false;
  bool _showCategoryChange = false;
  FlutterTts flutterTts = FlutterTts();
  VideoPlayerController? _driveVideoController;
  Timer? _timer;
  Timer? _autoStartTimer;
  int _secondsLeft = 0;
  int _totalSeconds = 0;
  int _autoStartSeconds = 6;
  String _alertaVoz = '';
  String _categoriaActual = '';
  String _categoriaAnterior = '';
  // Eliminada la declaración duplicada
  int _movementSeconds = 0;
  bool _movementSuccess = false;
  bool _movementTimeout = false;
  int _repeticiones = 0;
  bool _showRepsFeedback = false;
  String _repsFeedbackMsg = '';
  bool _hasDetectedMovement =
      false; // Nueva variable para rastrear si ya se detectó movimiento

  List<String> motivos = [];
  final detector = PauseDetectorService();

  int _ejercicioActual() {
    int ejercicio = 0;
    for (int i = 0; i < widget.ejercicios.length; i++) {
      if (widget.ejercicios[i]['estado'] != false) {
        ejercicio = i;
        break;
      }
    }

    return ejercicio;
  }

  void activarSensorYCapturar() {
    try {
      detector.start((count) {
        setState(() {
          _repeticiones = count;
          _updateRepsFeedback(count);
        });
      });
    } catch (e) {
      debugPrint('Error al iniciar el servicio de sensor: $e');
      if (mounted) Navigator.of(context).pop();
    }
  }

  void _updateRepsFeedback(int count) {
    if (count == 1) {
      _showRepsFeedback = true;
      _repsFeedbackMsg = 'Movimiento detectado';
      // Hide feedback after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _showRepsFeedback = false;
          });
        }
      });
    } else if (count > 50) {
      _showRepsFeedback = true;
      _repsFeedbackMsg = 'Movimiento aceptable';
      // Hide feedback after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _showRepsFeedback = false;
          });
        }
      });
    }
  }

  void _initDriveVideoController() {
    final ejercicio = widget.ejercicios[_currentIndex];
    if (ejercicio.containsKey('videoUrl') && ejercicio['videoUrl'] != null) {
      final driveId = ejercicio['videoUrl'] as String;
      final url = 'https://drive.google.com/uc?export=download&id=$driveId';
      debugPrint('Inicializando video desde URL: $url');
      _driveVideoController?.dispose();
      _driveVideoController = VideoPlayerController.network(url)
        ..initialize().then((_) {
          setState(() {});
          _driveVideoController?.play(); // <-- Reproduce automáticamente
          _driveVideoController?.addListener(() {
            if (_driveVideoController!.value.position >=
                    _driveVideoController!.value.duration &&
                _driveVideoController!.value.isInitialized) {
              _driveVideoController!.seekTo(Duration.zero);
              _driveVideoController!.play();
            }
          });
        });
    } else {
      _driveVideoController?.dispose();
      _driveVideoController = null;
    }
  }

  @override
  void initState() {
    super.initState();
    _tts = TTSService();
    cargarMotivos();
    _categoriaActual = widget.ejercicios[0]['categoria'];
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      debugPrint('Iniciando rutina de ${widget.ejercicios[0]}');
      // Cargar calibración al inicio
      await detector.loadCalibration();
      await _announcePlan(true);
      _initDriveVideoController();
      _initTimer();
      final ejercicio = widget.ejercicios[_currentIndex];
      final requiereSensor = ejercicio['sensorEnabled'];
      if (requiereSensor) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const MotionDetectorDialog(),
        ).then((value) {
          if (value == true) {
            activarSensorYCapturar();
          }
        });
      }
      _initPauseDetector();
      //_onStartPressed();
    });
  }

  sendMotivoDeCacelacion(motivoDeCancelacion) async {
    String idUser = await _storage.read(key: 'admin_userId') ?? '';
    String username = await _storage.read(key: 'admin_email') ?? '';
    String motivo = motivoDeCancelacion;

    debugPrint('[DEBUG] Motivo de cancelación: $motivo');

    final response = await apiService.postRequest(
      'admin/motivos/comentarios',
      {
        'idUser': idUser,
        'username': username,
        'motivo': motivo,
      },
    );

    if (response == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al guardar el motivo.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Guardado exitosamente.'),
        backgroundColor: Colors.green,
      ),
    );
    debugPrint('Respuesta del servidor: $response');
  }

  Future<void> cargarMotivos() async {
    // Simula llamada a API, reemplaza por tu llamada real
    final response = await apiService.get('/admin/motivos/active');
    debugPrint(response.toString());

    // Suponiendo que response es una lista de objetos con la propiedad 'titulo'
    final data = (response['data'] as List)
        .map((e) => e['titulo']?.toString() ?? '')
        .where((titulo) => titulo.isNotEmpty)
        .toList();

    setState(() {
      motivos = data; // response debe ser List<String>
    });
  }

  /// Retorna la información relevante de la actividad actual para el backend
  sendActividadFinalizadaInfo() async {
    final ejercicio = widget.ejercicios[_currentIndex];
    debugPrint('Ejercicio finalizado: $ejercicio');
    final bool requiereSensor = ejercicio['sensorEnabled'] == true;
    final actividadInfo = {
      'nombre': ejercicio['nombre'],
      'categoria': ejercicio['categoria'],
      'repeticiones': _repeticiones > 100 ? 100 : _repeticiones,
      'tiempo': requiereSensor ? _totalSeconds : _cronometroSegundos,
      'sensorEnabled': ejercicio['sensorEnabled'] ?? false,
      'estado': ejercicio['estado'] ?? false,
      'idGrupo': ejercicio['grupoId'] ?? '',
      'idPlan': ejercicio['planDePausa'] ?? '',
      'idUsuario': ejercicio['userId'] ?? '',
      'idEjercicio': ejercicio['id'] ?? '',
      'createdAt': DateTime.now().toIso8601String().substring(0, 10),
    };

    await apiService.loadActivityToHistory(actividadInfo);

    // Puedes agregar más campos si lo necesitas
    debugPrint('Información de actividad para enviar: $actividadInfo');
  }

  void _initVideoController() {
    final ejercicio = widget.ejercicios[_currentIndex];
    // Si el ejercicio tiene un video de YouTube, usa YoutubePlayer
    String? url;
    if (ejercicio.containsKey('videoUrl') && ejercicio['videoUrl'] != null) {
      url = (ejercicio['videoUrl'] as String?)
          ?.replaceFirst('http://', 'https://');
    } else if (ejercicio.containsKey('driveId') &&
        ejercicio['driveId'] != null) {
      // Si el ejercicio tiene un id de Google Drive, genera el enlace embebido
      final driveId = ejercicio['driveId'] as String;
      url = 'https://drive.google.com/file/d/$driveId/preview';
    }
  }

  void _initTimer() {
    final ejercicio = widget.ejercicios[_currentIndex];
    final durRaw = ejercicio['duracion'];
    int durSeconds = 60;
    if (durRaw is String && durRaw.contains(':')) {
      final parts = durRaw.split(':');
      final min = int.tryParse(parts[0]) ?? 0;
      final sec = int.tryParse(parts[1]) ?? 0;
      durSeconds = min * 60 + sec;
    } else if (durRaw is int) {
      durSeconds = durRaw;
    }
    _secondsLeft = durSeconds;
    _totalSeconds = durSeconds;
    _timerStarted = false;
    _showMotivation = false;
    _showKeyPoints = false;
    _showCategoryChange = false;
    _autoStartSeconds = 6;
  }

  void _initPauseDetector() {
    final ejercicio = widget.ejercicios[_currentIndex];
    debugPrint(ejercicio);
    if (ejercicio['sensorEnabled'] == true) {
    } else {
      _pauseDetectorService = null;
    }
    _pauseDetectorService = null;
    _movementSeconds = 0;
    _movementSuccess = false;
    _movementTimeout = false;
    _repeticiones = 0;
    _showRepsFeedback = false;
    _repsFeedbackMsg = '';
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_secondsLeft > 0) {
        setState(() {
          _secondsLeft--;
        });
        if (_secondsLeft == (_totalSeconds / 2).round()) {
          setState(() => _showMotivation = true);
          await _speak('¡Vas por buen camino! Sigue así.');
          await Future.delayed(const Duration(seconds: 3));
          setState(() => _showMotivation = false);
        }
      } else if (_secondsLeft == 0) {
        timer.cancel();
        // Detener cronómetro si es ejercicio sin sensor
        final ejercicio = widget.ejercicios[_currentIndex];
        if (!(ejercicio['sensorEnabled'] == true)) {
          _cronometroTimer?.cancel();
        }
        setState(() {
          _ejercicioTerminado = true;
        });
        setState(() {
          _showKeyPoints = true;
        });
        await _speak('¡Has acabado este ejercicio!');
        await Future.delayed(const Duration(seconds: 6));
        setState(() {
          _showKeyPoints = false;
        });
        if (ejercicio['sensorEnabled'] == true) {
          await _speak('Verificando movimiento espera un momento...');
          await Future.delayed(const Duration(seconds: 3));
        } else {
          await _speak('¡Continuamos al siguiente ejercicio!');
          await Future.delayed(const Duration(seconds: 3));
        }

        await Future.delayed(const Duration(seconds: 2));
        _nextExercise(ejercicio['sensorEnabled']);
      }
    });
  }

  void _startAutoStartTimer() {
    _autoStartTimer?.cancel();
    _autoStartSeconds = 6;
    _autoStartTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerStarted) {
        timer.cancel();
        return;
      }
      setState(() {
        _autoStartSeconds--;
      });
      if (_autoStartSeconds == 0) {
        timer.cancel();
        _onStartPressed();
      }
    });
  }

  @override
  void dispose() {
    _tts.stop();
    _timer?.cancel();
    _autoStartTimer?.cancel();
    _driveVideoController?.dispose();
    super.dispose();
  }

  Future<void> _announcePlan(bool isFirst) async {
    final ejercicio = widget.ejercicios[_currentIndex];
    final categoria = ejercicio['categoria'];
    final pasos = (ejercicio['pasos'] as List).join('. ');
    String plan = '';
    if (isFirst) {
      plan =
          'La actividad que realizarás hoy será de la categoría $categoria. Comenzamos con el ejercicio número ${_currentIndex + 1}: ${ejercicio['nombre']}. ${ejercicio['descripcion']}. Los pasos son: $pasos';
    } else if (_categoriaActual != _categoriaAnterior) {
      plan = 'Cambiamos de categoría. Ahora pasamos a $categoria.';
      setState(() => _showCategoryChange = true);
      await _speak(plan);
      await Future.delayed(const Duration(seconds: 2));
      setState(() => _showCategoryChange = false);
      plan =
          'Ejercicio: ${ejercicio['nombre']}. ${ejercicio['descripcion']}. Los pasos son: $pasos';
    } else {
      plan =
          'Ejercicio: ${ejercicio['nombre']}. ${ejercicio['descripcion']}. Los pasos son: $pasos';
    }
    _alertaVoz = plan;
    await flutterTts.speak(plan);
  }

  Future<void> _speak(String text) async {
    _alertaVoz = text;
    await flutterTts.speak(text);
  }

  Future<void> _onStartPressed() async {
    if (!mounted) return;
    setState(() {
      _timerStarted = true;
      _isDetecting = false;
      _movementTimeout = false;
      _movementSuccess = false;
      _repeticiones = 0;
      _ejercicioTerminado = false;
      _cronometroSegundos = 0;
    });
    final ejercicio = widget.ejercicios[_currentIndex];
    if (!(ejercicio['sensorEnabled'] == true)) {
      if (_cronometroTimer != null) {
        _cronometroTimer!.cancel();
      }
      _cronometroTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _cronometroSegundos++;
        });
      });
    }
    await detector.loadCalibration(); // carga los valores del storage
    detector.start((count) {
      setState(() {
        _repeticiones = count;
        _updateRepsFeedback(count);
      });
    });

    _startTimer();
  }

  void _nextExercise(bool requiereSensor) async {
    // Detener cronómetro si está activo
    _cronometroTimer?.cancel();

    final bool esUltimo = _currentIndex == widget.ejercicios.length - 1;

    if (requiereSensor && (_repeticiones < 50 || _isDetecting == false)) {
      // Mostrar mensaje de error SOLO si requiere sensor y no cumple repeticiones
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No Cumpliste con las repeticiones mínimas para avanzar.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      detector.stop();
      Navigator.of(context).pop();
      return; // <-- Salir aquí, NO sigue el flujo
    }

    if (!mounted) return; // Verificación temprana de mounted
    detector.stop();
    setState(() {
      _showMotivation = false;
      _showKeyPoints = false;
      _timerStarted = false;
    });

    final ejercicio = widget.ejercicios[_currentIndex];

    if (!esUltimo) {
      if (!mounted) return;
      // Pausa de 10 segundos antes de continuar
      await _speak('Tómate una pausa de 10 segundos antes de continuar.');
      await Future.delayed(const Duration(seconds: 10));
      if (!mounted) return;
      await sendActividadFinalizadaInfo(); // Enviar info al terminar ejercicio
      setState(() {
        _currentIndex++;
        _initVideoController();
        _initDriveVideoController(); // <-- Asegura que el video se actualice
        _initTimer();
        _timerStarted = false; // <-- Reinicia timer
        _ejercicioTerminado = false; // <-- Reinicia estado de ejercicio
      });

      if (!mounted) return;
      // Cargar calibración para el siguiente ejercicio
      await detector.loadCalibration();
      await _announcePlan(_categoriaActual != _categoriaAnterior);
      // _startAutoStartTimer(); // Eliminar autoinicio, solo inicia cuando el usuario presione 'Iniciar'
    } else {
      if (!mounted) return;
      await _speak(
          'Con esta categoría acabamos. ¡Rutina completada! Felicitaciones.');
      await Future.delayed(
          const Duration(seconds: 8)); // Más tiempo para la voz
      if (!mounted) return;
      detector.stop();
      // Solo si cumple repeticiones mínimas, marcar como finalizada y enviar info
      if (!(requiereSensor && _repeticiones < 50 && _isDetecting == false)) {
        setState(() {
          _rutinaFinalizada = true;
        });
        await sendActividadFinalizadaInfo();
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('¡Felicidades!'),
            content: const Text('Has completado la rutina. ¡Buen trabajo!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Aceptar'),
                style: TextButton.styleFrom(foregroundColor: Colors.green),
              ),
            ],
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        // Si no cumple, ya se salió antes (por el return de arriba)
        // No hacer nada aquí
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentIndex < 0 || _currentIndex >= widget.ejercicios.length) {
      if (_rutinaFinalizada) {
        return const Scaffold(
          body: Center(child: Text('No hay más ejercicios.')),
        );
      } else if (widget.ejercicios.isNotEmpty) {
        // Si el índice se sale pero la rutina no está finalizada, mostrar el último ejercicio válido
        _currentIndex = widget.ejercicios.length - 1;
      } else {
        return const Scaffold(
          body: Center(child: Text('No hay ejercicios disponibles.')),
        );
      }
    }
    final ejercicio = widget.ejercicios[_currentIndex];
    final color = ejercicio['color'];
    const font = 'HelveticaRounded';
    final keyPoints =
        (ejercicio['pasos'] as List).map((e) => e.toString()).toList();
    final double percentElapsed =
        _totalSeconds > 0 ? (_totalSeconds - _secondsLeft) / _totalSeconds : 0;
    _isDetecting = _repeticiones > 50 ? true : false;
    final bool puedeSiguiente = percentElapsed >= 0.8 &&
        _timerStarted &&
        !_isDetecting &&
        !_rutinaFinalizada &&
        !_ejercicioTerminado;
    final bool requiereSensor = ejercicio['sensorEnabled'];

    // Formato para mostrar el cronómetro
    String _formatCronometro(int segundos) {
      final min = (segundos ~/ 60).toString().padLeft(2, '0');
      final sec = (segundos % 60).toString().padLeft(2, '0');
      return '$min:$sec';
    }

    return WillPopScope(
        onWillPop: () async {
          _showExitDialog();
          return false;
        },
        child: Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withAlpha(60), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // AppBar custom
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 18),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withAlpha(60),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Ejercicio #${_currentIndex + 1} de ${widget.ejercicios.length}',
                                  style: const TextStyle(
                                    fontFamily: font,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.exit_to_app,
                                      color: Colors.white),
                                  onPressed: _showExitDialog,
                                  tooltip: 'Salir',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          // Video y timer
                          ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            // Modifica el tamaño del cuadro del video aquí
                            child: Container(
                              width: double
                                  .infinity, // Ocupa todo el ancho disponible
                              height:
                                  220, // Altura fija, puedes ajustar este valor
                              child: _driveVideoController != null &&
                                      _driveVideoController!.value.isInitialized
                                  ? AspectRatio(
                                      aspectRatio: _driveVideoController!
                                          .value.aspectRatio,
                                      child: Stack(
                                        alignment: Alignment.bottomCenter,
                                        children: [
                                          VideoPlayer(_driveVideoController!),
                                          VideoProgressIndicator(
                                            _driveVideoController!,
                                            allowScrubbing: true,
                                            colors: VideoProgressColors(
                                              playedColor: color,
                                              bufferedColor:
                                                  color.withAlpha(80),
                                              backgroundColor: Colors.black12,
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 10,
                                            right: 10,
                                            child: FloatingActionButton(
                                              mini: true,
                                              backgroundColor: color,
                                              onPressed: () {
                                                setState(() {
                                                  if (_driveVideoController!
                                                      .value.isPlaying) {
                                                    _driveVideoController!
                                                        .pause();
                                                  } else {
                                                    _driveVideoController!
                                                        .play();
                                                  }
                                                });
                                              },
                                              child: Icon(
                                                _driveVideoController!
                                                        .value.isPlaying
                                                    ? Icons.pause
                                                    : Icons.play_arrow,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Center(
                                      child: CircularProgressIndicator(
                                          color: color),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          // Barra de progreso y tiempo
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: color.withAlpha(40),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: color.withAlpha(40),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    _formatTime(_secondsLeft),
                                    style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 28,
                                      fontFamily: font,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: _ejercicioTerminado
                                      ? 1.0
                                      : (_timerStarted && _totalSeconds > 0
                                          ? (_totalSeconds - _secondsLeft) /
                                              _totalSeconds
                                          : 0),
                                  backgroundColor: color.withAlpha(40),
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(color),
                                  minHeight: 8,
                                ),
                                if (requiereSensor && _timerStarted)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12.0),
                                    child: Column(
                                      children: [
                                        _RepsCounterWidget(
                                          repeticiones: _repeticiones,
                                          color: color,
                                        ),
                                        if (_showRepsFeedback)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 6.0),
                                            child: AnimatedOpacity(
                                              opacity:
                                                  _showRepsFeedback ? 1 : 0,
                                              duration: const Duration(
                                                  milliseconds: 300),
                                              child: Text(
                                                _repsFeedbackMsg,
                                                style: const TextStyle(
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                if (!requiereSensor && _timerStarted)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.timer,
                                                color: color, size: 28),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Tiempo: ${_formatCronometro(_cronometroSegundos)}',
                                              style: TextStyle(
                                                color: color,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                if (requiereSensor && _timerStarted)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12.0),
                                    child: _MovementDetectorWidget(
                                      isDetecting: _isDetecting,
                                      seconds: _movementSeconds,
                                      success: _movementSuccess,
                                      timeout: _movementTimeout,
                                      color: color,
                                    ),
                                  ),
                                if (!_rutinaFinalizada &&
                                    !_timerStarted &&
                                    !_ejercicioTerminado)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Column(
                                      children: [
                                        ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: color,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16)),
                                          ),
                                          onPressed: _rutinaFinalizada
                                              ? null
                                              : _onStartPressed,
                                          icon: const Icon(Icons.play_arrow,
                                              color: Colors.white),
                                          label: const Text('Iniciar',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'El tiempo iniciará automáticamente en $_autoStartSeconds segundos',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontFamily: font,
                                              fontSize: 14),
                                        ),
                                        const SizedBox(height: 6),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          // Card de ejercicio
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withAlpha(30),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ejercicio['nombre'],
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                    fontFamily: font,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  ejercicio['descripcion'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black87,
                                    fontFamily: font,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ...List.generate(
                                  keyPoints.length,
                                  (i) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 2.0),
                                    child: Text(
                                      '${i + 1}. ${keyPoints[i]}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                        fontFamily: font,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_showKeyPoints)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: color.withAlpha(40),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Puntos clave:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                    ...keyPoints.map((e) => Text('• $e',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: color,
                                            fontFamily: font))),
                                  ],
                                ),
                              ),
                            ),
                          if (_isDetecting)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              child: Row(
                                children: [
                                  const CircularProgressIndicator(),
                                  const SizedBox(width: 16),
                                  Text('Detectando movimiento...',
                                      style: TextStyle(
                                          color: color, fontFamily: font)),
                                ],
                              ),
                            ),
                          if (_showMotivation)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              child: Center(
                                child: Text(
                                  '¡Vas bien, continúa! 💪',
                                  style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    fontFamily: font,
                                  ),
                                ),
                              ),
                            ),
                          if (_showCategoryChange)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              child: Center(
                                child: Text(
                                  'Cambiamos de categoría: $_categoriaActual',
                                  style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    fontFamily: font,
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(height: 90),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: color,
            onPressed: () => _speak(_alertaVoz),
            tooltip: 'Repetir voz',
            child: const Icon(Icons.volume_up, color: Colors.white),
          ),
          // Botón fijo abajo
          bottomNavigationBar: Container(
            color: Colors.transparent,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: AnimatedOpacity(
                      opacity: puedeSiguiente ? 1 : 0.8,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: color.withAlpha(89),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color,
                            elevation: 0,
                            minimumSize: const Size(180, 54),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(horizontal: 36),
                          ),
                          onPressed: puedeSiguiente
                              ? () {
                                  detector.stop();
                                  _nextExercise(requiereSensor);
                                }
                              : null,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _currentIndex < widget.ejercicios.length - 1
                                    ? 'Siguiente'
                                    : 'Finalizar',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontFamily: font,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Icon(
                                _currentIndex < widget.ejercicios.length - 1
                                    ? Icons.arrow_forward_rounded
                                    : Icons.check_circle_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  void _showExitDialog() {
    final ejercicio = widget.ejercicios[_currentIndex];
    final color = ejercicio['color'];
    const font = 'HelveticaRounded';
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color, width: 2),
          ),
          child: StatefulBuilder(
            builder: (context, setStateDialog) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  backgroundColor: color,
                  radius: 32,
                  child: const Icon(Icons.exit_to_app,
                      color: Colors.white, size: 32),
                ),
                const SizedBox(height: 16),
                Text(
                  '¿Por qué deseas salir?',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: color,
                      fontFamily: font),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                ...motivos
                    .map((motivo) => RadioListTile<String>(
                          title: Text(motivo),
                          value: motivo,
                          groupValue: motivoSeleccionado,
                          activeColor: color,
                          onChanged: (v) {
                            setStateDialog(() {
                              motivoSeleccionado = v;
                            });
                            _confirmExit(motivoSeleccionado!);
                          },
                        ))
                    .toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmExit(String motivo) {
    final ejercicio = widget.ejercicios[_currentIndex];
    final color = ejercicio['color'];
    const font = 'HelveticaRounded';
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded, color: color, size: 40),
              const SizedBox(height: 12),
              Text(
                '¿Seguro que deseas salir?',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: color,
                    fontFamily: font),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text('Motivo: $motivo',
                  style: TextStyle(color: color, fontFamily: font)),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: color,
                      side: BorderSide(color: color),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      detector.stop();
                      sendMotivoDeCacelacion(motivo);
                      Navigator.of(context).pop(true);
                      Navigator.of(context).pop(true);
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('Enviar y salir',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final min = (seconds ~/ 60).toString().padLeft(2, '0');
    final sec = (seconds % 60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  // Al seleccionar un ejercicio individual desde la hoja de detalles
  // (esto se hace en DescubrePage, pero aquí agregamos un método público)
  Future<void> announceCurrentExercise() async {
    await _announcePlan(true);
  }
}

class _MovementDetectorWidget extends StatelessWidget {
  final bool isDetecting;
  final int seconds;
  final bool success;
  final bool timeout;
  final Color color;
  const _MovementDetectorWidget({
    required this.isDetecting,
    required this.seconds,
    required this.success,
    required this.timeout,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Animación y texto según estado
    if (!isDetecting) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('assets/animaciones/fallo.json',
              width: 48, height: 48, repeat: true),
          const SizedBox(width: 8),
          Text('No se detecta movimiento',
              style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset('assets/animaciones/detectado_exito.json',
            width: 48, height: 48, repeat: true),
        const SizedBox(width: 8),
        Text('Detectando  movimiento',
            style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _RepsCounterWidget extends StatelessWidget {
  final int repeticiones;
  final Color color;
  const _RepsCounterWidget({required this.repeticiones, required this.color});

  @override
  Widget build(BuildContext context) {
    final repeticiones_view = repeticiones >= 100 ? 100 : repeticiones;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.fitness_center, color: color, size: 28),
        const SizedBox(width: 8),
        Text(
          'Porcentaje: $repeticiones_view  %',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ],
    );
  }
}
