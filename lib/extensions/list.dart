extension SumInt on Iterable<int> {
  int sum() {
    return fold<int>(0, (s, e) => s + e);
  }

  int sumWhere(bool Function(int e) test) {
    return where(test).sum();
  }
}

extension SumDouble on Iterable<double> {
  double sum() {
    return fold<double>(0.0, (s, e) => s + e);
  }

  double sumWhere(bool Function(double e) test) {
    return where(test).sum();
  }
}
