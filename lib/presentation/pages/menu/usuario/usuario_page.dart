import 'package:flutter/material.dart';
import 'package:ecoapp/presentation/pages/menu/usuario/usuario_graficos.dart';

class UsuarioPage extends StatelessWidget {
  const UsuarioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child:
                UsuarioGraficos(), // Muestra gráficos del usuario ocupando todo el espacio disponible
          ),
          _buildBottomDesign(context)
        ],
      ),
    );
  }

  Widget _buildBottomDesign(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.11,
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(top: BorderSide(color: Color(0xFF0085DC), width: 8.0)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildMenuButton(
              imagePath: 'assets/imagenes/menu/exit.png',
              label: "Salir",
              onPressed: () {
                Navigator.pushNamed(context, '/menu');
              },
            ),
            _buildMenuButton(
              imagePath: 'assets/imagenes/menu/ajustes.png',
              label: "Ajustes",
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
            padding: const EdgeInsets.all(2),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          child: Image.asset(imagePath, width: 40, height: 40),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF0085DC),
          ),
        ),
      ],
    );
  }
}
