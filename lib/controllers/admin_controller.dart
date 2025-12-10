import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_controller.dart';

class AdminRoom {
  AdminRoom({
    required this.id,
    required this.code,
    required this.isAvailable,
    this.type,
  });

  final String id;
  final String code;
  final String? type;
  final bool isAvailable;

  factory AdminRoom.fromMap(Map<String, dynamic> map) {
    return AdminRoom(
      id: map['id'] as String,
      code: map['code'] as String,
      type: map['type'] as String?,
      isAvailable: map['is_available'] as bool? ?? true,
    );
  }

  AdminRoom copyWith({bool? isAvailable}) {
    return AdminRoom(
      id: id,
      code: code,
      type: type,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}

class AdminAssignment {
  AdminAssignment({
    required this.id,
    required this.userEmail,
    required this.roomCode,
    this.note,
    this.createdAt,
  });

  final String id;
  final String userEmail;
  final String roomCode;
  final String? note;
  final DateTime? createdAt;

  factory AdminAssignment.fromMap(Map<String, dynamic> map) {
    return AdminAssignment(
      id: map['id'] as String,
      userEmail: map['user_email'] as String,
      roomCode: map['room_code'] as String,
      note: map['note'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
    );
  }
}

class AdminBookingHistory {
  AdminBookingHistory({
    required this.id,
    required this.roomCode,
    required this.serviceName,
    required this.finalPrice,
    required this.createdAt,
    required this.isRoomBooking,
    this.roomType,
    this.userId,
    this.assignedEmail,
    this.userEmail,
    this.quantity,
  });

  final String id;
  final String roomCode;
  final String serviceName;
  final num finalPrice;
  final DateTime createdAt;
  final bool isRoomBooking;
  final String? roomType;
  final String? userId;
  final String? assignedEmail;
  final String? userEmail;
  final int? quantity;

  factory AdminBookingHistory.fromMap(Map<String, dynamic> map,
      {String? assignedEmail}) {
    return AdminBookingHistory(
      id: map['id'] as String,
      roomCode: (map['room_code'] as String?) ?? '-',
      serviceName: (map['service_name'] as String?) ?? '-',
      finalPrice: (map['final_price'] as num?) ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
      roomType: map['room_type'] as String?,
      userId: map['user_id'] as String?,
      assignedEmail: assignedEmail,
      userEmail: map['user_email'] as String?,
      isRoomBooking: map['is_room_booking'] as bool? ?? false,
      quantity: (map['quantity'] as int?),
    );
  }
}

class AdminController extends GetxController {
  final RxList<AdminRoom> rooms = <AdminRoom>[].obs;
  final RxList<AdminAssignment> assignments = <AdminAssignment>[].obs;
  final RxList<AdminBookingHistory> history = <AdminBookingHistory>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSavingRoom = false.obs;
  final RxBool isSavingAssignment = false.obs;
  final RxBool isLoadingHistory = false.obs;
  final RxBool isAddingNewRoom = false.obs;
  final RxnString error = RxnString();

  final TextEditingController roomCodeCtrl = TextEditingController();
  final TextEditingController roomTypeCtrl = TextEditingController();
  final RxBool roomAvailable = true.obs;

  final TextEditingController assignEmailCtrl = TextEditingController();
  final TextEditingController assignRoomCtrl = TextEditingController();
  final TextEditingController assignNoteCtrl = TextEditingController();

  final RxString selectedRoomCode = 'all'.obs;

  SupabaseClient get _client => Supabase.instance.client;
  AuthController get _auth => Get.find<AuthController>();

  @override
  void onInit() {
    super.onInit();
    _ensureAdmin();
    fetchAll();
    fetchHistory();
  }

  @override
  void onClose() {
    roomCodeCtrl.dispose();
    roomTypeCtrl.dispose();
    assignEmailCtrl.dispose();
    assignRoomCtrl.dispose();
    assignNoteCtrl.dispose();
    super.onClose();
  }

  void _ensureAdmin() {
    if (!_auth.isAdmin) {
      Get.snackbar(
        'Akses ditolak',
        'Hanya admin yang dapat membuka halaman ini.',
        snackPosition: SnackPosition.BOTTOM,
      );
      Future.microtask(() => Get.back());
    }
  }

  Future<void> fetchAll() async {
    isLoading.value = true;
    error.value = null;
    try {
      final roomResp =
          await _client.from('rooms').select().order('code', ascending: true);
      final assignResp = await _client
          .from('room_assignments')
          .select()
          .order('created_at', ascending: false);

      rooms.assignAll(
        (roomResp as List<dynamic>)
            .map((e) => AdminRoom.fromMap(Map<String, dynamic>.from(e)))
            .toList(),
      );
      assignments.assignAll(
        (assignResp as List<dynamic>)
            .map((e) => AdminAssignment.fromMap(Map<String, dynamic>.from(e)))
            .toList(),
      );
    } catch (e) {
      error.value = 'Gagal memuat data admin: $e';
      Get.snackbar(
        'Gagal memuat',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchHistory({String? roomCode}) async {
    final filterCode = roomCode ?? selectedRoomCode.value;
    selectedRoomCode.value = filterCode;
    isLoadingHistory.value = true;
    try {
      dynamic resp;
      if (filterCode == 'all') {
        resp = await _client
            .from('admin_room_history')
            .select()
            .order('created_at', ascending: false);
      } else {
        resp = await _client
            .from('admin_room_history')
            .select()
            .eq('room_code', filterCode)
            .order('created_at', ascending: false);
      }
      final assignsByRoom = <String, String>{};
      for (final a in assignments) {
        assignsByRoom[a.roomCode] = a.userEmail;
      }

      history.assignAll(
        (resp as List<dynamic>).map((e) {
          final map = Map<String, dynamic>.from(e);
          final assignedEmail = assignsByRoom[map['room_code']];
          return AdminBookingHistory.fromMap(
            map,
            assignedEmail: assignedEmail,
          );
        }).toList(),
      );
    } catch (e) {
      Get.snackbar(
        'Gagal memuat riwayat',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingHistory.value = false;
    }
  }

  Future<void> addRoom() async {
    final code = roomCodeCtrl.text.trim();
    final type = roomTypeCtrl.text.trim().isEmpty ? null : roomTypeCtrl.text;
    if (code.isEmpty) {
      Get.snackbar(
        'Kode kosong',
        'Isi kode kamar terlebih dahulu.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (isSavingRoom.value) return;

    isSavingRoom.value = true;
    try {
      // jika kamar sudah ada, cuma update status + tipe
      AdminRoom? existing;
      for (final r in rooms) {
        if (r.code.toLowerCase() == code.toLowerCase()) {
          existing = r;
          break;
        }
      }
      if (existing != null) {
        await _client.from('rooms').update({
          'type': type ?? existing.type,
          'is_available': roomAvailable.value,
        }).eq('id', existing.id);
      } else {
        await _client.from('rooms').insert({
          'code': code,
          'type': type,
          'is_available': roomAvailable.value,
        });
      }

      await fetchAll();
      roomCodeCtrl.clear();
      roomTypeCtrl.clear();
      roomAvailable.value = true;
      isAddingNewRoom.value = false;
    } catch (e) {
      Get.snackbar(
        'Gagal menyimpan kamar',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSavingRoom.value = false;
    }
  }

  Future<void> toggleAvailability(AdminRoom room, bool available) async {
    try {
      await _client
          .from('rooms')
          .update({'is_available': available}).eq('id', room.id);
      rooms.assignAll(
        rooms
            .map(
                (r) => r.id == room.id ? r.copyWith(isAvailable: available) : r)
            .toList(),
      );
      await fetchHistory(roomCode: selectedRoomCode.value);
    } catch (e) {
      Get.snackbar(
        'Gagal mengubah status',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteRoom(AdminRoom room) async {
    try {
      await _client.from('rooms').delete().eq('id', room.id);
      rooms.removeWhere((r) => r.id == room.id);
    } catch (e) {
      Get.snackbar(
        'Gagal menghapus kamar',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> saveAssignment() async {
    final email = assignEmailCtrl.text.trim();
    final roomCode = assignRoomCtrl.text.trim();
    final note =
        assignNoteCtrl.text.trim().isEmpty ? null : assignNoteCtrl.text;

    if (email.isEmpty || roomCode.isEmpty) {
      Get.snackbar(
        'Data belum lengkap',
        'Isi email dan kode kamar.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (isSavingAssignment.value) return;

    isSavingAssignment.value = true;
    try {
      await _client.from('room_assignments').insert({
        'user_email': email,
        'room_code': roomCode,
        'note': note,
      });
      await fetchAll();
      await fetchHistory(roomCode: selectedRoomCode.value);
      assignEmailCtrl.clear();
      assignRoomCtrl.clear();
      assignNoteCtrl.clear();
    } catch (e) {
      Get.snackbar(
        'Gagal menyimpan penugasan',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSavingAssignment.value = false;
    }
  }

  Future<void> deleteAssignment(AdminAssignment a) async {
    try {
      await _client.from('room_assignments').delete().eq('id', a.id);
      assignments.removeWhere((x) => x.id == a.id);
    } catch (e) {
      Get.snackbar(
        'Gagal menghapus penugasan',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
