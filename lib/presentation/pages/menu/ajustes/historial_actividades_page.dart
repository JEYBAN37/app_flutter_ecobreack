import 'package:flutter/material.dart';

class HistorialActividadesPage extends StatelessWidget {
  const HistorialActividadesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _buildEmptyState(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
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
          Positioned(
            left: 8,
            top: 0,
            bottom: 0,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Center(
            child: Text(
              'Historial de Actividades',
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                // Reemplazado withOpacity(0.1) por withAlpha(26)
                color: const Color(0xFFC6DA23).withAlpha(26),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.sports_gymnastics,
                size: 80,
                color: Color(0xFF0067AC),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No hay actividades registradas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0067AC),
                fontFamily: 'HelveticaRounded',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Aquí podrás ver el historial de todas las actividades que realices.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontFamily: 'HelveticaRounded',
              ),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: null, // Disabled for now
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                side: const BorderSide(
                  color: Color(0xFFC6DA23),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              icon: const Icon(
                Icons.history,
                color: Color(0xFF0067AC),
              ),
              label: const Text(
                'Próximamente',
                style: TextStyle(
                  color: Color(0xFF0067AC),
                  fontFamily: 'HelveticaRounded',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
