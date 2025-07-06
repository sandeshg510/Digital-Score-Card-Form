// lib/screens/station_score_card_screen.dart

import 'dart:convert';

import 'package:flutter/material.dart' as pw;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

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
    _tabController = TabController(
      length: provider.stationInspectionData.coachColumns.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _goToNextCoach(InspectionProvider provider, String currentCoachId) {
    provider.fillEmptyScoresWithZero(currentCoachId);
    if (_tabController.index < _tabController.length - 1) {
      _tabController.animateTo(_tabController.index + 1);
    }
  }

  Future<void> _submitForm() async {
    final provider = Provider.of<InspectionProvider>(context, listen: false);

    // Before final submission, ensure all fields are explicitly set to 0 if left blank
    provider.stationInspectionData.coachColumns.forEach((coachId) {
      provider.fillEmptyScoresWithZero(coachId);
    });

    // Now validate that all fields are non-null (i.e., they are either manually set or defaulted to 0)
    if (!provider.isStationFormValidForSubmission()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Submission Error: Some scores are still missing. This should not happen if "Next Coach" was used.',
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
        'https://httpbin.org/post',
      ); // Your backend endpoint
      // final url = Uri.parse('https://webhook.site/YOUR_UNIQUE_WEBHOOK_URL'); // Replace with your webhook.site URL

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(jsonData),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Station Form submitted successfully!')),
        );
        print('Station Submission Successful: ${response.body}');
        provider.resetStationForm();
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Station Form submission failed: ${response.statusCode}',
            ),
          ),
        );
        print('Station Submission Failed: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred during Station Form submission: $e'),
        ),
      );
      print('Error during Station submission: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InspectionProvider>(
      builder: (context, inspectionProvider, child) {
        final List<String> coachColumns =
            inspectionProvider.stationInspectionData.coachColumns;

        return DefaultTabController(
          length: coachColumns.length,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Clean Train Station Score Card'),
              bottom: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: coachColumns
                    .map((coachId) => Tab(text: coachId))
                    .toList(),
              ),
            ),
            body: Column(
              children: [
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: List.generate(coachColumns.length, (index) {
                      final coachId = coachColumns[index];
                      final isLastCoach = index == coachColumns.length - 1;

                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16.0,
                                ),
                                child: Text(
                                  'Scoring for $coachId',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ),
                            ),
                            ...inspectionProvider.stationInspectionData.sections.map((
                              section,
                            ) {
                              return Column(
                                crossAxisAlignment: pw
                                    .CrossAxisAlignment
                                    .start, // Use pw.CrossAxisAlignment for pdf
                                children: [
                                  const Divider(),
                                  ...section.parameters.map((parameter) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8.0,
                                      ),
                                      child: Column(
                                        crossAxisAlignment: pw
                                            .CrossAxisAlignment
                                            .start, // Use pw.CrossAxisAlignment for pdf
                                        children: [
                                          Text(
                                            parameter.name,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 8.0),
                                          ...parameter.subParameters.map((
                                            subParameter,
                                          ) {
                                            if (subParameter.coachIds.contains(
                                              coachId,
                                            )) {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 16.0,
                                                  bottom: 8.0,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 2,
                                                      child: Text(
                                                        subParameter.name,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 1,
                                                      child: DropdownButtonFormField<int>(
                                                        value: subParameter
                                                            .scores[coachId],
                                                        decoration: const InputDecoration(
                                                          contentPadding:
                                                              EdgeInsets.symmetric(
                                                                horizontal: 8,
                                                                vertical: 0,
                                                              ),
                                                          border:
                                                              OutlineInputBorder(),
                                                          isCollapsed: true,
                                                          labelText: 'Score',
                                                        ),
                                                        items: List.generate(11, (j) => j)
                                                            .map(
                                                              (score) =>
                                                                  DropdownMenuItem<
                                                                    int
                                                                  >(
                                                                    value:
                                                                        score,
                                                                    child: Text(
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
                                                                subParameter.id,
                                                                coachId,
                                                                newValue,
                                                              );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }
                                            return const SizedBox.shrink();
                                          }).toList(),
                                          const SizedBox(height: 8.0),
                                          TextFormField(
                                            initialValue: parameter.remarks,
                                            decoration: InputDecoration(
                                              labelText:
                                                  'Remarks for ${parameter.name} (Optional)',
                                              border:
                                                  const OutlineInputBorder(),
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
                                  const SizedBox(height: 20.0),
                                ],
                              );
                            }).toList(),
                            const SizedBox(height: 20.0),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                              ),
                              child: Center(
                                child: isLastCoach
                                    ? ElevatedButton(
                                        onPressed: _submitForm,
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 40,
                                            vertical: 15,
                                          ),
                                          textStyle: const TextStyle(
                                            fontSize: 18,
                                          ),
                                        ),
                                        child: const Text(
                                          'Submit Station Inspection',
                                        ),
                                      )
                                    : ElevatedButton(
                                        onPressed: () => _goToNextCoach(
                                          inspectionProvider,
                                          coachId,
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 40,
                                            vertical: 15,
                                          ),
                                          textStyle: const TextStyle(
                                            fontSize: 18,
                                          ),
                                        ),
                                        child: const Text('Next Coach'),
                                      ),
                              ),
                            ),
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
