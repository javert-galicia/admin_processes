import 'package:flutter/material.dart';
import 'package:admin_processes/data/process_list.dart';

class ProcessItems extends StatefulWidget {
  const ProcessItems({required this.indexPage, super.key});

  final int indexPage;

  @override
  State<ProcessItems> createState() => _ProcessItemsState();
}

class _ProcessItemsState extends State<ProcessItems> {

  List<bool> checkboxValue = [];
  void checkBoxFilled(int j) {
   for (int i = 0; i < j; i++) {
      checkboxValue.add(false);
    }
  }

  @override
  Widget build(BuildContext context) {

    String title = processList[widget.indexPage].title;
    List<String> currentListSteps = processList[widget.indexPage].stages;
    List<String> currentListDescr = processList[widget.indexPage].description;

    checkBoxFilled(currentListSteps.length);

    return Column(
      children: [
        Text(title),
        Expanded(
          child: ListView.builder(
            itemCount: currentListSteps.length,
            itemBuilder: (context, index) {
              return CheckboxListTile(
                value: checkboxValue[index],
                title: ExpansionTile(
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(currentListSteps[index]),
                  children: [
                    Text(currentListDescr[index]),
                  ],
                ),
                onChanged: (value) {
                  setState(() {
                    checkboxValue[index] = value!;
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
