class CurrencyFormatter {
  static String format(int amount) {
    final value = amount.toString();
    final buffer = StringBuffer();

    for (var i = 0; i < value.length; i++) {
      final remaining = value.length - i;
      buffer.write(value[i]);
      if (remaining > 1 && remaining % 3 == 1) {
        buffer.write('.');
      }
    }

    return 'Rp$buffer';
  }

  static String formatCompact(int amount) {
    if (amount >= 1000000000) {
      return 'Rp${(amount / 1000000000).toStringAsFixed(1)}M';
    }
    if (amount >= 1000000) {
      return 'Rp${(amount / 1000000).toStringAsFixed(1)}jt';
    }
    if (amount >= 1000) {
      return 'Rp${(amount / 1000).toStringAsFixed(0)}rb';
    }
    return format(amount);
  }
}
