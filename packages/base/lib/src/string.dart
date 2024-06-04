import 'dart:math';

extension MhuStringExt on String {
  String? get nullWhenEmpty => this.isEmpty ? null : this;
}

String generateRandomString({
  List<String> characters = const [
    "A",
    "B",
    "C",
    "D",
    "E",
    "F",
    "G",
    "H",
    "I",
    "J",
    "K",
    "L",
    "M",
    "N",
    "O",
    "P",
    "Q",
    "R",
    "S",
    "T",
    "U",
    "V",
    "W",
    "X",
    "Y",
    "Z",
    "a",
    "b",
    "c",
    "d",
    "e",
    "f",
    "g",
    "h",
    "i",
    "j",
    "k",
    "l",
    "m",
    "n",
    "o",
    "p",
    "q",
    "r",
    "s",
    "t",
    "u",
    "v",
    "w",
    "x",
    "y",
    "z",
    "0",
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
  ],
  int length = 20,
}) {
  final buffer = StringBuffer();
  final random = Random();

  for (int i = 0; i < length; ++i) {
    final index = random.nextInt(characters.length);
    final char = characters[index];
    buffer.write(char);
  }

  return buffer.toString();
}
