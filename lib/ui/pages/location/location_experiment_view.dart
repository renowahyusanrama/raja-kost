import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../../app/theme/app_colors.dart';
import '../../../controllers/location_experiment_controller.dart';
import '../../shared/widgets/app_overflow_menu.dart';
import '../../shared/widgets/custom_app_bar.dart';

class LocationExperimentView extends GetView<LocationExperimentController> {
  const LocationExperimentView({super.key});

  String _experimentLabel(ExperimentType type) {
    switch (type) {
      case ExperimentType.outdoorStatic:
        return 'Statis Outdoor';
      case ExperimentType.indoorStatic:
        return 'Statis Indoor';
      case ExperimentType.dynamicMove:
        return 'Dinamis (Live)';
    }
  }

  String _profileLabel(LocationProfile profile) {
    switch (profile) {
      case LocationProfile.gpsHigh:
        return 'GPS (High)';
      case LocationProfile.networkLike:
        return 'Network-like';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(
              title: 'Eksperimen Lokasi',
              subtitle: 'Bandingkan GPS vs Network',
              showBackButton: true,
              leading: AppOverflowMenu(),
            ),
            Expanded(
              child: Obx(
                () => SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: Column(
                    children: [
                      _InfoBanner(
                        icon: Icons.science_outlined,
                        message:
                            'Ikuti 3 eksperimen: statis outdoor, statis indoor, dan dinamis. '
                            'Catat lat/lng, akurasi, timestamp, dan speed (jika bergerak).',
                      ),
                      const SizedBox(height: 12),
                      _SectionCard(
                        title: 'Peta & Jalur',
                        child: _MapPanel(controller: controller),
                      ),
                      const SizedBox(height: 12),
                      _SectionCard(
                        title: 'Pengaturan Eksperimen',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Jenis Eksperimen',
                              style: Get.textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: ExperimentType.values.map((exp) {
                                final selected =
                                    controller.selectedExperiment.value == exp;
                                return ChoiceChip(
                                  label: Text(_experimentLabel(exp)),
                                  selected: selected,
                                  onSelected: controller.isTracking.value
                                      ? null
                                      : (_) => controller
                                          .selectedExperiment.value = exp,
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Mode Provider',
                              style: Get.textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: LocationProfile.values.map((prof) {
                                final selected =
                                    controller.selectedProfile.value == prof;
                                return ChoiceChip(
                                  label: Text(_profileLabel(prof)),
                                  selected: selected,
                                  onSelected: controller.isTracking.value
                                      ? null
                                      : (_) => controller
                                          .selectedProfile.value = prof,
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Interval pencatatan (${controller.intervalSeconds.value}s)',
                                        style:
                                            Get.textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Slider(
                                        min: 5,
                                        max: 30,
                                        divisions: 25,
                                        value: controller.intervalSeconds.value
                                            .toDouble(),
                                        onChanged: controller.isTracking.value
                                            ? null
                                            : (v) => controller.intervalSeconds
                                                .value = v.round(),
                                      ),
                                      Text(
                                        'Atur 10-20 detik untuk eksperimen statis, atau 1 detik (Live) untuk dinamis.',
                                        style: Get.textTheme.bodySmall
                                            ?.copyWith(
                                                color: Get.theme.colorScheme
                                                    .onSurfaceVariant),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: controller.isTracking.value
                                        ? controller.stopTracking
                                        : () => controller.startTracking(
                                              liveMode: false,
                                            ),
                                    icon: controller.isTracking.value
                                        ? const Icon(Icons.stop_circle)
                                        : const Icon(Icons.play_arrow),
                                    label: Text(
                                      controller.isTracking.value
                                          ? 'Stop Logging'
                                          : 'Mulai Logging',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: controller.isTracking.value ||
                                            controller
                                                    .selectedExperiment.value !=
                                                ExperimentType.dynamicMove
                                        ? null
                                        : () => controller.startTracking(
                                              liveMode: true,
                                            ),
                                    icon: const Icon(Icons.wifi_tethering),
                                    label: const Text('Live 1 dtk'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  controller.statusText.value.isEmpty
                                      ? 'Siap memulai eksperimen.'
                                      : controller.statusText.value,
                                  style: Get.textTheme.bodyMedium?.copyWith(
                                    color:
                                        Get.theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const Spacer(),
                                TextButton.icon(
                                  onPressed: controller.currentLog.isEmpty
                                      ? null
                                      : controller.resetCurrentLog,
                                  icon: const Icon(Icons.delete_outline),
                                  label: const Text('Reset log'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _SectionCard(
                        title: 'Sampel Terakhir',
                        child: controller.lastSample.value == null
                            ? const Text('Belum ada data. Mulai logging dulu.')
                            : _LastSampleInfo(
                                sample: controller.lastSample.value!,
                                profileLabel: _profileLabel(
                                    controller.lastSample.value!.profile),
                              ),
                      ),
                      const SizedBox(height: 12),
                      _SectionCard(
                        title:
                            'Log ${_experimentLabel(controller.selectedExperiment.value)} | ${_profileLabel(controller.selectedProfile.value)}',
                        child: _LogTable(
                          samples: controller.currentLog,
                          avgAccuracy:
                              controller.averageAccuracy(controller.currentLog),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _SectionCard(
                        title: 'Panduan Singkat',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                                '1) Outdoor statis: pilih titik terbuka, set interval 10-20s, jalankan mode Network lalu GPS.'),
                            SizedBox(height: 4),
                            Text(
                                '2) Indoor statis: ulangi di dalam ruangan, bandingkan akurasi Network vs GPS.'),
                            SizedBox(height: 4),
                            Text(
                                '3) Dinamis: pilih mode dinamis, gunakan Live 1 dtk saat berjalan mengelilingi area.'),
                            SizedBox(height: 4),
                            Text(
                                'Catat perbedaan akurasi, waktu fix pertama, kehalusan pergerakan, dan jalur yang terbentuk.'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.message, required this.icon});
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Get.textTheme.bodyMedium?.copyWith(
                color: Get.theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Get.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _MapPanel extends StatefulWidget {
  const _MapPanel({required this.controller});
  final LocationExperimentController controller;

  @override
  State<_MapPanel> createState() => _MapPanelState();
}

class _MapPanelState extends State<_MapPanel> {
  final MapController _mapCtrl = MapController();
  final Distance _distance = const Distance();
  LatLng? _lastCentered;
  double _currentZoom = 15;

  @override
  Widget build(BuildContext context) {
    const fallback = LatLng(0, 0);

    return Obx(() {
      final last = widget.controller.lastSample.value;
      final points = widget.controller.currentLog
          .map((s) => LatLng(s.latitude, s.longitude))
          .toList();

      final markers = <Marker>[
        if (last != null)
          Marker(
            point: LatLng(last.latitude, last.longitude),
            width: 40,
            height: 40,
            child: const Icon(Icons.location_on, color: AppColors.primary),
          ),
      ];

      final circles = <CircleMarker>[
        if (last != null)
          CircleMarker(
            point: LatLng(last.latitude, last.longitude),
            radius: last.accuracy,
            useRadiusInMeter: true,
            color: AppColors.primary.withValues(alpha: 0.15),
            borderColor: AppColors.primary.withValues(alpha: 0.4),
            borderStrokeWidth: 1,
          ),
      ];

      final polylines = <Polyline>[
        if (points.length > 1)
          Polyline(
            points: points,
            color: AppColors.primary,
            strokeWidth: 4,
          ),
      ];

      if (last != null) {
        final pos = LatLng(last.latitude, last.longitude);
        final shouldMove = _lastCentered == null ||
            _distance(pos, _lastCentered!) >
                last.accuracy.clamp(5, 80); // hindari jitter saat diam
        if (shouldMove) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _mapCtrl.move(pos, _currentZoom);
            _lastCentered = pos;
          });
        }
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 320,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Get.theme.colorScheme.outlineVariant.withValues(
                  alpha: 0.4,
                ),
              ),
            ),
            child: FlutterMap(
              mapController: _mapCtrl,
              options: MapOptions(
                initialCenter: last != null
                    ? LatLng(last.latitude, last.longitude)
                    : fallback,
                initialZoom: last != null ? 15 : 1,
                onPositionChanged: (pos, hasGesture) {
                  _currentZoom = pos.zoom ?? _currentZoom;
                  _lastCentered ??= pos.center;
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: 'com.rajakost.app',
                ),
                if (polylines.isNotEmpty) PolylineLayer(polylines: polylines),
                if (circles.isNotEmpty) CircleLayer(circles: circles),
                if (markers.isNotEmpty) MarkerLayer(markers: markers),
              ],
            ),
          ),
          if (last == null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Mulai logging untuk menampilkan marker pada peta.',
                style: Get.textTheme.bodySmall?.copyWith(
                  color: Get.theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      );
    });
  }
}

class _LastSampleInfo extends StatelessWidget {
  const _LastSampleInfo({
    required this.sample,
    required this.profileLabel,
  });

  final LocationSample sample;
  final String profileLabel;

  @override
  Widget build(BuildContext context) {
    final speedText = sample.speed != null
        ? '${(sample.speed! * 3.6).toStringAsFixed(1)} km/jam'
        : '-';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Provider: $profileLabel',
          style: Get.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            _Chip(label: 'Lat', value: sample.latitude.toStringAsFixed(6)),
            _Chip(label: 'Lng', value: sample.longitude.toStringAsFixed(6)),
            _Chip(
                label: 'Accuracy',
                value: '${sample.accuracy.toStringAsFixed(1)} m'),
            _Chip(label: 'Speed', value: speedText),
            _Chip(label: 'Waktu', value: sample.formattedTime),
          ],
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: Get.theme.colorScheme.outlineVariant.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: Get.textTheme.bodySmall?.copyWith(
              color: Get.theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            value,
            style: Get.textTheme.bodySmall?.copyWith(
              color: Get.theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _LogTable extends StatelessWidget {
  const _LogTable({
    required this.samples,
    required this.avgAccuracy,
  });

  final List<LocationSample> samples;
  final double? avgAccuracy;

  @override
  Widget build(BuildContext context) {
    if (samples.isEmpty) {
      return const Text('Belum ada data untuk mode ini.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (avgAccuracy != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Rata-rata akurasi: ${avgAccuracy!.toStringAsFixed(1)} m (${samples.length} sampel)',
              style: Get.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Get.theme.colorScheme.outlineVariant.withOpacity(0.4),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Get.theme.colorScheme.surface,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  children: const [
                    _TableHeader(flex: 1, label: '#'),
                    _TableHeader(flex: 3, label: 'Lat / Lng'),
                    _TableHeader(flex: 2, label: 'Accuracy'),
                    _TableHeader(flex: 2, label: 'Speed'),
                    _TableHeader(flex: 2, label: 'Time'),
                  ],
                ),
              ),
              ...samples.asMap().entries.map(
                (entry) {
                  final idx = entry.key;
                  final sample = entry.value;
                  final speedText = sample.speed != null
                      ? '${(sample.speed! * 3.6).toStringAsFixed(1)} km/jam'
                      : '-';
                  final isEven = idx.isEven;
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    decoration: BoxDecoration(
                      color: isEven
                          ? Get.theme.colorScheme.surfaceVariant
                              .withValues(alpha: 0.35)
                          : Colors.transparent,
                    ),
                    child: Row(
                      children: [
                        _TableCell(flex: 1, child: Text('${idx + 1}')),
                        _TableCell(
                          flex: 3,
                          child: Text(
                              '${sample.latitude.toStringAsFixed(5)}, ${sample.longitude.toStringAsFixed(5)}'),
                        ),
                        _TableCell(
                          flex: 2,
                          child:
                              Text('${sample.accuracy.toStringAsFixed(1)} m'),
                        ),
                        _TableCell(flex: 2, child: Text(speedText)),
                        _TableCell(
                          flex: 2,
                          child: Text(sample.formattedTime),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader({required this.flex, required this.label});
  final int flex;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: Get.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  const _TableCell({required this.flex, required this.child});
  final int flex;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: child,
    );
  }
}
