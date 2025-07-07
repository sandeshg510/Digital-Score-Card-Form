import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../constants/global_variables.dart';
import '../core/common/widgets/basics.dart';
import '../core/common/widgets/gradient_app_bar.dart';
import '../core/common/widgets/gradient_button.dart';
import '../models/coach_inspection_data.dart';
import '../providers/coach_cleaning_provider.dart';
import '../services/coach_cleaning_pdf_service.dart';

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

  final PdfServices _pdfService = PdfServices();

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<CoachCleaningProvider>(context, listen: false);
    final coachColumns = provider.coachCleaningInspectionData.coachColumns;

    _tabController = TabController(length: coachColumns.length, vsync: this);

    _initializeControllers(coachColumns);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {}
    });
  }

  void _initializeControllers(List<CoachColumnData> coachColumns) {
    _remarkControllers.clear();
    _scoreControllers.clear();
    _formKeys.clear();

    final List<Section> scoringSections = Section.values
        .where((s) => s.maxMarks != null)
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

    if (_formKeys.length <= currentCoachIndex ||
        _formKeys[currentCoachIndex].currentState == null) {
      showSnackBar(
        context,
        'Error: Form not ready for validation. Please restart the app.',
      );
      return;
    }

    final currentFormKey = _formKeys[currentCoachIndex];

    if (!currentFormKey.currentState!.validate()) {
      showSnackBar(context, 'Please correct invalid scores before saving.');
      return;
    }

    final currentCoachData =
        provider.coachCleaningInspectionData.coachColumns[currentCoachIndex];

    currentCoachData.remarks = _remarkControllers[currentCoachIndex].text
        .trim();

    provider.coachCleaningInspectionData.scoringParameters.forEach((section) {
      final controller = _scoreControllers[currentCoachIndex]![section];
      final enteredValue = int.tryParse(controller?.text ?? '');
      currentCoachData.scores[section] = enteredValue;
    });

    currentCoachData.totalScoreObtained = currentCoachData
        .calculateTotalScoreObtained();

    provider.updateCoachColumnData(currentCoachIndex, currentCoachData);

    showSnackBar(context, 'Scores and remarks saved for current coach.');
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
      showSnackBar(context, 'No coach data to generate PDF.');
      return;
    }

    final currentCoachData =
        provider.coachCleaningInspectionData.coachColumns[_tabController.index];

    showSnackBar(context, 'Generating PDF...');

    try {
      final pdfBytes = await _pdfService.generateCoachCleaningPdf(
        inspectionData: provider.coachCleaningInspectionData,
        coachColumnData: currentCoachData,
      );

      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: 'coach_score_card_${currentCoachData.coachNo}.pdf',
      );

      showSnackBar(context, 'PDF generated and opened successfully!');
    } catch (e) {
      showSnackBar(context, 'Failed to generate PDF: $e');
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
                                color: GlobalVariables.purpleColor,
                              ),
                            ),
                            verticalSpace(height: 20),

                            ...scoringSections.map((section) {
                              final maxScore = section.maxMarks!;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: _buildScoreInputField(
                                  section: section,
                                  maxScore: maxScore,
                                  controller:
                                      _scoreControllers[coachIndex]![section]!,
                                  onChanged: (value) {},
                                  validator: (value) =>
                                      _validateScore(value, maxScore),
                                ),
                              );
                            }),
                            const SizedBox(height: 16),
                            _buildRemarksInputField(
                              controller: _remarkControllers[coachIndex],
                              onChanged: (value) {},
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
    String labelText =
        '${section.itemCode != null ? '${section.itemCode} - ' : ''}${section.displayName}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$labelText (Max: $maxScore)',
          style: const TextStyle(
            color: GlobalVariables.purpleColor,
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
                color: GlobalVariables.deepPurpleColor,
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
          validator: validator,
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
            color: GlobalVariables.purpleColor,
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
                color: GlobalVariables.deepPurpleColor,
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
