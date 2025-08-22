import 'package:flutter/material.dart';

class AjustesDialogs {
  static Future<void> showInfoDialog({
    required BuildContext context,
    required String title,
    required Widget content,
  }) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF0067AC),
              fontFamily: 'HelveticaRounded',
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(child: content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF4CAF50),
              ),
              child: const Text(
                'ENTENDIDO',
                style: TextStyle(
                  fontFamily: 'HelveticaRounded',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        );
      },
    );
  }

  static Widget buildPrivacyContent() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'En ECOBREAK, valoramos tu privacidad. Esta aplicación no recopila información personal sin tu consentimiento.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        SizedBox(height: 16),
        Text(
          'Los datos que se ingresan (como encuestas o registros de actividad física) son utilizados únicamente con fines de seguimiento de salud musculoesquelética dentro del contexto laboral.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        SizedBox(height: 16),
        Text(
          'Toda la información recolectada es confidencial, no se comparte con terceros y es manejada bajo criterios éticos y técnicos, alineados con la normativa vigente de protección de datos.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
      ],
    );
  }

  static Widget buildTermsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTermItem('Uso voluntario',
            'El uso de la app es completamente voluntario y tiene fines informativos y preventivos sobre la salud musculoesquelética.'),
        _buildTermItem('Responsabilidad',
            'Los desarrolladores no se hacen responsables por lesiones o afectaciones causadas por una ejecución inadecuada de los ejercicios sugeridos en la app.'),
        _buildTermItem('Propiedad intelectual',
            'Todos los contenidos, diseños y funcionalidades de la app son propiedad del equipo desarrollador y están protegidos por derechos de autor.'),
        _buildTermItem('Actualizaciones',
            'Nos reservamos el derecho de actualizar o modificar la app y sus contenidos sin previo aviso, con el objetivo de mejorar el servicio ofrecido.'),
        _buildTermItem('Acceso gratuito',
            'ECOBREAK está disponible sin costo alguno para los empleados de EMAS BY VEOLIA y otras empresas interesadas en su uso.'),
      ],
    );
  }

  static Widget buildAboutContent() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'ECOBREAK es una aplicación móvil desarrollada por estudiantes de Ingeniería de Sistemas de la Universidad Mariana, con el objetivo de mejorar la salud musculoesquelética de los empleados de EMAS BY VEOLIA.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        SizedBox(height: 16),
        Text(
          'Esta solución tecnológica surge de una investigación aplicada, alineada con las políticas nacionales de salud ocupacional, como la Ley 1751 de 2015 y el Decreto 1477 de 2014, enfocadas en la innovación, ciencia y tecnología en salud.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        SizedBox(height: 16),
        Text(
          'La app ha sido desarrollada bajo metodología ágil Scrum, permitiendo un enfoque iterativo y centrado en el usuario.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
      ],
    );
  }

  static Widget _buildTermItem(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0067AC),
              fontFamily: 'HelveticaRounded',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }
}
