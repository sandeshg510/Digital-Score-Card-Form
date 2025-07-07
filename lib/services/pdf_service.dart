// lib/services/pdf_service.dart

import 'dart:typed_data';

import 'package:flutter/material.dart'; // Keep this for TimeOfDay, etc.
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/station_inspection_data.dart';

class PdfService {
  // Helper to map Flutter TextAlign to pdf Alignment
  // Moved this to be a static method so it can be called correctly.
  static pw.Alignment _getAlignment(pw.TextAlign textAlign) {
    switch (textAlign) {
      case pw.TextAlign.left:
        return pw.Alignment.centerLeft;
      case pw.TextAlign.right:
        return pw.Alignment.centerRight;
      case pw.TextAlign.center:
      default:
        return pw.Alignment.center;
    }
  }

  static Future<Uint8List> generateStationScoreCardPdf(
    StationInspectionData data,
  ) async {
    final pdf = pw.Document();

    final font = await PdfGoogleFonts.notoSerifRegular();

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

    // List to hold table rows
    final List<pw.TableRow> tableRows = [];

    // Cell styling helper
    pw.Container _buildCell(
      pw.Widget? child, {
      pw.TextAlign? textAlign,
      pw.Border? border,
      pw.EdgeInsets? padding = const pw.EdgeInsets.all(2),
      double? height,
    }) {
      return pw.Container(
        alignment: textAlign != null
            ? _getAlignment(textAlign)
            : pw.Alignment.center,
        padding: padding,
        decoration: border != null ? pw.BoxDecoration(border: border) : null,
        height: height,
        child: child,
      );
    }

    // Header row
    final List<pw.Widget> headerCells = [
      _buildCell(
        pw.Text(
          'Sl No',
          style: pw.TextStyle(
            font: font,
            fontWeight: pw.FontWeight.bold,
            fontSize: 8,
          ),
        ),
        textAlign: pw.TextAlign.center,
        border: pw.Border.all(width: 0.5),
      ),
      _buildCell(
        pw.Text(
          'Itemized Description of work',
          style: pw.TextStyle(
            font: font,
            fontWeight: pw.FontWeight.bold,
            fontSize: 8,
          ),
        ),
        textAlign: pw.TextAlign.center,
        border: pw.Border.all(width: 0.5),
      ),
      _buildCell(
        pw.Text(
          'T\'let',
          style: pw.TextStyle(
            font: font,
            fontWeight: pw.FontWeight.bold,
            fontSize: 8,
          ),
        ),
        textAlign: pw.TextAlign.center,
        border: pw.Border.all(width: 0.5),
      ), // Changed to T'let
    ];
    // Add dynamic coach headers
    for (var coachId in data.coachColumns) {
      headerCells.add(
        _buildCell(
          pw.Text(
            coachId,
            style: pw.TextStyle(
              font: font,
              fontWeight: pw.FontWeight.bold,
              fontSize: 8,
            ),
          ),
          textAlign: pw.TextAlign.center,
          border: pw.Border.all(width: 0.5),
        ),
      );
    }
    tableRows.add(pw.TableRow(children: headerCells));

    int slNo = 1;

    // Iterate through sections and then parameters to build the table with merged cells
    for (var section in data.sections) {
      for (var parameter in section.parameters) {
        if (parameter.subParameters.isEmpty) continue;

        final int subParameterCount = parameter.subParameters.length;

        // --- First row of the parameter block (with Sl No and Itemized Description) ---
        final List<pw.Widget> firstRowCells = [];

        // Sl No cell (with top, left, right border, but not bottom)
        firstRowCells.add(
          _buildCell(
            pw.Text(
              slNo.toString(),
              style: pw.TextStyle(font: font, fontSize: 8),
            ),
            textAlign: pw.TextAlign.center,
            border: pw.Border(
              top: const pw.BorderSide(width: 0.5),
              left: const pw.BorderSide(width: 0.5),
              right: const pw.BorderSide(width: 0.5),
              bottom: subParameterCount == 1
                  ? const pw.BorderSide(width: 0.5)
                  : pw
                        .BorderSide
                        .none, // Only bottom if it's a single sub-parameter
            ),
          ),
        );

        // Itemized Description of work cell (with top, left, right border, but not bottom)
        firstRowCells.add(
          _buildCell(
            pw.Text(
              parameter.name,
              style: pw.TextStyle(font: font, fontSize: 8),
            ),
            textAlign: pw.TextAlign.left, // Use pw.TextAlign.left directly
            border: pw.Border(
              top: const pw.BorderSide(width: 0.5),
              left: const pw.BorderSide(width: 0.5),
              right: const pw.BorderSide(width: 0.5),
              bottom: subParameterCount == 1
                  ? const pw.BorderSide(width: 0.5)
                  : pw
                        .BorderSide
                        .none, // Only bottom if it's a single sub-parameter
            ),
          ),
        );

        // First T'let (Tlm) and score cells (with all borders)
        final firstSubParameter = parameter.subParameters.first;
        firstRowCells.add(
          _buildCell(
            pw.Text(
              firstSubParameter.id,
              style: pw.TextStyle(font: font, fontSize: 8),
            ),
            textAlign: pw.TextAlign.center,
            border: pw.Border.all(width: 0.5),
          ),
        );

        for (var coachId in data.coachColumns) {
          firstRowCells.add(
            _buildCell(
              pw.Text(
                firstSubParameter.coachIds.contains(coachId)
                    ? (firstSubParameter.scores[coachId] ?? 0).toString()
                    : '',
                style: pw.TextStyle(font: font, fontSize: 8),
              ),
              textAlign: pw.TextAlign.center,
              border: pw.Border.all(width: 0.5),
            ),
          );
        }
        tableRows.add(pw.TableRow(children: firstRowCells));

        // --- Subsequent rows for sub-parameters (without Sl No and Itemized Description) ---
        for (int i = 1; i < subParameterCount; i++) {
          final subParameter = parameter.subParameters[i];
          final List<pw.Widget> subRowCells = [];

          // Add empty cells for spanned columns (Sl No and Itemized Description),
          // maintaining only left and right borders, no top/bottom for merging effect.
          final isLastSubParameter = (i == subParameterCount - 1);

          subRowCells.add(
            _buildCell(
              pw.SizedBox.shrink(), // Empty cell for visual spanning
              border: pw.Border(
                left: const pw.BorderSide(width: 0.5),
                right: const pw.BorderSide(width: 0.5),
                bottom: isLastSubParameter
                    ? const pw.BorderSide(width: 0.5)
                    : pw
                          .BorderSide
                          .none, // Only bottom border on the last sub-parameter row for this group
              ),
            ),
          );
          subRowCells.add(
            _buildCell(
              pw.SizedBox.shrink(), // Empty cell for visual spanning
              border: pw.Border(
                left: const pw.BorderSide(width: 0.5),
                right: const pw.BorderSide(width: 0.5),
                bottom: isLastSubParameter
                    ? const pw.BorderSide(width: 0.5)
                    : pw
                          .BorderSide
                          .none, // Only bottom border on the last sub-parameter row for this group
              ),
            ),
          );

          // T'let (Tlm) and score cells (with all borders)
          subRowCells.add(
            _buildCell(
              pw.Text(
                subParameter.id,
                style: pw.TextStyle(font: font, fontSize: 8),
              ),
              textAlign: pw.TextAlign.center,
              border: pw.Border.all(width: 0.5),
            ),
          );

          for (var coachId in data.coachColumns) {
            subRowCells.add(
              _buildCell(
                pw.Text(
                  subParameter.coachIds.contains(coachId)
                      ? (subParameter.scores[coachId] ?? 0).toString()
                      : '',
                  style: pw.TextStyle(font: font, fontSize: 8),
                ),
                textAlign: pw.TextAlign.center,
                border: pw.Border.all(width: 0.5),
              ),
            );
          }
          tableRows.add(pw.TableRow(children: subRowCells));
        }

        // Add remarks row if remarks exist for the parameter.
        // This row will typically span all columns and have full borders.
        if (parameter.remarks != null && parameter.remarks!.isNotEmpty) {
          tableRows.add(
            pw.TableRow(
              children: [
                _buildCell(
                  pw.SizedBox.shrink(),
                  border: pw.Border.all(width: 0.5),
                ), // Sl No column - empty
                _buildCell(
                  pw.Text(
                    'Remarks for ${parameter.name}:',
                    style: pw.TextStyle(font: font, fontSize: 8),
                  ),
                  textAlign: pw.TextAlign.left,
                  border: pw.Border.all(width: 0.5),
                ),
                _buildCell(
                  pw.Text(
                    parameter.remarks!,
                    style: pw.TextStyle(font: font, fontSize: 8),
                  ),
                  textAlign: pw.TextAlign.left,
                  border: pw.Border.all(width: 0.5),
                ),
                // Remaining columns for coach scores - empty with borders
                for (int i = 0; i < data.coachColumns.length; i++)
                  _buildCell(
                    pw.SizedBox.shrink(),
                    border: pw.Border.all(width: 0.5),
                  ),
              ],
            ),
          );
        }

        slNo++; // Increment Sl No for the next main parameter
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
                  // These fields are not in the current data model nor requested for calculations
                  // in provider due to 'no changes to files' instruction.
                  // pw.Expanded(
                  //   child: pw.Text(
                  //     'Total Score obtained: ${data.totalScoreObtained ?? 'N/A'}%',
                  //     style: pw.TextStyle(font: font, fontSize: 10),
                  //   ),
                  // ),
                  // pw.Expanded(
                  //   child: pw.Text(
                  //     'Inaccessible: ${data.inaccessibleCount ?? 'N/A'}x',
                  //     style: pw.TextStyle(font: font, fontSize: 10),
                  //   ),
                  // ),
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
              pw.Table(
                columnWidths: {
                  0: const pw.FixedColumnWidth(20), // Sl No
                  1: const pw.FlexColumnWidth(
                    3,
                  ), // Itemized Description of work (expanded)
                  2: const pw.FixedColumnWidth(25), // T'let
                  // Distribute coach columns equally
                  for (int i = 0; i < data.coachColumns.length; i++)
                    (i + 3): const pw.FlexColumnWidth(1),
                },
                children: tableRows,
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
