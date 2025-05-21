import 'package:flutter/material.dart';
import 'admin_sidebar.dart';
import 'db_helper.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Map<String, dynamic>> _notifications = [];
  bool _loading = true;
  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    final db = await DBHelper.database;
    // Only show for housekeeping role for now
    final res = await db.query('notifications', where: 'role = ?', whereArgs: ['housekeeping'], orderBy: 'created_at DESC');
    setState(() {
      _notifications = res;
      _loading = false;
    });
  }

  void _markAsReadAndGoToRoomService(int? roomId) async {
    final db = await DBHelper.database;
    if (roomId != null) {
      await db.update('notifications', {'is_read': 1}, where: 'room_id = ?', whereArgs: [roomId]);
    }
    if (mounted) {
      Navigator.pushNamed(context, '/room_service', arguments: 'housekeeping');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    final pageName = 'Notifications';
    final role = ModalRoute.of(context)?.settings.arguments as String? ?? 'housekeeping';
    final sidebar = AdminSidebar(pageName: pageName, role: role);
    final notificationList = _loading
        ? const Center(child: CircularProgressIndicator())
        : _notifications.isEmpty
            ? const Center(child: Text('No notifications.'))
            : ListView.builder(
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final n = _notifications[index];
                  return Card(
                    color: n['is_read'] == 1 ? Colors.grey[100] : Colors.orange[50],
                    child: ListTile(
                      leading: const Icon(Icons.notifications, color: Colors.orange),
                      title: Text(n['title'] ?? ''),
                      subtitle: Text(n['message'] ?? ''),
                      trailing: n['is_read'] == 1
                          ? null
                          : TextButton(
                              child: const Text('Go to Room Service'),
                              onPressed: () => _markAsReadAndGoToRoomService(n['room_id']),
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
              body: notificationList,
            ),
          ),
        ],
      );
    } else {
      return Scaffold(
        appBar: AppBar(title: Text(pageName)),
        drawer: Drawer(child: sidebar),
        body: notificationList,
      );
    }
  }
}
