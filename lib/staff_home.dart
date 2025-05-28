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
              body: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Wrap(
                    spacing: 32,
                    runSpacing: 32,
                    alignment: WrapAlignment.center,
                    children: [
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => Navigator.pushNamed(context, '/booking_management', arguments: role),
                          child: SizedBox(
                            width: 220,
                            height: 140,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.book_online, size: 48, color: Colors.blue),
                                SizedBox(height: 12),
                                Text('Booking Management', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                SizedBox(height: 4),
                                Text('Manage bookings and check-ins', textAlign: TextAlign.center, style: TextStyle(fontSize: 13)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => Navigator.pushNamed(context, '/notifications', arguments: role),
                          child: SizedBox(
                            width: 220,
                            height: 140,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.notifications, size: 48, color: Colors.orange),
                                SizedBox(height: 12),
                                Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                SizedBox(height: 4),
                                Text('View all notifications', textAlign: TextAlign.center, style: TextStyle(fontSize: 13)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => Navigator.pushNamed(context, '/help_support', arguments: role),
                          child: SizedBox(
                            width: 220,
                            height: 140,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.help_outline, size: 48, color: Colors.green),
                                SizedBox(height: 12),
                                Text('Help & Support', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                SizedBox(height: 4),
                                Text('Get help and support', textAlign: TextAlign.center, style: TextStyle(fontSize: 13)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
        body: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Wrap(
              spacing: 32,
              runSpacing: 32,
              alignment: WrapAlignment.center,
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Navigator.pushNamed(context, '/booking_management', arguments: role),
                    child: SizedBox(
                      width: 220,
                      height: 140,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.book_online, size: 48, color: Colors.blue),
                          SizedBox(height: 12),
                          Text('Booking Management', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          SizedBox(height: 4),
                          Text('Manage bookings and check-ins', textAlign: TextAlign.center, style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Navigator.pushNamed(context, '/notifications', arguments: role),
                    child: SizedBox(
                      width: 220,
                      height: 140,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.notifications, size: 48, color: Colors.orange),
                          SizedBox(height: 12),
                          Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          SizedBox(height: 4),
                          Text('View all notifications', textAlign: TextAlign.center, style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Navigator.pushNamed(context, '/help_support', arguments: role),
                    child: SizedBox(
                      width: 220,
                      height: 140,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.help_outline, size: 48, color: Colors.green),
                          SizedBox(height: 12),
                          Text('Help & Support', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          SizedBox(height: 4),
                          Text('Get help and support', textAlign: TextAlign.center, style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
