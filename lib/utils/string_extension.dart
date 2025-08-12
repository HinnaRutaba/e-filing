extension StringExtension on String {
  String extractFirstLetters() {
    List<String> words = split(" ");
    String initials = "";

    for (String word in words) {
      if (word.isNotEmpty) {
        initials += word[0].toUpperCase();
      }
    }

    return initials;
  }
}
