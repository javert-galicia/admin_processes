class ProcessStudy {
  const ProcessStudy(this.title, this.stages, this.description);

  final String title;
  final List<String> stages;
  final List<String> description;

  /*List<String> describeDef() {
    List<String> dictionary = [];
    for (int i = 0; i < stages.length; i++) {
      dictionary.add(stages[i]);
      dictionary.add(description[i]);
    }
    return dictionary;
  }*/
}
