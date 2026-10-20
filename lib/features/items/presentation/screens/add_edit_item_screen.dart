import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../../data/models/category.dart';
import '../../../../data/models/item.dart';
import '../../../home/providers/home_provider.dart';
import '../../data/item_repository.dart';
import '../../providers/add_edit_item_provider.dart';

/// Formatter ribuan untuk input Rupiah (mis. 1000000 -> 1.000.000).
class ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(text: '');
    }
    final formatted = _group(int.parse(digits));
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  static String _group(int n) {
    final s = n.toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
      b.write(s[i]);
    }
    return b.toString();
  }
}

int parseRupiah(String s) =>
    int.tryParse(s.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

class _PhotoEntry {
  final String id;
  final String? url; // foto existing
  final Uint8List? bytes; // foto baru
  final String ext;
  _PhotoEntry.existing(String u)
      : id = u,
        url = u,
        bytes = null,
        ext = 'jpg';
  _PhotoEntry.newFile(this.bytes, this.ext)
      : id = UniqueKey().toString(),
        url = null;
}

class AddEditItemScreen extends ConsumerStatefulWidget {
  final Item? item;
  const AddEditItemScreen({super.key, this.item});

  bool get isEditing => item != null;

  @override
  ConsumerState<AddEditItemScreen> createState() => _AddEditItemScreenState();
}

class _AddEditItemScreenState extends ConsumerState<AddEditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleC = TextEditingController();
  final _descC = TextEditingController();
  final _priceC = TextEditingController();
  final _depositC = TextEditingController();
  final _locationC = TextEditingController();

  final _photos = <_PhotoEntry>[];
  final _blocked = <DateTime>{};
  ItemCondition _condition = ItemCondition.baru;
  String? _categoryId;
  double? _lat;
  double? _lng;
  DateTime _focusedDay = DateTime.now();
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    if (item != null) {
      _titleC.text = item.title;
      _descC.text = item.description;
      _priceC.text = ThousandsFormatter._group(item.pricePerDay);
      _depositC.text =
          item.depositAmount > 0 ? ThousandsFormatter._group(item.depositAmount) : '';
      _locationC.text = item.location ?? '';
      _condition = item.condition ?? ItemCondition.baru;
      _categoryId = item.categoryId.isEmpty ? null : item.categoryId;
      _lat = item.latitude;
      _lng = item.longitude;
      _photos.addAll(item.imageUrls.map(_PhotoEntry.existing));
      _blocked.addAll(
          item.blockedDates.map((d) => DateTime(d.year, d.month, d.day)));
    }
  }

  @override
  void dispose() {
    _titleC.dispose();
    _descC.dispose();
    _priceC.dispose();
    _depositC.dispose();
    _locationC.dispose();
    super.dispose();
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? AppColors.error : null,
    ));
  }

  Future<void> _pickImages() async {
    if (_photos.length >= AppConstants.maxItemPhotos) {
      _snack('Maksimal ${AppConstants.maxItemPhotos} foto.');
      return;
    }
    try {
      final picked = await ImagePicker().pickMultiImage(imageQuality: 80);
      if (picked.isEmpty) return;
      for (final f in picked) {
        if (_photos.length >= AppConstants.maxItemPhotos) break;
        final bytes = await f.readAsBytes();
        final ext = f.name.toLowerCase().endsWith('.png') ? 'png' : 'jpg';
        _photos.add(_PhotoEntry.newFile(bytes, ext));
      }
      setState(() {});
    } catch (_) {
      _snack('Gagal memilih foto.', error: true);
    }
  }

  Future<void> _useMyLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _snack('Aktifkan layanan lokasi terlebih dahulu.', error: true);
        return;
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        _snack('Izin lokasi ditolak.', error: true);
        return;
      }
      final pos = await Geolocator.getCurrentPosition();

      // Ubah koordinat -> alamat yang mudah dibaca (reverse geocoding via HTTP).
      String address = '';
      try {
        address = await _reverseGeocode(pos.latitude, pos.longitude);
      } catch (_) {
        // Bisa gagal (mis. tanpa internet) -> fallback ke koordinat.
      }

      setState(() {
        _lat = pos.latitude;
        _lng = pos.longitude;
        // Selalu isi/timpa dengan alamat hasil deteksi (atau koordinat bila gagal).
        _locationC.text = address.isNotEmpty
            ? address
            : 'Lokasi saya (${pos.latitude.toStringAsFixed(4)}, '
                '${pos.longitude.toStringAsFixed(4)})';
      });
      _snack(address.isNotEmpty
          ? 'Lokasi terdeteksi: $address'
          : 'Lokasi berhasil diambil.');
    } on LocationServiceDisabledException {
      _snack('Layanan lokasi (GPS) belum aktif. Nyalakan dulu, ya.',
          error: true);
    } on PermissionDeniedException {
      _snack('Izin lokasi ditolak. Aktifkan lewat Pengaturan aplikasi.',
          error: true);
    } catch (e) {
      // Tampilkan pesan asli agar mudah didiagnosa
      // (mis. izin lokasi belum dideklarasikan di AndroidManifest.xml).
      _snack('Gagal mengambil lokasi: $e', error: true);
    }
  }

  /// Reverse geocoding via API gratis OpenStreetMap Nominatim (tanpa package
  /// native, cukup pakai `dio`). Mengembalikan alamat ringkas yang rapi.
  Future<String> _reverseGeocode(double lat, double lng) async {
    final dio = Dio();
    final res = await dio.get<Map<String, dynamic>>(
      'https://nominatim.openstreetmap.org/reverse',
      queryParameters: {
        'lat': lat,
        'lon': lng,
        'format': 'jsonv2',
        'accept-language': 'id',
        'zoom': 16,
      },
      options: Options(
        // Nominatim mewajibkan User-Agent unik yang mengidentifikasi aplikasi.
        headers: {'User-Agent': 'PinjamAja/1.0 (rental marketplace app)'},
        responseType: ResponseType.json,
      ),
    );
    final data = res.data;
    if (data == null) return '';
    final addr = data['address'];
    if (addr is Map) {
      return _formatNominatim(Map<String, dynamic>.from(addr));
    }
    // Fallback: pakai display_name bila struktur address tidak tersedia.
    final display = data['display_name'];
    return display is String ? display : '';
  }

  /// Susun alamat ringkas & rapi dari objek `address` Nominatim.
  String _formatNominatim(Map<String, dynamic> a) {
    String? pick(List<String> keys) {
      for (final k in keys) {
        final v = a[k];
        if (v is String && v.trim().isNotEmpty) return v.trim();
      }
      return null;
    }

    // Urut dari yang paling spesifik -> paling umum.
    final candidates = <String?>[
      pick(['village', 'suburb', 'neighbourhood', 'hamlet']),
      pick(['city_district', 'town', 'city', 'municipality']),
      pick(['county']),
      pick(['state']),
    ];
    // Buang duplikat sambil jaga urutan.
    final seen = <String>{};
    final unique = <String>[];
    for (final c in candidates) {
      if (c != null && seen.add(c.toLowerCase())) unique.add(c);
    }
    return unique.join(', ');
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null) {
      _snack('Pilih kategori barang.', error: true);
      return;
    }
    if (_photos.length < AppConstants.minItemPhotos) {
      _snack('Tambahkan minimal ${AppConstants.minItemPhotos} foto.',
          error: true);
      return;
    }
    FocusScope.of(context).unfocus();
    final controller = ref.read(addEditItemControllerProvider.notifier);

    // Unggah foto baru, lalu susun ulang URL sesuai urutan.
    final newUploads = [
      for (final p in _photos)
        if (p.bytes != null)
          ItemImageUpload(bytes: p.bytes!, fileExtension: p.ext),
    ];
    List<String> uploaded;
    setState(() => _uploading = true);
    try {
      uploaded = await controller.uploadImages(newUploads);
    } catch (e) {
      if (mounted) {
        _snack(e is AppException ? e.message : 'Gagal upload foto.',
            error: true);
      }
      return;
    } finally {
      if (mounted) setState(() => _uploading = false);
    }

    var u = 0;
    final urls = <String>[
      for (final p in _photos) p.url ?? uploaded[u++],
    ];

    final result = await controller.save(
      itemId: widget.item?.id,
      title: _titleC.text,
      categoryId: _categoryId!,
      condition: _condition,
      description: _descC.text,
      pricePerDay: parseRupiah(_priceC.text),
      depositAmount: parseRupiah(_depositC.text),
      location: _locationC.text,
      latitude: _lat,
      longitude: _lng,
      imageUrls: urls,
      blockedDates: _blocked.toList(),
    );

    if (!mounted) return;
    if (result != null) {
      _snack(widget.isEditing
          ? 'Barang berhasil diperbarui.'
          : 'Barang berhasil dipublikasikan.');
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(addEditItemControllerProvider, (_, next) {
      next.whenOrNull(error: (e, _) {
        _snack(e is AppException ? e.message : 'Terjadi kesalahan.',
            error: true);
      });
    });

    final saving = ref.watch(addEditItemControllerProvider).isLoading;
    final busy = saving || _uploading;
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Barang' : 'Tambah Barang'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _label('Foto Barang (maks ${AppConstants.maxItemPhotos})'),
              const SizedBox(height: 8),
              _photoSection(),
              const SizedBox(height: 20),
              _label('Judul'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleC,
                maxLength: AppConstants.maxTitleLength,
                decoration: const InputDecoration(
                    hintText: 'Contoh: Kamera Sony A6400'),
                validator: (v) => (v == null || v.trim().length < 3)
                    ? 'Judul minimal 3 karakter'
                    : null,
              ),
              const SizedBox(height: 8),
              _label('Kategori'),
              const SizedBox(height: 8),
              categoriesAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('Gagal memuat kategori',
                    style: TextStyle(color: AppColors.error)),
                data: (cats) => _categoryDropdown(cats),
              ),
              const SizedBox(height: 20),
              _label('Kondisi'),
              const SizedBox(height: 8),
              _conditionPicker(),
              const SizedBox(height: 20),
              _label('Deskripsi (min ${AppConstants.minDescriptionLength} karakter)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descC,
                maxLines: 5,
                decoration: const InputDecoration(
                    hintText: 'Jelaskan detail, kelengkapan, dan aturan sewa'),
                validator: (v) =>
                    (v == null || v.trim().length < AppConstants.minDescriptionLength)
                        ? 'Deskripsi minimal ${AppConstants.minDescriptionLength} karakter'
                        : null,
              ),
              const SizedBox(height: 12),
              _label('Harga Sewa per Hari'),
              const SizedBox(height: 8),
              _rupiahField(
                controller: _priceC,
                hint: '0',
                validator: (v) => parseRupiah(v ?? '') <= 0
                    ? 'Harga harus lebih dari 0'
                    : null,
              ),
              const SizedBox(height: 12),
              _label('Deposit (min ${(AppConstants.depositMinRate * 100).round()}% dari harga sewa)'),
              const SizedBox(height: 8),
              _rupiahField(
                controller: _depositC,
                hint: '0',
                // Deposit wajib >= depositMinRate (mis. 100%) dari harga/hari,
                // supaya cukup untuk meng-cover denda keterlambatan.
                validator: (v) {
                  final price = parseRupiah(_priceC.text);
                  final deposit = parseRupiah(v ?? '');
                  final minDeposit =
                      (price * AppConstants.depositMinRate).round();
                  if (price > 0 && deposit < minDeposit) {
                    return 'Deposit minimal Rp ${ThousandsFormatter._group(minDeposit)} '
                        '(${(AppConstants.depositMinRate * 100).round()}% dari harga sewa)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _label('Lokasi'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _locationC,
                decoration: const InputDecoration(
                    hintText: 'Contoh: Tebet, Jakarta Selatan'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Lokasi wajib diisi'
                    : null,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _useMyLocation,
                  icon: const Icon(Icons.my_location, size: 18),
                  label: const Text('Pakai Lokasi Saya'),
                ),
              ),
              const SizedBox(height: 12),
              _label('Tanggal Tidak Tersedia'),
              const SizedBox(height: 4),
              Text('${_blocked.length} tanggal dipilih',
                  style: const TextStyle(
                      color: AppColors.textTertiary, fontSize: 12)),
              const SizedBox(height: 8),
              _blockedCalendar(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: busy ? null : _submit,
                  child: busy
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white),
                        )
                      : Text(widget.isEditing
                          ? 'Update'
                          : 'Simpan & Publikasikan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14));

  Widget _photoSection() {
    return SizedBox(
      height: 104,
      child: Row(
        children: [
          Expanded(
            child: ReorderableListView.builder(
              scrollDirection: Axis.horizontal,
              buildDefaultDragHandles: true,
              itemCount: _photos.length,
              onReorder: (oldI, newI) {
                setState(() {
                  if (newI > oldI) newI -= 1;
                  final e = _photos.removeAt(oldI);
                  _photos.insert(newI, e);
                });
              },
              itemBuilder: (context, i) {
                final p = _photos[i];
                return Padding(
                  key: ValueKey(p.id),
                  padding: const EdgeInsets.only(right: 10),
                  child: _PhotoTile(
                    entry: p,
                    onRemove: () => setState(() => _photos.removeAt(i)),
                  ),
                );
              },
            ),
          ),
          if (_photos.length < AppConstants.maxItemPhotos)
            GestureDetector(
              onTap: _pickImages,
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo_outlined,
                        color: AppColors.textTertiary),
                    SizedBox(height: 4),
                    Text('Tambah',
                        style: TextStyle(
                            fontSize: 11, color: AppColors.textTertiary)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _categoryDropdown(List<Category> cats) {
    final value =
        cats.any((c) => c.id == _categoryId) ? _categoryId : null;
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: const InputDecoration(hintText: 'Pilih kategori'),
      items: [
        for (final c in cats)
          DropdownMenuItem(value: c.id, child: Text(c.name)),
      ],
      onChanged: (v) => setState(() => _categoryId = v),
      validator: (v) => v == null ? 'Kategori wajib dipilih' : null,
    );
  }

  Widget _conditionPicker() {
    return SegmentedButton<ItemCondition>(
      segments: [
        for (final c in ItemCondition.values)
          ButtonSegment(value: c, label: Text(c.label)),
      ],
      selected: {_condition},
      showSelectedIcon: false,
      onSelectionChanged: (s) => setState(() => _condition = s.first),
    );
  }

  Widget _rupiahField({
    required TextEditingController controller,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [ThousandsFormatter()],
      decoration: InputDecoration(
        prefixText: 'Rp ',
        hintText: hint,
      ),
      validator: validator,
    );
  }

  Widget _blockedCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(8),
      child: TableCalendar<void>(
        firstDay: DateTime.now(),
        lastDay: DateTime.now().add(const Duration(days: 365)),
        focusedDay: _focusedDay,
        headerStyle: const HeaderStyle(
            formatButtonVisible: false, titleCentered: true),
        availableGestures: AvailableGestures.horizontalSwipe,
        selectedDayPredicate: (day) =>
            _blocked.contains(DateTime(day.year, day.month, day.day)),
        onPageChanged: (d) => _focusedDay = d,
        onDaySelected: (selected, focused) {
          final key = DateTime(selected.year, selected.month, selected.day);
          setState(() {
            if (_blocked.contains(key)) {
              _blocked.remove(key);
            } else {
              _blocked.add(key);
            }
            _focusedDay = focused;
          });
        },
        calendarStyle: const CalendarStyle(
          selectedDecoration: BoxDecoration(
            color: AppColors.error,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final _PhotoEntry entry;
  final VoidCallback onRemove;
  const _PhotoTile({required this.entry, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 88,
            height: 88,
            child: entry.url != null
                ? Image.network(entry.url!, fit: BoxFit.cover)
                : Image.memory(entry.bytes!, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 2,
          right: 2,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(2),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}