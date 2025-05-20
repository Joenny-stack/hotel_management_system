import 'package:flutter/material.dart';
import 'admin_sidebar.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    final pageName = 'Notifications';
    final role = ModalRoute.of(context)?.settings.arguments as String? ?? 'admin';
    if (isWide) {
      return Row(
        children: [
          AdminSidebar(pageName: pageName, role: role),
          Container(width: 1, color: Colors.black12),
          Expanded(
            child: Scaffold(
              appBar: AppBar(title: Text(pageName)),
              body: Center(
                child: Card(
                  elevation: 6,
                  margin: const EdgeInsets.all(24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.notifications, size: 64, color: Colors.orange),
                        SizedBox(height: 16),
                        Text(
                          'Notifications and alerts coming soon!',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              backgroundColor: Theme.of(context).colorScheme.surface,
            ),
          ),
        ],
      );
    } else {
      return Scaffold(
        appBar: AppBar(title: Text(pageName)),
        drawer: Drawer(
          child: AdminSidebar(pageName: pageName, role: role),
        ),
        body: Center(
          child: Card(
            elevation: 6,
            margin: const EdgeInsets.all(24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.notifications, size: 64, color: Colors.orange),
                  SizedBox(height: 16),
                  Text(
                    'Notifications and alerts coming soon!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
      );
    }
  }
}
