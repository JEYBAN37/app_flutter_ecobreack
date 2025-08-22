import 'package:flutter/material.dart';
import 'package:ecoapp/presentation/pages/menu/widgetsM/custom_bottom_bar.dart';  // Corrige la ruta de importación

class MenuPrincipal extends StatelessWidget {
  const MenuPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (bool didPop, result) async {
        if (didPop) return; // Si ya se manejó el pop, no hacer nada

        final shouldExit = await _showExitDialog(context);
        if (context.mounted && shouldExit) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
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
            children: [
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    Positioned(
                      right: 0,
                      top: 0,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 300,
                        child: CustomPaint(
                          size: Size(MediaQuery.of(context).size.width, 200),
                          painter: HeaderPaintDiagonal(),
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 300,
                            height: 300,
                            child: Center(
                              child: Image.asset(
                                'assets/imagenes/LOGOECOBREACK.png',
                                width: 300,
                                height: 300,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Image.asset(
                            'assets/imagenes/logo_emas.png',
                            height: 70,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const CustomBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _showExitDialog(BuildContext context) async {
    final result =
        await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text("¿Estás seguro que quieres salir?"),
                content: Image.asset(
                  'assets/imagenes/icons/salir.png',
                  width: 80,
                  height: 80,
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      if (context.mounted) {
                        Navigator.pushNamed(context, '/inicio');
                        Navigator.of(context).pop(false);
                      }
                    },
                    child: const Text(
                      "Permanecer",
                      style: TextStyle(color: Color(0xFF0067AC)),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (context.mounted) {
                        Navigator.of(context).pop(true);
                      }
                    },
                    child: const Text(
                      "Salir",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
        ) ??
        false;
    return result;
  }
}

class HeaderPaintDiagonal extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFF0067AC)
          ..style = PaintingStyle.fill
          ..strokeWidth = 5;

    final borderPaint =
        Paint()
          ..color = const Color(0xFFC6DA23)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8.0;

    final path = Path();
    path.lineTo(0, size.height * 0.40);
    path.lineTo(size.width, size.height * 0.28);
    path.lineTo(size.width, 0);

    canvas.drawPath(path, paint);
    final borderPath =
        Path()
          ..moveTo(0, size.height * 0.40)
          ..lineTo(size.width, size.height * 0.28);
    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
