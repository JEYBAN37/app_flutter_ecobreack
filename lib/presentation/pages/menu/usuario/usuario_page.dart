import 'package:flutter/material.dart';
import 'package:ecoapp/presentation/pages/menu/usuario/usuario_info.dart';
import 'package:ecoapp/presentation/pages/menu/usuario/usuario_graficos.dart';

class UsuarioPage extends StatelessWidget {
  const UsuarioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.topLeft,
            colors: [
              Color.fromARGB(255, 255, 255, 255),
              Color.fromARGB(255, 255, 255, 255),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const UsuarioInfo(), // Muestra la información del usuario
            const Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end, // Align to the bottom
                children: [
                  UsuarioGraficos(), // Muestra gráficos del usuario
                  SizedBox(height: 20), // Add some space between stats and buttons
                ],
              ),
            ),
            _buildBottomDesign(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomDesign(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.20,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        border: Border(top: BorderSide(color: Color(0xFF0067AC), width: 8.0)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildMenuButton(
              imagePath: 'assets/imagenes/menu/exit.png',
              label: "SALIR",
              onPressed: () {
                Navigator.pushNamed(context, '/menu');
              },
            ),
            _buildMenuButton(
              imagePath: 'assets/imagenes/menu/ajustes.png',
              label: "AJUSTES",
              onPressed: () {
                Navigator.pushNamed(context, '/ajustes');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required String imagePath,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          child: Image.asset(imagePath, width: 50, height: 50),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
