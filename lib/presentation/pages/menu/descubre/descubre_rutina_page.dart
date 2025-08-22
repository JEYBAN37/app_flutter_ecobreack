import 'package:flutter/material.dart';
import 'package:ecoapp/core/services/tts_service.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'dart:async';
import 'package:ecoapp/presentation/pages/menu/menu_principal.dart';
import 'package:ecoapp/core/pause_detector_service.dart';
import 'package:lottie/lottie.dart';

class DescubreRutinaPage extends StatefulWidget {
  final Map<String, dynamic> categoria;
  final List<Map<String, dynamic>> ejercicios;
  const DescubreRutinaPage(
      {super.key, required this.categoria, required this.ejercicios});

  @override
  State<DescubreRutinaPage> createState() => _DescubreRutinaPageState();
}

class _DescubreRutinaPageState extends State<DescubreRutinaPage> {
  int _currentIndex = 0;
  late TTSService _tts;
  bool _showMotivation = false;
  bool _isDetecting = false;
  bool _showKeyPoints = false;
  bool _timerStarted = false;
  bool _showCategoryChange = false;
  FlutterTts flutterTts = FlutterTts();
  YoutubePlayerController? _videoController;
  Timer? _timer;
  Timer? _autoStartTimer;
  int _secondsLeft = 0;
  int _totalSeconds = 0;
  int _autoStartSeconds = 6;
  String _alertaVoz = '';
  String _categoriaActual = '';
  String _categoriaAnterior = '';
  PauseDetectorService? _pauseDetectorService;
  int _movementSeconds = 0;
  bool _movementSuccess = false;
  bool _movementTimeout = false;
  int _repeticiones = 0;
  bool _showRepsFeedback = false;
  String _repsFeedbackMsg = '';
  bool _hasDetectedMovement =
      false; // Nueva variable para rastrear si ya se detectó movimiento

  static const List<String> categoriasMovimiento = [
    'Tren Superior',
    'Tren Inferior',
    'Movilidad Articular',
    'Estiramientos Generales',
  ];

