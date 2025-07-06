// lib/screens/station_score_card_screen.dart

import 'dart:convert';

import 'package:flutter/material.dart'
    as material; // Alias flutter/material as material
import 'package:flutter/material.dart'; // Keep direct import for other Material widgets
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart'; // Import Provider directly

import '../providers/inspection_provider.dart';
import '../services/pdf_service.dart'; // Import printing package

class StationScoreCardScreen extends StatefulWidget {
  const StationScoreCardScreen({super.key});

  @override
  State<StationScoreCardScreen> createState() => _StationScoreCardScreenState();
}

class _StationScoreCardScreenState extends State<StationScoreCardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<InspectionProvider>(context, listen: false);
    // Initialize tab controller based on the dynamic number of coaches
    _tabController = TabController(
      length: provider.stationInspectionData.coachColumns.length,
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(covariant StationScoreCardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // This is important if the number of coaches can change while this screen is active
    // Although in our current flow, it navigates from a previous screen,
    // it's good practice for robustness.
    final provider = Provider.of<InspectionProvider>(context, listen: false);
    if (_tabController.length !=
        provider.stationInspectionData.coachColumns.length) {
      _tabController.dispose(); // Dispose old controller
      _tabController = TabController(
        length: provider.stationInspectionData.coachColumns.length,
        vsync: this,
      );
      // If the number of coaches changes, we might want to reset the selected tab
      // or try to keep it within bounds. For now, it will default to the first tab.
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _goToNextCoach(InspectionProvider provider, String currentCoachId) {
    // Fill empty scores for the current coach with 0 before moving to the next
    provider.fillEmptyScoresWithDefaultMark(currentCoachId);
    // Recalculate attended coaches after filling scores
    provider.calculateNoOfCoachesAttended();

    if (_tabController.index < _tabController.length - 1) {
      _tabController.animateTo(_tabController.index + 1);
    }
  }

  Future<void> _submitForm() async {
    final provider = Provider.of<InspectionProvider>(context, listen: false);

    // Before final submission, ensure all fields for ALL coaches are explicitly set to 0 if left blank
    for (var coachId in provider.stationInspectionData.coachColumns) {
      provider.fillEmptyScoresWithDefaultMark(coachId);
    }
    // After filling all scores, ensure the attended count is accurate
    provider.calculateNoOfCoachesAttended();

    // Now validate that all fields are non-null (i.e., they are either manually set or defaulted to 0)
    if (!provider.isStationFormValidForSubmission()) {
      material.ScaffoldMessenger.of(context).showSnackBar(
        const material.SnackBar(
          content: material.Text(
            'Submission Error: Some scores are still missing. Please ensure all coaches have been scored.',
          ),
        ),
      );
      return;
    }

    try {
      // 1. Generate PDF
      final pdfBytes = await PdfService.generateStationScoreCardPdf(
        provider.stationInspectionData,
      );

      // 2. Display PDF Preview
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
      );

      // 3. (Optional) Submit data to backend
      final jsonData = provider.stationInspectionData.toJson();
      final url = Uri.parse(
        // Corrected: Used Uri directly, not material.Uri
        'https://httpbin.org/post',
      ); // Use httpbin.org for testing
      // final url = Uri.parse('https://webhook.site/YOUR_UNIQUE_WEBHOOK_URL'); // Replace with your webhook.site URL

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(jsonData),
      );

      if (response.statusCode == 200) {
        material.ScaffoldMessenger.of(context).showSnackBar(
          const material.SnackBar(
            content: material.Text('Station Form submitted successfully!'),
          ),
        );
        print('Station Submission Successful: ${response.body}');
        provider.resetStationForm();
        material.Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        material.ScaffoldMessenger.of(context).showSnackBar(
          material.SnackBar(
            content: material.Text(
              'Station Form submission failed: ${response.statusCode}',
            ),
          ),
        );
        print('Station Submission Failed: ${response.body}');
      }
    } catch (e) {
      material.ScaffoldMessenger.of(context).showSnackBar(
        material.SnackBar(
          content: material.Text(
            'An error occurred during Station Form submission: $e',
          ),
        ),
      );
      print('Error during Station submission: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InspectionProvider>(
      // Corrected: Used Consumer directly, not material.Consumer
      builder: (context, inspectionProvider, child) {
        final List<String> coachColumns =
            inspectionProvider.stationInspectionData.coachColumns;

        // Re-initialize TabController if coachColumns length changes (edge case if state changes after init)
        // This handles cases where totalNoOfCoaches might be updated after initial build.
        // It's technically covered by didUpdateWidget but doing it here ensures it's always in sync.
        // We ensure we only dispose and re-create if really needed to avoid unnecessary widget rebuilds.
        if (_tabController.length != coachColumns.length) {
          _tabController.dispose();
          _tabController = TabController(
            length: coachColumns.length,
            vsync: this,
          );
        }

        return DefaultTabController(
          length: coachColumns.length,
          child: material.Scaffold(
            appBar: material.AppBar(
              title: const material.Text('Clean Train Station Score Card'),
              bottom: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: coachColumns
                    .map((coachId) => material.Tab(text: coachId))
                    .toList(),
              ),
            ),
            body: material.Column(
              children: [
                material.Padding(
                  padding: const material.EdgeInsets.all(16.0),
                  child: material.Align(
                    alignment: material.Alignment.centerLeft,
                    child: material.Text(
                      'No. of Coaches attended: ${inspectionProvider.stationInspectionData.noOfCoachesAttended ?? 'N/A'}',
                      style: const material.TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                material.Expanded(
                  child: material.TabBarView(
                    controller: _tabController,
                    children: List.generate(coachColumns.length, (index) {
                      final coachId = coachColumns[index];
                      final isLastCoach = index == coachColumns.length - 1;
                      final totalScoreForCoach = inspectionProvider
                          .calculateTotalScoreForCoach(coachId);

                      return material.SingleChildScrollView(
                        padding: const material.EdgeInsets.all(16.0),
                        child: material.Column(
                          crossAxisAlignment: material.CrossAxisAlignment.start,
                          children: [
                            material.Center(
                              child: material.Text(
                                'Scoring - $coachId',
                                style: const material.TextStyle(
                                  fontSize: 20,
                                  fontWeight: material.FontWeight.bold,
                                  color: material.Colors.blueAccent,
                                ),
                              ),
                            ),
                            const material.SizedBox(height: 16.0),
                            ...inspectionProvider.stationInspectionData.sections.map((
                              section,
                            ) {
                              return material.Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: const material.EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: material.Padding(
                                  padding: const material.EdgeInsets.all(12.0),
                                  child: material.Column(
                                    crossAxisAlignment:
                                        material.CrossAxisAlignment.start,
                                    children: [
                                      material.Text(
                                        section.name,
                                        style: const material.TextStyle(
                                          fontSize: 18,
                                          fontWeight: material.FontWeight.bold,
                                          color: material.Colors.deepPurple,
                                        ),
                                      ),
                                      const material.SizedBox(height: 12),
                                      ...section.parameters.map((parameter) {
                                        return material.Padding(
                                          padding:
                                              const material.EdgeInsets.only(
                                                bottom: 12.0,
                                              ),
                                          child: material.Column(
                                            crossAxisAlignment: material
                                                .CrossAxisAlignment
                                                .start,
                                            children: [
                                              material.Text(
                                                parameter.name,
                                                style: const material.TextStyle(
                                                  fontSize: 16,
                                                  fontWeight:
                                                      material.FontWeight.w600,
                                                ),
                                              ),
                                              const material.SizedBox(
                                                height: 8.0,
                                              ),
                                              ...parameter.subParameters.map((
                                                subParam,
                                              ) {
                                                if (!subParam.coachIds.contains(
                                                  coachId,
                                                )) {
                                                  return const material.SizedBox.shrink();
                                                }
                                                return material.Row(
                                                  children: [
                                                    material.Expanded(
                                                      flex: 2,
                                                      child: material.Text(
                                                        subParam.name,
                                                        style:
                                                            const material.TextStyle(
                                                              fontSize: 14,
                                                            ),
                                                      ),
                                                    ),
                                                    material.SizedBox(
                                                      width: 12,
                                                    ),
                                                    material.Expanded(
                                                      flex: 1,
                                                      child: material.DropdownButtonFormField<int>(
                                                        value: subParam
                                                            .scores[coachId],
                                                        decoration: InputDecoration(
                                                          contentPadding:
                                                              const material.EdgeInsets.symmetric(
                                                                horizontal: 12,
                                                                vertical: 8,
                                                              ),
                                                          border: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8,
                                                                ),
                                                          ),
                                                          filled: true,
                                                          fillColor: material
                                                              .Colors
                                                              .grey[100],
                                                          labelText: 'Score',
                                                        ),
                                                        items: List.generate(11, (j) => j)
                                                            .map(
                                                              (
                                                                score,
                                                              ) => material.DropdownMenuItem<int>(
                                                                value: score,
                                                                child:
                                                                    material.Text(
                                                                      '$score',
                                                                    ),
                                                              ),
                                                            )
                                                            .toList(),
                                                        onChanged: (int? newValue) {
                                                          inspectionProvider
                                                              .updateStationSubParameterScore(
                                                                section.name,
                                                                parameter.name,
                                                                subParam.id,
                                                                coachId,
                                                                newValue,
                                                              );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }).toList(),
                                              const material.SizedBox(
                                                height: 8.0,
                                              ),
                                              material.TextFormField(
                                                initialValue: parameter.remarks,
                                                decoration: InputDecoration(
                                                  labelText: 'Remarks',
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  filled: true,
                                                  fillColor:
                                                      material.Colors.grey[100],
                                                ),
                                                maxLines: 2,
                                                onChanged: (value) {
                                                  inspectionProvider
                                                      .updateStationParameterRemarks(
                                                        section.name,
                                                        parameter.name,
                                                        value,
                                                      );
                                                },
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                            const material.SizedBox(height: 16.0),
                            material.Container(
                              width: double.infinity,
                              padding: const material.EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: material.Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: material.Center(
                                child: material.Text(
                                  'Total Score for $coachId: $totalScoreForCoach',
                                  style: const material.TextStyle(
                                    fontSize: 18,
                                    fontWeight: material.FontWeight.bold,
                                    color: material.Colors.deepOrange,
                                  ),
                                ),
                              ),
                            ),
                            const material.SizedBox(height: 24),
                            material.Center(
                              child: material.ElevatedButton.icon(
                                icon: material.Icon(
                                  isLastCoach
                                      ? material.Icons.check
                                      : material.Icons.arrow_forward,
                                ),
                                label: material.Text(
                                  isLastCoach
                                      ? 'Submit Inspection'
                                      : 'Next Coach',
                                ),
                                style: material.ElevatedButton.styleFrom(
                                  backgroundColor: material.Colors.deepPurple,
                                  padding: const material.EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 14,
                                  ),
                                  textStyle: const material.TextStyle(
                                    fontSize: 16,
                                    fontWeight: material.FontWeight.bold,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: isLastCoach
                                    ? _submitForm
                                    : () => _goToNextCoach(
                                        inspectionProvider,
                                        coachId,
                                      ),
                              ),
                            ),
                            const material.SizedBox(height: 24),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
