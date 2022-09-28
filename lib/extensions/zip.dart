class Zip2Entry<A, B> {
  const Zip2Entry(this.item1, this.item2);

  final A item1;
  final B item2;
}

class Zip3Entry<A, B, C> {
  const Zip3Entry(this.item1, this.item2, this.item3);

  final A item1;
  final B item2;
  final C item3;
}

// class Zip4Entry<A, B, C, D> {
//   const Zip4Entry(this.item1, this.item2, this.item3, this.item4);

//   final A item1;
//   final B item2;
//   final C item3;
//   final D item4;
// }

Iterable<Zip2Entry<A, B>> zip2<A, B>(
  Iterable<A> iterable1,
  Iterable<B> iterable2,
) sync* {
  assert(iterable1.length == iterable2.length);

  final iterator1 = iterable1.iterator;
  final iterator2 = iterable2.iterator;

  while (iterator1.moveNext() && iterator2.moveNext()) {
    yield Zip2Entry<A, B>(iterator1.current, iterator2.current);
  }
}

Iterable<Zip3Entry<A, B, C>> zip3<A, B, C>(
  Iterable<A> iterable1,
  Iterable<B> iterable2,
  Iterable<C> iterable3,
) sync* {
  assert({iterable1.length, iterable2.length, iterable3.length}.length == 1);

  final iterator1 = iterable1.iterator;
  final iterator2 = iterable2.iterator;
  final iterator3 = iterable3.iterator;

  while (iterator1.moveNext() && iterator2.moveNext() && iterator3.moveNext()) {
    yield Zip3Entry<A, B, C>(
      iterator1.current,
      iterator2.current,
      iterator3.current,
    );
  }
}
