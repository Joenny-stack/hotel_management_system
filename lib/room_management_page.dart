import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'admin_sidebar.dart';

class RoomManagementPage extends StatefulWidget {
  const RoomManagementPage({super.key});

  @override
  State<RoomManagementPage> createState() => _RoomManagementPageState();
}

class _RoomManagementPageState extends State<RoomManagementPage> {
  List<Room> _rooms = [];
  bool _loading = true;

  // Search and filter state
  String _searchQuery = '';
  String? _statusFilter;
  String? _typeFilter;
  String? _housekeepingFilter;
  String? _classFilter;

  @override
  void initState() {
    super.initState();
    _fetchRooms();
  }

  Future<void> _fetchRooms() async {
    final rooms = await DBHelper.getRooms();
    setState(() {
      _rooms = rooms;
      _loading = false;
    });
  }

  List<Room> get _filteredRooms {
    return _rooms.where((room) {
      final matchesSearch = _searchQuery.isEmpty ||
          room.roomNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          room.type.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _statusFilter == null || room.status == _statusFilter;
      final matchesType = _typeFilter == null || room.type == _typeFilter;
      final matchesHousekeeping = _housekeepingFilter == null || (room.housekeepingStatus ?? 'clean') == _housekeepingFilter;
      final matchesClass = _classFilter == null || (room.roomClass ?? 'Budget') == _classFilter;
      return matchesSearch && matchesStatus && matchesType && matchesHousekeeping && matchesClass;
    }).toList();
  }

