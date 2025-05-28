import 'package:flutter/material.dart';
import 'admin_sidebar.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    final pageName = 'Help & Support';
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
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.help, size: 64, color: Colors.blue),
                          SizedBox(height: 16),
                          Text(
                            'Frequently Asked Questions',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 24),
                          ExpansionTile(
                            title: Text('How do I make a new booking?'),
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Go to the Booking Management page and select "Add Booking". Fill in the required details and save.'),
                              ),
                            ],
                          ),
                          ExpansionTile(
                            title: Text('How do I check in a guest?'),
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('In Booking Management, find the booking and select "Check In" from the menu. Confirm payment if required.'),
                              ),
                            ],
                          ),
                          ExpansionTile(
                            title: Text('How do I check out a guest?'),
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('In Booking Management, select "Check Out" for the guest. The room will be marked dirty and housekeepers notified.'),
                              ),
                            ],
                          ),
                          ExpansionTile(
                            title: Text('How do I add or edit a guest?'),
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Go to the Guests tab in Booking Management. Use the Add or Edit buttons to manage guest information.'),
                              ),
                            ],
                          ),
                          ExpansionTile(
                            title: Text('How do I manage rooms?'),
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Go to Room Management from the sidebar. You can add, edit, or update room status there.'),
                              ),
                            ],
                          ),
                          ExpansionTile(
                            title: Text('How do I view notifications?'),
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Click on Notifications in the sidebar to see all system alerts and messages.'),
                              ),
                            ],
                          ),
                          ExpansionTile(
                            title: Text('How do I reset my password?'),
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Go to Settings from the sidebar and follow the instructions to change your password.'),
                              ),
                            ],
                          ),
                          ExpansionTile(
                            title: Text('Who do I contact for technical support?'),
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Please contact your system administrator or the IT support team for assistance.'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
        body: Center(
          child: Card(
            elevation: 6,
            margin: const EdgeInsets.all(24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.help, size: 64, color: Colors.blue),
                    SizedBox(height: 16),
                    Text(
                      'Frequently Asked Questions',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),
                    ExpansionTile(
                      title: Text('How do I make a new booking?'),
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Go to the Booking Management page and select "Add Booking". Fill in the required details and save.'),
                        ),
                      ],
                    ),
                    ExpansionTile(
                      title: Text('How do I check in a guest?'),
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('In Booking Management, find the booking and select "Check In" from the menu. Confirm payment if required.'),
                        ),
                      ],
                    ),
                    ExpansionTile(
                      title: Text('How do I check out a guest?'),
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('In Booking Management, select "Check Out" for the guest. The room will be marked dirty and housekeepers notified.'),
                        ),
                      ],
                    ),
                    ExpansionTile(
                      title: Text('How do I add or edit a guest?'),
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Go to the Guests tab in Booking Management. Use the Add or Edit buttons to manage guest information.'),
                        ),
                      ],
                    ),
                    ExpansionTile(
                      title: Text('How do I manage rooms?'),
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Go to Room Management from the sidebar. You can add, edit, or update room status there.'),
                        ),
                      ],
                    ),
                    ExpansionTile(
                      title: Text('How do I view notifications?'),
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Click on Notifications in the sidebar to see all system alerts and messages.'),
                        ),
                      ],
                    ),
                    ExpansionTile(
                      title: Text('How do I reset my password?'),
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Go to Settings from the sidebar and follow the instructions to change your password.'),
                        ),
                      ],
                    ),
                    ExpansionTile(
                      title: Text('Who do I contact for technical support?'),
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Please contact your system administrator or the IT support team for assistance.'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
  }
}
