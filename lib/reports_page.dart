import 'package:flutter/material.dart';
import 'admin_sidebar.dart';
import 'db_helper.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String _filterType = 'All'; // All, Daily, Weekly, Monthly, Custom
  DateTime? _selectedDate;
  DateTimeRange? _customRange;

  Future<Map<String, dynamic>> _fetchReportData(BuildContext context) async {
    final db = await DBHelper.database;
    // Bookings summary with filter
    List<Map<String, dynamic>> bookings = await db.query('bookings');
    DateTime now = DateTime.now();
    if (_filterType == 'Daily' && _selectedDate != null) {
      final day = _selectedDate!;
      bookings = bookings.where((b) {
        final date = DateTime.tryParse(b['check_in_date'] ?? '') ?? now;
        return date.year == day.year && date.month == day.month && date.day == day.day;
      }).toList();
    } else if (_filterType == 'Weekly' && _selectedDate != null) {
      final weekStart = _selectedDate!.subtract(Duration(days: _selectedDate!.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 6));
      bookings = bookings.where((b) {
        final date = DateTime.tryParse(b['check_in_date'] ?? '') ?? now;
        return !date.isBefore(weekStart) && !date.isAfter(weekEnd);
      }).toList();
    } else if (_filterType == 'Monthly' && _selectedDate != null) {
      final month = _selectedDate!;
      bookings = bookings.where((b) {
        final date = DateTime.tryParse(b['check_in_date'] ?? '') ?? now;
        return date.year == month.year && date.month == month.month;
      }).toList();
    } else if (_filterType == 'Custom' && _customRange != null) {
      bookings = bookings.where((b) {
        final date = DateTime.tryParse(b['check_in_date'] ?? '') ?? now;
        return !date.isBefore(_customRange!.start) && !date.isAfter(_customRange!.end);
      }).toList();
    }
    // Bookings summary counts
    final totalBookings = bookings.length;
    final checkedIn = bookings.where((b) => b['booking_status'] == 'checked_in').length;
    final checkedOut = bookings.where((b) => b['booking_status'] == 'checked_out').length;
    final cancelled = bookings.where((b) => b['booking_status'] == 'cancelled').length;
    // Room summary
    final rooms = await db.query('rooms');
    final totalRooms = rooms.length;
    final availableRooms = rooms.where((r) => r['status'] == 'available').length;
    final occupiedRooms = rooms.where((r) => r['status'] == 'occupied').length;
    final dirtyRooms = rooms.where((r) => r['housekeeping_status'] == 'dirty').length;
    // Staff summary
    final staff = await db.query('users', where: 'role = ?', whereArgs: ['staff']);
    final housekeepers = await db.query('users', where: 'role = ?', whereArgs: ['housekeeping']);
    // Revenue (sum of total_amount for checked_out bookings)
    final revenue = bookings
        .where((b) => b['booking_status'] == 'checked_out' && b['total_amount'] != null)
        .fold<double>(0, (sum, b) {
          final amt = b['total_amount'];
          if (amt is int) return sum + amt.toDouble();
          if (amt is double) return sum + amt;
          if (amt is String) {
            final parsed = double.tryParse(amt);
            return parsed != null ? sum + parsed : sum;
          }
          return sum;
        });
    return {
      'totalBookings': totalBookings,
      'checkedIn': checkedIn,
      'checkedOut': checkedOut,
      'cancelled': cancelled,
      'totalRooms': totalRooms,
      'availableRooms': availableRooms,
      'occupiedRooms': occupiedRooms,
      'dirtyRooms': dirtyRooms,
      'staffCount': staff.length,
      'housekeepersCount': housekeepers.length,
      'revenue': revenue,
    };
  }

  void _pickDate(BuildContext context) async {
    if (_filterType == 'Daily' || _filterType == 'Weekly' || _filterType == 'Monthly') {
      final picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate ?? DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
      );
      if (picked != null) setState(() => _selectedDate = picked);
    } else if (_filterType == 'Custom') {
      final picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
      );
      if (picked != null) setState(() => _customRange = picked);
    }
  }

  void _downloadReport(Map<String, dynamic> data) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Hotel Management Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 16),
              pw.Text('Generated: ${DateTime.now().toString().substring(0, 19)}'),
              pw.SizedBox(height: 24),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Label', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Value', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  ...data.entries.map((e) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(e.key),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(e.value is double ? e.value.toStringAsFixed(2) : e.value.toString()),
                      ),
                    ],
                  )),
                ],
              ),
            ],
          );
        },
      ),
    );
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/hotel_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF saved to ${file.path}'), backgroundColor: Colors.green),
      );
      await OpenFile.open(file.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    final pageName = 'Reports';
    final role = ModalRoute.of(context)?.settings.arguments as String? ?? 'admin';
    final sidebar = AdminSidebar(pageName: pageName, role: role);
    final filterRow = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          DropdownButton<String>(
            value: _filterType,
            items: const [
              DropdownMenuItem(value: 'All', child: Text('All Time')),
              DropdownMenuItem(value: 'Daily', child: Text('Daily')),
              DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
              DropdownMenuItem(value: 'Monthly', child: Text('Monthly')),
              DropdownMenuItem(value: 'Custom', child: Text('Custom Range')),
            ],
            onChanged: (v) => setState(() => _filterType = v ?? 'All'),
          ),
          const SizedBox(width: 12),
          if (_filterType != 'All')
            ElevatedButton.icon(
              icon: const Icon(Icons.date_range),
              label: Text(_filterType == 'Custom'
                  ? (_customRange != null
                      ? '${_customRange!.start.toString().substring(0, 10)} - ${_customRange!.end.toString().substring(0, 10)}'
                      : 'Pick Range')
                  : (_selectedDate != null
                      ? _selectedDate.toString().substring(0, 10)
                      : 'Pick Date')),
              onPressed: () => _pickDate(context),
            ),
        ],
      ),
    );
    final reportCard = FutureBuilder<Map<String, dynamic>>(
      future: _fetchReportData(context),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data!;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              filterRow,
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hotel Summary', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 24),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final List<Widget> tiles = [
                            _reportTile('Total Bookings', data['totalBookings'].toString(), Icons.book_online, Colors.blue),
                            _reportTile('Checked In', data['checkedIn'].toString(), Icons.login, Colors.green),
                            _reportTile('Checked Out', data['checkedOut'].toString(), Icons.logout, Colors.grey),
                            _reportTile('Cancelled', data['cancelled'].toString(), Icons.cancel, Colors.red),
                            _reportTile('Total Rooms', data['totalRooms'].toString(), Icons.meeting_room, Colors.deepPurple),
                            _reportTile('Available Rooms', data['availableRooms'].toString(), Icons.hotel, Colors.teal),
                            _reportTile('Occupied Rooms', data['occupiedRooms'].toString(), Icons.bed, Colors.orange),
                            _reportTile('Dirty Rooms', data['dirtyRooms'].toString(), Icons.warning, Colors.brown),
                            _reportTile('Staff', data['staffCount'].toString(), Icons.people, Colors.indigo),
                            _reportTile('Housekeepers', data['housekeepersCount'].toString(), Icons.cleaning_services, Colors.pink),
                            _reportTile('Revenue', '\$${data['revenue'].toStringAsFixed(2)}', Icons.attach_money, Colors.green),
                          ];
                          List<Widget> rows = [];
                          for (int i = 0; i < tiles.length; i += 2) {
                            rows.add(Row(
                              children: [
                                Expanded(child: tiles[i]),
                                if (i + 1 < tiles.length) Expanded(child: tiles[i + 1]),
                              ],
                            ));
                            if (i + 2 < tiles.length) rows.add(const SizedBox(height: 16));
                          }
                          return Column(children: rows);
                        },
                      ),
                      const SizedBox(height: 24),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.download),
                          label: const Text('Download Report'),
                          onPressed: () => _downloadReport(data),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
              appBar: AppBar(title: Text(pageName)),
              body: reportCard,
            ),
          ),
        ],
      );
    } else {
      return Scaffold(
        appBar: AppBar(title: Text(pageName)),
        drawer: Drawer(child: sidebar),
        body: reportCard,
      );
    }
  }

  Widget _reportTile(String label, String value, IconData icon, Color color) {
    return SizedBox(
      width: 180,
      child: Card(
        color: color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(fontSize: 20, color: color, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
