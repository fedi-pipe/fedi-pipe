extension StringExtension on String {
  String clamp(int maxLength) {
    if (this.length <= maxLength) {
      return this;
    }

    return this.substring(0, maxLength) + '...';
  }
}
