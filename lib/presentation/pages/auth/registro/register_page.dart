import 'package:flutter/material.dart';
import 'package:ecoapp/data/repositories/auth_repository.dart';
import '../wave_clipper.dart'; // Asegurarnos que está en la misma carpeta

class AvatarData {
  Color color;
  String gender;
  AvatarData({this.color = const Color(0xFF0067AC), this.gender = 'otro'});
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthRepository _authRepository = AuthRepository();
  late TextEditingController nameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;

  final AvatarData avatarData = AvatarData();
  final List<Color> colorOptions = [
    const Color(0xFF0067AC),
    const Color(0xFFC6DA23),
    Colors.red,
    Colors.purple,
    Colors.orange,
    Colors.teal,
  ];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    lastNameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegistration() async {
    if (!mounted) return;

    // Validar campos vacíos
    if (nameController.text.trim().isEmpty ||
        lastNameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      _showSnackbar(
        context,
        "Por favor, completa todos los campos.",
        isError: true,
      );
      return;
    }

    // Validar formato de correo
    if (!emailController.text.trim().contains('@')) {
      _showSnackbar(
        context,
        "Por favor, ingresa un correo válido.",
        isError: true,
      );
      return;
    }

    try {
      final message = await _authRepository.registerUserWithEmailAndPassword(
        emailController.text.trim(),
        passwordController.text.trim(),
        name: nameController.text.trim(),
        lastName: lastNameController.text.trim(),
        gender: avatarData.gender,
        avatarColor:
            avatarData.color.toARGB32(), // Reemplazado el uso de 'value'
      );

      if (!mounted) return;

      if (message.contains('exitoso')) {
        _showSnackbar(context, "¡Registro exitoso!");
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        _showSnackbar(context, message, isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackbar(
        context,
        "Ocurrió un error al registrar. Inténtalo de nuevo.",
        isError: true,
      );
    }
  }

  void _showSnackbar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? Colors.red : const Color.fromRGBO(76, 175, 80, 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isPortrait = size.height > size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF0067AC),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Encabezado con onda azul
            Stack(
              children: [
                ClipPath(
                  clipper: WaveClipper(), // Aquí está el error
                  child: Container(
                    height: isPortrait ? size.height * 0.2 : size.height * 0.15,
                    decoration: const BoxDecoration(color: Color(0xFFFFFFFF)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: size.height * 0.005,
                          color: const Color(0xFFC6DA23),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Texto principal
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: size.height * 0.02,
                horizontal: size.width * 0.05,
              ),
              child: Column(
                children: [
                  const Text(
                    "¡REGÍSTRATE!",
                    style: TextStyle(
                      fontFamily: 'HelveticaRounded',
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: size.height * 0.01),
                  Text(
                    "Registrarse es fácil y rápido.",
                    style: TextStyle(
                      fontFamily: 'HelveticaRounded',
                      color: const Color(0xFFC6DA23),
                      fontSize: size.width * 0.04,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Formulario
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.03),
                  _buildTextField(nameController, Icons.person, "NOMBRE"),
                  SizedBox(height: size.height * 0.015),
                  _buildTextField(
                    lastNameController,
                    Icons.person_outline,
                    "APELLIDO",
                  ),
                  SizedBox(height: size.height * 0.015),
                  _buildEmailField(emailController),
                  SizedBox(height: size.height * 0.015),
                  _buildTextField(
                    passwordController,
                    Icons.lock_outline,
                    "CONTRASEÑA",
                    isPassword: true,
                  ),
                  SizedBox(height: size.height * 0.03),

                  // Avatar Selector
                  _buildAvatarSelector(size),
                  SizedBox(height: size.height * 0.04),

                  // Botones
                  _buildButtons(size),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    IconData icon,
    String hint, {
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.black87, fontSize: 16),
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }

  Widget _buildEmailField(TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.black87, fontSize: 16),
      decoration: InputDecoration(
        hintText: "CORREO (opcional)",
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
        prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }

  Widget _buildAvatarSelector(Size size) {
    return Container(
      padding: EdgeInsets.all(size.height * 0.02),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((0.1 * 255).toInt()),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          // Avatar preview
          Container(
            width: size.height * 0.1,
            height: size.height * 0.1,
            decoration: BoxDecoration(
              color: avatarData.color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Icon(
              avatarData.gender == 'masculino'
                  ? Icons.face
                  : avatarData.gender == 'femenino'
                      ? Icons.face_3
                      : Icons.face_4,
              color: Colors.white,
              size: size.height * 0.06,
            ),
          ),
          SizedBox(height: size.height * 0.02),

          // Color selector
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: colorOptions.map((color) {
              return GestureDetector(
                onTap: () => setState(() => avatarData.color = color),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: avatarData.color == color
                          ? Colors.white
                          : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((0.1 * 255).toInt()),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Gender selector
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: _buildGenderOption('masculino', Icons.face),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: _buildGenderOption('femenino', Icons.face_3),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 200,
                child: _buildGenderOption('otro', Icons.face_4),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenderOption(String gender, IconData icon) {
    final isSelected = avatarData.gender == gender;
    return GestureDetector(
      onTap: () => setState(() => avatarData.gender = gender),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFC6DA23)
              : Colors.white.withAlpha((0.1 * 255).toInt()),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.1 * 255).toInt()),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.black : Colors.white,
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              gender[0].toUpperCase() + gender.substring(1),
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontFamily: 'HelveticaRounded',
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.help_outline, color: Color(0xFF0067AC)),
              SizedBox(width: 8),
              Text(
                "¿Cómo registrarse?",
                style: TextStyle(
                  fontFamily: 'HelveticaRounded',
                  color: Color(0xFF0067AC),
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: const Text(
            "Para registrarte en EcoBreak, sigue estos pasos:\n\n"
            "1. Selecciona tu avatar y personalízalo\n"
            "2. Completa los campos con tu nombre y apellido\n"
            "3. Agrega tu correo electrónico (opcional)\n"
            "4. Elige una contraseña segura\n"
            "5. Presiona el botón 'REGISTRARME'\n\n"
            "Si ya tienes una cuenta, puedes iniciar sesión con el botón 'YA TENGO CUENTA'.",
            style: TextStyle(fontFamily: 'HelveticaRounded', fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                "CERRAR",
                style: TextStyle(
                  fontFamily: 'HelveticaRounded',
                  color: Color(0xFF0067AC),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildButtons(Size size) {
    return Column(
      children: [
        // Botón de registro
        SizedBox(
          width: double.infinity,
          height: size.height * 0.06,
          child: ElevatedButton(
            onPressed: _handleRegistration,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(76, 175, 80, 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              "REGISTRARME",
              style: TextStyle(
                fontFamily: 'HelveticaRounded',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(height: size.height * 0.02),

        // Botón de ayuda
        TextButton(
          onPressed: () => _showHelpDialog(context),
          child: const Text(
            "¿Cómo registrarse?",
            style: TextStyle(
              fontFamily: 'HelveticaRounded',
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(height: size.height * 0.03),

        // Botón de inicio de sesión
        SizedBox(
          width: double.infinity,
          height: size.height * 0.06,
          child: ElevatedButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              "YA TENGO CUENTA",
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
      ],
    );
  }
}
