// lib/services/pdf_service.dart

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // <--- Make sure this line is present and correct!
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/station_inspection_data.dart';

class PdfService {
  static Future<Uint8List> generateStationScoreCardPdf(
    StationInspectionData data,
  ) async {
    final pdf = pw.Document();

    // Load a font that supports Indian languages if needed, otherwise use a default.
    // For simplicity, we'll use a standard font here.
    final font =
        await PdfGoogleFonts.poppinsRegular(); // Or .openSansRegular(), .notoSansRegular()

    // Helper to format dates and times
    String formatDate(DateTime? date) {
      return date != null ? DateFormat('dd/MM/yyyy').format(date) : '';
    }

    String formatTime(TimeOfDay? time) {
      if (time == null) return '';
      final now = DateTime.now();
      final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
      return DateFormat('hh:mm a').format(dt);
    }

    // Prepare table data for scores
    // Header row: 'Sl No', 'Itemized Description of work', 'Tlm', 'C1', 'C2', ..., 'C13'
    final List<List<String>> tableData = [];

    // Add main header row for coach IDs
    final List<String> coachHeaders = [
      'Sl No',
      'Itemized Description of work',
      'Tlm',
    ];
    coachHeaders.addAll(data.coachColumns);
    tableData.add(coachHeaders);

    int slNo = 1;

    for (var section in data.sections) {
      // Add a row for the section name (span across columns)
      tableData.add([
        section.name,
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
      ]); // Assuming max columns for span

      for (var parameter in section.parameters) {
        for (var subParameter in parameter.subParameters) {
          final row = [
            slNo.toString(),
            subParameter.name, // The friendly name (e.g., Toilet 1)
            subParameter.id, // The 'Tlm' value (e.g., T1)
          ];
          // Add scores for each coach
          for (var coachId in data.coachColumns) {
            // Check if the sub-parameter applies to this coach
            if (subParameter.coachIds.contains(coachId)) {
              row.add(
                (subParameter.scores[coachId] ?? 0).toString(),
              ); // Use 0 for null scores
            } else {
              row.add(''); // Empty cell if not applicable
            }
          }
          tableData.add(row);
          slNo++;
        }
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'Annexure-B of TT',
                  style: pw.TextStyle(font: font, fontSize: 10),
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Container(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'RAILWAY',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'CLEAN TRAIN STATION',
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'FOR THROUGH PASSED TRAINS',
                      style: pw.TextStyle(font: font, fontSize: 10),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'SCORE CARD (TO BE FILLED BY THE RAILWAY SUPERVISOR / CTS INSPECTION)',
                style: pw.TextStyle(
                  font: font,
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      'W.O. No: ${data.woNo ?? ''}',
                      style: pw.TextStyle(font: font, fontSize: 10),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      'Date: ${formatDate(data.date)}',
                      style: pw.TextStyle(font: font, fontSize: 10),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      'Name of Work: ${data.nameOfWork ?? ''}',
                      style: pw.TextStyle(font: font, fontSize: 10),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      'Name of Contractor: ${data.nameOfContractor ?? ''}',
                      style: pw.TextStyle(font: font, fontSize: 10),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      'Name of Supervisor: ${data.nameOfSupervisor ?? ''}',
                      style: pw.TextStyle(font: font, fontSize: 10),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      'Designation: ${data.designation ?? ''}',
                      style: pw.TextStyle(font: font, fontSize: 10),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      'Date of Inspection: ${formatDate(data.dateOfInspection)}',
                      style: pw.TextStyle(font: font, fontSize: 10),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      'Train No: ${data.trainNo ?? ''}',
                      style: pw.TextStyle(font: font, fontSize: 10),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      'Arrival Time: ${formatTime(data.arrivalTime)}',
                      style: pw.TextStyle(font: font, fontSize: 10),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      'Dep. Time: ${formatTime(data.depTime)}',
                      style: pw.TextStyle(font: font, fontSize: 10),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      'Total No. of Coaches: ${data.totalNoOfCoaches ?? ''}',
                      style: pw.TextStyle(font: font, fontSize: 10),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      'No. of Coaches attended by contractor: ${data.noOfCoachesAttended ?? ''}',
                      style: pw.TextStyle(font: font, fontSize: 10),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.SizedBox(),
                  ), // Empty expanded for spacing
                  pw.Expanded(
                    child: pw.SizedBox(),
                  ), // Empty expanded for spacing
                ],
              ),
              pw.SizedBox(height: 15),

              // Score Table
              pw.Text(
                'CLEAN TRAIN STATION ACTIVITIES',
                style: pw.TextStyle(
                  font: font,
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Table.fromTextArray(
                headers: tableData.first,
                data: tableData.sublist(1),
                border: pw.TableBorder.all(),
                headerStyle: pw.TextStyle(
                  font: font,
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 8,
                ),
                cellStyle: pw.TextStyle(font: font, fontSize: 8),
                columnWidths: {
                  0: const pw.FixedColumnWidth(20), // Sl No
                  1: const pw.FixedColumnWidth(120), // Itemized Description
                  2: const pw.FixedColumnWidth(25), // Tlm
                  // Distribute coach columns equally
                  for (int i = 0; i < data.coachColumns.length; i++)
                    (i + 3): const pw.FlexColumnWidth(1),
                },
                cellAlignment: pw.Alignment.center,
                headerAlignment: pw.Alignment.center,
                cellPadding: const pw.EdgeInsets.all(2),
              ),

              pw.SizedBox(height: 10),
              pw.Text(
                'Note: Please give marks for each item on a scale 0 or 1. All items as above which are inaccessible should be marked \'X\' and shall not be counted in total score. Item not available should be marked \'--\'. No column should be left blank.',
                style: pw.TextStyle(font: font, fontSize: 8),
              ),
              pw.SizedBox(height: 20),
              pw.Align(
                alignment: pw.Alignment.bottomRight,
                child: pw.Text(
                  'Signature of Contractor/Supervisor',
                  style: pw.TextStyle(font: font, fontSize: 10),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Align(
                alignment: pw.Alignment.bottomRight,
                child: pw.Text(
                  'Signature of Auth. Rep. of Sr.DME/LMG',
                  style: pw.TextStyle(font: font, fontSize: 10),
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Align(
                alignment: pw.Alignment.bottomLeft,
                child: pw.Text(
                  'NB: The above score card is indicative only. Original scanned format will be circulated by Railway Administration before commencement of the work.',
                  style: pw.TextStyle(font: font, fontSize: 7),
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Align(
                alignment: pw.Alignment.bottomRight,
                child: pw.Text(
                  'Page 1 of 12', // This might need dynamic page numbering if content overflows
                  style: pw.TextStyle(font: font, fontSize: 8),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
