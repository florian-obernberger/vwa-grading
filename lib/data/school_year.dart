List<String> generateSchoolYears({
  int amount = 5,
  int yearsBack = 2,
  DateTime? start,
}) {
  start ??= DateTime.now();

  final year = start.year;
  final years = <String>[];

  for (int y = 0; y <= amount; y++) {
    final f = year - yearsBack + y;
    final s = f + 1;
    years.add("$f/${s.toString().substring(2)}");
  }

  return years;
}
