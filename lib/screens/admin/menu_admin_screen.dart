import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:file_picker/file_picker.dart';

import '../../models/menu_component.dart';
import '../../models/menu_data.dart';
import '../../services/app_state.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/section_card.dart';

// Helper to load file bytes on desktop/mobile without breaking web compile
import 'dart:io' as io;

class MenuAdminScreen extends StatefulWidget {
  const MenuAdminScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<MenuAdminScreen> createState() => _MenuAdminScreenState();
}

class _MenuAdminScreenState extends State<MenuAdminScreen> {
  late MenuData _localMenu;
  Uint8List? _menuImageBytes;

  @override
  void initState() {
    super.initState();
    _localMenu = widget.appState.menuData;
    _cacheBase64Image();
  }

  void _cacheBase64Image() {
    final String imageUrl = _localMenu.imageUrl.trim();
    if (imageUrl.startsWith('data:image/') && imageUrl.contains('base64,')) {
      try {
        final String base64Str = imageUrl.split('base64,')[1];
        _menuImageBytes = base64Decode(base64Str);
      } catch (e) {
        debugPrint('Error caching base64 image: $e');
        _menuImageBytes = null;
      }
    } else {
      _menuImageBytes = null;
    }
  }

  bool get _isModified {
    return jsonEncode(_localMenu.toMap()) !=
        jsonEncode(widget.appState.menuData.toMap());
  }

  void _updateItem(int id, {String? kategori, String? nama, String? icon}) {
    final List<MenuComponent> updatedItems = _localMenu.items.map((item) {
      if (item.id != id) {
        return item;
      }

      return item.copyWith(kategori: kategori, nama: nama, icon: icon);
    }).toList();

    setState(() {
      _localMenu = _localMenu.copyWith(items: updatedItems);
    });
  }

  void _clearAllComponents() {
    final List<MenuComponent> clearedItems = _localMenu.items.map((item) {
      return item.copyWith(kategori: '', nama: '', icon: '');
    }).toList();

    setState(() {
      _localMenu = _localMenu.copyWith(items: clearedItems);
    });
  }

