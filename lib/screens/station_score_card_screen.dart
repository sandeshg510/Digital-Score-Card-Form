import 'dart:convert';

import 'package:flutter/material.dart' as material;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../constants/global_variables.dart';
import '../core/common/widgets/gradient_tab_app_bar.dart';
import '../providers/inspection_provider.dart';
import '../services/pdf_service.dart';

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
  void didUpdateWidget(covariant StationScoreCardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final provider = Provider.of<InspectionProvider>(context, listen: false);
    if (_tabController.length !=
        provider.stationInspectionData.coachColumns.length) {
      _tabController.dispose();
      _tabController = TabController(
        length: provider.stationInspectionData.coachColumns.length,
        vsync: this,
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _goToNextCoach(InspectionProvider provider, String currentCoachId) {
    provider.fillEmptyScoresWithDefaultMark(currentCoachId);
    provider.calculateNoOfCoachesAttended();

    if (_tabController.index < _tabController.length - 1) {
      _tabController.animateTo(_tabController.index + 1);
    }
  }

  Future<void> _submitForm() async {
    final provider = Provider.of<InspectionProvider>(context, listen: false);

    for (var coachId in provider.stationInspectionData.coachColumns) {
      provider.fillEmptyScoresWithDefaultMark(coachId);
    }
    provider.calculateNoOfCoachesAttended();

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
      final pdfBytes = await PdfService.generateStationScoreCardPdf(
        provider.stationInspectionData,
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
      );

      final jsonData = provider.stationInspectionData.toJson();
      final url = Uri.parse('https://httpbin.org/post');

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
      }
    } catch (e) {
      material.ScaffoldMessenger.of(context).showSnackBar(
        material.SnackBar(
          content: material.Text(
            'An error occurred during Station Form submission: $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InspectionProvider>(
      builder: (context, inspectionProvider, child) {
        final List<String> coachColumns =
            inspectionProvider.stationInspectionData.coachColumns;

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
            backgroundColor: Colors.white,
            appBar: GradientTabAppBar(
              title: 'Clean Train Station Score Card',
              tabController: _tabController,
              tabs: coachColumns
                  .map(
                    (coachId) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Tab(
                        child: material.Text(
                          coachId,
                          style: const material.TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
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
                        color: Colors.black87,
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
                        padding: const material.EdgeInsets.symmetric(
                          horizontal: 4.0,
                          vertical: 10,
                        ),
                        child: material.Column(
                          crossAxisAlignment: material.CrossAxisAlignment.start,
                          children: [
                            const material.SizedBox(height: 24.0),

                            material.Center(
                              child: material.Text(
                                'Scoring - $coachId',
                                style: const material.TextStyle(
                                  fontSize: 20,
                                  fontWeight: material.FontWeight.bold,
                                  color: GlobalVariables.deepPurpleColor,
                                ),
                              ),
                            ),
                            ...inspectionProvider.stationInspectionData.sections.map((
                              section,
                            ) {
                              return material.Container(
                                margin: const material.EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                padding: const material.EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: material.Column(
                                  crossAxisAlignment:
                                      material.CrossAxisAlignment.start,
                                  children: [
                                    material.Text(
                                      section.name,
                                      style: const material.TextStyle(
                                        fontSize: 18,
                                        fontWeight: material.FontWeight.bold,
                                        color: GlobalVariables.deepPurpleColor,
                                      ),
                                    ),
                                    ...section.parameters.map((parameter) {
                                      return material.Padding(
                                        padding: const material.EdgeInsets.only(
                                          top: 20,
                                          bottom: 12.0,
                                        ),
                                        child: material.Column(
                                          crossAxisAlignment:
                                              material.CrossAxisAlignment.start,
                                          children: [
                                            material.Text(
                                              parameter.name,
                                              style: const material.TextStyle(
                                                fontSize: 16,
                                                fontWeight:
                                                    material.FontWeight.w600,
                                                color: material.Colors.black87,
                                              ),
                                            ),
                                            const material.SizedBox(
                                              height: 18.0,
                                            ),
                                            ...parameter.subParameters.map((
                                              subParam,
                                            ) {
                                              if (!subParam.coachIds.contains(
                                                coachId,
                                              )) {
                                                return const material.SizedBox.shrink();
                                              }
                                              return material.Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 14.0,
                                                ),
                                                child: material.Row(
                                                  children: [
                                                    material.Expanded(
                                                      flex: 2,
                                                      child: material.Text(
                                                        subParam.name,
                                                        style:
                                                            const material.TextStyle(
                                                              fontSize: 14,
                                                              color: material
                                                                  .Colors
                                                                  .black54,
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
                                                                horizontal: 18,
                                                                vertical: 8,
                                                              ),
                                                          border: OutlineInputBorder(
                                                            borderRadius:
                                                                material
                                                                    .BorderRadius.circular(
                                                                  10,
                                                                ),
                                                            borderSide:
                                                                BorderSide(
                                                                  color: material
                                                                      .Colors
                                                                      .grey
                                                                      .shade400,
                                                                  width: 1,
                                                                ),
                                                          ),
                                                          enabledBorder: OutlineInputBorder(
                                                            borderRadius:
                                                                material
                                                                    .BorderRadius.circular(
                                                                  10,
                                                                ),
                                                            borderSide:
                                                                BorderSide(
                                                                  color: material
                                                                      .Colors
                                                                      .grey
                                                                      .shade400,
                                                                  width: 1,
                                                                ),
                                                          ),
                                                          focusedBorder: OutlineInputBorder(
                                                            borderRadius:
                                                                material
                                                                    .BorderRadius.circular(
                                                                  10,
                                                                ),
                                                            borderSide: const BorderSide(
                                                              color: GlobalVariables
                                                                  .deepPurpleColor,
                                                              width: 2,
                                                            ),
                                                          ),
                                                          filled: true,
                                                          fillColor:
                                                              Colors.white,
                                                          labelText: 'Score',
                                                          labelStyle:
                                                              const material.TextStyle(
                                                                color: material
                                                                    .Colors
                                                                    .grey,
                                                              ),
                                                        ),
                                                        items: List.generate(11, (j) => j)
                                                            .map(
                                                              (
                                                                score,
                                                              ) => material.DropdownMenuItem<int>(
                                                                value: score,
                                                                child: material.Text(
                                                                  '$score',
                                                                  style: const material.TextStyle(
                                                                    color: material
                                                                        .Colors
                                                                        .black87,
                                                                  ),
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
                                                ),
                                              );
                                            }),
                                            const material.SizedBox(
                                              height: 18.0,
                                            ),
                                            material.TextFormField(
                                              initialValue: parameter.remarks,
                                              decoration: InputDecoration(
                                                labelText: 'Remarks',
                                                labelStyle:
                                                    const material.TextStyle(
                                                      color:
                                                          material.Colors.grey,
                                                    ),
                                                border: OutlineInputBorder(
                                                  borderRadius: material
                                                      .BorderRadius.circular(10),
                                                  borderSide: BorderSide(
                                                    color: material
                                                        .Colors
                                                        .grey
                                                        .shade400,
                                                    width: 1,
                                                  ),
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderRadius: material
                                                      .BorderRadius.circular(10),
                                                  borderSide: BorderSide(
                                                    color: material
                                                        .Colors
                                                        .grey
                                                        .shade400,
                                                    width: 1,
                                                  ),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius: material
                                                      .BorderRadius.circular(10),
                                                  borderSide: const BorderSide(
                                                    color: GlobalVariables
                                                        .deepPurpleColor,
                                                    width: 2,
                                                  ),
                                                ),
                                                filled: true,
                                                fillColor: Colors.white,
                                              ),
                                              maxLines: 2,
                                              style: const material.TextStyle(
                                                color: material.Colors.black87,
                                              ),
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
                                    }),
                                  ],
                                ),
                              );
                            }),
                            const material.SizedBox(height: 16.0),
                            material.Container(
                              width: double.infinity,
                              padding: const material.EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              child: material.Center(
                                child: material.Text(
                                  'Total Score for $coachId: $totalScoreForCoach',
                                  style: const material.TextStyle(
                                    fontSize: 18,
                                    fontWeight: material.FontWeight.bold,
                                    color: GlobalVariables.deepPurpleColor,
                                  ),
                                ),
                              ),
                            ),
                            const material.SizedBox(height: 24),
                            material.Center(
                              child: material.Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: GlobalVariables.appBarGradient,
                                ),
                                child: material.ElevatedButton.icon(
                                  icon: material.Icon(
                                    isLastCoach
                                        ? material.Icons.check
                                        : material.Icons.arrow_forward,
                                    color: Colors.white,
                                  ),

                                  label: material.Text(
                                    isLastCoach
                                        ? 'Submit Inspection'
                                        : 'Next Coach',
                                    style: const material.TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  style: material.ElevatedButton.styleFrom(
                                    backgroundColor:
                                        material.Colors.transparent,
                                    shadowColor: material.Colors.transparent,
                                    padding:
                                        const material.EdgeInsets.symmetric(
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
                            ),
                            const material.SizedBox(height: 40),
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
