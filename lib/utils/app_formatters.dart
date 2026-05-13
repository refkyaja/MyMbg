class AppFormatters {
  static const List<String> _dayNames = <String>[
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  static const List<String> _monthNames = <String>[
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static String weekdayName(DateTime date) {
    return _dayNames[date.weekday - 1];
  }

  static String monthName(DateTime date) {
    return _monthNames[date.month - 1];
  }

  static String formatLongDate(DateTime date) {
    return '${weekdayName(date)}, ${date.day} ${monthName(date)} ${date.year}';
  }

  static String formatShortTime(DateTime date) {
    final String hour = date.hour.toString().padLeft(2, '0');
    final String minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static String formatRupiah(int value) {
    final bool isNegative = value < 0;
    final String raw = value.abs().toString();
    final StringBuffer buffer = StringBuffer();

    for (int index = 0; index < raw.length; index++) {
      final int reverseIndex = raw.length - index;
      buffer.write(raw[index]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write('.');
      }
    }

    return '${isNegative ? '-' : ''}Rp${buffer.toString()}';
  }

  static String extractMonthYear(String dateLabel) {
    final List<String> parts = dateLabel.split(' ');
    if (parts.length < 4) {
      return 'Unknown';
    }
    return '${parts[2]} ${parts[3]}';
  }
}
