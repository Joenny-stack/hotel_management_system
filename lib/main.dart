import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';
import 'admin_home.dart';
import 'staff_home.dart';
import 'booking_management_page.dart';
import 'room_management_page.dart';
import 'notifications_page.dart';
import 'feedback_page.dart';
import 'help_support_page.dart';
import 'staff_management_page.dart';
import 'staff_training_page.dart';
import 'security_settings_page.dart';
import 'reports_page.dart';
import 'housekeeping_home.dart';
import 'room_service_page.dart';
import 'security_settings_page.dart' show ThemeProvider;

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      darkTheme: ThemeData.dark(),
      themeMode: themeProvider.themeMode,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) {
          final role = ModalRoute.of(context)?.settings.arguments as String?;
          if (role == 'admin') {
            return const AdminHomePage();
          } else if (role == 'staff') {
            return const StaffHomePage();
          } else if (role == 'housekeeping') {
            return const HousekeepingHomePage();
          } else {
            return const MyHomePage(title: 'Flutter Demo Home Page');
          }
        },
        '/booking_management': (context) => BookingManagementPage(),
        '/room_management': (context) => RoomManagementPage(),
        '/notifications': (context) => NotificationsPage(),
        '/feedback': (context) => FeedbackPage(),
        '/help_support': (context) => HelpSupportPage(),
        '/staff_management': (context) => StaffManagementPage(),
        '/staff_training': (context) => StaffTrainingPage(),
        '/security_settings': (context) => SecuritySettingsPage(),
        '/reports': (context) => ReportsPage(),
        '/room_service': (context) => RoomServicePage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
