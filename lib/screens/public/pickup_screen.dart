import 'package:flutter/material.dart';

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
