import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/tracking_record.dart';

class ReportGenerator {
  static List<int> generateExcel({
    required String month,
    required String year,
    required Map<String, Map<String, TrackingRecord>> historyData,
  }) {
    final Excel excel = Excel.createExcel();
    final Sheet sheetObject = excel['Laporan MBG - $month $year'];
    excel.delete('Sheet1'); // Remove default sheet

    // Style configuration
    final CellStyle headerStyle = CellStyle(
      backgroundColorHex: ExcelColor.fromHexString('#0F172A'), // Slate 900
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      fontFamily: getFontFamily(FontFamily.Calibri),
      horizontalAlign: HorizontalAlign.Center,
      bold: true,
    );

    // Add Title Block
    sheetObject.appendRow(<CellValue?>[
      TextCellValue('LAPORAN BULANAN REKAPITULASI PENDATAAN MyMbg'),
    ]);
    sheetObject.appendRow(<CellValue?>[
      TextCellValue('Periode Laporan: $month $year'),
    ]);
    sheetObject.appendRow(<CellValue?>[]); // Spacer

    // Table Columns Header
    sheetObject.appendRow(<CellValue?>[
      TextCellValue('Tanggal'),
      TextCellValue('Nama Kelas'),
      TextCellValue('Porsi MBG Diambil'),
      TextCellValue('Status Pengembalian'),
      TextCellValue('Denda'),
    ]);

    // Apply header styling to row index 3 (4th row, 1-indexed)
    for (int col = 0; col < 5; col++) {
      final CellIndex cellIndex = CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 3);
      sheetObject.cell(cellIndex).cellStyle = headerStyle;
    }

    int totalPorsi = 0;
    int totalDenda = 0;
    int totalSelesai = 0;
    int totalRows = 0;

    // Filter and sort dates belonging to selected month & year
    final List<String> sortedDates = historyData.keys.where((String date) {
      final List<String> parts = date.split(' ');
      if (parts.length >= 3) {
        final String y = parts.last;
        final String m = parts[parts.length - 2];
        return y == year && m == month;
      }
      return false;
    }).toList();
    sortedDates.sort();

    for (final String date in sortedDates) {
      final Map<String, TrackingRecord> records = historyData[date]!;
      for (final MapEntry<String, TrackingRecord> entry in records.entries) {
        final String className = entry.key;
        final TrackingRecord rec = entry.value;
        final bool isSelesai = rec.status.name == 'selesai';

        totalPorsi += rec.mbgDiambil;
        totalDenda += rec.denda;
        if (isSelesai) totalSelesai++;
        totalRows++;

        sheetObject.appendRow(<CellValue?>[
          TextCellValue(date.split(',').last.trim()), // Remove day name for brevity
          TextCellValue(className),
          IntCellValue(rec.mbgDiambil),
          TextCellValue(isSelesai ? 'Sudah Mengembalikan' : 'Belum Kembali'),
          IntCellValue(rec.denda),
        ]);
      }
    }

    sheetObject.appendRow(<CellValue?>[]); // Spacer
    
    // Summary box
    sheetObject.appendRow(<CellValue?>[TextCellValue('RINGKASAN LAPORAN BULANAN')]);
    sheetObject.appendRow(<CellValue?>[
      TextCellValue('Total Porsi Didistribusi'),
      IntCellValue(totalPorsi),
    ]);
    sheetObject.appendRow(<CellValue?>[
      TextCellValue('Kepatuhan Pengembalian'),
      TextCellValue('$totalSelesai / $totalRows Kelas'),
    ]);
    sheetObject.appendRow(<CellValue?>[
      TextCellValue('Total Akumulasi Denda'),
      IntCellValue(totalDenda),
    ]);

    return excel.encode() ?? <int>[];
  }

  static Future<List<int>> generatePdf({
    required String month,
    required String year,
    required Map<String, Map<String, TrackingRecord>> historyData,
  }) async {
    final pw.Document pdf = pw.Document();

    final List<String> sortedDates = historyData.keys.where((String date) {
      final List<String> parts = date.split(' ');
      if (parts.length >= 3) {
        final String y = parts.last;
        final String m = parts[parts.length - 2];
        return y == year && m == month;
      }
      return false;
    }).toList();
    sortedDates.sort();

    final List<List<String>> tableData = <List<String>>[];
    int totalPorsi = 0;
    int totalDenda = 0;
    int totalSelesai = 0;
    int totalRows = 0;

    for (final String date in sortedDates) {
      final Map<String, TrackingRecord> records = historyData[date]!;
      for (final MapEntry<String, TrackingRecord> entry in records.entries) {
        final String className = entry.key;
        final TrackingRecord rec = entry.value;
        final bool isSelesai = rec.status.name == 'selesai';

        totalPorsi += rec.mbgDiambil;
        totalDenda += rec.denda;
        if (isSelesai) totalSelesai++;
        totalRows++;

        tableData.add(<String>[
          date.split(',').last.trim(), // Date
          className,
          '${rec.mbgDiambil} Porsi',
          isSelesai ? 'Lengkap' : 'Belum Kembali',
          rec.denda > 0 ? 'Rp ${rec.denda}' : '-',
        ]);
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return <pw.Widget>[
            // Title Block
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: <pw.Widget>[
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: <pw.Widget>[
                    pw.Text(
                      'LAPORAN BULANAN MONITORING MyMbg',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#0F172A'),
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Sistem Informasi Pendataan Makanan Bergizi Gratis',
                      style: pw.TextStyle(
                        fontSize: 9,
                        color: PdfColor.fromHex('#64748B'),
                      ),
                    ),
                    pw.SizedBox(height: 12),
                    pw.Text(
                      'Periode Laporan: $month $year',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#0F172A'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.Divider(thickness: 1.5, color: PdfColor.fromHex('#CBD5E1')),
            pw.SizedBox(height: 16),

            // Summary cards
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: <pw.Widget>[
                _pdfStatBox('Total Distribusi', '$totalPorsi Porsi', '#3B82F6'),
                _pdfStatBox('Tingkat Kepatuhan', '$totalSelesai/$totalRows Kelas', '#10B981'),
                _pdfStatBox('Total Denda', 'Rp $totalDenda', '#EF4444'),
              ],
            ),
            pw.SizedBox(height: 24),

            // Data Table Title
            pw.Text(
              'Rincian Transaksi Harian',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#0F172A'),
              ),
            ),
            pw.SizedBox(height: 8),

            // Table Grid
            pw.TableHelper.fromTextArray(
              headers: <String>['Tanggal', 'Kelas', 'MBG Diambil', 'Status', 'Denda'],
              data: tableData,
              border: pw.TableBorder.all(color: PdfColor.fromHex('#E2E8F0')),
              headerStyle: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
              ),
              headerDecoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#0F172A'),
              ),
              cellAlignment: pw.Alignment.centerLeft,
              cellAlignments: <int, pw.Alignment>{
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.center,
                3: pw.Alignment.center,
                4: pw.Alignment.centerRight,
              },
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _pdfStatBox(String label, String value, String hexColor) {
    return pw.Container(
      width: 160,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#F8FAFC'),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0')),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex(hexColor),
            ),
          ),
        ],
      ),
    );
  }
}
