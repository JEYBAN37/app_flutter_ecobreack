import 'package:flutter/material.dart';
import 'package:ecoapp/data/repositories/auth_repository.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final AuthRepository _authRepository = AuthRepository();
  late TextEditingController emailController;

  @override
  void initState() {
    emailController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    String email = emailController.text.trim();
    if (email.isEmpty) {
      _showSnackbar('Por favor ingresa tu correo electrónico.');
      return;
    }

    final message = await _authRepository.sendPasswordResetEmail(email);
    _showSnackbar(message);
  }

  void _showSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'HelveticaRounded'),
        ),
        backgroundColor: const Color(0xFF0067AC),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isPortrait = size.height > size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Contenedor azul con curva y borde inferior
            Container(
              height: isPortrait ? size.height * 0.35 : size.height * 0.45,
              decoration: const BoxDecoration(
                color: Color(0xFF0067AC),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
                border: Border(
                  bottom: BorderSide(color: Color(0xFFC6DA23), width: 6.0),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/imagenes/LOGOECOBREACK.png',
                      height: size.height * (isPortrait ? 0.18 : 0.2),
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '¿Olvidaste Tu Contraseña?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'HelveticaRounded',
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Formulario de recuperación
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.06,
                vertical: size.height * 0.04,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Ingresa tu correo electrónico para recuperar tu contraseña',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'HelveticaRounded',
                      color: Color(0xFF0067AC),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),
                  TextField(
                    controller: emailController,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontFamily: 'HelveticaRounded',
                    ),
                    decoration: InputDecoration(
                      hintText: "Email",
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 16,
                        fontFamily: 'HelveticaRounded',
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF0067AC),
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.05),

                  // Botón de Recuperar
                  SizedBox(
                    width: double.infinity,
                    height: size.height * 0.07,
                    child: ElevatedButton(
                      onPressed: _resetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0067AC),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "RECUPERAR CONTRASEÑA",
                        style: TextStyle(
                          fontFamily: 'HelveticaRounded',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),

                  // Botón para volver al login
                  TextButton(
                    onPressed:
                        () => Navigator.pushReplacementNamed(context, '/login'),
                    child: const Text(
                      "Volver al inicio de sesión",
                      style: TextStyle(
                        fontFamily: 'HelveticaRounded',
                        color: Color(0xFF0067AC),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
