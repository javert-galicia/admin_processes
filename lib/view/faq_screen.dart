import 'package:flutter/material.dart';
import 'package:admin_processes/l10n/localization.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.get('faq') ?? 'FAQ'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.help_outline,
                          color: Theme.of(context).colorScheme.primary,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)?.get('faqTitle') ?? 
                                'Preguntas Frecuentes',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)?.get('faqSubtitle') ?? 
                          'Encuentra respuestas a las preguntas más comunes sobre la aplicación.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Lista de preguntas frecuentes
            ..._buildFAQItems(context),

            // Sección de contacto
            const SizedBox(height: 32),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.contact_support,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          AppLocalizations.of(context)?.get('needMoreHelp') ?? 
                              '¿Necesitas más ayuda?',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Linkify(
                      onOpen: (link) async {
                        final Uri url = Uri.parse(link.url);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        }
                      },
                      text: AppLocalizations.of(context)?.get('contactInfo') ?? 
                          'Si no encuentras la respuesta que buscas, puedes contactarnos en: https://github.com/javert-galicia/admin_processes/issues',
                      style: Theme.of(context).textTheme.bodyMedium,
                      linkStyle: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        decoration: TextDecoration.underline,
                      ),
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

  List<Widget> _buildFAQItems(BuildContext context) {
    final faqItems = _getFAQItems(context);
    
    return faqItems.map((item) => 
      Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Card(
          elevation: 1,
          child: ExpansionTile(
            leading: Icon(
              item.icon,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            title: Text(
              item.question,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    item.answer,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).toList();
  }

  List<FAQItem> _getFAQItems(BuildContext context) {
    return [
      FAQItem(
        icon: Icons.info_outline,
        question: AppLocalizations.of(context)?.get('faqWhatIs') ?? 
            '¿Qué es Admin Processes?',
        answer: AppLocalizations.of(context)?.get('faqWhatIsAnswer') ?? 
            'Admin Processes es una aplicación para gestionar y seguir procesos administrativos paso a paso. Te permite crear, organizar y marcar el progreso de diferentes procedimientos administrativos.',
      ),
      FAQItem(
        icon: Icons.add_circle_outline,
        question: AppLocalizations.of(context)?.get('faqHowToAdd') ?? 
            '¿Cómo agregar un nuevo proceso?',
        answer: AppLocalizations.of(context)?.get('faqHowToAddAnswer') ?? 
            'Toca el botón "+" en la barra superior de la pantalla principal. Llena el título, descripción y agrega las etapas necesarias. Cada etapa debe tener un nombre y descripción.',
      ),
      FAQItem(
        icon: Icons.flag_outlined,
        question: AppLocalizations.of(context)?.get('faqCustomizeIcons') ?? 
            '¿Cómo personalizar las viñetas/iconos?',
        answer: AppLocalizations.of(context)?.get('faqCustomizeIconsAnswer') ?? 
            'Ve a Configuración (icono de engranaje) y busca la sección "Elige viñeta". Puedes elegir entre banderas, números, puntos, códigos o estrellas.',
      ),
      FAQItem(
        icon: Icons.language,
        question: AppLocalizations.of(context)?.get('faqChangeLanguage') ?? 
            '¿Cómo cambiar el idioma?',
        answer: AppLocalizations.of(context)?.get('faqChangeLanguageAnswer') ?? 
            'En Configuración, busca la sección "Idioma" y selecciona entre Inglés o Español. El cambio se aplica inmediatamente.',
      ),
      FAQItem(
        icon: Icons.dark_mode_outlined,
        question: AppLocalizations.of(context)?.get('faqDarkMode') ?? 
            '¿Cómo activar el modo oscuro?',
        answer: AppLocalizations.of(context)?.get('faqDarkModeAnswer') ?? 
            'En Configuración, en la sección "Tema", selecciona "Modo Oscuro" para cambiar la apariencia de la aplicación.',
      ),
      FAQItem(
        icon: Icons.check_box_outlined,
        question: AppLocalizations.of(context)?.get('faqSaveProgress') ?? 
            '¿Se guarda mi progreso automáticamente?',
        answer: AppLocalizations.of(context)?.get('faqSaveProgressAnswer') ?? 
            'Sí, cada vez que marcas o desmarcas una casilla de verificación, el progreso se guarda automáticamente en tu dispositivo.',
      ),
      FAQItem(
        icon: Icons.delete_outline,
        question: AppLocalizations.of(context)?.get('faqDeleteProcess') ?? 
            '¿Cómo eliminar un proceso?',
        answer: AppLocalizations.of(context)?.get('faqDeleteProcessAnswer') ?? 
            'Los procesos predeterminados no se pueden eliminar. Los procesos que tú hayas creado tendrán un botón de papelera en la esquina superior derecha.',
      ),
      FAQItem(
        icon: Icons.import_export,
        question: AppLocalizations.of(context)?.get('faqImportExport') ?? 
            '¿Puedo exportar/importar mis procesos?',
        answer: AppLocalizations.of(context)?.get('faqImportExportAnswer') ?? 
            'Sí, en Configuración encontrarás las opciones "Exportar Datos" e "Importar Datos" para respaldar y restaurar tus procesos personalizados.',
      ),
      FAQItem(
        icon: Icons.search_outlined,
        question: AppLocalizations.of(context)?.get('faqSearch') ?? 
            '¿Cómo buscar un proceso específico?',
        answer: AppLocalizations.of(context)?.get('faqSearchAnswer') ?? 
            'Usa el icono de lupa en la barra superior. Puedes buscar por título, descripción o contenido de las etapas.',
      ),
      FAQItem(
        icon: Icons.navigation_outlined,
        question: AppLocalizations.of(context)?.get('faqNavigation') ?? 
            '¿Cómo navegar entre procesos?',
        answer: AppLocalizations.of(context)?.get('faqNavigationAnswer') ?? 
            'Usa el dock inferior para cambiar páginas, el menú lateral para selección rápida, o desliza horizontalmente entre procesos.',
      ),
    ];
  }
}

class FAQItem {
  final IconData icon;
  final String question;
  final String answer;

  FAQItem({
    required this.icon,
    required this.question,
    required this.answer,
  });
}