  @override
  void initState() {
    super.initState();
    _hasDetectedMovement = false; // Resetear el estado de detección
    _tts = TTSService();
    _categoriaActual = widget.ejercicios[0]['categoria'];
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _announcePlan(true);
      _initVideoController();
      _initTimer();
      _initPauseDetector();
      _onStartPressed(); // Inicia automáticamente el tiempo y alertas en ejercicios individuales
    });
  }

  void _initVideoController() {
    final ejercicio = widget.ejercicios[_currentIndex];
    final url =
        (ejercicio['videoUrl'] as String?)?.replaceFirst('http://', 'https://');
    if (url != null && url.isNotEmpty) {
      final videoId = YoutubePlayer.convertUrlToId(url);
      if (videoId != null && videoId.isNotEmpty) {
        _videoController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
        );
      }
    }
  }

  void _initTimer() {
    final ejercicio = widget.ejercicios[_currentIndex];
    final dur = ejercicio['duracion'] as String?;
    if (dur != null && dur.contains(':')) {
      final parts = dur.split(':');
      final min = int.tryParse(parts[0]) ?? 0;
      final sec = int.tryParse(parts[1]) ?? 0;
      _secondsLeft = min * 60 + sec;
      _totalSeconds = _secondsLeft;
    } else {
      _secondsLeft = 60;
      _totalSeconds = 60;
    }
    _timerStarted = false;
    _showMotivation = false;
    _showKeyPoints = false;
    _showCategoryChange = false;
    _autoStartSeconds = 6;
  }

  void _initPauseDetector() {
    final ejercicio = widget.ejercicios[_currentIndex];
    if (categoriasMovimiento.contains(ejercicio['categoria'])) {
      _pauseDetectorService = PauseDetectorService(
        onPauseDetected: (success) {
          setState(() {
            _repeticiones++;
            _showRepsFeedback = true;
            _repsFeedbackMsg = success
                ? '¡Repetición detectada!'
                : 'No se detectó el movimiento';
            _movementSuccess = success;
            _movementTimeout = !success;
            _isDetecting = false;
          });
          Future.delayed(const Duration(milliseconds: 1200), () {
            if (mounted) setState(() => _showRepsFeedback = false);
          });
        },
        onProgressUpdate: (seconds) {
          setState(() {
            _movementSeconds = seconds;
          });
        },
        onTimeout: () {
          setState(() {
            _movementTimeout = true;
            _movementSuccess = false;
            _isDetecting = false;
          });
          _speak(
              'No se detectó el movimiento correctamente. Intenta de nuevo.');
        },
      );
    } else {
      _pauseDetectorService = null;
    }
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
          await Future.delayed(const Duration(seconds: 2));
          setState(() => _showMotivation = false);
        }
      } else if (_secondsLeft == 0) {
        timer.cancel();
        setState(() {
          _showKeyPoints = true;
        });
        await _speak('¡Has acabado este ejercicio!');
        await Future.delayed(const Duration(seconds: 2));
        setState(() {
          _showKeyPoints = false;
        });
        final requiereSensor = categoriasMovimiento
            .contains(widget.ejercicios[_currentIndex]['categoria']);
        if (requiereSensor) {
          if (!_pauseDetectorService!.movementSuccess) {
            setState(() {
              _movementTimeout = true;
              _isDetecting = false;
              _movementSuccess = false;
            });
            await _speak(
                'No se detectó el movimiento correctamente. Intenta de nuevo.');
            return; // No avanza al siguiente ejercicio
          } else {
            setState(() {
              _movementSuccess = true;
              _isDetecting = false;
              _movementTimeout = false;
            });
            await _speak('¡Movimiento detectado!');
            await Future.delayed(const Duration(seconds: 1));
          }
        }
        _nextExercise();
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
    _videoController?.dispose();
    _pauseDetectorService?.dispose();
    super.dispose();
  }

  Future<void> _announcePlan(bool isFirst) async {
    final ejercicio = widget.ejercicios[_currentIndex];
    final categoria = ejercicio['categoria'];
    final pasos = (ejercicio['pasos'] as List).join('. ');
    String plan = '';
    if (isFirst) {
      plan =
          'La actividad que realizarás hoy será de la categoría $categoria. Comenzamos con el ejercicio número 1: ${ejercicio['nombre']}. ${ejercicio['descripcion']}. Los pasos son: $pasos';
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

  void _onStartPressed() {
    if (!mounted) return;
    setState(() {
      _timerStarted = true;
      _isDetecting = false;
      _movementTimeout = false;
      _movementSuccess = false;
      _repeticiones = 0;
    });

    final requiereSensor = categoriasMovimiento
        .contains(widget.ejercicios[_currentIndex]['categoria']);
    if (requiereSensor &&
        _pauseDetectorService != null &&
        !_hasDetectedMovement) {
      setState(() {
        _isDetecting = true;
        _movementSuccess = false;
        _movementTimeout = false;
      });
      _pauseDetectorService!.startDetecting();
    }
    _startTimer();
  }

  void _nextExercise() async {
    if (!mounted) return; // Verificación temprana de mounted

    setState(() {
      _showMotivation = false;
      _showKeyPoints = false;
      _timerStarted = false;
    });

    final ejercicio = widget.ejercicios[_currentIndex];
    _categoriaAnterior = _categoriaActual;
    _categoriaActual = (_currentIndex + 1 < widget.ejercicios.length)
        ? widget.ejercicios[_currentIndex + 1]['categoria']
        : _categoriaActual;

    _pauseDetectorService?.stopDetecting();

    if (categoriasMovimiento.contains(ejercicio['categoria'])) {
      if (mounted) {
        await _speak(
            'Ejercicio finalizado. Total de repeticiones: $_repeticiones. ¡Muy bien!');
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    // Modificación principal aquí
    if (_currentIndex < widget.ejercicios.length - 1) {
      if (!mounted) return;
      setState(() {
        _currentIndex++;
        _initVideoController();
        _initTimer();
        _initPauseDetector();
      });

      // Solo realizar la calibración si no se ha detectado movimiento anteriormente
      final nextRequiereSensor = categoriasMovimiento
          .contains(widget.ejercicios[_currentIndex]['categoria']);
      if (nextRequiereSensor && !_hasDetectedMovement) {
        if (!mounted) return;
        setState(() {
          _isDetecting = true;
        });
        await _speak(
            'Ejercicio de movimiento. Por favor, realiza el movimiento indicado.');
        await Future.delayed(const Duration(seconds: 3));
        if (!mounted) return;
        setState(() {
          _isDetecting = false;
          _hasDetectedMovement =
              true; // Marcar que ya se ha detectado movimiento
        });
      }

      if (!mounted) return;
      await _announcePlan(_categoriaActual != _categoriaAnterior);
      _startAutoStartTimer();
    } else {
      if (!mounted) return;
      await _speak(
          'Con esta categoría acabamos. ¡Rutina completada! Felicitaciones.');
      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ejercicio = widget.ejercicios[_currentIndex];
    final color = ejercicio['color'] as Color;
    const font = 'HelveticaRounded';
    final keyPoints =
        (ejercicio['pasos'] as List).map((e) => e.toString()).toList();
    final double percentElapsed =
        _totalSeconds > 0 ? (_totalSeconds - _secondsLeft) / _totalSeconds : 0;
    final bool puedeSiguiente =
        percentElapsed >= 0.6 && _timerStarted && !_isDetecting;
    final requiereSensor =
        categoriasMovimiento.contains(ejercicio['categoria']);
    return Scaffold(
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
                      if (_videoController != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: YoutubePlayer(
                            controller: _videoController!,
                            showVideoProgressIndicator: true,
                            progressIndicatorColor: color,
                          ),
                        ),
                      if (_videoController != null) const SizedBox(height: 12),
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
                              value: _timerStarted && _totalSeconds > 0
                                  ? (_totalSeconds - _secondsLeft) /
                                      _totalSeconds
                                  : 0,
                              backgroundColor: color.withAlpha(40),
                              valueColor: AlwaysStoppedAnimation<Color>(color),
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
                                          opacity: _showRepsFeedback ? 1 : 0,
                                          duration:
                                              const Duration(milliseconds: 300),
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
                            if (!_timerStarted)
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
                                      onPressed: _onStartPressed,
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
                                      style: TextStyle(
                                          color: color,
                                          fontFamily: font,
                                          fontSize: 14),
                                    ),
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2.0),
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
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
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
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
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
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
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
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
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
                  opacity: puedeSiguiente ? 1 : 0.6,
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
                      onPressed: puedeSiguiente ? _nextExercise : null,
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
    );
  }

  void _showExitDialog() {
    String? motivoSeleccionado;
    final ejercicio = widget.ejercicios[_currentIndex];
    final color = ejercicio['color'] as Color;
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
              RadioListTile<String>(
                title: const Text('No me siento bien'),
                value: 'No me siento bien',
                groupValue: motivoSeleccionado,
                activeColor: color,
                onChanged: (v) {
                  motivoSeleccionado = v;
                  setState(() {});
                  Navigator.of(context).pop();
                  _confirmExit(motivoSeleccionado!);
                },
              ),
              RadioListTile<String>(
                title: const Text('No tengo tiempo'),
                value: 'No tengo tiempo',
                groupValue: motivoSeleccionado,
                activeColor: color,
                onChanged: (v) {
                  motivoSeleccionado = v;
                  setState(() {});
                  Navigator.of(context).pop();
                  _confirmExit(motivoSeleccionado!);
                },
              ),
              RadioListTile<String>(
                title: const Text('Otra razón'),
                value: 'Otra razón',
                groupValue: motivoSeleccionado,
                activeColor: color,
                onChanged: (v) {
                  motivoSeleccionado = v;
                  setState(() {});
                  Navigator.of(context).pop();
                  _confirmExit(motivoSeleccionado!);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmExit(String motivo) {
    final ejercicio = widget.ejercicios[_currentIndex];
    final color = ejercicio['color'] as Color;
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
                      Navigator.of(context).pop();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (_) => const MenuPrincipal()),
                        (route) => false,
                      );
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
    if (success) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 24),
          SizedBox(width: 8),
          Text('¡Movimiento detectado!',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
        ],
      );
    }
    if (timeout) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('assets/animaciones/fallo.json',
              width: 48, height: 48, repeat: false),
          const SizedBox(width: 8),
          const Text('No se detectó el movimiento',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
        ],
      );
    }
    if (isDetecting) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('assets/animaciones/fallo.json',
              width: 48, height: 48, repeat: true),
          const SizedBox(width: 8),
          Text('Detector de movimiento',
              style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset('assets/animaciones/fallo.json',
            width: 48, height: 48, repeat: true),
        const SizedBox(width: 8),
        Text('Listo para detectar movimiento', style: TextStyle(color: color)),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.fitness_center, color: color, size: 28),
        const SizedBox(width: 8),
        Text(
          'Repeticiones: $repeticiones',
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
