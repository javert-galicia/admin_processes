import 'package:flutter/material.dart';
import 'package:admin_processes/data/process_list.dart';

class ProcessScreen extends StatefulWidget {
  const ProcessScreen({super.key});

  @override
  State<ProcessScreen> createState() => _ProcessScreenState();
}

class _ProcessScreenState extends State<ProcessScreen> {
  bool checkboxValue1 = false;
  bool checkboxValue2 = true;
  bool checkboxValue3 = true;

  final currentProcess = processList[0];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        CheckboxListTile(
          value: checkboxValue1,
          onChanged: (bool? value) {
            setState(() {
              checkboxValue1 = value!;
            });
          },
          title: ExpansionTile(
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(currentProcess.title),
            children: [
              Text(currentProcess.stages[1]),
            ],
          ),
          //subtitle: const Text('Supporting text'),
        ),
        const Divider(height: 0),
        CheckboxListTile(
          value: checkboxValue2,
          onChanged: (bool? value) {
            setState(() {
              checkboxValue2 = value!;
            });
          },
          title: const Text('Headline'),
          subtitle: const Text(
              'Longer supporting text to demonstrate how the text wraps and the checkbox is centered vertically with the text.'),
        ),
        const Divider(height: 0),
        CheckboxListTile(
          value: checkboxValue3,
          onChanged: (bool? value) {
            setState(() {
              checkboxValue3 = value!;
            });
          },
          title: const Text('Headline'),
          subtitle: const Text(
              "Longer supporting text to demonstrate how the text wraps and how setting 'CheckboxListTile.isThreeLine = true' aligns the checkbox to the top vertically with the text."),
          isThreeLine: true,
        ),
        const Divider(height: 0),
      ],
    );
  }
}
