// lib/screens/coach_score_card_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For TextInputFormatter
import 'package:printing/printing.dart'; // Import the printing package
import 'package:provider/provider.dart';

import '../constants/global_variables.dart';
import '../core/common/widgets/basics.dart'; // Ensure this file exists for verticalSpace etc. and CommonWidgets mixin
import '../core/common/widgets/gradient_app_bar.dart';
import '../core/common/widgets/gradient_button.dart';
// Corrected import: Make sure this path points to your updated model file
import '../models/coach_inspection_data.dart';
import '../providers/coach_cleaning_provider.dart';
import '../services/coach_cleaning_pdf_service.dart'; // Import your PdfService

class CoachScoreCardScreen extends StatefulWidget {
  const CoachScoreCardScreen({super.key});

  @override
  State<CoachScoreCardScreen> createState() => _CoachScoreCardScreenState();
}

class _CoachScoreCardScreenState extends State<CoachScoreCardScreen>
    with SingleTickerProviderStateMixin, CommonWidgets {
  late TabController _tabController;
  final List<TextEditingController> _remarkControllers = [];
  final Map<int, Map<Section, TextEditingController>> _scoreControllers = {};
  final List<GlobalKey<FormState>> _formKeys = [];

  // Instantiate PdfService
  final PdfServices _pdfService = PdfServices();

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<CoachCleaningProvider>(context, listen: false);
    final coachColumns = provider.coachCleaningInspectionData.coachColumns;

    // Initialize TabController only if coachColumns is not empty to avoid errors
    // if no coaches are defined initially.
    _tabController = TabController(length: coachColumns.length, vsync: this);

    _initializeControllers(coachColumns);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        // Optionally, you can trigger a save or data refresh here if needed
      }
    });
  }

  void _initializeControllers(List<CoachColumnData> coachColumns) {
    _remarkControllers.clear();
    _scoreControllers.clear();
    _formKeys.clear();

    // Get scoring sections dynamically from the inspection data model
    // This is crucial to match the Sections defined in your model
    final List<Section> scoringSections = Section.values
        .where((s) => s.maxMarks != null) // Filter for actual scoring sections
        .toList();

    for (int i = 0; i < coachColumns.length; i++) {
      _remarkControllers.add(
        TextEditingController(text: coachColumns[i].remarks ?? ''),
      );
      _scoreControllers[i] = {};
      _formKeys.add(GlobalKey<FormState>());

      for (var section in scoringSections) {
        final score = coachColumns[i].scores[section];
        _scoreControllers[i]![section] = TextEditingController(
          text: score?.toString() ?? '',
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (var controller in _remarkControllers) {
      controller.dispose();
    }
    _scoreControllers.values.forEach((sectionControllers) {
      sectionControllers.values.forEach((controller) {
        controller.dispose();
      });
    });
    super.dispose();
  }

  void _saveScores(CoachCleaningProvider provider) {
    final currentCoachIndex = _tabController.index;
    // Check if the form key exists for the current index to prevent crashes
    if (_formKeys.length <= currentCoachIndex ||
        _formKeys[currentCoachIndex].currentState == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Error: Form not ready for validation. Please restart the app.',
          ),
        ),
      );
      return;
    }

    final currentFormKey = _formKeys[currentCoachIndex];

    if (!currentFormKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please correct invalid scores before saving.'),
        ),
      );
      return;
    }

    final currentCoachData =
        provider.coachCleaningInspectionData.coachColumns[currentCoachIndex];

    currentCoachData.remarks = _remarkControllers[currentCoachIndex].text
        .trim();

    // Ensure we iterate over the actual scoring parameters from the inspection data
    provider.coachCleaningInspectionData.scoringParameters.forEach((section) {
      final controller = _scoreControllers[currentCoachIndex]![section];
      final enteredValue = int.tryParse(controller?.text ?? '');
      currentCoachData.scores[section] = enteredValue;
    });

    // Recalculate total score for the current coach before updating
    currentCoachData.totalScoreObtained = currentCoachData
        .calculateTotalScoreObtained();

    provider.updateCoachColumnData(currentCoachIndex, currentCoachData);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Scores and remarks saved for current coach.'),
      ),
    );
  }

  String? _validateScore(String? value, int maxScore) {
    if (value == null || value.isEmpty) {
      return 'Required';
    }
    final score = int.tryParse(value);
    if (score == null || score < 0 || score > maxScore) {
      return 'Enter 0-$maxScore';
    }
    return null;
  }

  void _generatePdf() async {
    final provider = Provider.of<CoachCleaningProvider>(context, listen: false);
    if (provider.coachCleaningInspectionData.coachColumns.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No coach data to generate PDF.')),
      );
      return;
    }

    final currentCoachData =
        provider.coachCleaningInspectionData.coachColumns[_tabController.index];

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Generating PDF...')));

    try {
      final pdfBytes = await _pdfService.generateCoachCleaningPdf(
        inspectionData: provider.coachCleaningInspectionData,
        coachColumnData: currentCoachData,
      );

      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: 'coach_score_card_${currentCoachData.coachNo}.pdf',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF generated and opened successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to generate PDF: $e')));
      print('PDF generation error: $e'); // For debugging
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CoachCleaningProvider>(
      builder: (context, coachCleaningProvider, child) {
        final inspectionData =
            coachCleaningProvider.coachCleaningInspectionData;
        final coachColumns = inspectionData.coachColumns;
        final scoringSections = inspectionData.scoringParameters;

        if (coachColumns.isEmpty) {
          return Scaffold(
            appBar: const GradientAppBar(title: 'Coach Score Card'),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'No coaches found for scoring. Please go back to the previous screen and enter the number of coaches.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              ),
            ),
          );
        }

        // Re-initialize tab controller and text controllers if the number of coaches changes
        // This handles scenarios where coaches are added/removed from CoachHeaderFormScreen
        if (_tabController.length != coachColumns.length) {
          _tabController.dispose();
          _tabController = TabController(
            length: coachColumns.length,
            vsync: this,
          );
          _initializeControllers(coachColumns);
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: const GradientAppBar(title: 'Coach Score Card'),
          body: Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: GlobalVariables.appBarGradient,
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white.withOpacity(0.7),
                  indicatorColor: Colors.white,
                  tabs: coachColumns.map((coach) {
                    return Tab(text: coach.coachNo);
                  }).toList(),
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: coachColumns.map((coachData) {
                    final coachIndex = coachColumns.indexOf(coachData);
                    // Use a Form widget with a unique GlobalKey for each tab
                    return Form(
                      key: _formKeys[coachIndex],
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Scores for ${coachData.coachNo}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: GlobalVariables.reddishPurpleColor,
                              ),
                            ),
                            verticalSpace(height: 20),
                            // Map scoring sections to build input fields
                            ...scoringSections.map((section) {
                              final maxScore = section
                                  .maxMarks!; // Max marks should be non-null for scoring sections
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: _buildScoreInputField(
                                  section: section,
                                  maxScore: maxScore,
                                  controller:
                                      _scoreControllers[coachIndex]![section]!,
                                  onChanged: (value) {
                                    // onChanged is optional for direct controller updates.
                                    // Validation is triggered on save.
                                  },
                                  validator: (value) =>
                                      _validateScore(value, maxScore),
                                ),
                              );
                            }).toList(),
                            const SizedBox(height: 16),
                            _buildRemarksInputField(
                              controller: _remarkControllers[coachIndex],
                              onChanged: (value) {
                                // onChanged is optional for direct controller updates.
                              },
                            ),
                            const SizedBox(height: 30),
                            GradientActionButton(
                              label: 'SAVE SCORES',
                              onPressed: () {
                                _saveScores(coachCleaningProvider);
                              },
                            ),
                            verticalSpace(height: 10),
                            GradientActionButton(
                              label: 'GENERATE PDF FOR THIS COACH',
                              onPressed: _generatePdf,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScoreInputField({
    required Section section,
    required int maxScore,
    required TextEditingController controller,
    required Function(String) onChanged,
    String? Function(String?)? validator,
  }) {
    // Use itemCode and displayName from the SectionExtension
    String labelText =
        '${section.itemCode != null ? '${section.itemCode} - ' : ''}${section.displayName}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$labelText (Max: $maxScore)',
          style: const TextStyle(
            color: GlobalVariables.reddishPurpleColor,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        verticalSpace(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: '  Enter score (0-$maxScore)',
            hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
            prefixIcon: Container(
              margin: const EdgeInsets.only(top: 0, left: 6),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: GlobalVariables.appBarGradient,
              ),
              child: const Icon(Icons.score, color: Colors.white, size: 18),
            ),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.grey, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: GlobalVariables.purpleColor,
                width: 2,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 0,
            ),
          ),
          style: const TextStyle(fontSize: 16),
          onChanged: onChanged,
          validator:
              validator, // The validator is correctly passed to TextFormField
        ),
      ],
    );
  }

  Widget _buildRemarksInputField({
    required TextEditingController controller,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Remarks',
          style: TextStyle(
            color: GlobalVariables.reddishPurpleColor,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        verticalSpace(height: 6),
        TextFormField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: '  Enter any remarks for this coach',
            hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: GlobalVariables.purpleColor,
                width: 2,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 12,
            ),
          ),
          style: const TextStyle(fontSize: 16),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
