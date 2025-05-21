import 'package:flutter/material.dart';
import 'admin_sidebar.dart';
import 'db_helper.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  Future<Map<String, dynamic>> _fetchReportData(BuildContext context) async {
    final db = await DBHelper.database;
    // Bookings summary
    final bookings = await db.query('bookings');
    final totalBookings = bookings.length;
    final checkedIn = bookings.where((b) => b['booking_status'] == 'checked_in').length;
    final checkedOut = bookings.where((b) => b['booking_status'] == 'checked_out').length;
    final cancelled = bookings.where((b) => b['booking_status'] == 'cancelled').length;
    // Room summary
    final rooms = await db.query('rooms');
    final totalRooms = rooms.length;
    final availableRooms = rooms.where((r) => r['status'] == 'available').length;
    final occupiedRooms = rooms.where((r) => r['status'] == 'occupied').length;
    final dirtyRooms = rooms.where((r) => r['housekeeping_status'] == 'dirty').length;
    // Staff summary
    final staff = await db.query('users', where: 'role = ?', whereArgs: ['staff']);
    final housekeepers = await db.query('users', where: 'role = ?', whereArgs: ['housekeeping']);
    // Revenue (sum of total_amount for checked_out bookings)
    final revenue = bookings
        .where((b) => b['booking_status'] == 'checked_out' && b['total_amount'] != null)
        .fold<double>(0, (sum, b) {
          final amt = b['total_amount'];
          if (amt is int) return sum + amt.toDouble();
          if (amt is double) return sum + amt;
          if (amt is String) {
            final parsed = double.tryParse(amt);
            return parsed != null ? sum + parsed : sum;
          }
          return sum;
        });
    return {
      'totalBookings': totalBookings,
      'checkedIn': checkedIn,
      'checkedOut': checkedOut,
      'cancelled': cancelled,
      'totalRooms': totalRooms,
      'availableRooms': availableRooms,
      'occupiedRooms': occupiedRooms,
      'dirtyRooms': dirtyRooms,
      'staffCount': staff.length,
      'housekeepersCount': housekeepers.length,
      'revenue': revenue,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    final pageName = 'Reports';
    final role = ModalRoute.of(context)?.settings.arguments as String? ?? 'admin';
    final sidebar = AdminSidebar(pageName: pageName, role: role);
    final reportCard = FutureBuilder<Map<String, dynamic>>(
      future: _fetchReportData(context),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data!;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hotel Summary', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final double maxWidth = constraints.maxWidth;
                      final int cardsPerRow = maxWidth > 600 ? 2 : 1;
                      final List<Widget> tiles = [
                        _reportTile('Total Bookings', data['totalBookings'].toString(), Icons.book_online, Colors.blue),
                        _reportTile('Checked In', data['checkedIn'].toString(), Icons.login, Colors.green),
                        _reportTile('Checked Out', data['checkedOut'].toString(), Icons.logout, Colors.grey),
                        _reportTile('Cancelled', data['cancelled'].toString(), Icons.cancel, Colors.red),
                        _reportTile('Total Rooms', data['totalRooms'].toString(), Icons.meeting_room, Colors.deepPurple),
                        _reportTile('Available Rooms', data['availableRooms'].toString(), Icons.hotel, Colors.teal),
                        _reportTile('Occupied Rooms', data['occupiedRooms'].toString(), Icons.bed, Colors.orange),
                        _reportTile('Dirty Rooms', data['dirtyRooms'].toString(), Icons.warning, Colors.brown),
                        _reportTile('Staff', data['staffCount'].toString(), Icons.people, Colors.indigo),
                        _reportTile('Housekeepers', data['housekeepersCount'].toString(), Icons.cleaning_services, Colors.pink),
                        _reportTile('Revenue', '\$${data['revenue'].toStringAsFixed(2)}', Icons.attach_money, Colors.green),
                      ];
                      List<Row> rows = [];
                      for (int i = 0; i < tiles.length; i += cardsPerRow) {
                        rows.add(Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (int j = 0; j < cardsPerRow; j++)
                              if (i + j < tiles.length)
                                Expanded(child: tiles[i + j]),
                          ],
                         ));
                      }
                      return Column(
                        children: [
                          for (int i = 0; i < rows.length; i++) ...[
                            rows[i],
                            if (i < rows.length - 1) const SizedBox(height: 16),
                          ]
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (isWide) {
      return Row(
        children: [
          sidebar,
          Container(width: 1, color: Colors.black12),
          Expanded(
            child: Scaffold(
              appBar: AppBar(title: Text(pageName)),
              body: reportCard,
            ),
          ),
        ],
      );
    } else {
      return Scaffold(
        appBar: AppBar(title: Text(pageName)),
        drawer: Drawer(child: sidebar),
        body: reportCard,
      );
    }
  }

  Widget _reportTile(String label, String value, IconData icon, Color color) {
    return SizedBox(
      width: 180,
      child: Card(
        color: color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(fontSize: 20, color: color, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
