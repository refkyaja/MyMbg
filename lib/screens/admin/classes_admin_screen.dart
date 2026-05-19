import 'package:flutter/material.dart';

import '../../models/class_room.dart';
import '../../services/app_state.dart';
import '../../utils/app_colors.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/section_card.dart';

class ClassesAdminScreen extends StatefulWidget {
  const ClassesAdminScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<ClassesAdminScreen> createState() => _ClassesAdminScreenState();
}

class _ClassesAdminScreenState extends State<ClassesAdminScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _searchTerm = '';
  String _tableMode = 'hari-ini';
  bool _showForm = false;
  String? _editingClassId;
  String _namaKelas = '';
  String _totalSiswa = '';
  Map<String, String> _pj = _emptyPj();

  static Map<String, String> _emptyPj() {
    return <String, String>{
      'Senin': '',
      'Selasa': '',
      'Rabu': '',
      'Kamis': '',
      'Jumat': '',
    };
  }

  bool get _isEditMode => _editingClassId != null;

  void _openAddForm() {
    setState(() {
      _showForm = true;
      _editingClassId = null;
      _namaKelas = '';
      _totalSiswa = '';
      _pj = _emptyPj();
    });
  }

  void _openEditForm(ClassRoom classRoom) {
    setState(() {
      _showForm = true;
      _editingClassId = classRoom.id;
      _namaKelas = classRoom.nama;
      _totalSiswa = classRoom.totalSiswa.toString();
      _pj = <String, String>{...classRoom.pj};
    });
  }

  Future<void> _deleteClass(String id) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus kelas?'),
          content: const Text('Data kelas akan dihapus dari daftar saat ini.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(backgroundColor: AppColors.red),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      widget.appState.deleteClassRoom(id);
    }
  }

  void _saveForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final ClassRoom newRoom = ClassRoom(
      id: _editingClassId ?? _namaKelas.trim(),
      nama: _namaKelas.trim(),
      totalSiswa: int.tryParse(_totalSiswa) ?? 0,
      pj: <String, String>{..._pj},
    );

    if (_isEditMode) {
      widget.appState.updateClassRoom(newRoom);
    } else {
      widget.appState.addClassRoom(newRoom);
    }

    setState(() {
      _showForm = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEditMode
              ? 'Data kelas berhasil diperbarui.'
              : 'Kelas baru berhasil ditambahkan.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<ClassRoom> filteredClasses = widget.appState.classesData.where((
      ClassRoom room,
    ) {
      return room.nama.toLowerCase().contains(_searchTerm.toLowerCase());
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Master Data Kelas',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Kelola daftar kelas dan penanggung jawab per hari',
                      style: TextStyle(color: AppColors.slate500),
                    ),
                  ],
                ),
              ),
              if (!_showForm)
                CustomButton(
                  label: 'Tambah Kelas Baru',
                  icon: Icons.add_rounded,
                  backgroundColor: AppColors.slate900,
                  onPressed: _openAddForm,
                ),
            ],
          ),
          const SizedBox(height: 24),
          if (!_showForm)
            SectionCard(
              child: Column(
                children: <Widget>[
                  LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                          final bool isWide = constraints.maxWidth > 720;

                          final Widget searchField = TextFormField(
                            decoration: const InputDecoration(
                              hintText: 'Cari nama kelas...',
                              prefixIcon: Icon(Icons.search_rounded),
                            ),
                            onChanged: (String value) {
                              setState(() {
                                _searchTerm = value;
                              });
                            },
                          );

                          final Widget filterTabs = Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.slate100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.slate200, width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                _buildTabButton(
                                  label: 'PJ Hari Ini',
                                  isActive: _tableMode == 'hari-ini',
                                  onTap: () {
                                    setState(() {
                                      _tableMode = 'hari-ini';
                                    });
                                  },
                                ),
                                const SizedBox(width: 4),
                                _buildTabButton(
                                  label: 'Semua PJ',
                                  isActive: _tableMode == 'semua',
                                  onTap: () {
                                    setState(() {
                                      _tableMode = 'semua';
                                    });
                                  },
                                ),
                              ],
                            ),
                          );

                          if (isWide) {
                            return Row(
                              children: <Widget>[
                                Expanded(child: searchField),
                                const SizedBox(width: 16),
                                filterTabs,
                              ],
                            );
                          }

                          return Column(
                            children: <Widget>[
                              searchField,
                              const SizedBox(height: 14),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: filterTabs,
                              ),
                            ],
                          );
                        },
                  ),
                  const SizedBox(height: 18),
                  if (filteredClasses.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: Text(
                        'Tidak ada kelas yang ditemukan.',
                        style: TextStyle(color: AppColors.slate500),
                      ),
                    )
                  else
                    LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints tableConstraints) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: tableConstraints.maxWidth,
                            ),
                            child: DataTable(
                              headingTextStyle: const TextStyle(
                                color: AppColors.slate700,
                                fontWeight: FontWeight.w800,
                              ),
                              columns: _tableMode == 'hari-ini'
                                  ? <DataColumn>[
                                      const DataColumn(label: Text('Kelas')),
                                      const DataColumn(label: Text('Total Siswa')),
                                      DataColumn(
                                        label: Text(
                                          'PJ Hari Ini (${widget.appState.currentDayName})',
                                        ),
                                      ),
                                      const DataColumn(label: Text('Aksi')),
                                    ]
                                  : const <DataColumn>[
                                      DataColumn(label: Text('Kelas')),
                                      DataColumn(label: Text('Senin')),
                                      DataColumn(label: Text('Selasa')),
                                      DataColumn(label: Text('Rabu')),
                                      DataColumn(label: Text('Kamis')),
                                      DataColumn(label: Text('Jumat')),
                                      DataColumn(label: Text('Aksi')),
                                    ],
                              rows: filteredClasses.map((ClassRoom room) {
                                if (_tableMode == 'hari-ini') {
                                  return DataRow(
                                    cells: <DataCell>[
                                      DataCell(
                                        Text(
                                          room.nama,
                                          style: const TextStyle(
                                            color: AppColors.emeraldDark,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                      DataCell(Text('${room.totalSiswa} Siswa')),
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF0FDF4), // Very soft green
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: const Color(0xFFDCFCE7), // Soft border
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              const Icon(
                                                Icons.person_rounded,
                                                size: 14,
                                                color: AppColors.emeraldDark,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                widget.appState.getPjHariIni(room),
                                                style: const TextStyle(
                                                  color: AppColors.emeraldDark,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            IconButton(
                                              onPressed: () => _openEditForm(room),
                                              icon: const Icon(
                                                Icons.edit_rounded,
                                                color: AppColors.blue,
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () => _deleteClass(room.id),
                                              icon: const Icon(
                                                Icons.delete_outline_rounded,
                                                color: AppColors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }

                                return DataRow(
                                  cells: <DataCell>[
                                    DataCell(
                                      Text.rich(
                                        TextSpan(
                                          text: room.nama,
                                          style: const TextStyle(
                                            color: AppColors.emeraldDark,
                                            fontWeight: FontWeight.w800,
                                          ),
                                          children: <InlineSpan>[
                                            TextSpan(
                                              text: '\n${room.totalSiswa} Siswa',
                                              style: const TextStyle(
                                                color: AppColors.slate500,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    DataCell(Text(room.pj['Senin'] ?? '-')),
                                    DataCell(Text(room.pj['Selasa'] ?? '-')),
                                    DataCell(Text(room.pj['Rabu'] ?? '-')),
                                    DataCell(Text(room.pj['Kamis'] ?? '-')),
                                    DataCell(Text(room.pj['Jumat'] ?? '-')),
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          IconButton(
                                            onPressed: () => _openEditForm(room),
                                            icon: const Icon(
                                              Icons.edit_rounded,
                                              color: AppColors.blue,
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () => _deleteClass(room.id),
                                            icon: const Icon(
                                              Icons.delete_outline_rounded,
                                              color: AppColors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        );
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
                  key: ValueKey<String>('${_editingClassId ?? 'new'}_form'),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        const Icon(
                          Icons.menu_book_rounded,
                          color: AppColors.emerald,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _isEditMode ? 'Edit Data Kelas' : 'Form Tambah Kelas',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.slate900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                            final bool isWide = constraints.maxWidth > 640;

                            final Widget nameField = TextFormField(
                              initialValue: _namaKelas,
                              enabled: !_isEditMode,
                              decoration: const InputDecoration(
                                labelText: 'Nama Kelas',
                                hintText: 'Contoh: XII IPA 1',
                              ),
                              validator: (String? value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Nama kelas wajib diisi';
                                }
                                if (!_isEditMode) {
                                  final bool exists = widget.appState.classesData.any(
                                    (room) => room.nama.toLowerCase() == value.trim().toLowerCase(),
                                  );
                                  if (exists) {
                                    return 'data kelas sudah ada!';
                                  }
                                }
                                return null;
                              },
                              onChanged: (String value) {
                                _namaKelas = value;
                              },
                            );

                            final Widget totalField = TextFormField(
                              initialValue: _totalSiswa,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Total Siswa',
                                hintText: '0',
                              ),
                              validator: (String? value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Total siswa wajib diisi';
                                }
                                return null;
                              },
                              onChanged: (String value) {
                                _totalSiswa = value;
                              },
                            );

                            if (isWide) {
                              return Row(
                                children: <Widget>[
                                  Expanded(child: nameField),
                                  const SizedBox(width: 12),
                                  Expanded(child: totalField),
                                ],
                              );
                            }

                            return Column(
                              children: <Widget>[
                                nameField,
                                const SizedBox(height: 12),
                                totalField,
                              ],
                            );
                          },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Jadwal Penanggung Jawab Mingguan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.slate900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                            final int columns = constraints.maxWidth > 720
                                ? 2
                                : 1;
                            final List<String> days = _pj.keys.toList();

                            return GridView.builder(
                              itemCount: days.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: columns,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    mainAxisExtent: 86,
                                  ),
                              itemBuilder: (BuildContext context, int index) {
                                final String day = days[index];
                                return TextFormField(
                                  initialValue: _pj[day],
                                  decoration: InputDecoration(
                                    labelText: day,
                                    hintText: 'Nama PJ hari $day',
                                  ),
                                  validator: (String? value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Nama PJ wajib diisi';
                                    }
                                    return null;
                                  },
                                  onChanged: (String value) {
                                    _pj[day] = value;
                                  },
                                );
                              },
                            );
                          },
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.end,
                      children: <Widget>[
                        CustomButton(
                          label: 'Batal',
                          isOutlined: true,
                          foregroundColor: AppColors.slate700,
                          onPressed: () {
                            setState(() {
                              _showForm = false;
                            });
                          },
                        ),
                        CustomButton(
                          label: _isEditMode
                              ? 'Simpan Pembaruan'
                              : 'Simpan Data Kelas',
                          onPressed: _saveForm,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? AppColors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              boxShadow: isActive
                  ? <BoxShadow>[
                      const BoxShadow(
                        color: Color(0x12000000),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (isActive)
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: AppColors.emerald,
                  ),
                if (isActive) const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive ? AppColors.slate900 : AppColors.slate500,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
