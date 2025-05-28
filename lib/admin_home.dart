import 'package:flutter/material.dart';
import 'booking_management_page.dart';
import 'room_management_page.dart';
import 'notifications_page.dart';
import 'feedback_page.dart';
import 'help_support_page.dart';
import 'staff_training_page.dart';
import 'security_settings_page.dart';
import 'staff_management_page.dart';
import 'reports_page.dart';
import 'admin_sidebar.dart';
import 'db_helper.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  @override
  void initState() {
    super.initState();
  }

  Future<Map<String, dynamic>> _fetchReportData(BuildContext context) async {
    final db = await DBHelper.database;
    final bookings = await db.query('bookings');
    final totalBookings = bookings.length;
    final checkedIn = bookings.where((b) => b['booking_status'] == 'checked_in').length;
    final checkedOut = bookings.where((b) => b['booking_status'] == 'checked_out').length;
    final cancelled = bookings.where((b) => b['booking_status'] == 'cancelled').length;
    final rooms = await db.query('rooms');
    final totalRooms = rooms.length;
    final availableRooms = rooms.where((r) => r['status'] == 'available').length;
    final occupiedRooms = rooms.where((r) => r['status'] == 'occupied').length;
    final dirtyRooms = rooms.where((r) => r['housekeeping_status'] == 'dirty').length;
    final staff = await db.query('users', where: 'role = ?', whereArgs: ['staff']);
    final housekeepers = await db.query('users', where: 'role = ?', whereArgs: ['housekeeping']);
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

  Future<List<Map<String, dynamic>>> _fetchRecentActivity() async {
    final db = await DBHelper.database;
    final bookings = await db.query('bookings', orderBy: 'id DESC', limit: 5);
    final notifications = await db.query('notifications', orderBy: 'id DESC', limit: 5);
    List<Map<String, dynamic>> activity = [];
    activity.addAll(bookings.map((b) => {
      'type': 'booking',
      'desc': 'Booking for Room ${b['room_id']} - ${b['booking_status']}',
      'date': b['check_in_date'] ?? '',
    }));
    activity.addAll(notifications.map((n) => {
      'type': 'notification',
      'desc': n['message'],
      'date': n['created_at'] ?? '',
    }));
    activity.sort((a, b) => b['date'].toString().compareTo(a['date'].toString()));
    return activity.take(5).toList();
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  Widget _reportTile(String label, String value, IconData icon, Color color, {VoidCallback? onTap}) {
    return SizedBox(
      width: 180,
      child: Card(
        color: color.withOpacity(0.1),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
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
      ),
    );
  }

  Widget _quickActions(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.person_add),
          label: const Text('Add Staff'),
          onPressed: () => Navigator.pushNamed(context, '/staff_management'),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.meeting_room),
          label: const Text('Add Room'),
          onPressed: () => Navigator.pushNamed(context, '/room_management'),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.book_online),
          label: const Text('Add Booking'),
          onPressed: () => Navigator.pushNamed(context, '/booking_management'),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.bar_chart),
          label: const Text('View Reports'),
          onPressed: () => Navigator.pushNamed(context, '/reports'),
        ),
      ],
    );
  }

  Widget _recentActivitySection() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchRecentActivity(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final activity = snapshot.data!;
        if (activity.isEmpty) {
          return const Text('No recent activity.');
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Recent Activity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            ...activity.map((a) => ListTile(
              leading: Icon(a['type'] == 'booking' ? Icons.book_online : Icons.notifications),
              title: Text(a['desc'] ?? ''),
              subtitle: Text(a['date'] ?? ''),
            )),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    final pageName = 'Dashboard';
    final sidebar = const AdminSidebar(pageName: 'Dashboard');
    final summaryCards = FutureBuilder<Map<String, dynamic>>(
      future: _fetchReportData(context),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data!;
        final List<Widget> tiles = [
          _reportTile('Total Bookings', data['totalBookings'].toString(), Icons.book_online, Colors.blue,
            onTap: () => Navigator.pushNamed(context, '/booking_management'),
          ),
          _reportTile('Checked In', data['checkedIn'].toString(), Icons.login, Colors.green,
            onTap: () => Navigator.pushNamed(context, '/booking_management'),
          ),
          _reportTile('Checked Out', data['checkedOut'].toString(), Icons.logout, Colors.grey,
            onTap: () => Navigator.pushNamed(context, '/booking_management'),
          ),
          _reportTile('Available Rooms', data['availableRooms'].toString(), Icons.hotel, Colors.teal,
            onTap: () => Navigator.pushNamed(context, '/room_management'),
          ),
          _reportTile('Occupied Rooms', data['occupiedRooms'].toString(), Icons.bed, Colors.orange,
            onTap: () => Navigator.pushNamed(context, '/room_management'),
          ),
          _reportTile('Revenue', '\$${data['revenue'].toStringAsFixed(2)}', Icons.attach_money, Colors.green,
            onTap: () => Navigator.pushNamed(context, '/reports'),
          ),
        ];
        List<Widget> rows = [];
        for (int i = 0; i < tiles.length; i += 2) {
          rows.add(Row(
            children: [
              Expanded(child: tiles[i]),
              if (i + 1 < tiles.length) Expanded(child: tiles[i + 1]),
            ],
          ));
          if (i + 2 < tiles.length) rows.add(const SizedBox(height: 16));
        }
        return Column(children: rows);
      },
    );
    final dashboardContent = SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Hotel Summary(Today)', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          summaryCards,
          const SizedBox(height: 32),
          _quickActions(context),
          const SizedBox(height: 32),
          _recentActivitySection(),
        ],
      ),
    );
    if (isWide) {
      return Row(
        children: [
          AdminSidebar(pageName: pageName, role: 'admin'),
          Container(width: 1, color: Colors.black12),
          Expanded(
            child: Scaffold(
              appBar: AppBar(
                title: Text(pageName),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () => _confirmLogout(context),
                  ),
                ],
              ),
              body: dashboardContent,
            ),
          ),
        ],
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(pageName),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _confirmLogout(context),
            ),
          ],
        ),
        drawer: Drawer(child: AdminSidebar(pageName: pageName, role: 'admin')),
        body: dashboardContent,
      );
    }
  }
}
