import 'package:flutter/material.dart';

import '../../models/class_room.dart';
import '../../services/app_state.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/section_card.dart';
import '../../widgets/public/signature_pad.dart';

class PickupScreen extends StatefulWidget {
  const PickupScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<PickupScreen> createState() => _PickupScreenState();
}

class _PickupScreenState extends State<PickupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  ClassRoom? _selectedClass;
  int _tidakHadir = 0;
  bool _isSubmitted = false;

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
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: AppColors.emeraldSoft,
                    foregroundColor: AppColors.emerald,
                    child: Icon(Icons.restaurant_rounded),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Distribusi Pengambilan',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.slate900,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Validasi dan serah terima makanan bergizi',
                          style: TextStyle(color: AppColors.slate500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_isSubmitted)
                SectionCard(
                  backgroundColor: const Color(0xFFECFDF5),
                  child: Column(
                    children: <Widget>[
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 54,
                        color: AppColors.emerald,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Pengambilan Disahkan!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.slate900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Distribusi MBG telah dicatat ke sistem demo Flutter.',
                        style: TextStyle(color: AppColors.slate600),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      CustomButton(
                        label: 'Input Baru',
                        onPressed: () {
                          setState(() {
                            _isSubmitted = false;
                          });
                        },
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
                          'Pilih Kelas / Rombel',
                          style: TextStyle(
                            color: AppColors.slate700,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          key: ValueKey<String?>(_selectedClass?.id),
                          initialValue: _selectedClass?.id,
                          decoration: const InputDecoration(
                            hintText: '-- Pilih Kelas --',
                          ),
                          items: availableClasses
                              .map(
                                (ClassRoom room) => DropdownMenuItem<String>(
                                  value: room.id,
                                  child: Text(room.nama),
                                ),
                              )
                              .toList(),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Silakan pilih kelas';
                            }
                            return null;
                          },
                          onChanged: (String? value) {
                            setState(() {
                              _selectedClass = widget.appState.classesData
                                  .cast<ClassRoom?>()
                                  .firstWhere(
                                    (ClassRoom? room) => room?.id == value,
                                  );
                              _tidakHadir = 0;
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
                                  keyboardType: TextInputType.number,
                                  initialValue: _tidakHadir.toString(),
                                  decoration: const InputDecoration(
                                    labelText: 'Tidak Hadir',
                                  ),
                                  validator: (String? value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Isi jumlah tidak hadir';
                                    }
                                    return null;
                                  },
                                  onChanged: (String value) {
                                    setState(() {
                                      _tidakHadir = int.tryParse(value) ?? 0;
                                    });
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

                            widget.appState.submitPickup(
                              classId: _selectedClass!.id,
                              tidakHadir: _tidakHadir,
                            );

                            setState(() {
                              _isSubmitted = true;
                              _selectedClass = null;
                              _tidakHadir = 0;
                            });
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
}
