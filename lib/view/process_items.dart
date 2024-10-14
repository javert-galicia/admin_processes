import 'package:flutter/material.dart';
import 'package:admin_processes/data/process_list.dart';

class ProcessItems extends StatefulWidget {
  const ProcessItems({required this.indexPage, super.key});

  final int indexPage;

  @override
  State<ProcessItems> createState() => _ProcessItemsState();
}

class _ProcessItemsState extends State<ProcessItems> {
  List<Color> colors = [
    Colors.yellow,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.purple
  ];
  List<bool> checkboxValue = [];
  void checkBoxFilled(int j) {
    for (int i = 0; i < j; i++) {
      checkboxValue.add(false);
    }
  }

  Color backgroundColor = Colors.grey;
  void backColor(int j) {
    if (j % 2 != 0) {
      backgroundColor = Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = processList[widget.indexPage].title;
    List<String> currentListSteps = processList[widget.indexPage].stages;
    List<String> currentListDescr = processList[widget.indexPage].description;

    checkBoxFilled(currentListSteps.length);
    backColor(widget.indexPage);

    return Container(
      color: backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title),
          ListView.builder(
            shrinkWrap: true,
            itemCount: currentListSteps.length,
            itemBuilder: (context, index) {
              return Container(
                color: checkboxValue[index] ? Colors.black : colors[index],
                child: CheckboxListTile(
                  value: checkboxValue[index],
                  title: ExpansionTile(
                    shape: const Border(),
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(currentListSteps[index]),
                    children: [
                      Card.outlined(
                        color: Colors.white,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(currentListDescr[index]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  onChanged: (value) {
                    setState(() {
                      checkboxValue[index] = value!;
                    });
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
    );
  }
}
