import 'package:flutter/material.dart';

import '../../models/class_room.dart';
import '../../models/tracking_record.dart';
import '../../services/app_state.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_formatters.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/section_card.dart';

class ReturnScreen extends StatefulWidget {
  const ReturnScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<ReturnScreen> createState() => _ReturnScreenState();
}

class _ReturnScreenState extends State<ReturnScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _totalKembaliController = TextEditingController();
  final TextEditingController _jumlahRusakController = TextEditingController(
    text: '0',
  );

  ClassRoom? _selectedClass;
  String _kondisi = '';
  bool _isSubmitted = false;
  int _lastDenda = 0;

  @override
  void dispose() {
    _totalKembaliController.dispose();
    _jumlahRusakController.dispose();
    super.dispose();
  }

  int get _totalDenda {
    final int jumlahRusak = int.tryParse(_jumlahRusakController.text) ?? 0;
    if (_kondisi == 'Rusak') {
      return jumlahRusak * widget.appState.dendaRusak;
    } else if (_kondisi == 'Hilang') {
      return jumlahRusak * widget.appState.dendaHilang;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final List<ClassRoom> returningClasses = widget.appState.classesData
        .where(
          (ClassRoom room) =>
              widget.appState.trackingData[room.id]?.status ==
              TrackingStatus.diambil,
        )
        .toList();

    final TrackingRecord? selectedTracking = _selectedClass == null
        ? null
        : widget.appState.trackingData[_selectedClass!.id];

    final int mbgDiambil = selectedTracking?.mbgDiambil ?? 0;
    final int totalKembali = int.tryParse(_totalKembaliController.text) ?? 0;
    final bool isJumlahSama = mbgDiambil == totalKembali;

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
                        color: AppColors.amberSoft,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.assignment_return_rounded,
                        size: 32,
                        color: AppColors.amber,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Pengembalian Mbg',
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
                  backgroundColor: const Color(0xFFFFFBEB),
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
                        'Rekap Berhasil Disimpan!',
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
                        'Data pengembalian sudah kami catat.',
                        style: TextStyle(
                          color: AppColors.slate600,
                          fontSize: 14,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (_lastDenda > 0) ...<Widget>[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.redSoft,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'Tagihan denda: ${AppFormatters.formatRupiah(_lastDenda)}',
                            style: const TextStyle(
                              color: AppColors.red,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'Mohon segera melunasi denda tersebut kepada pihak admin',
                            style: TextStyle(
                              color: AppColors.red,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Center(
                        child: SizedBox(
                          width: 200,
                          child: CustomButton(
                            label: 'Selesai',
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
                  child: returningClasses.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Column(
                              children: <Widget>[
                                Icon(
                                  Icons.assignment_turned_in_rounded,
                                  size: 52,
                                  color: AppColors.slate400,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Semua kelas sudah mengembalikan kotak makan hari ini.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: AppColors.slate500),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Form(
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
                              DropdownButtonFormField<String>(
                                key: ValueKey<String?>(_selectedClass?.id),
                                initialValue: _selectedClass?.id,
                                decoration: const InputDecoration(
                                  hintText: '-- Pilih Kelas --',
                                ),
                                items: returningClasses
                                    .map(
                                      (ClassRoom room) =>
                                          DropdownMenuItem<String>(
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
                                  final ClassRoom room = widget
                                      .appState
                                      .classesData
                                      .firstWhere(
                                        (ClassRoom item) => item.id == value,
                                      );
                                  final TrackingRecord? record =
                                      widget.appState.trackingData[room.id];
                                  setState(() {
                                    _selectedClass = room;
                                    _totalKembaliController.text =
                                        record?.mbgDiambil.toString() ?? '';
                                  });
                                },
                              ),
                              const SizedBox(height: 18),
                              LayoutBuilder(
                                builder:
                                    (
                                      BuildContext context,
                                      BoxConstraints constraints,
                                    ) {
                                      final bool isWide =
                                          constraints.maxWidth > 520;
                                      final Widget pjField = TextFormField(
                                        key: ValueKey<String>(
                                          'return_pj_${_selectedClass?.id ?? 'none'}',
                                        ),
                                        readOnly: true,
                                        initialValue: widget.appState
                                            .getPjHariIni(_selectedClass),
                                        decoration: InputDecoration(
                                          labelText:
                                              'PJ Hari Ini (${widget.appState.currentDayName})',
                                          filled: true,
                                          fillColor: AppColors.slate50,
                                        ),
                                      );
                                      final Widget mbgField = TextFormField(
                                        key: ValueKey<String>(
                                          'return_mbg_${_selectedClass?.id ?? 'none'}',
                                        ),
                                        readOnly: true,
                                        initialValue:
                                            selectedTracking?.mbgDiambil
                                                .toString() ??
                                            '',
                                        decoration: const InputDecoration(
                                          labelText: 'MBG yang Diambil',
                                          filled: true,
                                          fillColor: AppColors.slate50,
                                        ),
                                      );

                                      if (isWide) {
                                        return Row(
                                          children: <Widget>[
                                            Expanded(child: pjField),
                                            const SizedBox(width: 12),
                                            Expanded(child: mbgField),
                                          ],
                                        );
                                      }

                                      return Column(
                                        children: <Widget>[
                                          pjField,
                                          const SizedBox(height: 12),
                                          mbgField,
                                        ],
                                      );
                                    },
                              ),
                              const SizedBox(height: 18),
                              TextFormField(
                                controller: _totalKembaliController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Total Mbg kembali',
                                ),
                                validator: (String? value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Isi total Mbg kembali';
                                  }
                                  return null;
                                },
                                onChanged: (String value) {
                                  setState(() {
                                    final int currentKembali = int.tryParse(value) ?? 0;
                                    if (currentKembali != mbgDiambil) {
                                      if (_kondisi == 'Lengkap') {
                                        _kondisi = '';
                                      }
                                      if (_kondisi == 'Rusak' || _kondisi == 'Hilang') {
                                        _jumlahRusakController.text =
                                            (mbgDiambil - currentKembali)
                                                .clamp(0, mbgDiambil)
                                                .toString();
                                      }
                                    } else {
                                      _kondisi = 'Lengkap';
                                      _jumlahRusakController.text = '0';
                                    }
                                  });
                                },
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Kondisi Inventaris',
                                style: TextStyle(
                                  color: AppColors.slate700,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: <String>['Lengkap', 'Rusak', 'Hilang']
                                    .map(
                                      (String value) {
                                        final bool isLengkap = value == 'Lengkap';
                                        final bool isClassSelected = _selectedClass != null;
                                        final bool canSelect = !isClassSelected || (isLengkap ? isJumlahSama : !isJumlahSama);

                                        return ChoiceChip(
                                          label: Text(value),
                                          selected: _kondisi == value,
                                          onSelected: canSelect
                                              ? (bool selected) {
                                                  setState(() {
                                                    _kondisi = value;
                                                    if (isLengkap) {
                                                      _jumlahRusakController.text = '0';
                                                    } else {
                                                      final int diff = (mbgDiambil - totalKembali)
                                                          .clamp(0, mbgDiambil);
                                                      _jumlahRusakController.text = diff.toString();
                                                    }
                                                  });
                                                }
                                              : null,
                                        );
                                      },
                                    )
                                    .toList(),
                              ),
                              if (_kondisi == 'Rusak' ||
                                  _kondisi == 'Hilang') ...<Widget>[
                                const SizedBox(height: 18),
                                Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: AppColors.redSoft,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: const Color(0xFFFCA5A5),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      const Row(
                                        children: <Widget>[
                                          Icon(
                                            Icons.warning_amber_rounded,
                                            color: AppColors.red,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Pencatatan Denda Inventaris',
                                            style: TextStyle(
                                              color: AppColors.red,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      LayoutBuilder(
                                        builder:
                                            (
                                              BuildContext context,
                                              BoxConstraints constraints,
                                            ) {
                                              final bool isWide =
                                                  constraints.maxWidth > 520;
                                              final Widget
                                              jumlahRusakField = TextFormField(readOnly: true,
                                                controller:
                                                    _jumlahRusakController,
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: InputDecoration(
                                                  labelText: 'Jumlah $_kondisi',
                                                  fillColor: AppColors.white,
                                                ),
                                                onChanged: (_) =>
                                                    setState(() {}),
                                              );

                                              final Widget
                                              totalDendaBox = Container(
                                                width: double.infinity,
                                                padding: const EdgeInsets.all(
                                                  16,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFFFECACA,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                child: Text(
                                                  AppFormatters.formatRupiah(
                                                    _totalDenda,
                                                  ),
                                                  style: const TextStyle(
                                                    color: AppColors.red,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                              );

                                              if (isWide) {
                                                return Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: jumlahRusakField,
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: totalDendaBox,
                                                    ),
                                                  ],
                                                );
                                              }

                                              return Column(
                                                children: <Widget>[
                                                  jumlahRusakField,
                                                  const SizedBox(height: 12),
                                                  totalDendaBox,
                                                ],
                                              );
                                            },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 24),
                              CustomButton(
                                label: 'Submit Pengembalian',
                                icon: Icons.check_circle_rounded,
                                expanded: true,
                                onPressed: () {
                                  if (!_formKey.currentState!.validate() ||
                                      _selectedClass == null ||
                                      _kondisi.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Lengkapi kelas dan kondisi inventaris.',
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  widget.appState.submitReturn(
                                    classId: _selectedClass!.id,
                                    kondisi: _kondisi,
                                    jumlahRusakHilang:
                                        int.tryParse(
                                          _jumlahRusakController.text,
                                        ) ??
                                        0,
                                  );

                                  setState(() {
                                    _lastDenda = _totalDenda;
                                    _isSubmitted = true;
                                    _selectedClass = null;
                                    _kondisi = '';
                                    _totalKembaliController.clear();
                                    _jumlahRusakController.text = '0';
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
