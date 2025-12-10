import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

/// =============== KONFIGURASI ===============
const String kUrl = 'https://jsonplaceholder.typicode.com/todos/1';
const int kCallsPerRound = 5; // panggilan per round
const int kRounds = 5; // jumlah round
const int kPauseMs = 50; // jeda antar panggilan (ms)
/// ==========================================

Future<void> _sleep([int ms = kPauseMs]) async =>
    Future<void>.delayed(Duration(milliseconds: ms));

Future<int> _httpOnce() async {
  final sw = Stopwatch()..start();
  final res = await http.get(Uri.parse(kUrl), headers: {
    'User-Agent': 'FlutterBench/1.0',
    'Accept': 'application/json',
  });
  sw.stop();
  expect(res.statusCode, 200, reason: 'HTTP status harus 200');
  return sw.elapsedMilliseconds;
}

final Dio _dio = Dio(BaseOptions(
  connectTimeout: const Duration(seconds: 10),
  receiveTimeout: const Duration(seconds: 10),
  headers: {
    'User-Agent': 'FlutterBench/1.0',
    'Accept': 'application/json',
  },
));

Future<int> _dioOnce() async {
  final sw = Stopwatch()..start();
  final res = await _dio.get(kUrl);
  sw.stop();
  expect(res.statusCode, 200, reason: 'Dio status harus 200');
  return sw.elapsedMilliseconds;
}

class Stats {
  Stats(this.samples) : n = samples.length {
    if (samples.isEmpty) {
      avg = 0;
      p50 = 0;
      p95 = 0;
      min = 0;
      max = 0;
      return;
    }
    final s = [...samples]..sort();
    min = s.first;
    max = s.last;
    avg = s.reduce((a, b) => a + b) / s.length;
    p50 = s[(0.50 * (s.length - 1)).round()];
    p95 = s[(0.95 * (s.length - 1)).round()];
  }

  final List<int> samples;
  final int n;
  late final double avg;
  late final int p50;
  late final int p95;
  late final int min;
  late final int max;

  String fmt(String label) => '$label n=$n | avg=${avg.toStringAsFixed(1)}ms | '
      'p50=$p50 | p95=$p95 | min=$min | max=$max';
}

Future<List<int>> _runMany(Future<int> Function() fn) async {
  final times = <int>[];
  for (var r = 0; r < kRounds; r++) {
    for (var i = 0; i < kCallsPerRound; i++) {
      times.add(await fn());
      await _sleep();
    }
    await _sleep(150); // jeda antar round
  }
  return times;
}

void main() {
  test('Benchmark: http vs dio (multi-round, multi-run, no UI)', () async {
    // warmup singkat (abaikan error warmup supaya tes utama tetap jalan)
    try {
      await Future.wait([_httpOnce(), _dioOnce()]);
    } catch (_) {}

    final httpTimes = await _runMany(_httpOnce);
    final dioTimes = await _runMany(_dioOnce);

    final sHttp = Stats(httpTimes);
    final sDio = Stats(dioTimes);

    // Tampilkan ringkasan ke output test (akan terlihat di terminal)
    // ignore: avoid_print
    print('\n== Benchmark Result (${kRounds}r x ${kCallsPerRound}c) ==');
    // ignore: avoid_print
    print(sHttp.fmt('HTTP'));
    // ignore: avoid_print
    print(sDio.fmt('DIO'));

    // Asersi “longgar” agar test hijau selama request jalan
    expect(sHttp.n, greaterThan(0));
    expect(sDio.n, greaterThan(0));
  });
}
