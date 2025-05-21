import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'admin_sidebar.dart';
import 'db_helper.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}

class SecuritySettingsPage extends StatefulWidget {
  final String? role;
  final int? userId;
  const SecuritySettingsPage({super.key, this.role, this.userId});

  @override
  State<SecuritySettingsPage> createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends State<SecuritySettingsPage> {
  bool _loading = true;
  bool _obscurePassword = true;
  bool _darkMode = false;
  String? _fullName;
  String? _email;
  String? _username;
  int? _userId;
  String? _role;
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Delay argument access until after build context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      int? userId;
      if (args is Map && args['userId'] != null) {
        userId = args['userId'] as int?;
      } else if (widget.userId != null) {
        userId = widget.userId;
      }
      _fetchUser(userId: userId);
    });
  }

  Future<void> _fetchUser({int? userId}) async {
    final db = await DBHelper.database;
    Map<String, dynamic>? user;
    if (userId != null) {
      final res = await db.query('users', where: 'id = ?', whereArgs: [userId], limit: 1);
      if (res.isNotEmpty) {
        user = res.first;
      } else {
        // fallback: try to get by role if userId not found
        final args = ModalRoute.of(context)?.settings.arguments;
        String? role;
        if (args is Map && args['role'] != null) {
          role = args['role'] as String?;
        } else if (widget.role != null) {
          role = widget.role;
        }
        if (role != null) {
          final resRole = await db.query('users', where: 'role = ?', whereArgs: [role], limit: 1);
          if (resRole.isNotEmpty) user = resRole.first;
        }
      }
    } else {
      // fallback: try to get by role if userId not provided
      final args = ModalRoute.of(context)?.settings.arguments;
      String? role;
      if (args is Map && args['role'] != null) {
        role = args['role'] as String?;
      } else if (widget.role != null) {
        role = widget.role;
      }
      if (role != null) {
        final resRole = await db.query('users', where: 'role = ?', whereArgs: [role], limit: 1);
        if (resRole.isNotEmpty) user = resRole.first;
      } else {
        final res = await db.query('users', limit: 1);
        if (res.isNotEmpty) user = res.first;
      }
    }
    setState(() {
      _userId = user?['id'];
      _fullName = user?['full_name'];
      _email = user?['email'];
      _username = user?['username'];
      _role = user?['role'];
      _loading = false;
    });
  }

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate() || _userId == null) return;
    final db = await DBHelper.database;
    await db.update('users', {'password': _passwordController.text}, where: 'id = ?', whereArgs: [_userId]);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password updated!'), backgroundColor: Colors.green));
      _passwordController.clear();
    }
  }

  void _toggleTheme(bool value) {
    setState(() {
      _darkMode = value;
    });
    // Use Provider to update the app's theme
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.setThemeMode(_darkMode ? ThemeMode.dark : ThemeMode.light);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_darkMode ? 'Dark mode enabled' : 'Light mode enabled')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    final pageName = 'Settings';
    // Accept arguments as a map for userId and role
    final args = ModalRoute.of(context)?.settings.arguments;
    String? role;
    int? userId;
    if (args is Map) {
      role = args['role'] as String?;
      userId = args['userId'] as int?;
    } else {
      role = _role ?? widget.role ?? 'admin';
      userId = _userId;
    }
    final sidebar = AdminSidebar(pageName: pageName, role: role ?? 'admin');
    final profileSection = _loading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('User Profile', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                Text('Full Name: ${_fullName ?? ''}'),
                Text('Email: ${_email ?? ''}'),
                Text('Username: ${_username ?? ''}'),
                Text('Role: ${role ?? ''}'),
                const Divider(height: 32),
                Text('Update Password', style: Theme.of(context).textTheme.titleMedium),
                Form(
                  key: _formKey,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'New Password',
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          validator: (v) => (v == null || v.length < 4) ? 'Min 4 chars' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _updatePassword,
                        child: const Text('Update'),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 32),
                Row(
                  children: [
                    const Text('Dark Mode'),
                    Switch(
                      value: _darkMode,
                      onChanged: _toggleTheme,
                    ),
                  ],
                ),
              ],
            ),
          );
    if (isWide) {
      return Row(
        children: [
          sidebar,
          Container(width: 1, color: Colors.black12),
          Expanded(
            child: Scaffold(
              appBar: AppBar(title: Text(pageName)),
              body: profileSection,
            ),
          ),
        ],
      );
    } else {
      return Scaffold(
        appBar: AppBar(title: Text(pageName)),
        drawer: Drawer(child: sidebar),
        body: profileSection,
      );
    }
  }
}
