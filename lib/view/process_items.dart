import 'package:admin_processes/model/process_stage.dart';
import 'package:flutter/material.dart';
import 'package:admin_processes/data/process_list.dart' show getProcessList;
import 'package:admin_processes/l10n/localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  Color backColorStage(int j) {
    if (j < colors.length) {
      return colors[j];
    }
    else{
      return backColorStage(j-colors.length);
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
    await prefs.setStringList(key, checkboxValue.map((e) => e.toString()).toList());
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
    final processList = getProcessList(context);
    String title = processList[k].title;
    String descriptionStudy = processList[k].description;
    List<ProcessStage> currentListSteps = processList[k].processStage.toList();

    if (checkboxValue.isEmpty && isLoading) {
      loadCheckboxState(k, currentListSteps.length);
    }
    backColor(k);

    if (isLoading || checkboxValue.length != currentListSteps.length) {
      return const Center(child: CircularProgressIndicator());
    }

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
                      backgroundColor: const Color.fromARGB(255, 254, 232, 159),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 30,
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              descriptionStudy,
                              style: const TextStyle(
                                fontSize: 20,
                                fontFamily: 'Lato',
                              ),
                            ),
                            const SizedBox(height: 15),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(AppLocalizations.of(context)?.get('close') ?? 'Close'),
                            ),
                          ],
                        ),
                      ),
                    ),
                ),
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
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: currentListSteps.length,
                itemBuilder: (context, index) {
                  return Container(
                    color: checkboxValue[index] ? Colors.black : backColorStage(index),
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
    ]);
  }
}
