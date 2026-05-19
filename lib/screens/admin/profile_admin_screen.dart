import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:file_picker/file_picker.dart';

import '../../models/admin_profile.dart';
import '../../services/app_state.dart';
import '../../utils/app_colors.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/section_card.dart';

// Helper to load file bytes on desktop/mobile without breaking web compile
import 'dart:io' as io;

class ProfileAdminScreen extends StatefulWidget {
  const ProfileAdminScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<ProfileAdminScreen> createState() => _ProfileAdminScreenState();
}

class _ProfileAdminScreenState extends State<ProfileAdminScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _finesFormKey = GlobalKey<FormState>();
  late String _name;
  late String _email;
  late String _photo;
  late String _password;
  bool _isSaved = false;

  late TextEditingController _dendaRusakController;
  late TextEditingController _dendaHilangController;

  @override
  void initState() {
    super.initState();
    final AdminProfile profile = widget.appState.adminProfile;
    _name = profile.name;
    _email = profile.email;
    _photo = profile.photo;
    _password = profile.password;

    _dendaRusakController = TextEditingController(
      text: widget.appState.dendaRusak.toString(),
    );
    _dendaHilangController = TextEditingController(
      text: widget.appState.dendaHilang.toString(),
    );
  }

  @override
  void dispose() {
    _dendaRusakController.dispose();
    _dendaHilangController.dispose();
    super.dispose();
  }

  void _saveFines() {
    if (!_finesFormKey.currentState!.validate()) {
      return;
    }

    final int rusak = int.tryParse(_dendaRusakController.text) ?? 15000;
    final int hilang = int.tryParse(_dendaHilangController.text) ?? 25000;

    widget.appState.updateFines(rusak: rusak, hilang: hilang);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tarif denda berhasil disimpan!'),
        backgroundColor: AppColors.emerald,
      ),
    );
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    widget.appState.updateAdminProfile(
      AdminProfile(
        username: widget.appState.adminProfile.username,
        name: _name,
        email: _email,
        photo: _photo,
        password: _password,
      ),
    );

    setState(() {
      _isSaved = true;
    });
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
        setState(() {
          _photo = croppedBase64;
          _isSaved = false;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih gambar: $e')),
        );
      }
    }
  }

  Widget _buildAvatarWidget(String initial) {
    if (_photo.isEmpty) {
      return Container(
        color: AppColors.emerald,
        alignment: Alignment.center,
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    try {
      if (_photo.startsWith('data:image/') && _photo.contains('base64,')) {
        final String base64Str = _photo.split('base64,')[1];
        final Uint8List bytes = base64Decode(base64Str);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) => Container(
            color: AppColors.emerald,
            alignment: Alignment.center,
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      } else if (_photo.startsWith('http')) {
        return Image.network(
          _photo,
          fit: BoxFit.cover,
          errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) => Container(
            color: AppColors.emerald,
            alignment: Alignment.center,
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      } else {
        if (kIsWeb) {
          return Container(
            color: AppColors.emerald,
            alignment: Alignment.center,
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        } else {
          return Image.file(
            io.File(_photo),
            fit: BoxFit.cover,
            errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) => Container(
              color: AppColors.emerald,
              alignment: Alignment.center,
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }
      }
    } catch (e) {
      return Container(
        color: AppColors.emerald,
        alignment: Alignment.center,
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String initial = _name.isNotEmpty ? _name[0].toUpperCase() : 'A';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Pengaturan Profile',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Kelola informasi akun administrator Anda',
                style: TextStyle(color: AppColors.slate500),
              ),
              const SizedBox(height: 20),
              if (_isSaved)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: const Row(
                      children: <Widget>[
                        Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.emerald,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Data profil berhasil diperbarui.',
                            style: TextStyle(
                              color: AppColors.emeraldDark,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              SectionCard(
                padding: EdgeInsets.zero,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: const BoxDecoration(
                          color: AppColors.slate50,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                        ),
                        child: LayoutBuilder(
                          builder: (BuildContext context, BoxConstraints constraints) {
                            final bool isWide = constraints.maxWidth > 640;

                            final Widget avatar = Stack(
                              children: <Widget>[
                                SizedBox(
                                  width: 110,
                                  height: 110,
                                  child: ClipOval(
                                    child: _buildAvatarWidget(initial),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: IconButton.filled(
                                    onPressed: _pickAndCropImage,
                                    style: IconButton.styleFrom(
                                      backgroundColor: AppColors.emerald,
                                    ),
                                    icon: const Icon(Icons.camera_alt_rounded),
                                  ),
                                ),
                              ],
                            );

                            final Widget identity = Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  _name,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.slate900,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Role: Administrator Sistem',
                                  style: TextStyle(color: AppColors.slate500),
                                ),
                              ],
                            );

                            if (isWide) {
                              return Row(
                                children: <Widget>[
                                  avatar,
                                  const SizedBox(width: 20),
                                  identity,
                                ],
                              );
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                avatar,
                                const SizedBox(height: 16),
                                identity,
                              ],
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              initialValue: _name,
                              decoration: const InputDecoration(
                                labelText: 'Nama Lengkap',
                                prefixIcon: Icon(Icons.person_outline_rounded),
                              ),
                              validator: (String? value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Nama wajib diisi';
                                }
                                return null;
                              },
                              onChanged: (String value) {
                                setState(() {
                                  _name = value;
                                  _isSaved = false;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              initialValue: _email,
                              decoration: const InputDecoration(
                                labelText: 'Email Akun',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              validator: (String? value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Email wajib diisi';
                                }
                                return null;
                              },
                              onChanged: (String value) {
                                setState(() {
                                  _email = value;
                                  _isSaved = false;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              initialValue: _password,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Password',
                                prefixIcon: Icon(Icons.lock_outline_rounded),
                              ),
                              validator: (String? value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password wajib diisi';
                                }
                                return null;
                              },
                              onChanged: (String value) {
                                setState(() {
                                  _password = value;
                                  _isSaved = false;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: CustomButton(
                            label: 'Simpan Profil',
                            icon: Icons.check_circle_rounded,
                            onPressed: _saveProfile,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SectionCard(
                child: Form(
                  key: _finesFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.redSoft,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.payments_rounded,
                              color: AppColors.red,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Pengaturan Tarif Denda Inventaris',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.slate900,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Sesuaikan biaya denda untuk boks makan siang yang rusak atau hilang',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.slate500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      LayoutBuilder(
                        builder: (BuildContext context, BoxConstraints constraints) {
                          final bool isWide = constraints.maxWidth > 500;

                          final Widget fieldRusak = TextFormField(
                            controller: _dendaRusakController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Tarif Denda Boks Rusak (Rp)',
                              prefixIcon: Icon(Icons.broken_image_rounded),
                            ),
                            validator: (String? value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Harap isi nominal denda rusak';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Isi dengan angka valid';
                              }
                              return null;
                            },
                          );

                          final Widget fieldHilang = TextFormField(
                            controller: _dendaHilangController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Tarif Denda Boks Hilang (Rp)',
                              prefixIcon: Icon(Icons.help_center_rounded),
                            ),
                            validator: (String? value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Harap isi nominal denda hilang';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Isi dengan angka valid';
                              }
                              return null;
                            },
                          );

                          if (isWide) {
                            return Row(
                              children: <Widget>[
                                Expanded(child: fieldRusak),
                                const SizedBox(width: 16),
                                Expanded(child: fieldHilang),
                              ],
                            );
                          }

                          return Column(
                            children: <Widget>[
                              fieldRusak,
                              const SizedBox(height: 16),
                              fieldHilang,
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      Align(
                        alignment: Alignment.centerRight,
                        child: CustomButton(
                          label: 'Simpan Tarif Denda',
                          icon: Icons.save_rounded,
                          backgroundColor: AppColors.red,
                          onPressed: _saveFines,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
      // Small delay to ensure rendering is completely stable
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
      debugPrint('Error cropping image: $e');
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
        'Atur & Potong Foto',
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
              child: ClipOval(
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: RepaintBoundary(
                    key: _cropBoundaryKey,
                    child: InteractiveViewer(
                      transformationController: _transformationController,
                      boundaryMargin: const EdgeInsets.all(100),
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
