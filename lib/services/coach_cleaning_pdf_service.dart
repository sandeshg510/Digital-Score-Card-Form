import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/coach_inspection_data.dart';

class PdfServices {
  Future<Uint8List> generateCoachCleaningPdf({
    required CoachCleaningInspectionData inspectionData,
    required CoachColumnData coachColumnData,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          final baseTextStyle = const pw.TextStyle(fontSize: 10);
          final boldTextStyle = pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
          );

          pw.Widget _buildCell(
            String text, {
            pw.TextStyle? style,
            pw.Alignment? alignment = pw.Alignment.centerLeft,
          }) {
            return pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                vertical: 4,
                horizontal: 2,
              ),
              alignment: alignment,
              child: pw.Text(text, style: style ?? baseTextStyle),
            );
          }

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'CLEAN TRAIN STATION ACTIVITY SCORE CARD',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text('Annexure-03 of ITT', style: baseTextStyle),
              pw.SizedBox(height: 5),

              pw.Table(
                border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey),
                columnWidths: {
                  0: const pw.FixedColumnWidth(100),
                  1: const pw.FlexColumnWidth(1),
                },
                children: [
                  pw.TableRow(
                    children: [
                      _buildCell('Agreement No:', style: boldTextStyle),
                      _buildCell(inspectionData.agreementNo ?? 'N/A'),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _buildCell('Agreement Date:', style: boldTextStyle),
                      _buildCell(formatDate(inspectionData.agreementDate)),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _buildCell('Date of Inspection:', style: boldTextStyle),
                      _buildCell(formatDate(inspectionData.dateOfInspection)),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _buildCell('Name of Contractor:', style: boldTextStyle),
                      _buildCell(inspectionData.nameOfContractor ?? 'N/A'),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _buildCell('Name of Supervisor:', style: boldTextStyle),
                      _buildCell(inspectionData.nameOfSupervisor ?? 'N/A'),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _buildCell('Train No:', style: boldTextStyle),
                      _buildCell(inspectionData.trainNo ?? 'N/A'),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _buildCell('Coach No. in Rake:', style: boldTextStyle),
                      _buildCell(
                        inspectionData.coachNoInRake?.toString() ?? 'N/A',
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _buildCell('Time Work Started:', style: boldTextStyle),
                      _buildCell(formatTime(inspectionData.timeWorkStarted)),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _buildCell('Time Work Completed:', style: boldTextStyle),
                      _buildCell(formatTime(inspectionData.timeWorkCompleted)),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _buildCell('Total No. of Coaches:', style: boldTextStyle),
                      _buildCell(
                        inspectionData.totalNoOfCoaches?.toString() ?? 'N/A',
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _buildCell('Inaccessible Coaches:', style: boldTextStyle),
                      _buildCell(inspectionData.inaccessibleCoaches ?? 'N/A'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              pw.Text(
                'COACH CLEANING ACTIVITIES FOR ${coachColumnData.coachNo}',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),

              pw.Table.fromTextArray(
                headers: [
                  'S. No.',
                  'Itemized Description of Work',
                  'Max. Marks',
                  'Marks Obtained',
                ],
                data: inspectionData.scoringParameters.map((section) {
                  final score = coachColumnData.scores[section];
                  return [
                    section.itemCode ?? '',
                    section.displayName,
                    section.maxMarks?.toString() ?? 'N/A',
                    score?.toString() ?? 'N/A',
                  ];
                }).toList(),
                border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey),
                headerStyle: boldTextStyle,
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.blueGrey100,
                ),
                cellAlignment: pw.Alignment.centerLeft,
                cellStyle: baseTextStyle,
                columnWidths: {
                  0: const pw.FixedColumnWidth(30),
                  1: const pw.FlexColumnWidth(3),
                  2: const pw.FixedColumnWidth(60),
                  3: const pw.FixedColumnWidth(60),
                },
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text(
                    'Total Score for ${coachColumnData.coachNo}: ${coachColumnData.totalScoreObtained ?? '0'} / ${coachColumnData.getTotalPossibleScore()}',
                    style: boldTextStyle,
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Remarks: ${coachColumnData.remarks ?? 'No remarks for this coach.'}',
                style: baseTextStyle,
              ),
              pw.SizedBox(height: 20),
              pw.Align(
                alignment: pw.Alignment.bottomRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Signature of Supervisor', style: boldTextStyle),
                    pw.SizedBox(height: 20),
                    pw.Text(
                      'Signature of Contractor/Supervisor',
                      style: boldTextStyle,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String formatTime(TimeOfDay? time) {
    if (time == null) return 'N/A';
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('hh:mm a').format(dt);
  }
}
