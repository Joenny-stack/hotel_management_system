import 'package:flutter/material.dart';

class AdminSidebar extends StatelessWidget {
  final String pageName;
  final String role;
  const AdminSidebar({super.key, required this.pageName, this.role = 'admin'});

  @override
  Widget build(BuildContext context) {
    List<Widget> navItems = [];
    // Home is always shown
    navItems.add(
      ListTile(
        leading: const Icon(Icons.home, color: Colors.white),
        title: const Text('Home', style: TextStyle(color: Colors.white)),
        onTap: () {
          if (ModalRoute.of(context)?.settings.name != '/home') {
            Navigator.pushNamed(context, '/home', arguments: role);
          }
        },
      ),
    );

    navItems.add(
    ListTile(
          leading: const Icon(Icons.book_online, color: Colors.white),
          title: const Text('Booking Management', style: TextStyle(color: Colors.white)),
          onTap: () {
            if (ModalRoute.of(context)?.settings.name != '/booking_management') {
              Navigator.pushNamed(context, '/booking_management', arguments: role);
            }
          },
        )
    );

    if (role == 'admin') {
      navItems.addAll([
        
        ListTile(
          leading: const Icon(Icons.meeting_room, color: Colors.white),
          title: const Text('Room Management', style: TextStyle(color: Colors.white)),
          onTap: () {
            if (ModalRoute.of(context)?.settings.name != '/room_management') {
              Navigator.pushNamed(context, '/room_management', arguments: role);
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.people, color: Colors.white),
          title: const Text('Staff Management', style: TextStyle(color: Colors.white)),
          onTap: () {
            if (ModalRoute.of(context)?.settings.name != '/staff_management') {
              Navigator.pushNamed(context, '/staff_management', arguments: role);
            }
          },
        ),
        
      ]);
    }
        // Room Service (for all, but especially for housekeeping)
    if (role == 'housekeeping' || role == 'admin') {
      navItems.add(
        ListTile(
          leading: const Icon(Icons.room_service, color: Colors.white),
          title: const Text('Room Service', style: TextStyle(color: Colors.white)),
          onTap: () {
            if (ModalRoute.of(context)?.settings.name != '/room_service') {
              Navigator.pushNamed(context, '/room_service', arguments: role);
            }
          },
        ),
      );
    }
    // Notifications
    navItems.add(
      ListTile(
        leading: const Icon(Icons.notifications, color: Colors.white),
        title: const Text('Notifications', style: TextStyle(color: Colors.white)),
        onTap: () {
          if (ModalRoute.of(context)?.settings.name != '/notifications') {
            Navigator.pushNamed(context, '/notifications', arguments: role);
          }
        },
      ),
    );
    // Feedback & Reviews
    navItems.add(
      ListTile(
        leading: const Icon(Icons.feedback, color: Colors.white),
        title: const Text('Feedback & Reviews', style: TextStyle(color: Colors.white)),
        onTap: () {
          if (ModalRoute.of(context)?.settings.name != '/feedback') {
            Navigator.pushNamed(context, '/feedback', arguments: role);
          }
        },
      ),
    );
    // Help & Support
    navItems.add(
      ListTile(
        leading: const Icon(Icons.help, color: Colors.white),
        title: const Text('Help & Support', style: TextStyle(color: Colors.white)),
        onTap: () {
          if (ModalRoute.of(context)?.settings.name != '/help_support') {
            Navigator.pushNamed(context, '/help_support', arguments: role);
          }
        },
      ),
    );
    // Removed Staff Training nav item as requested
    // Security Settings
    navItems.add(
      ListTile(
        leading: const Icon(Icons.security, color: Colors.white),
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        onTap: () {
          if (ModalRoute.of(context)?.settings.name != '/security_settings') {
            // Try to get userId from arguments if available, else null
            final args = ModalRoute.of(context)?.settings.arguments;
            int? userId;
            if (args is Map && args['userId'] != null) {
              userId = args['userId'] as int?;
            }
            Navigator.pushNamed(
              context,
              '/security_settings',
              arguments: {'role': role, 'userId': userId},
            );
          }
        },
      ),
    );
    // Reports (admin only)
    if (role == 'admin') {
      navItems.add(
        ListTile(
          leading: const Icon(Icons.bar_chart, color: Colors.white),
          title: const Text('Reports', style: TextStyle(color: Colors.white)),
          onTap: () {
            if (ModalRoute.of(context)?.settings.name != '/reports') {
              Navigator.pushNamed(context, '/reports', arguments: role);
            }
          },
        ),
      );
    }
    navItems.add(const Divider(color: Colors.white70));
    navItems.add(
      ListTile(
        leading: const Icon(Icons.logout, color: Colors.white),
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        onTap: () {
          Navigator.pushReplacementNamed(context, '/');
        },
      ),
    );
    // Housekeeping: only show allowed items
    if (role == 'housekeeping') {
      navItems = navItems.where((item) {
        if (item is ListTile) {
          final title = (item.title as Text).data;
          return [
            'Home',
            'Room Service',
            'Notifications',
            'Feedback & Reviews',
            'Help & Support',
            'Security Settings',
            'Logout',
          ].contains(title);
        }
        return true;
      }).toList();
    }
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      width: 260,
      color: isDark ? Colors.black : Colors.blue,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Text(
              pageName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          ...navItems,
        ],
      ),
    );
  }
}