  void _addNewComponent() {
    if (_localMenu.items.length >= 7) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Komposisi makanan maksimal 7 sajian.'),
        ),
      );
      return;
    }

    final int newId = _localMenu.items.isEmpty
        ? 1
        : _localMenu.items.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1;

    final MenuComponent newComponent = MenuComponent(
      id: newId,
      kategori: 'Lainnya',
      nama: '',
      icon: '🍱',
    );

    setState(() {
      _localMenu = _localMenu.copyWith(
        items: <MenuComponent>[..._localMenu.items, newComponent],
      );
    });
  }

  void _deleteComponent(int id) {
    setState(() {
      _localMenu = _localMenu.copyWith(
        items: _localMenu.items.where((e) => e.id != id).toList(),
      );
    });
  }

  String? _validateFields() {
    if (_localMenu.judul.trim().isEmpty) {
      return 'judul menu wajib di isi';
    }

    if (_localMenu.imageUrl.trim().isEmpty) {
      return 'foto menu makanan wajib di isi';
    }

    if (_localMenu.gizi.kalori <= 0 ||
        _localMenu.gizi.protein <= 0 ||
        _localMenu.gizi.karbohidrat <= 0 ||
        _localMenu.gizi.lemak <= 0) {
      return 'kandungan gizi total wajib di isi';
    }

    if (_localMenu.items.isEmpty) {
      return 'rincian komposisi wajib di isi';
    }

    for (final MenuComponent item in _localMenu.items) {
      if (item.icon.trim().isEmpty ||
          item.kategori.trim().isEmpty ||
          item.nama.trim().isEmpty) {
        return 'rincian komposisi wajib di isi';
      }
    }

    return null; // Valid!
  }

  Future<void> _pickAndCropImage() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true, // Crucial for both Web and Mobile/Desktop to load bytes
      );

      if (result == null) {
        return;
      }

      Uint8List? imageBytes;

      if (kIsWeb) {
        imageBytes = result.files.single.bytes;
      } else {
        final String? pickedPath = result.files.single.path;
        if (pickedPath != null) {
          imageBytes = await io.File(pickedPath).readAsBytes();
        } else {
          imageBytes = result.files.single.bytes;
        }
      }

      if (imageBytes == null) {
        return;
      }

      if (!mounted) return;

      final String? croppedBase64 = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => ImageCropDialog(imageBytes: imageBytes!),
      );

      if (croppedBase64 != null) {
        Uint8List? decoded;
        try {
          final String base64Str = croppedBase64.split('base64,')[1];
          decoded = base64Decode(base64Str);
        } catch (e) {
          debugPrint('Error decoding cropped base64: $e');
        }
        setState(() {
          _localMenu = _localMenu.copyWith(imageUrl: croppedBase64);
          _menuImageBytes = decoded;
        });
      }
    } catch (e) {
      debugPrint('Error picking menu image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih gambar menu: $e')),
        );
      }
    }
  }

  Widget _buildImagePreviewWidget() {
    final String imageUrl = _localMenu.imageUrl.trim();
    if (imageUrl.isEmpty) {
      return const Center(
        child: Text(
          'Tidak ada gambar',
          style: TextStyle(color: AppColors.slate500),
        ),
      );
    }

    if (_menuImageBytes != null) {
      return Image.memory(
        _menuImageBytes!,
        fit: BoxFit.cover,
      );
    }

    try {
      if (imageUrl.startsWith('data:image/') && imageUrl.contains('base64,')) {
        final String base64Str = imageUrl.split('base64,')[1];
        final Uint8List bytes = base64Decode(base64Str);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Center(
            child: Text(
              'Gagal memuat gambar memori',
              style: TextStyle(color: AppColors.slate500),
            ),
          ),
        );
      } else if (imageUrl.startsWith('http')) {
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Center(
            child: Text(
              'Gagal memuat gambar URL',
              style: TextStyle(color: AppColors.slate500),
            ),
          ),
        );
      } else {
        if (kIsWeb) {
          return const Center(
            child: Text(
              'Path lokal tidak didukung di Web',
              style: TextStyle(color: AppColors.slate500),
            ),
          );
        } else {
          return Image.file(
            io.File(imageUrl),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Center(
              child: Text(
                'Gagal memuat file gambar',
                style: TextStyle(color: AppColors.slate500),
              ),
            ),
          );
        }
      }
    } catch (e) {
      return const Center(
        child: Text(
          'Format gambar tidak dikenali',
          style: TextStyle(color: AppColors.slate500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 110), // Bottom padding to clear floating button
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Manajemen Menu MBG',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Atur sajian dan detail makanan yang dibagikan hari ini',
                          style: TextStyle(color: AppColors.slate500),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: widget.appState.useDummyMenuFallback 
                          ? AppColors.emeraldSoft 
                          : AppColors.slate100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: widget.appState.useDummyMenuFallback 
                            ? AppColors.emerald.withOpacity(0.3) 
                            : AppColors.slate200,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          widget.appState.useDummyMenuFallback ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                          size: 18,
                          color: widget.appState.useDummyMenuFallback ? AppColors.emerald : AppColors.slate500,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Gunakan Dummy',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: widget.appState.useDummyMenuFallback ? AppColors.emeraldDark : AppColors.slate600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Switch(
                          value: widget.appState.useDummyMenuFallback,
                          onChanged: (bool value) {
                            widget.appState.toggleDummyMenuFallback(value);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(value 
                                    ? 'Data dummy akan ditampilkan ke publik jika menu kosong.' 
                                    : 'Data dummy tidak akan ditampilkan.'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          activeColor: AppColors.emerald,
                          activeTrackColor: AppColors.emeraldSoft,
                          inactiveThumbColor: AppColors.slate400,
                          inactiveTrackColor: AppColors.slate200,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Informasi Umum & Gambar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.slate900,
                      ),
                    ),
                    const SizedBox(height: 18),
                    LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints constraints) {
                        final bool isWide = constraints.maxWidth > 760;

                        final Widget imageEditor = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text(
                              'Judul Menu',
                              style: TextStyle(
                                color: AppColors.slate700,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              initialValue: _localMenu.judul,
                              decoration: const InputDecoration(
                                hintText: 'Misal: Nasi Ayam Teriyaki Pedas Manis',
                                prefixIcon: Icon(Icons.restaurant_menu_rounded),
                              ),
                              onChanged: (String value) {
                                setState(() {
                                  _localMenu = _localMenu.copyWith(judul: value);
                                });
                              },
                            ),
                            const SizedBox(height: 18),
                            const Text(
                              'Foto Menu Makanan',
                              style: TextStyle(
                                color: AppColors.slate700,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            CustomButton(
                              label: 'Pilih Foto dari Galeri',
                              icon: Icons.photo_library_rounded,
                              isOutlined: true,
                              foregroundColor: AppColors.emerald,
                              borderColor: AppColors.emeraldSoft,
                              onPressed: _pickAndCropImage,
                            ),
                          ],
                        );

                        final Widget imagePreview = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text(
                              'Preview Gambar',
                              style: TextStyle(
                                color: AppColors.slate700,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 180,
                              width: double.infinity,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                color: AppColors.slate50,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.slate200),
                              ),
                              child: _buildImagePreviewWidget(),
                            ),
                          ],
                        );

                        if (isWide) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(child: imageEditor),
                              const SizedBox(width: 18),
                              Expanded(child: imagePreview),
                            ],
                          );
                        }

                        return Column(
                          children: <Widget>[
                            imageEditor,
                            const SizedBox(height: 18),
                            imagePreview,
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Kandungan Gizi Total',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.slate900,
                      ),
                    ),
                    const SizedBox(height: 18),
                    LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints constraints) {
                        final int columns = constraints.maxWidth > 840 ? 4 : 2;
                        return GridView.count(
                          crossAxisCount: columns,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 2.2,
                          children: <Widget>[
                            _NutritionField(
                              label: 'Kalori (kcal)',
                              initialValue: _localMenu.gizi.kalori.toString(),
                              onChanged: (String value) {
                                setState(() {
                                  _localMenu = _localMenu.copyWith(
                                    gizi: _localMenu.gizi.copyWith(
                                      kalori: int.tryParse(value) ?? 0,
                                    ),
                                  );
                                });
                              },
                            ),
                            _NutritionField(
                              label: 'Protein (g)',
                              initialValue: _localMenu.gizi.protein.toString(),
                              onChanged: (String value) {
                                setState(() {
                                  _localMenu = _localMenu.copyWith(
                                    gizi: _localMenu.gizi.copyWith(
                                      protein: int.tryParse(value) ?? 0,
                                    ),
                                  );
                                });
                              },
                            ),
                            _NutritionField(
                              label: 'Karbohidrat (g)',
                              initialValue: _localMenu.gizi.karbohidrat.toString(),
                              onChanged: (String value) {
                                setState(() {
                                  _localMenu = _localMenu.copyWith(
                                    gizi: _localMenu.gizi.copyWith(
                                      karbohidrat: int.tryParse(value) ?? 0,
                                    ),
                                  );
                                });
                              },
                            ),
                            _NutritionField(
                              label: 'Lemak (g)',
                              initialValue: _localMenu.gizi.lemak.toString(),
                              onChanged: (String value) {
                                setState(() {
                                  _localMenu = _localMenu.copyWith(
                                    gizi: _localMenu.gizi.copyWith(
                                      lemak: int.tryParse(value) ?? 0,
                                    ),
                                  );
                                });
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        const Expanded(
                          child: Text(
                            'Rincian Komposisi Makanan (Maks 7)',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.slate900,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            if (_localMenu.items.isNotEmpty)
                              TextButton.icon(
                                onPressed: _clearAllComponents,
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.red,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  backgroundColor: AppColors.redSoft,
                                ),
                                icon: const Icon(Icons.delete_sweep_rounded, size: 18),
                                label: const Text(
                                  'Clear',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    if (_localMenu.items.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                        decoration: BoxDecoration(
                          color: AppColors.slate50,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.slate200),
                        ),
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
                                color: AppColors.slate100,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.no_food_rounded,
                                color: AppColors.slate400,
                                size: 36,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Belum Ada Rincian Komposisi',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.slate800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Tambahkan hingga 7 sajian piring isi komposisi hari ini.',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.slate500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ..._localMenu.items.asMap().entries.map((entry) {
                      final int index = entry.key;
                      final MenuComponent item = entry.value;

                      return _MenuComponentCard(
                        key: ValueKey('card_${item.id}'),
                        index: index,
                        item: item,
                        onDelete: () => _deleteComponent(item.id),
                        onUpdate: ({String? kategori, String? nama, String? icon}) {
                          _updateItem(item.id, kategori: kategori, nama: nama, icon: icon);
                        },
                        availableEmojis: availableEmojis,
                      );
                    }),
                    if (_localMenu.items.length < 7) ...<Widget>[
                      const SizedBox(height: 12),
                      Center(
                        child: CustomButton(
                          label: 'Tambah Sajian Komposisi',
                          icon: Icons.add_rounded,
                          isOutlined: true,
                          foregroundColor: AppColors.emerald,
                          borderColor: AppColors.emeraldSoft,
                          onPressed: _addNewComponent,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        // Premium Floating Save Button on the bottom right of the page
        Positioned(
          bottom: 24,
          right: 24,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 250),
            scale: _isModified ? 1.0 : 0.95,
            curve: Curves.easeOutBack,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              opacity: _isModified ? 1.0 : 0.85,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: _isModified ? const Color(0x3D008955) : const Color(0x1F000000),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: _isModified ? AppColors.emerald : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: BorderSide(
                      color: _isModified ? Colors.transparent : AppColors.slate200,
                      width: 1.5,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: _isModified
                        ? () {
                            final String? errorMsg = _validateFields();
                            if (errorMsg != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(errorMsg),
                                  backgroundColor: AppColors.red,
                                ),
                              );
                              return;
                            }
                            widget.appState.updateMenuData(_localMenu);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Perubahan menu berhasil disimpan.'),
                              ),
                            );
                            setState(() {});
                          }
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 15),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            _isModified ? Icons.check_circle_rounded : Icons.edit_rounded,
                            color: _isModified ? Colors.white : AppColors.slate500,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _isModified ? 'Simpan Perubahan' : 'Menu Tersimpan (Edit Mode)',
                            style: TextStyle(
                              color: _isModified ? Colors.white : AppColors.slate600,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NutritionField extends StatefulWidget {
  const _NutritionField({
    required this.label,
    required this.initialValue,
    required this.onChanged,
  });

  final String label;
  final String initialValue;
  final ValueChanged<String> onChanged;

  @override
  State<_NutritionField> createState() => _NutritionFieldState();
}

class _NutritionFieldState extends State<_NutritionField> {
  late TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant _NutritionField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
      ],
      decoration: InputDecoration(labelText: widget.label),
      onChanged: (String value) {
        if (_debounce?.isActive ?? false) _debounce!.cancel();
        _debounce = Timer(const Duration(milliseconds: 250), () {
          widget.onChanged(value);
        });
      },
    );
  }
}

class _MenuComponentCard extends StatefulWidget {
  const _MenuComponentCard({
    super.key,
    required this.index,
    required this.item,
    required this.onDelete,
    required this.onUpdate,
    required this.availableEmojis,
  });

  final int index;
  final MenuComponent item;
  final VoidCallback onDelete;
  final Function({String? kategori, String? nama, String? icon}) onUpdate;
  final List<String> availableEmojis;

  @override
  State<_MenuComponentCard> createState() => _MenuComponentCardState();
}

class _MenuComponentCardState extends State<_MenuComponentCard> {
  late TextEditingController _kategoriController;
  late TextEditingController _namaController;
  Timer? _debounce;

  static const Map<String, List<String>> _kategoriEmojis = <String, List<String>>{
    'Karbohidrat': <String>['🍚', '🍞', '🥔', '🍠', '🍝', '🥐', '🍜'],
    'Protein': <String>['🍗', '🥩', '🍖', '🥚', '🐟', '🦐', '🍔', '🌭'],
    'Sayuran': <String>['🥦', '🥬', '🥕', '🥒', '🍆', '🍅'],
    'Buah-buahan': <String>['🍎', '🍌', '🍉', '🍇', '🍓', '🍊'],
    'Kalsium': <String>['🥛', '🧀', '🍼'],
    'Lemak': <String>['🧈', '🥜', '🥑'],
    'Lainnya': <String>['🍲', '🥗', '🍱', '🥣', '🍛'],
  };

  static const List<String> _kategoriList = <String>[
    'Karbohidrat',
    'Protein',
    'Sayuran',
    'Buah-buahan',
    'Kalsium',
    'Lemak',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    _kategoriController = TextEditingController(text: widget.item.kategori);
    _namaController = TextEditingController(text: widget.item.nama);
  }

  @override
  void didUpdateWidget(covariant _MenuComponentCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item.kategori != oldWidget.item.kategori &&
        widget.item.kategori != _kategoriController.text) {
      _kategoriController.text = widget.item.kategori;
    }
    if (widget.item.nama != oldWidget.item.nama &&
        widget.item.nama != _namaController.text) {
      _namaController.text = widget.item.nama;
    }
  }

  @override
  void dispose() {
    _kategoriController.dispose();
    _namaController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onTextChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      widget.onUpdate(
        kategori: _kategoriController.text,
        nama: _namaController.text,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final String currentCategory = _kategoriController.text;
    final List<String> allowedEmojis = _kategoriEmojis[currentCategory] ?? widget.availableEmojis;

    final List<String> dropdownEmojis = allowedEmojis.contains(widget.item.icon)
        ? allowedEmojis
        : <String>[widget.item.icon, ...allowedEmojis];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.slate50,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppColors.slate900,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${widget.index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                onPressed: widget.onDelete,
                style: IconButton.styleFrom(
                  foregroundColor: AppColors.red,
                  backgroundColor: AppColors.redSoft,
                  padding: const EdgeInsets.all(6),
                ),
                icon: const Icon(Icons.delete_rounded, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final bool isWide = constraints.maxWidth > 780;

              final Widget iconField = DropdownButtonFormField<String>(
                initialValue: widget.item.icon,
                items: dropdownEmojis
                    .map(
                      (String emoji) => DropdownMenuItem<String>(
                        value: emoji,
                        child: Text(
                          emoji.isEmpty ? '❓ Pilih' : emoji,
                          style: TextStyle(
                            fontSize: emoji.isEmpty ? 14 : 22,
                            color: emoji.isEmpty ? AppColors.slate500 : null,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                decoration: const InputDecoration(
                  labelText: 'Ikon Emoji',
                ),
                onChanged: (String? value) {
                  if (value == null) return;
                  widget.onUpdate(icon: value);
                },
              );

              final List<String> currentKategoriList = _kategoriList.contains(_kategoriController.text)
                  ? _kategoriList
                  : (_kategoriController.text.isNotEmpty
                      ? <String>[_kategoriController.text, ..._kategoriList]
                      : _kategoriList);

              final Widget categoryField = DropdownButtonFormField<String>(
                value: _kategoriController.text.isEmpty ? null : _kategoriController.text,
                items: currentKategoriList
                    .map((String k) => DropdownMenuItem<String>(value: k, child: Text(k)))
                    .toList(),
                decoration: const InputDecoration(
                  labelText: 'Kategori Gizi',
                  hintText: 'Pilih Kategori',
                ),
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() {
                      _kategoriController.text = value;
                    });
                    
                    final List<String> newEmojis = _kategoriEmojis[value] ?? widget.availableEmojis;
                    String newIcon = widget.item.icon;
                    if (newIcon.isNotEmpty && !newEmojis.contains(newIcon)) {
                      newIcon = newEmojis.isNotEmpty ? newEmojis.first : '';
                    }
                    
                    widget.onUpdate(
                      kategori: value,
                      nama: _namaController.text,
                      icon: newIcon,
                    );
                  }
                },
              );

              final Widget nameField = TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Sajian',
                  hintText: 'Misal: Sup Ayam',
                ),
                onChanged: (_) => _onTextChanged(),
              );

              if (isWide) {
                return Row(
                  children: <Widget>[
                    SizedBox(width: 140, child: iconField),
                    const SizedBox(width: 12),
                    Expanded(child: categoryField),
                    const SizedBox(width: 12),
                    Expanded(flex: 2, child: nameField),
                  ],
                );
              }

              return Column(
                children: <Widget>[
                  iconField,
                  const SizedBox(height: 12),
                  categoryField,
                  const SizedBox(height: 12),
                  nameField,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class ImageCropDialog extends StatefulWidget {
  const ImageCropDialog({super.key, required this.imageBytes});

  final Uint8List imageBytes;

  @override
  State<ImageCropDialog> createState() => _ImageCropDialogState();
}

class _ImageCropDialogState extends State<ImageCropDialog> {
  final GlobalKey _cropBoundaryKey = GlobalKey();
  final TransformationController _transformationController = TransformationController();
  double _zoom = 1.0;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final RenderRepaintBoundary? boundary = _cropBoundaryKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final String base64String = 'data:image/png;base64,${base64Encode(pngBytes)}';

      if (mounted) {
        Navigator.of(context).pop(base64String);
      }
    } catch (e) {
      debugPrint('Error cropping menu image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memotong gambar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Atur & Potong Foto Menu',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      contentPadding: const EdgeInsets.all(16),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              'Geser untuk memposisikan, gunakan roda mouse/cubit untuk zoom.',
              style: TextStyle(color: AppColors.slate500, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Center(
              // Beautiful rectangular crop ratio matching the 180x280 (approx. 1.55:1) card display aspect ratio
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: 280,
                  height: 180,
                  child: RepaintBoundary(
                    key: _cropBoundaryKey,
                    child: InteractiveViewer(
                      transformationController: _transformationController,
                      boundaryMargin: const EdgeInsets.all(120),
                      minScale: 0.5,
                      maxScale: 4.0,
                      onInteractionUpdate: (ScaleUpdateDetails details) {
                        setState(() {
                          _zoom = _transformationController.value.getMaxScaleOnAxis();
                        });
                      },
                      child: Image.memory(
                        widget.imageBytes,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                const Icon(Icons.zoom_out_rounded, color: AppColors.slate400, size: 20),
                Expanded(
                  child: Slider(
                    value: _zoom.clamp(0.5, 4.0),
                    min: 0.5,
                    max: 4.0,
                    activeColor: AppColors.emerald,
                    inactiveColor: AppColors.slate200,
                    onChanged: (double value) {
                      setState(() {
                        _zoom = value;
                        final Matrix4 matrix = Matrix4.diagonal3Values(value, value, 1.0);
                        _transformationController.value = matrix;
                      });
                    },
                  ),
                ),
                const Icon(Icons.zoom_in_rounded, color: AppColors.slate400, size: 20),
              ],
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: _onSave,
          style: FilledButton.styleFrom(backgroundColor: AppColors.emerald),
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
