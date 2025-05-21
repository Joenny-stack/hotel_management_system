import 'package:flutter/material.dart';
import 'admin_sidebar.dart';
import 'db_helper.dart';

class StaffHomePage extends StatefulWidget {
  const StaffHomePage({super.key});

  @override
  State<StaffHomePage> createState() => _StaffHomePageState();
}

class _StaffHomePageState extends State<StaffHomePage> {
  Future<Map<String, dynamic>> _fetchStaffDashboardData() async {
    final db = await DBHelper.database;
    final today = DateTime.now();
    final todayStr = today.toIso8601String().substring(0, 10);
    final bookings = await db.query('bookings');
    final todaysCheckIns = bookings.where((b) => b['check_in_date'] == todayStr).length;
    final todaysCheckOuts = bookings.where((b) => b['check_out_date'] == todayStr).length;
    final rooms = await db.query('rooms');
    final availableRooms = rooms.where((r) => r['status'] == 'available').length;
    final occupiedRooms = rooms.where((r) => r['status'] == 'occupied').length;
    final pendingTasks = await db.query('room_service', where: 'status = ?', whereArgs: ['pending']);
    return {
      'todaysCheckIns': todaysCheckIns,
      'todaysCheckOuts': todaysCheckOuts,
      'availableRooms': availableRooms,
      'occupiedRooms': occupiedRooms,
      'pendingTasks': pendingTasks.length,
    };
  }

  Future<List<Map<String, dynamic>>> _fetchRecentActivity() async {
    final db = await DBHelper.database;
    final bookings = await db.query('bookings', orderBy: 'id DESC', limit: 5);
    final roomService = await db.query('room_service', orderBy: 'id DESC', limit: 5);
    List<Map<String, dynamic>> activity = [];
    activity.addAll(bookings.map((b) => {
      'type': 'booking',
      'desc': 'Booking for Room ${b['room_id']} - ${b['booking_status']}',
      'date': b['check_in_date'] ?? '',
    }));
    activity.addAll(roomService.map((r) => {
      'type': 'room_service',
      'desc': 'Room Service: ${r['service_type']} for Room ${r['room_id']} - ${r['status']}',
      'date': r['created_at'] ?? '',
    }));
    activity.sort((a, b) => b['date'].toString().compareTo(a['date'].toString()));
    return activity.take(5).toList();
  }

  Widget _dashboardTile(String label, String value, IconData icon, Color color, {VoidCallback? onTap}) {
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
          icon: const Icon(Icons.book_online),
          label: const Text('Add Booking'),
          onPressed: () => Navigator.pushNamed(context, '/booking_management'),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.room_service),
          label: const Text('Room Service'),
          onPressed: () => Navigator.pushNamed(context, '/room_service'),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.notifications),
          label: const Text('Notifications'),
          onPressed: () => Navigator.pushNamed(context, '/notifications'),
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
              leading: Icon(a['type'] == 'booking' ? Icons.book_online : Icons.room_service),
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
    final pageName = 'Staff Dashboard';
    final role = 'staff';
    final sidebar = AdminSidebar(pageName: pageName, role: role);
    final summaryCards = FutureBuilder<Map<String, dynamic>>(
      future: _fetchStaffDashboardData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data!;
        final List<Widget> tiles = [
          _dashboardTile("Today's Check-Ins", data['todaysCheckIns'].toString(), Icons.login, Colors.green,
            onTap: () => Navigator.pushNamed(context, '/booking_management'),
          ),
          _dashboardTile("Today's Check-Outs", data['todaysCheckOuts'].toString(), Icons.logout, Colors.grey,
            onTap: () => Navigator.pushNamed(context, '/booking_management'),
          ),
          _dashboardTile('Available Rooms', data['availableRooms'].toString(), Icons.hotel, Colors.teal,
            onTap: () => Navigator.pushNamed(context, '/room_management'),
          ),
          _dashboardTile('Occupied Rooms', data['occupiedRooms'].toString(), Icons.bed, Colors.orange,
            onTap: () => Navigator.pushNamed(context, '/room_management'),
          ),
          _dashboardTile('Pending Tasks', data['pendingTasks'].toString(), Icons.room_service, Colors.purple,
            onTap: () => Navigator.pushNamed(context, '/room_service'),
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
          const Text('Staff Summary', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
          sidebar,
          Container(width: 1, color: Colors.black12),
          Expanded(
            child: Scaffold(
              appBar: AppBar(title: Text(pageName)),
              body: dashboardContent,
            ),
          ),
        ],
      );
    } else {
      return Scaffold(
        appBar: AppBar(title: Text(pageName)),
        drawer: Drawer(child: sidebar),
        body: dashboardContent,
      );
    }
  }
}
