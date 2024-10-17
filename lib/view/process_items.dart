import 'package:admin_processes/model/process_stage.dart';
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
    const Color.fromRGBO(75, 17, 57, 1),
    const Color.fromRGBO(59, 64, 88, 1),
    const Color.fromRGBO(42, 110, 120, 1),
    const Color.fromRGBO(122, 144, 124, 1),
    const Color.fromRGBO(201, 177, 128, 1),
  ];
  List<bool> checkboxValue = [];
  void checkBoxFilled(int j) {
    for (int i = 0; i < j; i++) {
      checkboxValue.add(false);
    }
  }

  Color backgroundColor = const Color.fromRGBO(94, 116, 167, 1);
  void backColor(int j) {
    if (j % 2 != 0) {
      backgroundColor = const Color.fromRGBO(114, 185, 223, 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    int k = widget.indexPage;
    String title = processList[k].title;
    List<ProcessStage> currentListSteps = processList[k].processStage.toList();

    checkBoxFilled(currentListSteps.length);
    backColor(k);

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
                onPressed: (){},
                child: Text(
                  title,
                  style: TextStyle(
                    color: k%2 != 0 ? Colors.black : Colors.white,
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
                        title: Text(
                          currentListSteps[index].stage,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontFamily: 'Lato',
                          ),
                        ),
                        children: [
                          Card.outlined(
                            color: const Color.fromARGB(255, 254, 232, 159),
                            child:
                                // ignore: sized_box_for_whitespace
                                Container(
                                  width: double.infinity,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 10),
                                    child: Text(currentListSteps[index].description,style: const TextStyle(
                                      fontFamily: 'Lato',
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),),
                                  ),
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
        ),
      ),
    ]);
  }
}
