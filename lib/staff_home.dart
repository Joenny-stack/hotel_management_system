import 'package:flutter/material.dart';
import 'admin_sidebar.dart';

class StaffHomePage extends StatelessWidget {
  const StaffHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    final pageName = 'Staff Dashboard';
    final role = 'staff';
    if (isWide) {
      return Row(
        children: [
          AdminSidebar(pageName: pageName, role: role),
          Container(width: 1, color: Colors.black12),
          Expanded(
            child: Scaffold(
              appBar: AppBar(title: Text(pageName)),
              body: const Center(
                child: Text('Welcome, Staff! Here you can manage bookings, check-ins, and more.'),
              ),
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
        body: const Center(
          child: Text('Welcome, Staff! Here you can manage bookings, check-ins, and more.'),
        ),
      );
    }
  }
}
