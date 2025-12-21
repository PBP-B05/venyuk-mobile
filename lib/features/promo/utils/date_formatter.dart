class DateFormatter {
  static String formatDate(String date) {
    try {
      final dateTime = DateTime.parse(date);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
    } catch (e) {
      return date;
    }
  }

  static String formatDateRange(String startDate, String endDate) {
    return '${formatDate(startDate)} - ${formatDate(endDate)}';
  }
}