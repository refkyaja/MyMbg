import 'package:flutter/material.dart';

import '../../models/class_room.dart';

class SearchableClassDropdown extends StatelessWidget {
  const SearchableClassDropdown({
    super.key,
    required this.availableClasses,
    this.initialClass,
    required this.onSelected,
    this.validator,
  });

  final List<ClassRoom> availableClasses;
  final ClassRoom? initialClass;
  final ValueChanged<ClassRoom?> onSelected;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Autocomplete<ClassRoom>(
          initialValue: TextEditingValue(text: initialClass?.nama ?? ''),
          displayStringForOption: (ClassRoom option) => option.nama,
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return availableClasses;
            }
            final String query = textEditingValue.text.toLowerCase().replaceAll(' ', '');
            return availableClasses.where((ClassRoom room) {
              final String className = room.nama.toLowerCase().replaceAll(' ', '');
              return className.contains(query) || query.contains(className);
            });
          },
          onSelected: (ClassRoom selection) {
            onSelected(selection);
          },
          fieldViewBuilder: (
            BuildContext context,
            TextEditingController textEditingController,
            FocusNode focusNode,
            VoidCallback onFieldSubmitted,
          ) {
            return TextFormField(
              controller: textEditingController,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: '-- Pilih Kelas --',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_drop_down_rounded),
                  onPressed: () {
                    if (!focusNode.hasFocus) {
                      focusNode.requestFocus();
                    } else {
                      // Workaround to trigger Autocomplete options to appear when tapping arrow
                      final String currentText = textEditingController.text;
                      textEditingController.text = currentText + ' ';
                      textEditingController.text = currentText;
                    }
                  },
                ),
              ),
              onFieldSubmitted: (String value) {
                onFieldSubmitted();
              },
              onChanged: (String value) {
                if (value.isEmpty) {
                  onSelected(null);
                } else {
                  final Iterable<ClassRoom> matches = availableClasses.where(
                    (ClassRoom c) => c.nama == value,
                  );
                  if (matches.isEmpty) {
                    onSelected(null);
                  } else {
                    onSelected(matches.first);
                  }
                }
              },
              validator: validator ?? (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Silakan pilih kelas';
                }
                if (!availableClasses.any((ClassRoom c) => c.nama == value)) {
                  return 'Pilih kelas yang valid dari daftar';
                }
                return null;
              },
            );
          },
          optionsViewBuilder: (
            BuildContext context,
            AutocompleteOnSelected<ClassRoom> onSelect,
            Iterable<ClassRoom> options,
          ) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4.0,
                color: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 250,
                    maxWidth: constraints.maxWidth,
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (BuildContext context, int index) {
                      final ClassRoom option = options.elementAt(index);
                      return InkWell(
                        onTap: () {
                          onSelect(option);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 12.0,
                          ),
                          child: Text(
                            option.nama,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
