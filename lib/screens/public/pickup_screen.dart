import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/class_room.dart';
import '../../services/app_state.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/section_card.dart';
import '../../widgets/common/searchable_class_dropdown.dart';
import '../../widgets/public/signature_pad.dart';

class PickupScreen extends StatefulWidget {
  const PickupScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<PickupScreen> createState() => _PickupScreenState();
}

class _PickupScreenState extends State<PickupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _tidakHadirController = TextEditingController(text: '0');
  ClassRoom? _selectedClass;
  int _tidakHadir = 0;
  bool _isSubmitted = false;

  @override
  void dispose() {
    _tidakHadirController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<ClassRoom> availableClasses = widget.appState.classesData.where((
      ClassRoom room,
    ) {
      final TrackingStatus status =
          widget.appState.trackingData[room.id]?.status ?? TrackingStatus.belum;
      return status == TrackingStatus.belum;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: AppColors.emeraldSoft,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.restaurant_rounded,
                        size: 32,
                        color: AppColors.emerald,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Pengambilan Mbg',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppColors.slate900,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              if (_isSubmitted)
                SectionCard(
                  backgroundColor: const Color(0xFFECFDF5),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 64,
                        color: AppColors.emerald,
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Pengambilan Berhasil',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppColors.slate900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Pengambilan MBG telah dicatat. Selamat menikmati! 😊',
                        style: TextStyle(
                          color: AppColors.slate600,
                          fontSize: 14,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: SizedBox(
                          width: 200,
                          child: CustomButton(
                            label: 'Input Baru',
                            onPressed: () {
                              setState(() {
                                _isSubmitted = false;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                SectionCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'Pilih Kelas',
                          style: TextStyle(
                            color: AppColors.slate700,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SearchableClassDropdown(
                          key: ValueKey<String?>(_selectedClass?.id),
                          availableClasses: availableClasses,
                          initialClass: _selectedClass,
                          onSelected: (ClassRoom? room) {
                            setState(() {
                              _selectedClass = room;
                              _tidakHadir = 0;
                              _tidakHadirController.text = '0';
                            });
                          },
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          key: ValueKey<String>(
                            'pj_${_selectedClass?.id ?? 'none'}',
                          ),
                          readOnly: true,
                          initialValue: widget.appState.getPjHariIni(
                            _selectedClass,
                          ),
                          decoration: InputDecoration(
                            labelText:
                                'Penanggung Jawab Hari Ini (${widget.appState.currentDayName})',
                            prefixIcon: const Icon(
                              Icons.person_outline_rounded,
                            ),
                            filled: true,
                            fillColor: AppColors.slate50,
                          ),
                        ),
                        const SizedBox(height: 18),
                        LayoutBuilder(
                          builder:
                              (
                                BuildContext context,
                                BoxConstraints constraints,
                              ) {
                                final bool isWide = constraints.maxWidth > 520;
                                final Widget totalSiswaField = TextFormField(
                                  key: ValueKey<String>(
                                    'total_${_selectedClass?.id ?? 'none'}',
                                  ),
                                  readOnly: true,
                                  initialValue:
                                      _selectedClass?.totalSiswa.toString() ??
                                      '',
                                  decoration: const InputDecoration(
                                    labelText: 'Total Siswa',
                                    filled: true,
                                    fillColor: AppColors.slate50,
                                  ),
                                  textAlign: TextAlign.center,
                                );

                                final Widget tidakHadirField = TextFormField(
                                  key: ValueKey<String>(
                                    'tidak_hadir_${_selectedClass?.id ?? 'none'}',
                                  ),
                                  controller: _tidakHadirController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  decoration: const InputDecoration(
                                    labelText: 'Tidak Hadir',
                                  ),
                                  validator: (String? value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Isi jumlah tidak hadir';
                                    }
                                    final int? val = int.tryParse(value);
                                    if (val == null) {
                                      return 'Masukkan angka valid';
                                    }
                                    if (val < 0) {
                                      return 'Jumlah tidak boleh kurang dari 0';
                                    }
                                    if (_selectedClass != null &&
                                        val > _selectedClass!.totalSiswa) {
                                      return 'Maksimal ${_selectedClass!.totalSiswa} siswa';
                                    }
                                    return null;
                                  },
                                  onChanged: (String value) {
                                    if (value.isEmpty) {
                                      setState(() {
                                        _tidakHadir = 0;
                                      });
                                      return;
                                    }
                                    final int? parsed = int.tryParse(value);
                                    if (parsed != null) {
                                      if (_selectedClass != null &&
                                          parsed > _selectedClass!.totalSiswa) {
                                        final String clampedStr =
                                            _selectedClass!.totalSiswa.toString();
                                        _tidakHadirController.text = clampedStr;
                                        _tidakHadirController.selection =
                                            TextSelection.fromPosition(
                                              TextPosition(
                                                offset: clampedStr.length,
                                              ),
                                            );
                                        setState(() {
                                          _tidakHadir =
                                              _selectedClass!.totalSiswa;
                                        });
                                      } else {
                                        final String normStr = parsed.toString();
                                        if (value != normStr) {
                                          _tidakHadirController.text = normStr;
                                          _tidakHadirController.selection =
                                              TextSelection.fromPosition(
                                                TextPosition(
                                                  offset: normStr.length,
                                                ),
                                              );
                                        }
                                        setState(() {
                                          _tidakHadir = parsed;
                                        });
                                      }
                                    }
                                  },
                                  textAlign: TextAlign.center,
                                );

                                if (isWide) {
                                  return Row(
                                    children: <Widget>[
                                      Expanded(child: totalSiswaField),
                                      const SizedBox(width: 12),
                                      Expanded(child: tidakHadirField),
                                    ],
                                  );
                                }

                                return Column(
                                  children: <Widget>[
                                    totalSiswaField,
                                    const SizedBox(height: 12),
                                    tidakHadirField,
                                  ],
                                );
                              },
                        ),
                        if (_selectedClass != null) ...<Widget>[
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFA7F3D0),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                const Text(
                                  'MBG yang diserahkan',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.emeraldDark,
                                  ),
                                ),
                                Text(
                                  '${(_selectedClass!.totalSiswa - _tidakHadir).clamp(0, _selectedClass!.totalSiswa)} Porsi',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.emeraldDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        const SignaturePad(),
                        const SizedBox(height: 24),
                        CustomButton(
                          label: 'Submit Pengambilan',
                          icon: Icons.check_circle_rounded,
                          expanded: true,
                          onPressed: () {
                            if (!_formKey.currentState!.validate() ||
                                _selectedClass == null) {
                              return;
                            }

                            _showConfirmationDialog();
                          },
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

  void _showConfirmationDialog() {
    if (_selectedClass == null) return;
    
    final String className = _selectedClass!.nama;
    final String pjName = widget.appState.getPjHariIni(_selectedClass);
    final int totalSiswa = _selectedClass!.totalSiswa;
    final int tidakHadir = _tidakHadir;
    final int porsi = (totalSiswa - tidakHadir).clamp(0, totalSiswa);

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Row(
            children: <Widget>[
              Icon(
                Icons.fact_check_rounded,
                color: AppColors.emerald,
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                'Verifikasi Data',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  color: AppColors.slate900,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Apakah data pengambilan MBG di bawah ini sudah benar?',
                style: TextStyle(
                  color: AppColors.slate600,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.slate50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.slate200),
                ),
                child: Column(
                  children: <Widget>[
                    _buildPreviewRow('Kelas', className),
                    const Divider(height: 16),
                    _buildPreviewRow('PJ Hari Ini', pjName),
                    const Divider(height: 16),
                    _buildPreviewRow('Total Siswa', '$totalSiswa Anak'),
                    const Divider(height: 16),
                    _buildPreviewRow('Tidak Hadir', '$tidakHadir Anak'),
                    const Divider(height: 16),
                    _buildPreviewRow(
                      'MBG Diserahkan',
                      '$porsi Porsi',
                      isBoldValue: true,
                      valueColor: AppColors.emeraldDark,
                    ),
                  ],
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Batal',
                style: TextStyle(
                  color: AppColors.slate500,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _submitData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emerald,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                elevation: 0,
              ),
              child: const Text(
                'Ya, Sudah Benar',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPreviewRow(
    String label,
    String value, {
    bool isBoldValue = false,
    Color valueColor = AppColors.slate800,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
            color: AppColors.slate500,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 14,
            fontWeight: isBoldValue ? FontWeight.w800 : FontWeight.w700,
          ),
        ),
      ],
    );
  }

  void _submitData() {
    widget.appState.submitPickup(
      classId: _selectedClass!.id,
      tidakHadir: _tidakHadir,
    );

    setState(() {
      _isSubmitted = true;
      _selectedClass = null;
      _tidakHadir = 0;
      _tidakHadirController.text = '0';
    });
  }
}
