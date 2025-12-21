import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/venue_model.dart';

class BookingModal extends StatefulWidget {
  final Venue venue;
  const BookingModal({super.key, required this.venue});

  @override
  State<BookingModal> createState() => _BookingModalState();
}

class _BookingModalState extends State<BookingModal> {
  // ==================== STATE VARIABLES ====================
  DateTime? selectedDate;
  List<String> availableSlots = [];
  String? selectedStart;
  String? selectedEnd;
  bool loadingSlots = false;
  bool isSubmitting = false;
  String? errorMessage;
  String? successMessage;
  final String baseUrl = 'http://localhost:8000'; // Update sesuai host Anda

  @override
  void initState() {
    super.initState();
    // Set default date ke besok
    selectedDate = DateTime.now().add(Duration(days: 1));
  }

  // ==================== FETCH AVAILABILITY ==================
  /// Fetch available time slots dari Django API
  Future<void> fetchAvailability() async {
    if (selectedDate == null) return;

    setState(() {
      loadingSlots = true;
      availableSlots = [];
      selectedStart = null;
      selectedEnd = null;
      errorMessage = null;
    });

    final dateStr = selectedDate!.toIso8601String().split('T')[0];
    final url = '$baseUrl/api/availability/${widget.venue.id}/?date=$dateStr';

    // 🔍 DEBUG
    print('[DEBUG] Fetching from URL: $url');
    print('[DEBUG] Venue ID: ${widget.venue.id}');
    print('[DEBUG] Date: $dateStr');

    try {
      final res = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Koneksi timeout'),
      );

      // 🔍 DEBUG
      print('[DEBUG] Response status: ${res.statusCode}');
      print('[DEBUG] Response body: ${res.body}');

      if (!mounted) return;

      if (res.statusCode == 200) {
        final jsonData = json.decode(res.body);
        print('[DEBUG] Available slots: ${jsonData['available_slots']}');
        
        setState(() {
          availableSlots = List<String>.from(jsonData['available_slots'] ?? []);
          if (availableSlots.isEmpty) {
            errorMessage = 'Tidak ada slot yang tersedia untuk tanggal ini';
          }
        });
      } else if (res.statusCode == 400) {
        final jsonData = json.decode(res.body);
        setState(() {
          errorMessage = jsonData['error'] ?? 'Format tanggal tidak valid';
        });
      } else if (res.statusCode == 404) {
        final jsonData = json.decode(res.body);
        print('[DEBUG] 404 Error: ${jsonData}');
        setState(() {
          errorMessage = 'Venue tidak ditemukan: ${jsonData['error'] ?? ''}';
        });
      } else {
        setState(() {
          errorMessage = 'Gagal memuat ketersediaan slot (${res.statusCode})';
        });
      }
    } catch (e) {
      if (mounted) {
        print('[DEBUG] Exception: $e');
        setState(() {
          errorMessage = 'Error: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() => loadingSlots = false);
      }
    }
  }

  // ==================== VALIDATION LOGIC ====================
  /// Validasi input booking
  String? validateBooking() {
    if (selectedDate == null) return 'Pilih tanggal terlebih dahulu';
    if (selectedStart == null) return 'Pilih jam mulai';
    if (selectedEnd == null) return 'Pilih jam selesai';

    // Validasi tanggal tidak boleh di masa lalu
    if (selectedDate!.isBefore(DateTime.now())) {
      return 'Tanggal tidak boleh di masa lalu';
    }

    // Validasi jam selesai harus setelah jam mulai
    final startHour = int.parse(selectedStart!.split(':')[0]);
    final endHour = int.parse(selectedEnd!.split(':')[0]);

    if (endHour <= startHour) {
      return 'Jam selesai harus setelah jam mulai';
    }

    // Validasi durasi minimal 1 jam
    if (endHour - startHour < 1) {
      return 'Durasi booking minimal 1 jam';
    }

    return null; // Semua validasi passed
  }

  /// Hitung total harga berdasarkan durasi
  int calculateTotalPrice() {
    if (selectedStart == null || selectedEnd == null) return 0;

    final startHour = int.parse(selectedStart!.split(':')[0]);
    final endHour = int.parse(selectedEnd!.split(':')[0]);
    final duration = endHour - startHour;

    return widget.venue.price * duration;
  }

  // ==================== SUBMIT BOOKING ==================
  /// Submit booking ke Django API menggunakan CookieRequest (dengan session/cookies)
Future<void> submitBooking() async {
  final request = context.read<CookieRequest>();

  final validationError = validateBooking();
  if (validationError != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(validationError), backgroundColor: Colors.red),
    );
    return;
  }

  setState(() {
    isSubmitting = true;
    errorMessage = null;
    successMessage = null;
  });

  final dateStr = selectedDate!.toIso8601String().split('T')[0];
  final url = '$baseUrl/api/book/${widget.venue.id}/';

  final bookingData = {
    'booking_date': dateStr,
    'start_time': selectedStart,
    'end_time': selectedEnd,
  };

  print('[DEBUG] POST $url');
  print('[DEBUG] Payload: $bookingData');
  print('[DEBUG] Logged in: ${request.loggedIn}');

