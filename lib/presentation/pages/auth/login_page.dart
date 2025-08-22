import 'package:flutter/material.dart';
import 'package:ecoapp/data/repositories/auth_repository.dart';
import 'package:ecoapp/utils/styles.dart';
import 'widgets/login_header.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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

    return Scaffold(
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
      child: TextButton(
        onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
        child: const Text(
          "¿Olvidaste tu Contraseña?",
          style: TextStyle(
            color: Color(0xFF0067AC),
            fontSize: 14,
            fontFamily: 'HelveticaRounded',
          ),
        ),
      ),
    );
  }

  Widget _buildSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () async {
          final email = emailController.text.trim();
          final password = passwordController.text.trim();

          if (email.isEmpty || password.isEmpty) {
            _showSnackbar("Por favor, completa todos los campos.");
            return;
          }

          try {
            final success = await _authRepository.signIn(email, password);
            if (!mounted) return;

            if (success) {
              await Navigator.pushReplacementNamed(context, '/menu');
            } else {
              _showSnackbar("Usuario o contraseña incorrectos.");
            }
          } catch (e) {
            if (!mounted) return;
            _showSnackbar("Error al iniciar sesión: ${e.toString()}");
          }
        },
        style: AppStyles.primaryButtonStyle,
        child: const Text("INGRESAR", style: AppStyles.buttonTextStyle),
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
          backgroundColor: AppStyles.registerButtonColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: const Text("REGÍSTRATE", style: AppStyles.buttonTextStyle),
      ),
    );
  }

  void _showSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: message.contains("Error")
            ? Colors.red
            : const Color.fromRGBO(76, 175, 80, 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
