import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';

/// Hasil pilihan kamar
class RoomSelection {
  final String roomType; // 'single_fan' | 'single_ac' | 'deluxe'
  final String roomCode; // contoh: '1C'
  RoomSelection({required this.roomType, required this.roomCode});
}

/// Helper: list kode kamar per tipe
List<String> roomsForType(String type) {
  switch (type) {
    case 'single_fan':
      return const ['1C', '2C', '3C', '4C', '5C'];
    case 'single_ac':
      return const ['1B', '2B', '3B', '4B', '5B'];
    case 'deluxe':
      return const ['1A', '2A', '3A'];
    default:
      return const [];
  }
}

const _typeOrder = ['single_fan', 'single_ac', 'deluxe'];
const _typeLabel = {
  'single_fan': 'Single Fan',
  'single_ac': 'Single AC',
  'deluxe': 'Deluxe',
};

/// Bottom sheet: pilih tipe kamar + kode kamar
Future<RoomSelection?> selectRoomBottomSheet({
  String? initialType, // opsional: preselect dari filter (mis. 'single_ac')
}) async {
  return Get.bottomSheet<RoomSelection>(
    _RoomSelectorSheet(initialType: initialType),
    isScrollControlled: true,
    backgroundColor: AppColors.cardBackground,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
  );
}

class _RoomSelectorSheet extends StatefulWidget {
  final String? initialType;
  const _RoomSelectorSheet({this.initialType});

  @override
  State<_RoomSelectorSheet> createState() => _RoomSelectorSheetState();
}

class _RoomSelectorSheetState extends State<_RoomSelectorSheet> {
  late String selectedType;
  String? selectedCode;

  @override
  void initState() {
    super.initState();
    selectedType = _typeOrder.contains(widget.initialType)
        ? widget.initialType!
        : 'single_fan';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chips = roomsForType(selectedType);

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface
                        .withOpacity(Get.isDarkMode ? 0.3 : 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),

              // judul
              Text(
                'Pilih Kamar',
                style: Get.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),

              // ==== PILIH TIPE KAMAR ====
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _typeOrder.map((t) {
                  final sel = selectedType == t;
                  return ChoiceChip(
                    label: Text(_typeLabel[t]!),
                    selected: sel,
                    onSelected: (_) {
                      setState(() {
                        selectedType = t;
                        selectedCode =
                            null; // reset pilihan kode ketika ganti tipe
                      });
                    },
                    selectedColor:
                        theme.colorScheme.primary.withValues(alpha: .15),
                    labelStyle: TextStyle(
                      color: sel
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withOpacity(0.8),
                      fontWeight: FontWeight.w600,
                    ),
                    side: BorderSide(
                      color: sel
                          ? theme.colorScheme.primary.withValues(alpha: .45)
                          : theme.colorScheme.outline.withOpacity(0.3),
                    ),
                    shape: const StadiumBorder(),
                  );
                }).toList(),
              ),

              const SizedBox(height: 12),

              // ==== PILIH KODE KAMAR ====
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: chips.map((kode) {
                  final sel = selectedCode == kode;
                  return ChoiceChip(
                    label: Text(kode),
                    selected: sel,
                    onSelected: (_) => setState(() => selectedCode = kode),
                    selectedColor:
                        theme.colorScheme.primary.withValues(alpha: .15),
                    labelStyle: TextStyle(
                      color: sel
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withOpacity(0.8),
                      fontWeight: FontWeight.w600,
                    ),
                    side: BorderSide(
                      color: sel
                          ? theme.colorScheme.primary.withValues(alpha: .45)
                          : theme.colorScheme.outline.withOpacity(0.3),
                    ),
                    shape: const StadiumBorder(),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // tombol aksi
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back<RoomSelection?>(result: null),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: selectedCode == null
                          ? null
                          : () => Get.back<RoomSelection>(
                                result: RoomSelection(
                                  roomType: selectedType,
                                  roomCode: selectedCode!,
                                ),
                              ),
                      child: const Text('Konfirmasi'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
