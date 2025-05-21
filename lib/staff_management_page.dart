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
  String _search = '';

  @override
  void initState() {
    super.initState();
    _fetchStaff();
  }

  Future<void> _fetchStaff() async {
    final db = await DBHelper.database;
    final res = await db.query('users', where: "role = ? OR role = ? OR role = ?", whereArgs: ['staff', 'admin', 'housekeeping']);
    setState(() {
      _staffList = res.map((e) => User.fromMap(e)).toList();
      _isLoading = false;
    });
  }

  Future<void> _deleteStaff(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this staff member?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final db = await DBHelper.database;
      await db.delete('users', where: 'id = ?', whereArgs: [id]);
      _fetchStaff();
    }
  }

  void _showAddOrEditStaffDialog({User? staff}) {
    final usernameController = TextEditingController(text: staff?.username ?? '');
    final passwordController = TextEditingController();
    final fullNameController = TextEditingController(text: staff?.fullName ?? '');
    final emailController = TextEditingController(text: staff?.email ?? '');
    String role = staff?.role ?? 'staff';
    final _formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(staff == null ? 'Add Staff' : 'Edit Staff'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: usernameController,
                    decoration: const InputDecoration(labelText: 'Username'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Username required' : null,
                  ),
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(labelText: staff == null ? 'Password' : 'New Password (leave blank to keep)'),
                    obscureText: true,
                    validator: (v) => staff == null && (v == null || v.isEmpty) ? 'Password required' : null,
                  ),
                  DropdownButtonFormField<String>(
                    value: role,
                    decoration: const InputDecoration(labelText: 'Role'),
                    items: const [
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                      DropdownMenuItem(value: 'staff', child: Text('Staff')),
                      DropdownMenuItem(value: 'housekeeping', child: Text('Housekeeping')),
                    ],
                    onChanged: (v) => role = v ?? 'staff',
                  ),
                  TextFormField(
                    controller: fullNameController,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                  ),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState?.validate() ?? false) {
                final db = await DBHelper.database;
                final data = {
                  'username': usernameController.text,
                  'role': role,
                  'full_name': fullNameController.text,
                  'email': emailController.text,
                };
                if (passwordController.text.isNotEmpty) {
                  data['password'] = passwordController.text;
                }
                if (staff == null) {
                  if (passwordController.text.isEmpty) return;
                  data['password'] = passwordController.text;
                  await db.insert('users', data);
                } else {
                  await db.update('users', data, where: 'id = ?', whereArgs: [staff.id]);
                }
                if (mounted) {
                  Navigator.pop(context);
                  _fetchStaff();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(staff == null ? 'Staff added!' : 'Staff updated!'), backgroundColor: Colors.green),
                  );
                }
              }
            },
            child: Text(staff == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  List<User> get _filteredStaffList {
    if (_search.isEmpty) return _staffList;
    return _staffList.where((u) =>
      u.username.toLowerCase().contains(_search.toLowerCase()) ||
      (u.fullName ?? '').toLowerCase().contains(_search.toLowerCase()) ||
      (u.email ?? '').toLowerCase().contains(_search.toLowerCase()) ||
      u.role.toLowerCase().contains(_search.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    final pageName = 'Staff Management';
    final role = ModalRoute.of(context)?.settings.arguments as String? ?? 'admin';
    final searchBar = Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: const InputDecoration(
          labelText: 'Search staff by username, name, email, or role',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
        onChanged: (v) => setState(() => _search = v),
      ),
    );
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
                        searchBar,
                        Expanded(
                          child: ListView.builder(
                            itemCount: _filteredStaffList.length,
                            itemBuilder: (context, index) {
                              final staff = _filteredStaffList[index];
                              return ListTile(
                                title: Text(staff.username),
                                subtitle: Text('${staff.fullName ?? ''}\n${staff.email ?? ''}\nRole: ${staff.role}'),
                                isThreeLine: true,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () => _showAddOrEditStaffDialog(staff: staff),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteStaff(staff.id!),
                                    ),
                                  ],
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
                            onPressed: () => _showAddOrEditStaffDialog(),
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
                  searchBar,
                  Expanded(
                    child: ListView.builder(
                      itemCount: _filteredStaffList.length,
                      itemBuilder: (context, index) {
                        final staff = _filteredStaffList[index];
                        return ListTile(
                          title: Text(staff.username),
                          subtitle: Text('${staff.fullName ?? ''}\n${staff.email ?? ''}\nRole: ${staff.role}'),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _showAddOrEditStaffDialog(staff: staff),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteStaff(staff.id!),
                              ),
                            ],
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
                      onPressed: () => _showAddOrEditStaffDialog(),
                    ),
                  ),
                ],
              ),
      );
    }
  }
}
