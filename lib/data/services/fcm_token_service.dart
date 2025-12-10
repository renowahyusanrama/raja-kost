import 'package:supabase_flutter/supabase_flutter.dart';

/// Service penyimpanan token FCM ke Supabase (per user / role).
class FcmTokenService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Simpan atau update token untuk user tertentu.
  Future<void> upsertToken({
    required String userId,
    required String token,
    String? role,
  }) async {
    if (token.isEmpty) return;
    try {
      await _client.from('fcm_tokens').upsert(
        {
          'user_id': userId,
          'token': token,
          'role': role,
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'token',
      );
      // Debug log
      // ignore: avoid_print
      print('FCM token upserted for $userId, role=$role');
    } catch (e) {
      // ignore: avoid_print
      print('FCM upsert error: $e');
      rethrow;
    }
  }

  /// Hapus token tertentu (opsional saat logout).
  Future<void> deleteToken(String token) async {
    if (token.isEmpty) return;
    await _client.from('fcm_tokens').delete().eq('token', token);
  }
}
