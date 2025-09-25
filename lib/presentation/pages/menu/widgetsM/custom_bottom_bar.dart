import 'package:flutter/material.dart';
import 'package:ecoapp/presentation/pages/menu/actividades/actividades_page.dart';

class CustomBottomBar extends StatelessWidget {
  const CustomBottomBar({super.key});

  Widget _buildGradientButton({
    required String imagePath,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: onPressed,
              child: Container(
                height: 55, // Slightly reduced
                width: 55, // Slightly reduced
                padding: const EdgeInsets.all(5),
                child: Image.asset(
                  imagePath,
                  width: 30,
                  height: 30,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Flexible(
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    colors: [Color(0xFF0067AC), Color(0xFF0085DC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds);
                },
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color.fromARGB(255, 255, 255, 255),
                    height: 1.1,
                    letterSpacing: 0.5, // Added for better readability
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      child: Container(
        height: 110, // Increased height
        margin: EdgeInsets.only(
          bottom:
              MediaQuery.of(context).padding.bottom, // Adds safe area padding
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          border: Border(top: BorderSide(color: Color(0xFF0085DC), width: 8.0)),
        ),
        child: Padding(
          padding:
              const EdgeInsets.fromLTRB(8, 12, 8, 8), // Increased top padding
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildGradientButton(
                imagePath: 'assets/imagenes/menu/grafico-de-progreso.png',
                label: "Progreso",
                onPressed: () => Navigator.pushNamed(
                    context, '/progreso'), // Changed from '/calendario'
              ),
              _buildGradientButton(
                imagePath: 'assets/imagenes/menu/actividades.png',
                label: "Planes",
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ActividadesPage()),
                ),
              ),
              _buildGradientButton(
                imagePath: 'assets/imagenes/menu/activities_realizadas.png',
                label: "Pendientes",
                onPressed: () => Navigator.pushNamed(context, '/descubre'),
              ),
              _buildGradientButton(
                imagePath: 'assets/imagenes/menu/usuario.png',
                label: "Yo",
                onPressed: () => Navigator.pushNamed(context, '/usuario'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
