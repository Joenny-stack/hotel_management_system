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

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    final pageName = 'Dashboard';
    if (isWide) {
      return Row(
        children: [
          const AdminSidebar(pageName: 'Dashboard'),
          Container(width: 1, color: Colors.black12),
          Expanded(
            child: Scaffold(
              appBar: AppBar(
                title: Text(pageName),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/');
                    },
                  ),
                ],
              ),
              body: const Center(
                child: Text('Welcome to the Admin Dashboard! Use the menu to navigate.'),
              ),
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
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Text(
                  pageName,
                  style: const TextStyle(
                    color: Colors.deepPurple,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text('Staff Management'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const StaffManagementPage()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.book_online),
                title: const Text('Booking Management'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingManagementPage()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.meeting_room),
                title: const Text('Room Management'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const RoomManagementPage()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Notifications'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsPage()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.feedback),
                title: const Text('Feedback & Reviews'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedbackPage()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.help),
                title: const Text('Help & Support'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportPage()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.school),
                title: const Text('Staff Training'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const StaffTrainingPage()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.security),
                title: const Text('Security Settings'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SecuritySettingsPage()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.bar_chart),
                title: const Text('Reports'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsPage()));
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/');
                },
              ),
            ],
          ),
        ),
        body: const Center(
          child: Text('Welcome to the Admin Dashboard! Use the menu to navigate.'),
        ),
      );
    }
  }
}
