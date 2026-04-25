class AdminStats {
  final int totalUsers;
  final int totalBookings;
  final int confirmedBookings;
  final int cancelledBookings;
  final double totalRevenue;
  final int totalTickets;

  final Map<String, int> ticketsByType;
  final Map<String, int> bookingsByHall;
  final Map<String, double> revenueByType;

  // ✅ الجديد
  final Map<String, int> dailySales;

  const AdminStats({
    required this.totalUsers,
    required this.totalBookings,
    required this.confirmedBookings,
    required this.cancelledBookings,
    required this.totalRevenue,
    required this.totalTickets,
    required this.ticketsByType,
    required this.bookingsByHall,
    required this.revenueByType,
    required this.dailySales, // ✅ مهم
  });

  factory AdminStats.fromJson(Map<String, dynamic> j) {
    final tickets = Map<String, int>.from(
      (j['ticketsByType'] ?? {}).map(
            (k, v) => MapEntry(k.toString(), (v as num).toInt()),
      ),
    );

    final total = tickets.values.fold(0, (a, b) => a + b);

    final bookingsByHall = Map<String, int>.from(
      (j['bookingsByHall'] ?? {}).map(
            (k, v) => MapEntry(k.toString(), (v as num).toInt()),
      ),
    );

    final revenueByType = Map<String, double>.from(
      (j['revenueByType'] ?? {}).map(
            (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
      ),
    );

    // ✅ الجديد
    final dailySales = Map<String, int>.from(
      (j['dailySales'] ?? {}).map(
            (k, v) => MapEntry(k.toString(), (v as num).toInt()),
      ),
    );

    return AdminStats(
      totalUsers: (j['totalUsers'] ?? 0),
      totalBookings: (j['totalBookings'] ?? 0),
      confirmedBookings: (j['confirmedBookings'] ?? 0),
      cancelledBookings: (j['cancelledBookings'] ?? 0),
      totalRevenue: (j['totalRevenue'] ?? 0).toDouble(),
      totalTickets: total,
      ticketsByType: tickets,
      bookingsByHall: bookingsByHall,
      revenueByType: revenueByType,
      dailySales: dailySales, // ✅ مهم
    );
  }


}