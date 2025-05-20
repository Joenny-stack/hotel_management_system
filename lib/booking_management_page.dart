import 'package:flutter/material.dart';
import 'admin_sidebar.dart';
import 'db_helper.dart';

class BookingManagementPage extends StatefulWidget {
  const BookingManagementPage({super.key});

  @override
  State<BookingManagementPage> createState() => _BookingManagementPageState();
}

class _BookingManagementPageState extends State<BookingManagementPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    final pageName = 'Booking Management';
    final role = ModalRoute.of(context)?.settings.arguments as String? ?? 'admin';
    final sidebar = AdminSidebar(pageName: pageName, role: role);

    final tabBar = TabBar(
      controller: _tabController,
      tabs: const [
        Tab(text: 'Current Bookings', icon: Icon(Icons.event_available)),
        Tab(text: 'Add Booking', icon: Icon(Icons.add_box)),
        Tab(text: 'Guests', icon: Icon(Icons.people)),
        Tab(text: 'Booking History', icon: Icon(Icons.history)),
      ],
    );

    final tabViews = TabBarView(
      controller: _tabController,
      children: [
        // --- Current Bookings Tab ---
        _CurrentBookingsTab(),
        // --- Add Booking Tab ---
        _AddBookingTab(onBookingAdded: () => _tabController.animateTo(0)),
        // --- Guests Tab ---
        _GuestsTab(),
        // --- Booking History Tab ---
        _BookingHistoryTab(),
      ],
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
                bottom: tabBar,
              ),
              body: tabViews,
            ),
          ),
        ],
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(pageName),
          bottom: tabBar,
        ),
        drawer: Drawer(child: sidebar),
        body: tabViews,
      );
    }
  }
}

// --- Current Bookings Tab ---
class _CurrentBookingsTab extends StatefulWidget {
  @override
  State<_CurrentBookingsTab> createState() => _CurrentBookingsTabState();
}

