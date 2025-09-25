import 'dart:async';
import 'dart:math';

import 'package:ecoapp/core/services/calibration_storage.dart';
import 'package:ecoapp/presentation/pages/menu/ajustes/button_gradient.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalibrationScreen extends StatefulWidget {
  const CalibrationScreen({super.key});

  @override
  State<CalibrationScreen> createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends State<CalibrationScreen> {
  // saved thresholds (editable)
  double squatThreshold = 12.0;
  double jumpThreshold = 20.0;
  double stepThreshold = 6.0;

  // listening state
  StreamSubscription<AccelerometerEvent>? _sub;
  Timer? _uiTimer;
  Timer? _timeoutTimer;

  // runtime stats
  double _currentMax = 0.0;
  int _stepPeakCount = 0;
  int _secondsLeft = 0;
  bool _listening = false;
  String _status = 'Presiona "Calibrar" para detectar movimiento';
  bool _detected = false;
  String _detectedType = '';

  // protect against spurious repeated peaks
  int _lastPeakAt = 0;

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final m = await CalibrationStorage.loadThresholds();
    if (!mounted) return;
    setState(() {
      squatThreshold = m['squat']!;
      jumpThreshold = m['jump']!;
      stepThreshold = m['step']!;
    });
  }

  void _startListening(String type) {
    if (_listening) return;
    _stopAll(); // cleanup any leftovers

    _currentMax = 0.0;
    _stepPeakCount = 0;
    _detected = false;
    _detectedType = '';
    _secondsLeft = 8; // timeout seconds
    _listening = true;
    _status = '📡 Realiza ahora el movimiento de $type (esperando...)';

    // ui refresher (cada 300ms) para no llamar setState constante desde el stream
    _uiTimer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      if (!mounted) return;
      setState(() {}); // solo para actualizar barra / texto cada 300ms
    });

    // timeout
    _timeoutTimer = Timer(Duration(seconds: _secondsLeft), () {
      if (_detected) return;
      _stopAll();
      if (!mounted) return;
      setState(() {
        _status = '❌ No se detectó el movimiento. Intenta de nuevo.';
      });
    });

    // subscribe accelerometer
    _sub = accelerometerEvents.listen((event) {
      // usar Y para sentadilla (arriba/abajo), Z para salto (pico), y ambos para pasos
      final diffY = event.y.abs(); // absolute acceleration
      final diffZ = event.z.abs();
      final sampleValue = max(diffY, diffZ);

      // actualizar máximo observado (rápido)
      if (sampleValue > _currentMax) {
        _currentMax = sampleValue;
      }

      final nowMs = DateTime.now().millisecondsSinceEpoch;

      // detectar picos para "paso": contar picos separados en el tiempo
      final stepPeakDetectThreshold = max(1.5, stepThreshold); // mínimo detect
      if (sampleValue > stepPeakDetectThreshold) {
        if (nowMs - _lastPeakAt > 300) {
          _stepPeakCount++;
          _lastPeakAt = nowMs;
        }
      }

      // lógica de detección (tolerante):
      // - sentadilla: pico en Y suficientemente alto (ej. > 6)
      // - salto: pico en Z suficientemente alto (ej. > 10)
      // - paso: varios picos pequeños (>=3) en la ventana
      if (!_detected) {
        if (type == 'sentadilla') {
          if (_currentMax > 8.0) {
            _onDetected(type, _currentMax);
          }
        } else if (type == 'salto') {
          // para saltos, preferimos Z (pico vertical)
          if (diffZ > 12.0) {
            _onDetected(type, diffZ);
          } else if (_currentMax > 15.0) {
            _onDetected(type, _currentMax);
          }
        } else if (type == 'paso') {
          if (_stepPeakCount >= 3) {
            final peak = _currentMax;
            _onDetected(type, peak);
          }
        }
      }
    });
  }

  void _onDetected(String type, double peakValue) {
    // detected: sugerir umbral con margen
    final margin = type == 'paso' ? 1.0 : 2.0;
    final suggested = (peakValue + margin).clamp(1.0, 100.0);

    _detected = true;
    _detectedType = type;
    _stopAll();

    if (!mounted) return;
    setState(() {
      _status =
          '✅ Detectado $type. peak=${peakValue.toStringAsFixed(2)} → umbral sugerido ${suggested.toStringAsFixed(2)}';
      if (type == 'sentadilla') squatThreshold = suggested;
      if (type == 'salto') jumpThreshold = suggested;
      if (type == 'paso') stepThreshold = suggested;
    });
  }

  void _stopAll() {
    _sub?.cancel();
    _sub = null;
    _uiTimer?.cancel();
    _uiTimer = null;
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
    _listening = false;
  }

  @override
  void dispose() {
    _stopAll();
    super.dispose();
  }

  Future<void> _saveValues() async {
    await CalibrationStorage.saveThresholds(
      squat: squatThreshold,
      jump: jumpThreshold,
      step: stepThreshold,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isCalibrated", true); // 👈 marca como calibrado

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Valores guardados')),
    );
    // a la pantalla menu
    await Navigator.pushReplacementNamed(context, '/menu');
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentMax / 40.0).clamp(0.0, 1.0); // escala para barra
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: _buildHeader(),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // <-- Centra verticalmente
          children: [
            Text(_status),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: _listening ? progress : null,
              color: Colors.green,
              backgroundColor: Colors.green.shade100,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0085DC),
                  ),
                  onPressed:
                      _listening ? null : () => _startListening('sentadilla'),
                  child: const Text(
                    'Calibrar Sentadilla',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0085DC),
                  ),
                  onPressed: _listening ? null : () => _startListening('salto'),
                  child: const Text(
                    'Calibrar Salto',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _listening ? null : () => _startListening('paso'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0085DC),
                  ),
                  child: const Text(
                    'Calibrar Paso',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSlider('Sentadilla', squatThreshold, 5, 30,
                (v) => setState(() => squatThreshold = v)),
            _buildSlider('Salto', jumpThreshold, 8, 50,
                (v) => setState(() => jumpThreshold = v)),
            _buildSlider('Paso', stepThreshold, 1, 20,
                (v) => setState(() => stepThreshold = v)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GradientButton(
                  text: 'Guardar',
                  icon: Icons.save,
                  onPressed: _saveValues,
                ),
                const SizedBox(width: 12),
                GradientButton(
                  text: 'Cancelar',
                  icon: Icons.cancel,
                  onPressed: _stopAll,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Max detectado: ${_currentMax.toStringAsFixed(2)}'),
            Text('Picos pasos contados: $_stepPeakCount'),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(String label, double value, double min, double max,
      ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.toStringAsFixed(1)}'),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: ((max - min).round()),
          label: value.toStringAsFixed(1),
          onChanged: onChanged,
          activeColor: Color(0xFF0067AC),
          thumbColor: Color(0xFF0067AC),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0067AC), Color(0xFF0085DC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFC6DA23),
            width: 3.0,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Text(
                  'Ajuste Inicial',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'HelveticaRounded',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
      ),
    );
  }
}
