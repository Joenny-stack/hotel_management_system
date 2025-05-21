import 'package:flutter/material.dart';
import 'admin_sidebar.dart';
import 'db_helper.dart';

class RoomServicePage extends StatefulWidget {
  const RoomServicePage({super.key});

  @override
  State<RoomServicePage> createState() => _RoomServicePageState();
}

class _RoomServicePageState extends State<RoomServicePage> with SingleTickerProviderStateMixin {
  List<Room> _rooms = [];
  bool _loading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchRooms();
  }

  Future<void> _fetchRooms() async {
    setState(() => _loading = true);
    final rooms = await DBHelper.getRooms();
    setState(() {
      _rooms = rooms;
      _loading = false;
    });
  }

  Future<void> _updateRoomStatus(Room room, String newStatus) async {
    final updated = Room(
      id: room.id,
      roomNumber: room.roomNumber,
      type: room.type,
      status: room.status,
      pricePerNight: room.pricePerNight,
      imagePath: room.imagePath,
      housekeepingStatus: newStatus,
      roomClass: room.roomClass,
    );
    await DBHelper.updateRoom(updated);
    _fetchRooms();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Room ${room.roomNumber} marked as $newStatus.'), backgroundColor: Colors.green),
      );
    }
  }

  Widget _buildRoomList(List<Room> rooms, String status) {
    final filtered = rooms.where((r) => (r.housekeepingStatus ?? 'clean') == status).toList();
    if (filtered.isEmpty) {
      return const Center(child: Text('No rooms.'));
    }
    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final room = filtered[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            leading: const Icon(Icons.meeting_room, size: 40),
            title: Text('Room ${room.roomNumber} - ${room.type}'),
            subtitle: Text('Status: ${room.status}\nHousekeeping: ${room.housekeepingStatus ?? 'clean'}'),
            trailing: status == 'dirty'
                ? ElevatedButton(
                    child: const Text('Mark Clean'),
                    onPressed: () => _updateRoomStatus(room, 'clean'),
                  )
                : null,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    final pageName = 'Room Service';
    final role = ModalRoute.of(context)?.settings.arguments as String? ?? 'housekeeping';
    final sidebar = AdminSidebar(pageName: pageName, role: role);
    final tabs = TabBar(
      controller: _tabController,
      tabs: const [
        Tab(text: 'Dirty', icon: Icon(Icons.warning, color: Colors.red)),
        Tab(text: 'Clean', icon: Icon(Icons.check_circle, color: Colors.green)),
        Tab(text: 'Under Maintenance', icon: Icon(Icons.build, color: Colors.orange)),
      ],
    );
    final tabViews = TabBarView(
      controller: _tabController,
      children: [
        _loading ? const Center(child: CircularProgressIndicator()) : _buildRoomList(_rooms, 'dirty'),
        _loading ? const Center(child: CircularProgressIndicator()) : _buildRoomList(_rooms, 'clean'),
        _loading ? const Center(child: CircularProgressIndicator()) : _buildRoomList(_rooms, 'in progress'),
      ],
    );
    if (isWide) {
      return Row(
        children: [
          sidebar,
          Container(width: 1, color: Colors.black12),
          Expanded(
            child: Scaffold(
              appBar: AppBar(title: Text(pageName), bottom: tabs),
              body: tabViews,
            ),
          ),
        ],
      );
    } else {
      return Scaffold(
        appBar: AppBar(title: Text(pageName), bottom: tabs),
        drawer: Drawer(child: sidebar),
        body: tabViews,
      );
    }
  }
}
