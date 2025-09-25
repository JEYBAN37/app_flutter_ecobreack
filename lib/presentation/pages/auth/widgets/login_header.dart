import 'package:flutter/material.dart';
import 'package:ecoapp/utils/styles.dart';

class LoginHeader extends StatelessWidget {
  final Size size;
  final bool isPortrait;

  const LoginHeader({super.key, required this.size, required this.isPortrait});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isPortrait ? size.height * 0.4 : size.height * 0.3,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0067AC),
            Color(0xFF0085DC),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        border: Border(
          bottom: BorderSide(color: AppStyles.accentColor, width: 6.0),
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/imagenes/LOGOECOBREACK.png',
                height: isPortrait ? size.height * 0.2 : size.height * 0.15,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 10),
              const Text('Inicia Sesión', style: AppStyles.headerTextStyle),
              const Text('ECOBREAK', style: AppStyles.headerTextStyle),
            ],
          ),
        ),
      ),
    );
  }
}
