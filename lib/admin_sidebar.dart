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
    // Room Service (for all, but especially for housekeeping)
    if (role == 'housekeeping' || role == 'admin' || role == 'staff') {
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
    if (role == 'admin') {
      navItems.addAll([
        ListTile(
          leading: const Icon(Icons.people, color: Colors.white),
          title: const Text('Staff Management', style: TextStyle(color: Colors.white)),
          onTap: () {
            if (ModalRoute.of(context)?.settings.name != '/staff_management') {
              Navigator.pushNamed(context, '/staff_management', arguments: role);
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.book_online, color: Colors.white),
          title: const Text('Booking Management', style: TextStyle(color: Colors.white)),
          onTap: () {
            if (ModalRoute.of(context)?.settings.name != '/booking_management') {
              Navigator.pushNamed(context, '/booking_management', arguments: role);
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.meeting_room, color: Colors.white),
          title: const Text('Room Management', style: TextStyle(color: Colors.white)),
          onTap: () {
            if (ModalRoute.of(context)?.settings.name != '/room_management') {
              Navigator.pushNamed(context, '/room_management', arguments: role);
            }
          },
        ),
      ]);
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
    // Staff Training (not for housekeeping)
    if (role == 'admin' || role == 'staff') {
      navItems.add(
        ListTile(
          leading: const Icon(Icons.school, color: Colors.white),
          title: const Text('Staff Training', style: TextStyle(color: Colors.white)),
          onTap: () {
            if (ModalRoute.of(context)?.settings.name != '/staff_training') {
              Navigator.pushNamed(context, '/staff_training', arguments: role);
            }
          },
        ),
      );
    }
    // Security Settings
    navItems.add(
      ListTile(
        leading: const Icon(Icons.security, color: Colors.white),
        title: const Text('Security Settings', style: TextStyle(color: Colors.white)),
        onTap: () {
          if (ModalRoute.of(context)?.settings.name != '/security_settings') {
            Navigator.pushNamed(context, '/security_settings', arguments: role);
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
    return Container(
      width: 260,
      color: Colors.deepPurple,
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
