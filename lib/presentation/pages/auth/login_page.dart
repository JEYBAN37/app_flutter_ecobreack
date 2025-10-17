import 'package:flutter/material.dart';
import 'package:ecoapp/data/repositories/auth_repository.dart';
import 'package:ecoapp/utils/styles.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'widgets/login_header.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const _storage = FlutterSecureStorage();
  final AuthRepository _authRepository = AuthRepository();
  late TextEditingController emailController;
  late TextEditingController passwordController;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isPortrait = size.height > size.width;

    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('¿Salir del login?'),
            content: const Text(
                '¿Seguro que quieres salir? Se perderá tu avance en el inicio de sesión.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Salir'),
              ),
            ],
          ),
        );
        return shouldExit ?? false;
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Column(
              children: [
                LoginHeader(size: size, isPortrait: isPortrait),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [const SizedBox(height: 30), _buildLoginForm()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        TextField(
          controller: emailController,
          decoration: AppStyles.textFieldDecoration("Email"),
        ),
        const SizedBox(height: 20),
        _buildPasswordField(),
        const SizedBox(height: 10),
        _buildForgotPasswordButton(),
        const SizedBox(height: 20),
        _buildSignInButton(),
        const SizedBox(height: 16),
        _buildRegisterButton(),
      ],
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: passwordController,
      obscureText: !_isPasswordVisible,
      decoration: AppStyles.textFieldDecoration("Contraseña").copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey.shade600,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
      ),
    );
  }

  Widget _buildForgotPasswordButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return const LinearGradient(
            colors: [Color(0xFF0067AC), Color(0xFF0085DC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds);
        },
        child: TextButton(
          onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
          child: const Text(
            "¿Olvidaste tu Contraseña?",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'HelveticaRounded',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0067AC), Color(0xFF0085DC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
        ),
        child: ElevatedButton(
          onPressed: () async {
            final email = emailController.text.trim();
            final password = passwordController.text.trim();

            if (email.isEmpty || password.isEmpty) {
              _showSnackbar("Por favor, completa todos los campos.", true);
              return;
            }

            // Oculta el teclado antes de procesar el login
            FocusScope.of(context).unfocus();

            try {
              final success = await _authRepository.signIn(email, password);
              if (!mounted) return;

              if (success) {
                await Navigator.pushReplacementNamed(context, '/menu');
              } else {
                _showSnackbar("Usuario o contraseña incorrectos.", true);
              }
            } catch (e) {
              if (!mounted) return;
              _showSnackbar("Error al iniciar sesión: \\${e.toString()}", true);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: const Text("INGRESAR", style: AppStyles.buttonTextStyle),
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, '/register'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppStyles.accentColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: const Text("REGÍSTRATE", style: AppStyles.buttonTextStyle),
      ),
    );
  }

  void _showSnackbar(String message, bool isError) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Colors.red
            : const Color.fromRGBO(76, 175, 80, 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
