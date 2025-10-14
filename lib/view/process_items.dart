import 'package:admin_processes/model/process_stage.dart';
import 'package:admin_processes/model/process_study.dart';
import 'package:flutter/material.dart';
import 'package:admin_processes/l10n/localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:admin_processes/db/process_data_service.dart';

class ProcessItems extends StatefulWidget {
  const ProcessItems(
      {required this.processStudy,
      required this.indexPage,
      this.onProcessDeleted,
      super.key});

  final ProcessStudy processStudy;
  final int indexPage;
  final VoidCallback? onProcessDeleted;

  @override
  State<ProcessItems> createState() => _ProcessItemsState();
}

class _ProcessItemsState extends State<ProcessItems>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Keep page alive to prevent rebuilds

  List<Color> colors = [
    const Color(0xFFE53E3E), // Rojo primario vibrante
    const Color(0xFF3182CE), // Azul primario
    const Color(0xFF38A169), // Verde primario
    const Color(0xFFD69E2E), // Amarillo/Naranja primario
    const Color(0xFF9F7AEA), // Púrpura primario
  ];
  Color backColorStage(int j) {
    if (j < colors.length) {
      return colors[j];
    } else {
      return backColorStage(j - colors.length);
    }
  }

  List<bool> checkboxValue = [];
  bool isLoading = true;

  Future<void> loadCheckboxState(int processIndex, int stepsCount) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'checkbox_${processIndex}_$stepsCount';
    final saved = prefs.getStringList(key);
    if (saved != null && saved.length == stepsCount) {
      checkboxValue = saved.map((e) => e == 'true').toList();
    } else {
      checkboxValue = List<bool>.filled(stepsCount, false);
    }
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> saveCheckboxState(int processIndex, int stepsCount) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'checkbox_${processIndex}_$stepsCount';
    await prefs.setStringList(
        key, checkboxValue.map((e) => e.toString()).toList());
  }

  /// Get background color based on page index
  Color _getBackgroundColor(int index, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return index % 2 != 0
        ? (isDark ? Theme.of(context).colorScheme.surface.withOpacity(0.7) : const Color(0xFFE3F2FD)) // Azul muy claro profesional o superficie oscura
        : Theme.of(context).colorScheme.surface; // Superficie del tema
  }

  /// Show confirmation dialog before deleting process
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            AppLocalizations.of(context)?.get('confirm_delete') ??
                'Confirm Delete',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            AppLocalizations.of(context)?.get('delete_process_confirmation') ??
                'Are you sure you want to delete this process? This action cannot be undone.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar diálogo de confirmación
              },
              child: Text(
                AppLocalizations.of(context)?.get('cancel') ?? 'Cancel',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar diálogo de confirmación
                _deleteProcess(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
              ),
              child: Text(
                AppLocalizations.of(context)?.get('delete') ?? 'Delete',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Delete the process and close dialog
  Future<void> _deleteProcess(BuildContext context) async {
    try {
      await ProcessDataService.deleteProcessStudy(widget.processStudy.id!);

      if (mounted) {
        Navigator.of(context).pop(); // Cerrar diálogo principal

        // Mostrar mensaje de confirmación
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)
                      ?.get('process_deleted_successfully') ??
                  'Process deleted successfully',
            ),
            backgroundColor: Colors.green.shade600,
          ),
        );

        // Notificar al widget padre para recargar la lista
        widget.onProcessDeleted?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)?.get('error_deleting_process') ??
                  'Error deleting process',
            ),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    final k = widget.indexPage;
    final backgroundColor = _getBackgroundColor(k, context);

    final processStudy = widget.processStudy;
    String title = processStudy.title;
    String descriptionStudy = processStudy.description;
    List<ProcessStage> currentListSteps = processStudy.processStage.toList();

    if (checkboxValue.isEmpty && isLoading) {
      loadCheckboxState(k, currentListSteps.length);
    }

    if (isLoading || checkboxValue.length != currentListSteps.length) {
      return const Center(child: CircularProgressIndicator());
    }

    return _buildProcessContent(
        context, title, descriptionStudy, currentListSteps, k, backgroundColor);
  }

  Widget _buildProcessContent(
      BuildContext context,
      String title,
      String descriptionStudy,
      List<ProcessStage> currentListSteps,
      int k,
      Color backgroundColor) {
    return Stack(
      children: [
        Container(
          color: backgroundColor,
        ),
        Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // Calcular el tamaño máximo disponible
                          final maxHeight = MediaQuery.of(context).size.height *
                              0.8; // 80% de la altura de pantalla
                          final maxWidth = MediaQuery.of(context).size.width *
                              0.9; // 90% del ancho de pantalla

                          return ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: maxHeight,
                              maxWidth: maxWidth,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Título (siempre visible)
                                  Text(
                                    title,
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurface,
                                      fontSize: 24,
                                      fontFamily: 'Nunito',
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),

                                  // Descripción con scroll
                                  Flexible(
                                    child: SingleChildScrollView(
                                      child: Text(
                                        descriptionStudy,
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.onSurface,
                                          fontSize: 16,
                                          fontFamily: 'Lato',
                                          height: 1.4, // Espaciado entre líneas
                                        ),
                                        textAlign: TextAlign.justify,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // Botones (cerrar siempre, eliminar condicionalmente)
                                  Row(
                                    children: [
                                      // Botón cerrar
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Theme.of(context).colorScheme.secondary,
                                            foregroundColor: Theme.of(context).colorScheme.onSecondary,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12),
                                          ),
                                          child: Text(
                                            AppLocalizations.of(context)
                                                    ?.get('close') ??
                                                'Close',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Botón eliminar (solo si es eliminable)
                                      if (widget.processStudy.isDeletable) ...[
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              _showDeleteConfirmation(context);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.red.shade600,
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12),
                                            ),
                                            child: Text(
                                              AppLocalizations.of(context)
                                                      ?.get('delete') ??
                                                  'Delete',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white
                          : Theme.of(context).colorScheme.primary,
                      fontSize: 30,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: currentListSteps.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        color: checkboxValue[index]
                            ? Theme.of(context).colorScheme.surface.withOpacity(0.8)
                            : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border(
                          left: BorderSide(
                            color: backColorStage(index),
                            width: 6.0,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).brightness == Brightness.dark 
                                ? Colors.black.withOpacity(0.3)
                                : Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: CheckboxListTile(
                        value: checkboxValue[index],
                        title: ExpansionTile(
                          shape: const Border(),
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Row(
                            children: [
                              Icon(
                                Icons.flag_rounded,
                                color: backColorStage(index),
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  currentListSteps[index].stage,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontSize: 20,
                                    fontFamily: 'Lato',
                                    fontWeight: FontWeight.w600,
                                    decoration: checkboxValue[index] 
                                        ? TextDecoration.lineThrough 
                                        : TextDecoration.none,
                                    decorationColor: Theme.of(context).colorScheme.onSurface,
                                    decorationThickness: 2.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          children: [
                            Card.outlined(
                              color: Theme.of(context).colorScheme.surface,
                              child: Container(
                                width: double.infinity,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Text(
                                    currentListSteps[index].description,
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurface,
                                      fontFamily: 'Lato',
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                          onChanged: (value) {
                            setState(() {
                              checkboxValue[index] = value!;
                            });
                            saveCheckboxState(k, currentListSteps.length);
                          },
                        ),
                    );
                  },
                ),
                const SizedBox(
                  height: 40,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
