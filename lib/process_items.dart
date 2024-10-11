import 'package:flutter/material.dart';
import 'package:admin_processes/data/process_list.dart';

class ProcessItems extends StatefulWidget {
  const ProcessItems({super.key});

  @override
  State<ProcessItems> createState() => _ProcessItemsState();
}

class _ProcessItemsState extends State<ProcessItems> {
  List<bool> checkboxValue1 = [];

  List<String> currentListSteps = processList[0].stages;
  List<String> currentListDescr = processList[0].description;
  void checkBoxFalse() {
    for (int i = 0; i < currentListSteps.length; i++) {
      checkboxValue1.add(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    checkBoxFalse();
    return ListView.builder(
      itemCount: currentListSteps.length,
      itemBuilder: (context, index) {
        return CheckboxListTile(
          value: checkboxValue1[index],
          title: ExpansionTile(
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(currentListSteps[index]),
            children: [
              Text(currentListDescr[index]),
            ],
          ),
          onChanged: (value) {
            setState(() {
              checkboxValue1[index] = value!;
            });
          },
        );
      },
    );
  }
}