  try {
    // ✅ GUNAKAN request.post() DARI CookieRequest (otomatis handle CSRF & cookies)
    final response = await request.post(
      url,
      jsonEncode(bookingData),
    );
    
    print('[DEBUG] Response: $response');

    if (!mounted) return;

    /// ✅ RESPONSE DARI request.post() SUDAH JSON DECODED
    if (response['success'] == true) {
      setState(() {
        successMessage = response['message'] ?? 'Booking berhasil!';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Booking ${widget.venue.name} berhasil!\n'
            'Tanggal: $dateStr\n'
            'Waktu: $selectedStart - $selectedEnd',
          ),
          backgroundColor: Colors.green,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 800));

      if (mounted) {
        Navigator.pop(context, response);
      }
    } else {
      final msg = response['message'] ?? 'Booking gagal';

      setState(() {
        errorMessage = msg;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    }
  } catch (e) {
    print('[DEBUG] Exception: $e');

    if (mounted) {
      setState(() {
        errorMessage = 'Terjadi kesalahan koneksi: ${e.toString()}';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal terhubung ke server: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } finally {
    if (mounted) {
      setState(() => isSubmitting = false);
    }
  }
}

  // ==================== GET VALID END TIMES ====================
  List<String> getValidEndTimes() {
    if (selectedStart == null) return [];
    
    final startHour = int.parse(selectedStart!.split(':')[0]);
    final endTimes = <String>[];
    
    // End time harus 1-12 jam setelah start time
    for (int h = startHour + 1; h <= 23 && h <= startHour + 12; h++) {
      endTimes.add("${h.toString().padLeft(2, '0')}:00");
    }
    
    return endTimes;
  }

  // ==================== BUILD UI ==================
  @override
  Widget build(BuildContext context) {
    final totalPrice = calculateTotalPrice();
    final validationError = validateBooking();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ============ HEADER ============
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Booking ${widget.venue.name}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Rp ${widget.venue.price}/jam",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ============ ERROR MESSAGE ============
            if (errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red[900], fontSize: 13),
                ),
              ),

            // ============ SUCCESS MESSAGE ============
            if (successMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  successMessage!,
                  style: TextStyle(color: Colors.green[900], fontSize: 13),
                ),
              ),

            const SizedBox(height: 16),

            // ============ DATE PICKER ============
            Text(
              'Tanggal Booking',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: selectedDate ?? DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now().add(const Duration(days: 1)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: Colors.red[400] ?? Colors.red,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );

                if (pickedDate != null && pickedDate != selectedDate) {
                  setState(() {
                    selectedDate = pickedDate;
                  });
                  await fetchAvailability();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedDate == null
                          ? 'Pilih Tanggal'
                          : selectedDate!.toIso8601String().split('T')[0],
                      style: TextStyle(
                        fontSize: 16,
                        color: selectedDate == null ? Colors.grey : Colors.black,
                      ),
                    ),
                    Icon(Icons.calendar_today, color: Colors.red[400]),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ============ LOADING SLOTS ============
            if (loadingSlots)
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.red[400]),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text('Memuat slot tersedia...'),
                  ],
                ),
              )
            else if (selectedDate != null && availableSlots.isEmpty && !loadingSlots)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Tidak ada slot yang tersedia untuk tanggal ini',
                  style: TextStyle(color: Colors.orange[900], fontSize: 13),
                ),
              ),

            // ============ TIME SELECTION ============
            if (!loadingSlots && availableSlots.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Jam Mulai',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedStart,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                hint: const Text('Pilih jam mulai'),
                items: availableSlots
                    .map(
                      (slot) => DropdownMenuItem<String>(
                        value: slot,
                        child: Text(slot),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedStart = value;
                    selectedEnd = null; // Reset end time
                  });
                },
              ),

              const SizedBox(height: 16),

              Text(
                'Jam Selesai',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedEnd,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                hint: const Text('Pilih jam selesai'),
                disabledHint: const Text('Pilih jam mulai terlebih dahulu'),
                items: selectedStart == null
                    ? []
                    : availableSlots
                        .where((slot) => slot.compareTo(selectedStart!) > 0)
                        .map(
                          (slot) => DropdownMenuItem<String>(
                            value: slot,
                            child: Text(slot),
                          ),
                        )
                        .toList(),
                onChanged: selectedStart == null
                    ? null
                    : (value) {
                        setState(() {
                          selectedEnd = value;
                        });
                      },
              ),
            ],

            const SizedBox(height: 16),

            // ============ PRICE SUMMARY ============
            if (selectedStart != null && selectedEnd != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Harga',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rp ${totalPrice.toString()}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[400],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${int.parse(selectedEnd!.split(':')[0]) - int.parse(selectedStart!.split(':')[0])} jam',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$selectedStart - $selectedEnd',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // ============ BUTTONS ============
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isSubmitting ? null : () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: (isSubmitting || validationError != null || availableSlots.isEmpty)
                        ? null
                        : submitBooking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400],
                      disabledBackgroundColor: Colors.grey[300],
                    ),
                    child: isSubmitting
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.red[400]),
                            ),
                          )
                        : const Text(
                            'Booking Sekarang',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}