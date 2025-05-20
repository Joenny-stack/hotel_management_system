import 'package:flutter/material.dart';
import 'admin_sidebar.dart';

class RoomServicePage extends StatelessWidget {
  const RoomServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    final pageName = 'Room Service';
    final role = ModalRoute.of(context)?.settings.arguments as String? ?? 'housekeeping';
    if (isWide) {
      return Row(
        children: [
          AdminSidebar(pageName: pageName, role: role),
          Container(width: 1, color: Colors.black12),
          Expanded(
            child: Scaffold(
              appBar: AppBar(title: Text(pageName)),
              body: const Center(
                child: Text('Room service management features coming soon!'),
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
          child: Text('Room service management features coming soon!'),
        ),
      );
    }
  }
}
