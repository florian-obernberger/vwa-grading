extension FirstUpper on String {
  String firstUpper() {
    return this[0].toUpperCase() + substring(1);
  }
}