  void _showRoomDialog({Room? room}) {
    final roomNumberController = TextEditingController(text: room?.roomNumber ?? '');
    final typeController = TextEditingController(text: room?.type ?? '');
    final statusController = TextEditingController(text: room?.status ?? 'available');
    final priceController = TextEditingController(text: room?.pricePerNight.toString() ?? '');
    final imagePathController = TextEditingController(text: room?.imagePath ?? '');
    final housekeepingStatusController = TextEditingController(text: room?.housekeepingStatus ?? 'clean');
    final roomClassController = TextEditingController(text: room?.roomClass ?? '');
    final typeValue = typeController.text.isNotEmpty ? typeController.text : 'Single';
    final statusValue = statusController.text.isNotEmpty ? statusController.text : 'available';
    final roomClassValue = roomClassController.text.isNotEmpty ? roomClassController.text : 'Budget';

    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(room == null ? 'Add Room' : 'Edit Room'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: roomNumberController,
                    decoration: const InputDecoration(labelText: 'Room Number'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Room number is required';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: typeValue,
                    decoration: const InputDecoration(labelText: 'Type'),
                    items: const [
                      DropdownMenuItem(value: 'Single', child: Text('Single')),
                      DropdownMenuItem(value: 'Double', child: Text('Double')),
                      DropdownMenuItem(value: 'Suite', child: Text('Suite')),
                    ],
                    onChanged: (value) {
                      typeController.text = value ?? 'Single';
                    },
                    validator: (value) => value == null || value.isEmpty ? 'Type is required' : null,
                  ),
                  DropdownButtonFormField<String>(
                    value: statusValue,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: const [
                      DropdownMenuItem(value: 'available', child: Text('Available')),
                      DropdownMenuItem(value: 'occupied', child: Text('Occupied')),
                      DropdownMenuItem(value: 'maintenance', child: Text('Maintenance')),
                    ],
                    onChanged: (value) {
                      statusController.text = value ?? 'available';
                    },
                    validator: (value) => value == null || value.isEmpty ? 'Status is required' : null,
                  ),
                  TextFormField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: 'Price per Night',
                      prefixText: '\$ ',
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Price is required';
                      }
                      final price = double.tryParse(value);
                      if (price == null || price < 0) {
                        return 'Enter a valid price';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: imagePathController,
                    decoration: const InputDecoration(labelText: 'Image Path (optional)'),
                  ),
                  DropdownButtonFormField<String>(
                    value: housekeepingStatusController.text.isNotEmpty ? housekeepingStatusController.text : 'clean',
                    decoration: const InputDecoration(labelText: 'Housekeeping Status'),
                    items: const [
                      DropdownMenuItem(value: 'clean', child: Text('Clean')),
                      DropdownMenuItem(value: 'dirty', child: Text('Dirty')),
                      DropdownMenuItem(value: 'in progress', child: Text('In Progress')),
                    ],
                    onChanged: (value) {
                      housekeepingStatusController.text = value ?? 'clean';
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: roomClassValue,
                    decoration: const InputDecoration(labelText: 'Room Class'),
                    items: const [
                      DropdownMenuItem(value: 'Budget', child: Text('Budget')),
                      DropdownMenuItem(value: 'Executive', child: Text('Executive')),
                      DropdownMenuItem(value: 'Presidential', child: Text('Presidential')),
                    ],
                    onChanged: (value) {
                      roomClassController.text = value ?? 'Budget';
                    },
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
                final roomData = Room(
                  id: room?.id,
                  roomNumber: roomNumberController.text,
                  type: typeController.text,
                  status: statusController.text,
                  pricePerNight: double.tryParse(priceController.text) ?? 0.0,
                  imagePath: imagePathController.text.isNotEmpty ? imagePathController.text : null,
                  housekeepingStatus: housekeepingStatusController.text.isNotEmpty ? housekeepingStatusController.text : 'clean',
                  roomClass: roomClassController.text.isNotEmpty ? roomClassController.text : null,
                );
                if (room == null) {
                  await DBHelper.insertRoom(roomData);
                } else {
                  await DBHelper.updateRoom(roomData);
                }
                if (mounted) {
                  Navigator.pop(context);
                  _fetchRooms();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(room == null ? 'Room added successfully!' : 'Room updated successfully!'),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: Text(room == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteRoom(int id) async {
    await DBHelper.deleteRoom(id);
    _fetchRooms();
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Search by Room Number or Type',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              DropdownButton<String>(
                value: _statusFilter,
                hint: const Text('Status'),
                items: const [
                  DropdownMenuItem(value: null, child: Text('All Statuses')),
                  DropdownMenuItem(value: 'available', child: Text('Available')),
                  DropdownMenuItem(value: 'occupied', child: Text('Occupied')),
                  DropdownMenuItem(value: 'maintenance', child: Text('Maintenance')),
                ],
                onChanged: (value) => setState(() => _statusFilter = value),
              ),
              DropdownButton<String>(
                value: _typeFilter,
                hint: const Text('Type'),
                items: const [
                  DropdownMenuItem(value: null, child: Text('All Types')),
                  DropdownMenuItem(value: 'Single', child: Text('Single')),
                  DropdownMenuItem(value: 'Double', child: Text('Double')),
                  DropdownMenuItem(value: 'Suite', child: Text('Suite')),
                ],
                onChanged: (value) => setState(() => _typeFilter = value),
              ),
              DropdownButton<String>(
                value: _housekeepingFilter,
                hint: const Text('Housekeeping'),
                items: const [
                  DropdownMenuItem(value: null, child: Text('All Housekeeping')),
                  DropdownMenuItem(value: 'clean', child: Text('Clean')),
                  DropdownMenuItem(value: 'dirty', child: Text('Dirty')),
                  DropdownMenuItem(value: 'in progress', child: Text('In Progress')),
                ],
                onChanged: (value) => setState(() => _housekeepingFilter = value),
              ),
              DropdownButton<String>(
                value: _classFilter,
                hint: const Text('Room Class'),
                items: const [
                  DropdownMenuItem(value: null, child: Text('All Classes')),
                  DropdownMenuItem(value: 'Budget', child: Text('Budget')),
                  DropdownMenuItem(value: 'Executive', child: Text('Executive')),
                  DropdownMenuItem(value: 'Presidential', child: Text('Presidential')),
                ],
                onChanged: (value) => setState(() => _classFilter = value),
              ),
              TextButton(
                onPressed: () => setState(() {
                  _searchQuery = '';
                  _statusFilter = null;
                  _typeFilter = null;
                  _housekeepingFilter = null;
                  _classFilter = null;
                }),
                child: const Text('Clear Filters'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    final pageName = 'Room Management';
    final role = ModalRoute.of(context)?.settings.arguments as String? ?? 'admin';
    final sidebar = AdminSidebar(pageName: pageName, role: role);
    final roomList = _loading
        ? const Center(child: CircularProgressIndicator())
        : _filteredRooms.isEmpty
            ? const Center(child: Text('No rooms found.'))
            : ListView.builder(
                itemCount: _filteredRooms.length,
                itemBuilder: (context, index) {
                  final room = _filteredRooms[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: room.imagePath != null && room.imagePath!.isNotEmpty
                          ? Image.network(room.imagePath!, width: 56, height: 56, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.meeting_room, size: 40))
                          : const Icon(Icons.meeting_room, size: 40),
                      title: Text('Room ${room.roomNumber} - ${room.type}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Status: ${room.status}'),
                          Text('Price: \$${room.pricePerNight.toStringAsFixed(2)}'),
                          if (room.housekeepingStatus != null) Text('Housekeeping: ${room.housekeepingStatus}'),
                          if (room.roomClass != null) Text('Room Class: ${room.roomClass}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.indigo),
                            onPressed: () => _showRoomDialog(room: room),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Room'),
                                  content: const Text('Are you sure you want to delete this room? This action cannot be undone.'),
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
                              if (confirmed == true) {
                                _deleteRoom(room.id!);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
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
                    icon: const Icon(Icons.add),
                    tooltip: 'Add Room',
                    onPressed: () => _showRoomDialog(),
                  ),
                ],
              ),
              body: Column(
                children: [
                  _buildFilters(),
                  Expanded(child: roomList),
                ],
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
              icon: const Icon(Icons.add),
              tooltip: 'Add Room',
              onPressed: () => _showRoomDialog(),
            ),
          ],
        ),
        drawer: Drawer(child: sidebar),
        body: Column(
          children: [
            _buildFilters(),
            Expanded(child: roomList),
          ],
        ),
      );
    }
  }
}
