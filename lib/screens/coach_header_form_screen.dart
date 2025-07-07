import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/global_variables.dart';
import '../core/common/widgets/basics.dart';
import '../core/common/widgets/gradient_app_bar.dart';
import '../core/common/widgets/gradient_button.dart';
import '../providers/coach_cleaning_provider.dart';
import 'coach_score_card_screen.dart';

class CoachHeaderFormScreen extends StatefulWidget {
  const CoachHeaderFormScreen({super.key});

  @override
  State<CoachHeaderFormScreen> createState() => _CoachHeaderFormScreenState();
}

class _CoachHeaderFormScreenState extends State<CoachHeaderFormScreen>
    with CommonWidgets {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _agreementNoController = TextEditingController();
  final TextEditingController _nameOfContractorController =
      TextEditingController();
  final TextEditingController _nameOfSupervisorController =
      TextEditingController();
  final TextEditingController _trainNoController = TextEditingController();
  final TextEditingController _coachNoInRakeController =
      TextEditingController();
  final TextEditingController _totalCoachesForScoringController =
      TextEditingController();

  String _selectedAgreementDateText = "Select Date";
  String _selectedInspectionDateText = "Select Date of Inspection";
  String _selectedTimeWorkStartedText = "Select Time";
  String _selectedTimeWorkCompletedText = "Select Time";

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<CoachCleaningProvider>(context, listen: false);
    final data = provider.coachCleaningInspectionData;

    _agreementNoController.text = data.agreementNo ?? '';
    _nameOfContractorController.text = data.nameOfContractor ?? '';
    _nameOfSupervisorController.text = data.nameOfSupervisor ?? '';
    _trainNoController.text = data.trainNo ?? '';
    _coachNoInRakeController.text = data.coachNoInRake?.toString() ?? '';
    _totalCoachesForScoringController.text = data.coachColumns.isNotEmpty
        ? data.coachColumns.length.toString()
        : '';

    _updateDateDisplay(
      data.agreementDate,
      (text) => _selectedAgreementDateText = text,
    );
    _updateDateDisplay(
      data.dateOfInspection,
      (text) => _selectedInspectionDateText = text,
    );
    _updateTimeDisplay(
      data.timeWorkStarted,
      (text) => _selectedTimeWorkStartedText = text,
    );
    _updateTimeDisplay(
      data.timeWorkCompleted,
      (text) => _selectedTimeWorkCompletedText = text,
    );
  }

  void _updateDateDisplay(DateTime? date, Function(String) setText) {
    if (date != null) {
      setText("${date.day}/${date.month}/${date.year}");
    }
  }

  void _updateTimeDisplay(TimeOfDay? time, Function(String) setText) {
    if (time != null) {
      setText(time.format(context));
    }
  }

  @override
  void dispose() {
    _agreementNoController.dispose();
    _nameOfContractorController.dispose();
    _nameOfSupervisorController.dispose();
    _trainNoController.dispose();
    _coachNoInRakeController.dispose();
    _totalCoachesForScoringController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
    BuildContext context,
    CoachCleaningProvider provider,
    bool isAgreementDate,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isAgreementDate
          ? provider.coachCleaningInspectionData.agreementDate ?? DateTime.now()
          : provider.coachCleaningInspectionData.dateOfInspection ??
                DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: GlobalVariables.purpleColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: GlobalVariables.deepPurpleColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      if (isAgreementDate) {
        if (picked != provider.coachCleaningInspectionData.agreementDate) {
          provider.updateCoachCleaningAgreementDate(picked);
          setState(() {
            _selectedAgreementDateText =
                "${picked.day}/${picked.month}/${picked.year}";
          });
        }
      } else {
        if (picked != provider.coachCleaningInspectionData.dateOfInspection) {
          provider.updateCoachCleaningDateOfInspection(picked);
          setState(() {
            _selectedInspectionDateText =
                "${picked.day}/${picked.month}/${picked.year}";
          });
        }
      }
    }
  }

  Future<void> _selectTime(
    BuildContext context,
    CoachCleaningProvider provider,
    bool isWorkStartedTime,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isWorkStartedTime
          ? provider.coachCleaningInspectionData.timeWorkStarted ??
                TimeOfDay.now()
          : provider.coachCleaningInspectionData.timeWorkCompleted ??
                TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: GlobalVariables.purpleColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: GlobalVariables.deepPurpleColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      if (isWorkStartedTime) {
        if (picked != provider.coachCleaningInspectionData.timeWorkStarted) {
          provider.updateCoachCleaningTimeWorkStarted(picked);
          setState(() {
            _selectedTimeWorkStartedText = picked.format(context);
          });
        }
      } else {
        if (picked != provider.coachCleaningInspectionData.timeWorkCompleted) {
          provider.updateCoachCleaningTimeWorkCompleted(picked);
          setState(() {
            _selectedTimeWorkCompletedText = picked.format(context);
          });
        }
      }
    }
  }

  void _navigateToCoaches() {
    final provider = Provider.of<CoachCleaningProvider>(context, listen: false);
    if (_formKey.currentState!.validate()) {
      if (provider.coachCleaningInspectionData.coachColumns.isEmpty) {
        showSnackBar(
          context,
          'Please enter a valid number of coaches to score (>0) to generate coach columns.',
        );

        return;
      }
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CoachScoreCardScreen()),
      );
    } else {
      showSnackBar(context, 'Please fill all required fields to continue.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CoachCleaningProvider>(
      builder: (context, coachCleaningProvider, child) {
        final data = coachCleaningProvider.coachCleaningInspectionData;

        _updateDateDisplay(
          data.agreementDate,
          (text) => _selectedAgreementDateText = text,
        );
        _updateDateDisplay(
          data.dateOfInspection,
          (text) => _selectedInspectionDateText = text,
        );
        _updateTimeDisplay(
          data.timeWorkStarted,
          (text) => _selectedTimeWorkStartedText = text,
        );
        _updateTimeDisplay(
          data.timeWorkCompleted,
          (text) => _selectedTimeWorkCompletedText = text,
        );
        _totalCoachesForScoringController.text = data.coachColumns.isNotEmpty
            ? data.coachColumns.length.toString()
            : _totalCoachesForScoringController.text;

        _agreementNoController.text = data.agreementNo ?? '';
        _nameOfContractorController.text = data.nameOfContractor ?? '';
        _nameOfSupervisorController.text = data.nameOfSupervisor ?? '';
        _trainNoController.text = data.trainNo ?? '';
        _coachNoInRakeController.text = data.coachNoInRake?.toString() ?? '';

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: GradientAppBar(title: 'Coach Cleaning Inspection Details'),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  verticalSpace(height: 20),
                  _buildTextField(
                    controller: _agreementNoController,
                    labelText: 'Agreement No.',
                    icon: Icons.article,
                    onChanged:
                        coachCleaningProvider.updateCoachCleaningAgreementNo,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Agreement No. is required'
                        : null,
                    isMandatory: true,
                  ),
                  verticalSpace(height: 25),
                  _buildDateSelectionField(
                    context: context,
                    onTap: () =>
                        _selectDate(context, coachCleaningProvider, true),
                    selectedText: _selectedAgreementDateText,
                    labelText: 'Agreement Date',
                    icon: Icons.calendar_month,
                    validator: (value) =>
                        coachCleaningProvider
                                .coachCleaningInspectionData
                                .agreementDate ==
                            null
                        ? 'Agreement Date is required'
                        : null,
                    isMandatory: true,
                  ),
                  const SizedBox(height: 16),
                  _buildDateSelectionField(
                    context: context,
                    onTap: () =>
                        _selectDate(context, coachCleaningProvider, false),
                    selectedText: _selectedInspectionDateText,
                    labelText: 'Date of Inspection*',
                    icon: Icons.calendar_month,
                    validator: (value) =>
                        coachCleaningProvider
                                .coachCleaningInspectionData
                                .dateOfInspection ==
                            null
                        ? 'Inspection Date is required'
                        : null,
                    isMandatory: true,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _nameOfSupervisorController,
                    labelText: 'Name of Supervisor*',
                    icon: Icons.supervisor_account,
                    onChanged: coachCleaningProvider
                        .updateCoachCleaningNameOfSupervisor,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Supervisor Name is required'
                        : null,
                    isMandatory: true,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _nameOfContractorController,
                    labelText: 'Name of Contractor',
                    icon: Icons.business,
                    onChanged: coachCleaningProvider
                        .updateCoachCleaningNameOfContractor,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _trainNoController,
                    labelText: 'Train No.',
                    icon: Icons.train,
                    onChanged: coachCleaningProvider.updateCoachCleaningTrainNo,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Train No. is required'
                        : null,
                    isMandatory: true,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimeSelectionField(
                          context: context,
                          onTap: () =>
                              _selectTime(context, coachCleaningProvider, true),
                          selectedText: _selectedTimeWorkStartedText,
                          labelText: 'Time Work Started',
                          icon: Icons.access_time,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTimeSelectionField(
                          context: context,
                          onTap: () => _selectTime(
                            context,
                            coachCleaningProvider,
                            false,
                          ),
                          selectedText: _selectedTimeWorkCompletedText,
                          labelText: 'Time Work Completed',
                          icon: Icons.access_time,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _coachNoInRakeController,
                    labelText: 'Coach No. in the Rake',
                    icon: Icons.confirmation_number,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      coachCleaningProvider.updateCoachCleaningCoachNoInRake(
                        int.tryParse(value),
                      );
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Coach No. in Rake is required';
                      }
                      if (int.tryParse(value) == null ||
                          int.parse(value) <= 0) {
                        return 'Please enter a valid number (>0)';
                      }
                      return null;
                    },
                    isMandatory: true,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _totalCoachesForScoringController,
                    labelText: 'Number of Coaches to Score*',
                    icon: Icons.numbers,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      int? count = int.tryParse(value);
                      if (count != null && count > 0) {
                        coachCleaningProvider.generateCoachCleaningCoachColumns(
                          count,
                        );
                      } else {
                        coachCleaningProvider.generateCoachCleaningCoachColumns(
                          0,
                        );
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      if (int.tryParse(value) == null ||
                          int.parse(value) <= 0) {
                        return 'Enter >0 coaches';
                      }
                      return null;
                    },
                    isMandatory: true,
                  ),
                  const SizedBox(height: 30),
                  _buildNextButton(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    Function(String)? onChanged,
    String? Function(String?)? validator,
    bool isMandatory = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            color: GlobalVariables.purpleColor,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        verticalSpace(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: '  Enter $labelText',
            hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
            prefixIcon: Container(
              margin: const EdgeInsets.only(top: 0, left: 6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: GlobalVariables.appBarGradient,
              ),
              child: Icon(icon, color: Colors.white, size: 18),
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
            suffixIcon: isMandatory
                ? const Padding(
                    padding: EdgeInsets.only(left: 8.0, top: 12),
                    child: Text(
                      '*',
                      style: TextStyle(color: Colors.red, fontSize: 20),
                    ),
                  )
                : null,
          ),
          style: const TextStyle(fontSize: 16),
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDateSelectionField({
    required BuildContext context,
    required VoidCallback onTap,
    required String selectedText,
    required String labelText,
    required IconData icon,
    String? Function(String?)? validator,
    bool isMandatory = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelText,
            style: const TextStyle(
              color: GlobalVariables.purpleColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          verticalSpace(height: 6),
          AbsorbPointer(
            child: TextFormField(
              controller: TextEditingController(text: selectedText),
              decoration: InputDecoration(
                labelStyle: TextStyle(color: Colors.grey[700]),
                prefixIcon: Icon(icon, color: GlobalVariables.purpleColor),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.grey, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(
                    color: Color(0xFF852093),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                suffixIcon: isMandatory
                    ? const Padding(
                        padding: EdgeInsets.only(left: 8.0, top: 12),
                        child: Text(
                          '*',
                          style: TextStyle(color: Colors.red, fontSize: 20),
                        ),
                      )
                    : null,
              ),
              style: const TextStyle(fontSize: 14),
              validator: validator,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelectionField({
    required BuildContext context,
    required VoidCallback onTap,
    required String selectedText,
    required String labelText,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelText,
            style: const TextStyle(
              color: GlobalVariables.purpleColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          verticalSpace(height: 6),
          AbsorbPointer(
            child: TextFormField(
              controller: TextEditingController(text: selectedText),
              decoration: InputDecoration(
                labelStyle: TextStyle(color: Colors.grey[700]),
                prefixIcon: Icon(icon, color: GlobalVariables.purpleColor),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
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
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return GradientActionButton(label: 'NEXT', onPressed: _navigateToCoaches);
  }
}
