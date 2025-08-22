import 'package:flutter/material.dart';
import 'widgets/progreso_header.dart';
import 'widgets/progreso_stats.dart';
import 'widgets/progreso_chart.dart';

class ProgresoPage extends StatefulWidget {
  const ProgresoPage({super.key});

  @override
  State<ProgresoPage> createState() => _ProgresoPageState();
}

class _ProgresoPageState extends State<ProgresoPage> {
  bool _isWeekView = true; // true = semana, false = mes

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _buildHeader(),
          _buildViewSelector(),
          Expanded(
            child: _buildMainContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
                  'Tu Progreso',
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

  Widget _buildViewSelector() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
            BoxShadow(
              color: const Color(0xFF0067AC).withAlpha(15),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 2,
            ),
        ],
      ),
      child: Stack(
        children: [
          // Indicador animado
          AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            alignment: _isWeekView ? Alignment.centerLeft : Alignment.centerRight,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.43,
              height: 45,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0067AC), Color(0xFF0085DC)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x800067AC),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          // Botones
          Row(
            children: [
              _buildSwitchTab(
                text: 'SEMANA',
                icon: Icons.calendar_view_week,
                isSelected: _isWeekView,
                onTap: () => setState(() => _isWeekView = true),
              ),
              _buildSwitchTab(
                text: 'MES',
                icon: Icons.calendar_month,
                isSelected: !_isWeekView,
                onTap: () => setState(() => _isWeekView = false),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTab({
    required String text,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : const Color(0xFF0067AC),
              ),
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF0067AC),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ProgresoHeader(),
          const SizedBox(height: 24),
          const ProgresoStats(),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gráfica de progreso',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0067AC),
                    fontFamily: 'HelveticaRounded',
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(  // Removed const since ProgresoChart isn't const
                  height: 200,
                  child: ProgresoChart(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
