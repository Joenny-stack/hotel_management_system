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
    final sidebar = const AdminSidebar(pageName: 'Dashboard');
    if (isWide) {
      return Row(
        children: [
          sidebar,
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
        drawer: Drawer(child: sidebar),
        body: const Center(
          child: Text('Welcome to the Admin Dashboard! Use the menu to navigate.'),
        ),
      );
    }
  }
}
