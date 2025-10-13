import 'package:flutter/material.dart';
import 'package:admin_processes/db/process_data_service.dart';
import 'package:admin_processes/model/process_study.dart';
import 'package:admin_processes/model/process_stage.dart';
import 'package:admin_processes/l10n/localization.dart';

class AddProcessScreen extends StatefulWidget {
  final String language;

  const AddProcessScreen({super.key, required this.language});

  @override
  State<AddProcessScreen> createState() => _AddProcessScreenState();
}

class _AddProcessScreenState extends State<AddProcessScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<StageFormData> _stages = [StageFormData()];
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (final stage in _stages) {
      stage.dispose();
    }
    super.dispose();
  }

  void _addStage() {
    setState(() {
      _stages.add(StageFormData());
    });
  }

  void _removeStage(int index) {
    if (_stages.length > 1) {
      setState(() {
        _stages[index].dispose();
        _stages.removeAt(index);
      });
    }
  }

  Future<void> _saveProcess() async {
    if (_titleController.text.trim().isEmpty) {
      _showError(AppLocalizations.of(context)?.get('titleRequired') ??
          'Title is required');
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      _showError(AppLocalizations.of(context)?.get('descriptionRequired') ??
          'Description is required');
      return;
    }

    // Validar que todas las etapas tengan contenido
    for (int i = 0; i < _stages.length; i++) {
      if (_stages[i].stageController.text.trim().isEmpty ||
          _stages[i].descriptionController.text.trim().isEmpty) {
        _showError(AppLocalizations.of(context)?.get('allStagesRequired') ??
            'All stages must have title and description');
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Crear las etapas
      final processStages = _stages
          .map((stageData) => ProcessStage(
                stageData.stageController.text.trim(),
                stageData.descriptionController.text.trim(),
                processStudyId: null,
              ))
          .toList();

      // Crear el proceso
      final newProcess = ProcessStudy(
        _titleController.text.trim(),
        _descriptionController.text.trim(),
        processStages,
      );

      // Guardar en la base de datos
      final processId =
          await ProcessDataService.addProcessStudy(newProcess, widget.language);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${AppLocalizations.of(context)?.get('processAddedSuccessfully') ?? 'Process added successfully'} (ID: $processId)'),
            backgroundColor: const Color(0xFF38A169), // Verde primario
          ),
        );
        Navigator.of(context)
            .pop(true); // Retornar true para indicar que se agregó
      }
    } catch (e) {
      if (mounted) {
        _showError(
            '${AppLocalizations.of(context)?.get('errorSavingProcess') ?? 'Error saving process'}: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFE53E3E), // Rojo primario vibrante
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${AppLocalizations.of(context)?.get('addNewProcess') ?? 'Add New Process'} (${widget.language.toUpperCase()})'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(AppLocalizations.of(context)?.get('initializing') ??
                      'Initializing...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Título del proceso
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)
                              ?.get('processTitle_field') ??
                          'Process Title',
                      border: const OutlineInputBorder(),
                      hintText: AppLocalizations.of(context)
                              ?.get('processTitleHint') ??
                          'Enter the process title',
                    ),
                    maxLines: 1,
                  ),
                  const SizedBox(height: 16),

                  // Descripción del proceso
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)
                              ?.get('processDescription') ??
                          'Process Description',
                      border: const OutlineInputBorder(),
                      hintText: AppLocalizations.of(context)
                              ?.get('processDescriptionHint') ??
                          'Describe the process in general',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  // Etapas del proceso
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)?.get('processStages') ??
                            'Process Stages',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      IconButton(
                        onPressed: _addStage,
                        icon: const Icon(Icons.add_circle),
                        color: const Color(0xFF38A169), // Verde primario
                        tooltip:
                            AppLocalizations.of(context)?.get('addStage') ??
                                'Add stage',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Lista de etapas
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _stages.length,
                    itemBuilder: (context, index) {
                      // Lista de colores primarios (igual que en process_items.dart)
                      final stageColors = [
                        const Color(0xFFE53E3E), // Rojo primario vibrante
                        const Color(0xFF3182CE), // Azul primario
                        const Color(0xFF38A169), // Verde primario
                        const Color(0xFFD69E2E), // Amarillo/Naranja primario
                        const Color(0xFF9F7AEA), // Púrpura primario
                      ];
                      final stageColor = stageColors[index % stageColors.length];
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border(
                            left: BorderSide(
                              color: stageColor,
                              width: 6.0,
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.flag_rounded,
                                        color: stageColor,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${AppLocalizations.of(context)?.get('stage') ?? 'Stage'} ${index + 1}',
                                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (_stages.length > 1)
                                    IconButton(
                                      onPressed: () => _removeStage(index),
                                      icon: const Icon(Icons.remove_circle),
                                      color: const Color(0xFFE53E3E), // Rojo primario vibrante
                                      iconSize: 20,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _stages[index].stageController,
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)
                                          ?.get('stageTitle') ??
                                      'Stage Title',
                                  border: const OutlineInputBorder(),
                                  isDense: true,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller:
                                    _stages[index].descriptionController,
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)
                                          ?.get('stageDescription') ??
                                      'Stage Description',
                                  border: const OutlineInputBorder(),
                                  isDense: true,
                                ),
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Botón para guardar
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveProcess,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                    child: Text(
                        AppLocalizations.of(context)?.get('saveProcess') ??
                            'Save Process'),
                  ),
                ],
              ),
            ),
    );
  }
}

class StageFormData {
  final TextEditingController stageController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  void dispose() {
    stageController.dispose();
    descriptionController.dispose();
  }
}
