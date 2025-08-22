import 'package:flutter/material.dart';
import 'package:ecoapp/presentation/pages/menu/ajustes/ajustes_dialogs.dart';

class AjustesPage extends StatelessWidget {
  const AjustesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFF0067AC),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFC6DA23),
                    width: 3.0,
                  ),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 8,
                    top: 0,
                    bottom: 0,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const Center(
                    child: Text(
                      'Ajustes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'HelveticaRounded',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSection(
                      'Configuración Personal',
                      [
                        _buildSettingButton(
                          context,
                          'Editar Perfil',
                          Icons.person,
                          '/perfil',
                        ),
                        _buildSettingButton(
                          context,
                          'Notificaciones',
                          Icons.notifications,
                          '/notificaciones',
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      'Historial',
                      [
                        _buildSettingButton(
                          context,
                          'Historial de Actividades',
                          Icons.sports_gymnastics,
                          '/historial-actividades',
                          isDouble: true,
                        ),
                        _buildSettingButton(
                          context,
                          'Historial de Notificaciones',
                          Icons.history,
                          '/historial-notificaciones',
                          isDouble: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      'Información',
                      [
                        _buildSettingButton(
                          context,
                          'Políticas de Privacidad',
                          Icons.privacy_tip,
                          '/privacidad',
                        ),
                        _buildSettingButton(
                          context,
                          'Términos y Condiciones',
                          Icons.description,
                          '/terminos',
                        ),
                        _buildSettingButton(
                          context,
                          'Acerca de',
                          Icons.info,
                          '/acerca',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0067AC),
                fontFamily: 'HelveticaRounded',
              ),
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingButton(
    BuildContext context,
    String title,
    IconData icon,
    String route, {
    bool isDouble = false,
  }) {
    void handleTap() {
      switch (route) {
        case '/privacidad':
          AjustesDialogs.showInfoDialog(
            context: context,
            title: 'Políticas de Privacidad',
            content: AjustesDialogs.buildPrivacyContent(),
          );
          break;
        case '/terminos':
          AjustesDialogs.showInfoDialog(
            context: context,
            title: 'Términos y Condiciones',
            content: AjustesDialogs.buildTermsContent(),
          );
          break;
        case '/acerca':
          AjustesDialogs.showInfoDialog(
            context: context,
            title: 'Acerca de ECOBREAK',
            content: AjustesDialogs.buildAboutContent(),
          );
          break;
        default:
          Navigator.pushNamed(context, route);
      }
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: handleTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDouble ? const Color(0xFFC6DA23) : const Color(0xFF0067AC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'HelveticaRounded',
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
