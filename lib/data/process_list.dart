import 'package:admin_processes/model/process_stage.dart';
import 'package:admin_processes/model/process_study.dart';
import 'package:admin_processes/data/process_list_localized.dart';
import 'package:flutter/material.dart';

List<ProcessStudy> getProcessList(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode;
  return processListLocalized[locale] ?? processListLocalized['es']!;
}