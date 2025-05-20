import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'admin_sidebar.dart';

class StaffManagementPage extends StatefulWidget {
  const StaffManagementPage({super.key});

  @override
  State<StaffManagementPage> createState() => _StaffManagementPageState();
}

class _StaffManagementPageState extends State<StaffManagementPage> {
  List<User> _staffList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStaff();
  }

  Future<void> _fetchStaff() async {
    final db = await DBHelper.database;
    final res = await db.query('users', where: 'role = ?', whereArgs: ['staff']);
    setState(() {
      _staffList = res.map((e) => User.fromMap(e)).toList();
      _isLoading = false;
    });
  }

  Future<void> _addStaff(String username, String password) async {
    final db = await DBHelper.database;
    await db.insert('users', {
      'username': username,
      'password': password,
      'role': 'staff',
    });
    _fetchStaff();
  }

  Future<void> _deleteStaff(int id) async {
    final db = await DBHelper.database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
    _fetchStaff();
  }

  void _showAddStaffDialog() {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Staff'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (usernameController.text.isNotEmpty && passwordController.text.isNotEmpty) {
                await _addStaff(usernameController.text, passwordController.text);
                if (!context.mounted) return;
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    final pageName = 'Staff Management';
    final role = ModalRoute.of(context)?.settings.arguments as String? ?? 'admin';
    if (isWide) {
      return Row(
        children: [
          AdminSidebar(pageName: pageName, role: role),
          Container(width: 1, color: Colors.black12),
          Expanded(
            child: Scaffold(
              appBar: AppBar(title: Text(pageName)),
              body: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: _staffList.length,
                            itemBuilder: (context, index) {
                              final staff = _staffList[index];
                              return ListTile(
                                title: Text(staff.username),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteStaff(staff.id!),
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('Add Staff'),
                            onPressed: _showAddStaffDialog,
                          ),
                        ),
                      ],
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
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: _staffList.length,
                      itemBuilder: (context, index) {
                        final staff = _staffList[index];
                        return ListTile(
                          title: Text(staff.username),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteStaff(staff.id!),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add Staff'),
                      onPressed: _showAddStaffDialog,
                    ),
                  ),
                ],
              ),
      );
    }
  }
}
