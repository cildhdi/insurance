final alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

int columnToIndex(String column) {
  if (column.length == 1) {
    return alphabet.indexOf(column[0]);
  } else {
    return alphabet.indexOf(column[1]) + (alphabet.indexOf(column[0]) + 1) * 26;
  }
}

int ageToIndex(int age) {
  return age + 28;
}
