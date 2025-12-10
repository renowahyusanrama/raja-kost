import 'dart:async';
import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

enum ExperimentType { outdoorStatic, indoorStatic, dynamicMove }

enum LocationProfile { gpsHigh, networkLike }

class LocationSample {
  LocationSample({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.timestamp,
    required this.profile,
    this.speed,
  });

  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime timestamp;
  final LocationProfile profile;
  final double? speed;

  String get formattedTime =>
      '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';
}

class LocationExperimentController extends GetxController {
  final Rx<ExperimentType> selectedExperiment =
      ExperimentType.outdoorStatic.obs;
  final Rx<LocationProfile> selectedProfile = LocationProfile.networkLike.obs;
  final RxBool isTracking = false.obs;
  final RxBool isLiveMode = false.obs;
  final RxInt intervalSeconds = 10.obs;
  final Rxn<LocationSample> lastSample = Rxn<LocationSample>();
  final RxString statusText = ''.obs;

  late final Map<ExperimentType, Map<LocationProfile, RxList<LocationSample>>>
      _logs;

  StreamSubscription<Position>? _positionSub;

  List<LocationSample> logFor(
    ExperimentType exp,
    LocationProfile profile,
  ) =>
      _logs[exp]![profile]!;

  List<LocationSample> get currentLog =>
      logFor(selectedExperiment.value, selectedProfile.value);

  @override
  void onInit() {
    super.onInit();
    _logs = {
      for (final exp in ExperimentType.values)
        exp: {
          for (final prof in LocationProfile.values)
            prof: <LocationSample>[].obs
        }
    };
    _ensurePermission(silent: true);
  }

  @override
  void onClose() {
    _positionSub?.cancel();
    super.onClose();
  }

  Future<void> startTracking({bool liveMode = false}) async {
    if (isTracking.value) return;
    final hasPermission = await _ensurePermission();
    if (!hasPermission) return;

    final effectiveInterval = liveMode ? 1 : intervalSeconds.value;
    final settings = _buildSettings(
      intervalSec: effectiveInterval,
      profile: selectedProfile.value,
    );

    isTracking.value = true;
    isLiveMode.value = liveMode;
    statusText.value = 'Mengaktifkan pelacakan...';

    _positionSub = Geolocator.getPositionStream(
      locationSettings: settings,
    ).listen((pos) {
      final ts = pos.timestamp.toLocal();
      final sample = LocationSample(
        latitude: pos.latitude,
        longitude: pos.longitude,
        accuracy: pos.accuracy,
        timestamp: ts,
        speed: pos.speed >= 0 ? pos.speed : null,
        profile: selectedProfile.value,
      );

      currentLog.add(sample);
      lastSample.value = sample;
      statusText.value =
          'Data ${currentLog.length} dicatat (${sample.formattedTime})';
    }, onError: (e) {
      statusText.value = 'Gagal memantau: $e';
      Get.snackbar(
        'Gagal memantau lokasi',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      stopTracking();
    });
  }

  Future<void> stopTracking() async {
    await _positionSub?.cancel();
    _positionSub = null;
    isTracking.value = false;
    isLiveMode.value = false;
    statusText.value = 'Pelacakan dihentikan';
  }

  Future<void> resetCurrentLog() async {
    currentLog.clear();
    lastSample.value = null;
  }

  double? averageAccuracy(List<LocationSample> samples) {
    if (samples.isEmpty) return null;
    final total = samples.fold<double>(0, (sum, s) => sum + s.accuracy);
    return total / samples.length;
  }

  Future<bool> _ensurePermission({bool silent = false}) async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!silent) {
        Get.snackbar(
          'Lokasi non-aktif',
          'Aktifkan Location/GPS di perangkat.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      if (!silent) {
        Get.snackbar(
          'Izin lokasi ditolak',
          'Berikan izin lokasi untuk menjalankan eksperimen.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return false;
    }
    return true;
  }

  LocationSettings _buildSettings({
    required int intervalSec,
    required LocationProfile profile,
  }) {
    final accuracy = profile == LocationProfile.gpsHigh
        ? LocationAccuracy.best
        : LocationAccuracy.low;
    final duration = Duration(seconds: intervalSec);

    if (Platform.isAndroid) {
      return AndroidSettings(
        accuracy: accuracy,
        distanceFilter: 0,
        intervalDuration: duration,
        forceLocationManager: profile == LocationProfile.gpsHigh,
      );
    }
    if (Platform.isIOS) {
      return AppleSettings(
        accuracy: accuracy,
        activityType: ActivityType.fitness,
        distanceFilter: 0,
        pauseLocationUpdatesAutomatically: false,
      );
    }
    return LocationSettings(
      accuracy: accuracy,
      distanceFilter: 0,
      timeLimit: duration,
    );
  }
}
