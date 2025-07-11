import 'package:intl/intl.dart';

class Formatters {
  // Date Formatters
  static final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');
  static final DateFormat dateTimeFormatter = DateFormat('yyyy-MM-dd HH:mm');
  static final DateFormat timeFormatter = DateFormat('HH:mm');
  static final DateFormat monthDayFormatter = DateFormat('MM월 dd일');
  static final DateFormat weekDayFormatter = DateFormat('EEEE', 'ko_KR');
  static final DateFormat fullDateFormatter = DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR');
  
  // Number Formatters
  static final NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'ko_KR',
    symbol: '₩',
    decimalDigits: 0,
  );
  
  static final NumberFormat percentFormatter = NumberFormat.percentPattern('ko_KR');
  static final NumberFormat decimalFormatter = NumberFormat.decimalPattern('ko_KR');
  
  // Date formatting methods
  static String formatDate(DateTime date) => dateFormatter.format(date);
  static String formatDateTime(DateTime dateTime) => dateTimeFormatter.format(dateTime);
  static String formatTime(DateTime time) => timeFormatter.format(time);
  static String formatMonthDay(DateTime date) => monthDayFormatter.format(date);
  static String formatWeekDay(DateTime date) => weekDayFormatter.format(date);
  static String formatFullDate(DateTime date) => fullDateFormatter.format(date);
  
  // Number formatting methods
  static String formatCurrency(num amount) => currencyFormatter.format(amount);
  static String formatPercent(double percent) => percentFormatter.format(percent);
  static String formatDecimal(num number) => decimalFormatter.format(number);
  
  // Duration formatting
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}시간 ${minutes}분';
  }
  
  // Phone number formatting
  static String formatPhoneNumber(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length == 11) {
      return '${cleaned.substring(0, 3)}-${cleaned.substring(3, 7)}-${cleaned.substring(7)}';
    }
    return phone;
  }
} 