class _CurrentBookingsTabState extends State<_CurrentBookingsTab> {
  List<Booking> _bookings = [];
  List<Guest> _guests = [];
  List<Room> _rooms = [];
  String _search = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    setState(() => _loading = true);
    final bookings = await BookingDB.getBookings();
    final guests = await GuestDB.getGuests();
    final rooms = await DBHelper.getRooms();
    setState(() {
      _bookings = bookings;
      _guests = guests;
      _rooms = rooms;
      _loading = false;
    });
  }

  List<Booking> get _filteredBookings {
    if (_search.isEmpty) return _bookings;
    return _bookings.where((b) {
      final guest = _guests.firstWhere((g) => g.id == b.guestId, orElse: () => Guest(fullName: '', phone: '', email: '', idNumber: '', preferences: '', notes: ''));
      final room = _rooms.firstWhere((r) => r.id == b.roomId, orElse: () => Room(id: 0, roomNumber: '', type: '', pricePerNight: 0, status: '', roomClass: ''));
      return guest.fullName.toLowerCase().contains(_search.toLowerCase()) ||
        room.roomNumber.toLowerCase().contains(_search.toLowerCase()) ||
        b.bookingStatus.toLowerCase().contains(_search.toLowerCase()) ||
        b.checkInDate.contains(_search) ||
        b.checkOutDate.contains(_search);
    }).toList();
  }

  String _getGuestName(int? guestId) {
    final guest = _guests.firstWhere((g) => g.id == guestId, orElse: () => Guest(fullName: 'Unknown', phone: '', email: '', idNumber: '', preferences: '', notes: ''));
    return guest.fullName;
  }

  String _getRoomDisplay(int? roomId) {
    final room = _rooms.firstWhere((r) => r.id == roomId, orElse: () => Room(id: 0, roomNumber: 'Unknown', type: '', pricePerNight: 0, status: '', roomClass: ''));
    return 'Room ${room.roomNumber} - ${room.type}${room.roomClass != null && room.roomClass!.isNotEmpty ? ' (${room.roomClass})' : ''}';
  }

  void _handleAction(String action, Booking booking) async {
    if (action == 'edit') {
      _showEditBookingDialog(booking);
    } else if (action == 'checkin') {
      _showCheckInDialog(booking);
    } else if (action == 'checkout') {
      await BookingDB.updateBooking(booking.copyWith(bookingStatus: 'checked_out'));
      await BookingDB.insertBookingHistory(booking.copyWith(bookingStatus: 'checked_out'));
      _fetchAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Checked out!'), backgroundColor: Colors.green));
      }
    } else if (action == 'cancel') {
      await BookingDB.deleteBooking(booking.id!);
      await BookingDB.insertBookingHistory(booking.copyWith(bookingStatus: 'cancelled'));
      _fetchAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking cancelled.'), backgroundColor: Colors.red));
      }
    }
  }

  void _showCheckInDialog(Booking booking) {
    final isPaid = (booking.paymentStatus ?? '').toLowerCase() == 'paid';
    if (isPaid) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Check-In'),
          content: const SizedBox(
            width: 400,
            child: Text('Are you sure you want to check in this booking?'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await BookingDB.updateBooking(
                  booking.copyWith(
                    bookingStatus: 'checked_in',
                    paymentStatus: 'paid',
                  ),
                );
                Navigator.pop(context);
                _fetchAll();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Checked in!'), backgroundColor: Colors.green));
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        ),
      );
      return;
    }
    // Not paid: use ValueNotifier for checkbox and button state
    final paymentConfirmedNotifier = ValueNotifier<bool>(false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Check-In'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Has the guest paid?'),
              Row(
                children: [
                  ValueListenableBuilder<bool>(
                    valueListenable: paymentConfirmedNotifier,
                    builder: (context, paymentConfirmed, _) => Checkbox(
                      value: paymentConfirmed,
                      onChanged: (v) => paymentConfirmedNotifier.value = v ?? false,
                    ),
                  ),
                  const Text('Payment received'),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: paymentConfirmedNotifier,
            builder: (context, paymentConfirmed, _) => ElevatedButton(
              onPressed: paymentConfirmed
                  ? () async {
                      await BookingDB.updateBooking(
                        booking.copyWith(
                          bookingStatus: 'checked_in',
                          paymentStatus: 'paid',
                        ),
                      );
                      Navigator.pop(context);
                      _fetchAll();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Checked in!'), backgroundColor: Colors.green));
                      }
                    }
                  : null,
              child: const Text('Confirm'),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditBookingDialog(Booking booking) async {
    final statusOptions = [
      'pending', 'confirmed', 'checked_in', 'checked_out', 'cancelled', 'no_show'
    ];
    String status = booking.bookingStatus;
    String payment = booking.paymentStatus ?? 'unpaid';
    final notesController = TextEditingController(text: booking.notes ?? '');

    // Fetch rooms and guests for dropdowns
    final allRooms = await DBHelper.getRooms();
    final currentRoom = allRooms.firstWhere((r) => r.id == booking.roomId, orElse: () => allRooms.first);
    final availableRooms = allRooms.where((r) => r.status == 'available' || r.id == booking.roomId).toList();
    int selectedRoomId = booking.roomId!;

    DateTime checkInDate = DateTime.parse(booking.checkInDate);
    DateTime checkOutDate = DateTime.parse(booking.checkOutDate);

    Future<void> pickCheckInDate(BuildContext context, void Function(DateTime) onPicked) async {
      final picked = await showDatePicker(
        context: context,
        initialDate: checkInDate,
        firstDate: DateTime.now().subtract(const Duration(days: 1)),
        lastDate: DateTime.now().add(const Duration(days: 366)),
      );
      if (picked != null) onPicked(picked);
    }
    Future<void> pickCheckOutDate(BuildContext context, void Function(DateTime) onPicked) async {
      final picked = await showDatePicker(
        context: context,
        initialDate: checkOutDate,
        firstDate: checkInDate.add(const Duration(days: 1)),
        lastDate: DateTime.now().add(const Duration(days: 367)),
      );
      if (picked != null) onPicked(picked);
    }

    showDialog(
      context: context,
      builder: (context) {
        String? errorText;
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Edit Booking'),
            content: SizedBox(
              width: 400,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      value: selectedRoomId,
                      decoration: const InputDecoration(labelText: 'Room'),
                      items: availableRooms.map((room) => DropdownMenuItem(
                        value: room.id,
                        child: Text('Room ${room.roomNumber} - ${room.type}${room.roomClass != null && room.roomClass!.isNotEmpty ? ' (${room.roomClass})' : ''}'),
                      )).toList(),
                      onChanged: (v) => setState(() => selectedRoomId = v ?? selectedRoomId),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              await pickCheckInDate(context, (picked) {
                                setState(() {
                                  checkInDate = picked;
                                  if (!checkOutDate.isAfter(checkInDate)) {
                                    checkOutDate = checkInDate.add(const Duration(days: 1));
                                  }
                                });
                              });
                            },
                            child: AbsorbPointer(
                              child: TextFormField(
                                decoration: const InputDecoration(labelText: 'Check-in Date'),
                                controller: TextEditingController(text: checkInDate.toIso8601String().substring(0, 10)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              await pickCheckOutDate(context, (picked) {
                                setState(() => checkOutDate = picked);
                              });
                            },
                            child: AbsorbPointer(
                              child: TextFormField(
                                decoration: const InputDecoration(labelText: 'Check-out Date'),
                                controller: TextEditingController(text: checkOutDate.toIso8601String().substring(0, 10)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: status,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: statusOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (v) => setState(() => status = v ?? status),
                    ),
                    DropdownButtonFormField<String>(
                      value: payment,
                      decoration: const InputDecoration(labelText: 'Payment Status'),
                      items: const [
                        DropdownMenuItem(value: 'unpaid', child: Text('Unpaid')),
                        DropdownMenuItem(value: 'paid', child: Text('Paid')),
                        DropdownMenuItem(value: 'refunded', child: Text('Refunded')),
                      ],
                      onChanged: (v) => setState(() => payment = v ?? payment),
                    ),
                    TextFormField(
                      controller: notesController,
                      decoration: const InputDecoration(labelText: 'Notes'),
                    ),
                    if (errorText != null) ...[
                      const SizedBox(height: 8),
                      Text(errorText ?? '', style: const TextStyle(color: Colors.red)),
                    ],
                  ],
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
                  // Validation: check-out after check-in
                  if (!checkOutDate.isAfter(checkInDate)) {
                    setState(() => errorText = 'Check-out must be after check-in.');
                    return;
                  }
                  // Check for room double-booking (ignore this booking's own id)
                  final overlapping = await BookingDB.getBookingsForRoomInRange(
                    selectedRoomId,
                    checkInDate.toIso8601String().substring(0, 10),
                    checkOutDate.toIso8601String().substring(0, 10),
                    excludeBookingId: booking.id,
                  );
                  if (overlapping.isNotEmpty) {
                    setState(() => errorText = 'Room is already booked for these dates.');
                    return;
                  }
                  await BookingDB.updateBooking(
                    booking.copyWith(
                      roomId: selectedRoomId,
                      checkInDate: checkInDate.toIso8601String().substring(0, 10),
                      checkOutDate: checkOutDate.toIso8601String().substring(0, 10),
                      bookingStatus: status,
                      paymentStatus: payment,
                      notes: notesController.text,
                    ),
                  );
                  Navigator.pop(context);
                  _fetchAll();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking updated!'), backgroundColor: Colors.green));
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search by guest, room, or status',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => setState(() => _search = v),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
                onPressed: _fetchAll,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredBookings.isEmpty
                    ? const Center(child: Text('No bookings found.'))
                    : ListView.builder(
                        itemCount: _filteredBookings.length,
                        itemBuilder: (context, index) {
                          final booking = _filteredBookings[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              leading: const Icon(Icons.hotel, size: 36, color: Colors.deepPurple),
                              title: Text(_getGuestName(booking.guestId)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_getRoomDisplay(booking.roomId)),
                                  Text('Check-in: ${booking.checkInDate}'),
                                  Text('Check-out: ${booking.checkOutDate}'),
                                  Text('Status: ${booking.bookingStatus}'),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) => _handleAction(value, booking),
                                itemBuilder: (context) {
                                  if (booking.bookingStatus == 'checked_in') {
                                    return [
                                      const PopupMenuItem(value: 'checkout', child: Text('Check Out')),
                                    ];
                                  } else {
                                    return [
                                      const PopupMenuItem(value: 'checkin', child: Text('Check In')),
                                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                      const PopupMenuItem(value: 'cancel', child: Text('Cancel')),
                                    ];
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// --- Add Booking Tab ---
class _AddBookingTab extends StatefulWidget {
  final VoidCallback onBookingAdded;
  const _AddBookingTab({required this.onBookingAdded});

  @override
  State<_AddBookingTab> createState() => _AddBookingTabState();
}

class _AddBookingTabState extends State<_AddBookingTab> {
  int _step = 0;
  // Booking fields
  int? _selectedRoomId;
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  double? _totalAmount;
  String _bookingStatus = 'pending';
  String _paymentStatus = 'unpaid';
  String? _notes;
  List<Room> _rooms = [];
  bool _loadingRooms = true;

  // Guest fields
  int? _selectedGuestId;
  String _guestName = '';
  String _guestPhone = '';
  String _guestEmail = '';
  String _guestIdNumber = '';
  String _guestPreferences = '';
  String _guestNotes = '';
  List<Guest> _guests = [];
  bool _loadingGuests = true;

  // Calculate total amount automatically
  void _updateTotalAmount() {
    if (_selectedRoomId != null && _checkInDate != null && _checkOutDate != null) {
      final room = _rooms.firstWhere((r) => r.id == _selectedRoomId, orElse: () => _rooms.first);
      final days = _checkOutDate!.difference(_checkInDate!).inDays;
      final chargeableDays = days < 1 ? 1 : days;
      _totalAmount = room.pricePerNight * chargeableDays;
    } else {
      _totalAmount = null;
    }
  }

  Future<void> _pickCheckInDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _checkInDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _checkInDate = picked;
        _updateTotalAmount();
      });
    }
  }

  Future<void> _pickCheckOutDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _checkOutDate ?? (_checkInDate != null ? _checkInDate!.add(const Duration(days: 1)) : DateTime.now().add(const Duration(days: 1))),
      firstDate: _checkInDate != null ? _checkInDate!.add(const Duration(days: 1)) : DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 366)),
    );
    if (picked != null) {
      setState(() {
        _checkOutDate = picked;
        _updateTotalAmount();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchRooms();
    _fetchGuests();
  }

  Future<void> _fetchRooms() async {
    setState(() => _loadingRooms = true);
    final rooms = await DBHelper.getRooms();
    setState(() {
      _rooms = rooms.where((r) => r.status == 'available').toList();
      _loadingRooms = false;
    });
  }

  Future<void> _fetchGuests() async {
    setState(() => _loadingGuests = true);
    final guests = await GuestDB.getGuests();
    setState(() {
      _guests = guests;
      _loadingGuests = false;
    });
  }

  void _nextStep() {
    setState(() => _step++);
  }
  void _prevStep() {
    setState(() => _step--);
  }

  Future<void> _saveBooking() async {
    int guestId = _selectedGuestId ?? -1;
    // If new guest, insert
    if (_selectedGuestId == null) {
      final guest = Guest(
        fullName: _guestName,
        phone: _guestPhone,
        email: _guestEmail,
        idNumber: _guestIdNumber,
        preferences: _guestPreferences,
        notes: _guestNotes,
      );
      guestId = await GuestDB.insertGuest(guest);
    }
    final booking = Booking(
      guestId: guestId,
      roomId: _selectedRoomId!,
      checkInDate: _checkInDate!.toIso8601String().substring(0, 10),
      checkOutDate: _checkOutDate!.toIso8601String().substring(0, 10),
      bookingStatus: _bookingStatus,
      totalAmount: _totalAmount,
      paymentStatus: _paymentStatus,
      notes: _notes,
    );
    await BookingDB.insertBooking(booking);
    if (mounted) {
      widget.onBookingAdded();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking added!'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_step == 0) {
      // Step 1: Booking details
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: _loadingRooms
                  ? const CircularProgressIndicator()
                  : Form(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Booking Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<int>(
                              value: _selectedRoomId,
                              decoration: const InputDecoration(labelText: 'Room'),
                              items: _rooms.map((room) => DropdownMenuItem(
                                value: room.id,
                                child: Text('Room ${room.roomNumber} - ${room.type} (${room.roomClass ?? 'Class'})'),
                              )).toList(),
                              onChanged: (v) {
                                setState(() => _selectedRoomId = v);
                                _updateTotalAmount();
                              },
                              validator: (v) => v == null ? 'Select a room' : null,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _pickCheckInDate(context),
                                    child: AbsorbPointer(
                                      child: TextFormField(
                                        decoration: const InputDecoration(labelText: 'Check-in Date'),
                                        controller: TextEditingController(
                                          text: _checkInDate != null ? _checkInDate!.toIso8601String().substring(0, 10) : '',
                                        ),
                                        validator: (v) => v == null || v.isEmpty ? 'Select check-in date' : null,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _pickCheckOutDate(context),
                                    child: AbsorbPointer(
                                      child: TextFormField(
                                        decoration: const InputDecoration(labelText: 'Check-out Date'),
                                        controller: TextEditingController(
                                          text: _checkOutDate != null ? _checkOutDate!.toIso8601String().substring(0, 10) : '',
                                        ),
                                        validator: (v) => v == null || v.isEmpty ? 'Select check-out date' : null,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              decoration: const InputDecoration(labelText: 'Total Amount (\$)'),
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              readOnly: true,
                              controller: TextEditingController(text: _totalAmount != null ? _totalAmount!.toStringAsFixed(2) : ''),
                              enableInteractiveSelection: false,
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: _bookingStatus,
                              decoration: const InputDecoration(labelText: 'Booking Status'),
                              items: const [
                                DropdownMenuItem(value: 'pending', child: Text('Pending')),
                                DropdownMenuItem(value: 'confirmed', child: Text('Confirmed')),
                                DropdownMenuItem(value: 'checked_in', child: Text('Checked In')),
                                DropdownMenuItem(value: 'checked_out', child: Text('Checked Out')),
                                DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                                DropdownMenuItem(value: 'no_show', child: Text('No Show')),
                              ],
                              onChanged: (v) => setState(() => _bookingStatus = v ?? 'pending'),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: _paymentStatus,
                              decoration: const InputDecoration(labelText: 'Payment Status'),
                              items: const [
                                DropdownMenuItem(value: 'unpaid', child: Text('Unpaid')),
                                DropdownMenuItem(value: 'paid', child: Text('Paid')),
                                DropdownMenuItem(value: 'refunded', child: Text('Refunded')),
                              ],
                              onChanged: (v) => setState(() => _paymentStatus = v ?? 'unpaid'),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              decoration: const InputDecoration(labelText: 'Notes'),
                              onChanged: (v) => setState(() => _notes = v),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: _selectedRoomId != null && _checkInDate != null && _checkOutDate != null && _totalAmount != null
                                      ? _nextStep
                                      : null,
                                  child: const Text('Next'),
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
      );
    } else if (_step == 1) {
      // Step 2: Guest info
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: _loadingGuests
                  ? const CircularProgressIndicator()
                  : Form(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Guest Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<int>(
                              value: _selectedGuestId,
                              decoration: const InputDecoration(labelText: 'Select Existing Guest'),
                              items: [
                                const DropdownMenuItem<int>(value: null, child: Text('New Guest')),
                                ..._guests.map((g) => DropdownMenuItem(
                                  value: g.id,
                                  child: Text(g.fullName),
                                ))
                              ],
                              onChanged: (v) => setState(() => _selectedGuestId = v),
                            ),
                            if (_selectedGuestId == null) ...[
                              const SizedBox(height: 12),
                              TextFormField(
                                decoration: const InputDecoration(labelText: 'Full Name'),
                                onChanged: (v) => setState(() => _guestName = v),
                              ),
                              TextFormField(
                                decoration: const InputDecoration(labelText: 'Phone'),
                                onChanged: (v) => setState(() => _guestPhone = v),
                              ),
                              TextFormField(
                                decoration: const InputDecoration(labelText: 'Email'),
                                onChanged: (v) => setState(() => _guestEmail = v),
                              ),
                              TextFormField(
                                decoration: const InputDecoration(labelText: 'ID Number'),
                                onChanged: (v) => setState(() => _guestIdNumber = v),
                              ),
                              TextFormField(
                                decoration: const InputDecoration(labelText: 'Preferences'),
                                onChanged: (v) => setState(() => _guestPreferences = v),
                              ),
                              TextFormField(
                                decoration: const InputDecoration(labelText: 'Notes'),
                                onChanged: (v) => setState(() => _guestNotes = v),
                              ),
                            ],
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: _prevStep,
                                  child: const Text('Back'),
                                ),
                                ElevatedButton(
                                  onPressed: _selectedGuestId != null || _guestName.isNotEmpty
                                      ? _nextStep
                                      : null,
                                  child: const Text('Next'),
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
      );
    } else {
      // Step 3: Review & Save
      final guest = _selectedGuestId != null
          ? _guests.firstWhere((g) => g.id == _selectedGuestId)
          : null;
      final room = _rooms.firstWhere((r) => r.id == _selectedRoomId);
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Review Booking', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Text('Room: ${room.roomNumber} - ${room.type}'),
                  Text('Check-in: ${_checkInDate?.toIso8601String().substring(0, 10) ?? ''}'),
                  Text('Check-out: ${_checkOutDate?.toIso8601String().substring(0, 10) ?? ''}'),
                  Text('Total Amount: \$${_totalAmount?.toStringAsFixed(2) ?? ''}'),
                  Text('Booking Status: $_bookingStatus'),
                  Text('Payment Status: $_paymentStatus'),
                  if (_notes != null && _notes!.isNotEmpty) Text('Notes: $_notes'),
                  const Divider(height: 32),
                  Text('Guest: ${guest?.fullName ?? _guestName}'),
                  if ((guest?.phone ?? _guestPhone).isNotEmpty) Text('Phone: ${guest?.phone ?? _guestPhone}'),
                  if ((guest?.email ?? _guestEmail).isNotEmpty) Text('Email: ${guest?.email ?? _guestEmail}'),
                  if ((guest?.idNumber ?? _guestIdNumber).isNotEmpty) Text('ID: ${guest?.idNumber ?? _guestIdNumber}'),
                  if ((guest?.preferences ?? _guestPreferences).isNotEmpty) Text('Preferences: ${guest?.preferences ?? _guestPreferences}'),
                  if ((guest?.notes ?? _guestNotes).isNotEmpty) Text('Notes: ${guest?.notes ?? _guestNotes}'),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: _prevStep,
                        child: const Text('Back'),
                      ),
                      ElevatedButton(
                        onPressed: _saveBooking,
                        child: const Text('Save Booking'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}

// --- Guests Tab ---
class _GuestsTab extends StatefulWidget {
  @override
  State<_GuestsTab> createState() => _GuestsTabState();
}

class _GuestsTabState extends State<_GuestsTab> {
  List<Guest> _guests = [];
  String _search = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchGuests();
  }

  Future<void> _fetchGuests() async {
    setState(() => _loading = true);
    final guests = await GuestDB.getGuests();
    setState(() {
      _guests = guests;
      _loading = false;
    });
  }

  List<Guest> get _filteredGuests {
    if (_search.isEmpty) return _guests;
    return _guests.where((g) =>
      g.fullName.toLowerCase().contains(_search.toLowerCase()) ||
      (g.email ?? '').toLowerCase().contains(_search.toLowerCase()) ||
      (g.phone ?? '').contains(_search)
    ).toList();
  }

  void _showGuestDialog({Guest? guest}) {
    final nameController = TextEditingController(text: guest?.fullName ?? '');
    final phoneController = TextEditingController(text: guest?.phone ?? '');
    final emailController = TextEditingController(text: guest?.email ?? '');
    final idController = TextEditingController(text: guest?.idNumber ?? '');
    final preferencesController = TextEditingController(text: guest?.preferences ?? '');
    final notesController = TextEditingController(text: guest?.notes ?? '');
    final _formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(guest == null ? 'Add Guest' : 'Edit Guest'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Name required' : null,
                  ),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'Phone'),
                  ),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  TextFormField(
                    controller: idController,
                    decoration: const InputDecoration(labelText: 'ID Number'),
                  ),
                  TextFormField(
                    controller: preferencesController,
                    decoration: const InputDecoration(labelText: 'Preferences'),
                  ),
                  TextFormField(
                    controller: notesController,
                    decoration: const InputDecoration(labelText: 'Notes'),
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
                final guestData = Guest(
                  id: guest?.id,
                  fullName: nameController.text,
                  phone: phoneController.text,
                  email: emailController.text,
                  idNumber: idController.text,
                  preferences: preferencesController.text,
                  notes: notesController.text,
                );
                if (guest == null) {
                  await GuestDB.insertGuest(guestData);
                } else {
                  await GuestDB.updateGuest(guestData);
                }
                if (mounted) {
                  Navigator.pop(context);
                  _fetchGuests();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(guest == null ? 'Guest added!' : 'Guest updated!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            child: Text(guest == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteGuest(int id) async {
    await GuestDB.deleteGuest(id);
    _fetchGuests();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search guests',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => setState(() => _search = v),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.person_add),
                label: const Text('Add Guest'),
                onPressed: () => _showGuestDialog(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredGuests.isEmpty
                    ? const Center(child: Text('No guests found.'))
                    : ListView.builder(
                        itemCount: _filteredGuests.length,
                        itemBuilder: (context, index) {
                          final guest = _filteredGuests[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              leading: const Icon(Icons.person, size: 36, color: Colors.indigo),
                              title: Text(guest.fullName),
                              subtitle: Text(guest.email ?? ''),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) async {
                                  if (value == 'edit') {
                                    _showGuestDialog(guest: guest);
                                  } else if (value == 'delete') {
                                    await _deleteGuest(guest.id!);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Guest deleted.'), backgroundColor: Colors.red),
                                    );
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// --- Booking History Tab ---
class _BookingHistoryTab extends StatefulWidget {
  @override
  State<_BookingHistoryTab> createState() => _BookingHistoryTabState();
}

class _BookingHistoryTabState extends State<_BookingHistoryTab> {
  List<Map<String, dynamic>> _history = [];
  List<Guest> _guests = [];
  List<Room> _rooms = [];
  List<Booking> _bookings = [];
  String _search = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() => _loading = true);
    final db = await DBHelper.database;
    // Get all booking history, use denormalized fields
    final history = await db.rawQuery('''
      SELECT * FROM booking_history
      ORDER BY changed_at DESC
    ''');
    final guests = await GuestDB.getGuests();
    final rooms = await DBHelper.getRooms();
    final bookings = await BookingDB.getBookings();
    setState(() {
      _history = history;
      _guests = guests;
      _rooms = rooms;
      _bookings = bookings;
      _loading = false;
    });
  }

  List<Map<String, dynamic>> get _filteredHistory {
    if (_search.isEmpty) return _history;
    return _history.where((h) {
      final guest = _guests.firstWhere((g) => g.id == h['guest_id'], orElse: () => Guest(fullName: '', phone: '', email: '', idNumber: '', preferences: '', notes: ''));
      final room = _rooms.firstWhere((r) => r.id == h['room_id'], orElse: () => Room(id: 0, roomNumber: '', type: '', pricePerNight: 0, status: '', roomClass: ''));
      return guest.fullName.toLowerCase().contains(_search.toLowerCase()) ||
        room.roomNumber.toLowerCase().contains(_search.toLowerCase()) ||
        (h['status'] ?? '').toLowerCase().contains(_search.toLowerCase()) ||
        (h['check_in_date'] ?? '').contains(_search) ||
        (h['check_out_date'] ?? '').contains(_search);
    }).toList();
  }

  String _getGuestName(dynamic guestId) {
    if (guestId == null) return 'Unknown';
    final guest = _guests.firstWhere((g) => g.id == guestId, orElse: () => Guest(fullName: 'Unknown', phone: '', email: '', idNumber: '', preferences: '', notes: ''));
    return guest.fullName;
  }

  String _getRoomDisplay(dynamic roomId) {
    if (roomId == null) return 'Unknown';
    final room = _rooms.firstWhere((r) => r.id == roomId, orElse: () => Room(id: 0, roomNumber: 'Unknown', type: '', pricePerNight: 0, status: '', roomClass: ''));
    return 'Room ${room.roomNumber} - ${room.type}${room.roomClass != null && room.roomClass!.isNotEmpty ? ' (${room.roomClass})' : ''}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search history',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => setState(() => _search = v),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
                onPressed: _fetchHistory,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredHistory.isEmpty
                    ? const Center(child: Text('No booking history found.'))
                    : ListView.builder(
                        itemCount: _filteredHistory.length,
                        itemBuilder: (context, index) {
                          final h = _filteredHistory[index];
                          final guestName = _getGuestName(h['guest_id']);
                          final roomDisplay = _getRoomDisplay(h['room_id']);
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              leading: const Icon(Icons.history, size: 36, color: Colors.grey),
                              title: Text(guestName),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(roomDisplay),
                                  Text('Check-in: ${h['check_in_date'] ?? ''}'),
                                  Text('Check-out: ${h['check_out_date'] ?? ''}'),
                                  if (h['payment_status'] != null) Text('Payment: ${h['payment_status']}'),
                                  if (h['total_amount'] != null) Text('Total: ${h['total_amount']}'),
                                  Text('Status: ${h['status'] ?? ''}'),
                                  if ((h['notes'] ?? '').toString().isNotEmpty) Text('Notes: ${h['notes']}'),
                                  Text('Changed: ${h['changed_at']?.toString().substring(0, 19) ?? ''}'),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
