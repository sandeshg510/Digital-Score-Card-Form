import 'package:digital_score_card_form_for_inspection/constants/global_variables.dart';
import 'package:digital_score_card_form_for_inspection/core/common/widgets/basics.dart';
import 'package:digital_score_card_form_for_inspection/core/common/widgets/gradient_button.dart';
import 'package:digital_score_card_form_for_inspection/screens/station_score_card_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/common/widgets/gradient_app_bar.dart';
import '../providers/inspection_provider.dart';

class StationHeaderFormScreen extends StatefulWidget {
  const StationHeaderFormScreen({super.key});

  @override
  State<StationHeaderFormScreen> createState() =>
      _StationHeaderFormScreenState();
}

class _StationHeaderFormScreenState extends State<StationHeaderFormScreen>
    with CommonWidgets {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _woNoController = TextEditingController();
  final TextEditingController _nameOfWorkController = TextEditingController();
  final TextEditingController _nameOfContractorController =
      TextEditingController();
  final TextEditingController _nameOfSupervisorController =
      TextEditingController();
  final TextEditingController _designationController = TextEditingController();
  final TextEditingController _trainNoController = TextEditingController();
  final TextEditingController _totalNoOfCoachesController =
      TextEditingController();

  String _selectedDateText = "Select Date";
  String _selectedInspectionDateText = "Select Date of Inspection";
  String _selectedArrivalTimeText = "Select Time";
  String _selectedDepTimeText = "Select Time";

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<InspectionProvider>(context, listen: false);
    _woNoController.text = provider.stationInspectionData.woNo ?? '';
    _nameOfWorkController.text =
        provider.stationInspectionData.nameOfWork ?? '';
    _nameOfContractorController.text =
        provider.stationInspectionData.nameOfContractor ?? '';
    _nameOfSupervisorController.text =
        provider.stationInspectionData.nameOfSupervisor ?? '';
    _designationController.text =
        provider.stationInspectionData.designation ?? '';
    _trainNoController.text = provider.stationInspectionData.trainNo ?? '';
    _totalNoOfCoachesController.text =
        provider.stationInspectionData.totalNoOfCoaches?.toString() ?? '';

    _updateDateDisplay(
      provider.stationInspectionData.date,
      (text) => _selectedDateText = text,
    );
    _updateDateDisplay(
      provider.stationInspectionData.dateOfInspection,
      (text) => _selectedInspectionDateText = text,
    );
    _updateTimeDisplay(
      provider.stationInspectionData.arrivalTime,
      (text) => _selectedArrivalTimeText = text,
    );
    _updateTimeDisplay(
      provider.stationInspectionData.depTime,
      (text) => _selectedDepTimeText = text,
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
    _woNoController.dispose();
    _nameOfWorkController.dispose();
    _nameOfContractorController.dispose();
    _nameOfSupervisorController.dispose();
    _designationController.dispose();
    _trainNoController.dispose();
    _totalNoOfCoachesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
    BuildContext context,
    InspectionProvider provider,
    bool isInspectionDate,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isInspectionDate
          ? provider.stationInspectionData.dateOfInspection ?? DateTime.now()
          : provider.stationInspectionData.date ?? DateTime.now(),
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
      if (isInspectionDate) {
        if (picked != provider.stationInspectionData.dateOfInspection) {
          provider.updateStationDateOfInspection(picked);
          setState(() {
            _selectedInspectionDateText =
                "${picked.day}/${picked.month}/${picked.year}";
          });
        }
      } else {
        if (picked != provider.stationInspectionData.date) {
          provider.updateStationDate(picked);
          setState(() {
            _selectedDateText = "${picked.day}/${picked.month}/${picked.year}";
          });
        }
      }
    }
  }

  Future<void> _selectTime(
    BuildContext context,
    InspectionProvider provider,
    bool isArrivalTime,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isArrivalTime
          ? provider.stationInspectionData.arrivalTime ?? TimeOfDay.now()
          : provider.stationInspectionData.depTime ?? TimeOfDay.now(),
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
      if (isArrivalTime) {
        if (picked != provider.stationInspectionData.arrivalTime) {
          provider.updateStationArrivalTime(picked);
          setState(() {
            _selectedArrivalTimeText = picked.format(context);
          });
        }
      } else {
        if (picked != provider.stationInspectionData.depTime) {
          provider.updateStationDepTime(picked);
          setState(() {
            _selectedDepTimeText = picked.format(context);
          });
        }
      }
    }
  }

  void _navigateToCoaches() {
    final provider = Provider.of<InspectionProvider>(context, listen: false);
    if (_formKey.currentState!.validate()) {
      if (provider.stationInspectionData.totalNoOfCoaches == null ||
          provider.stationInspectionData.totalNoOfCoaches! <= 0) {
        showSnackBar(context, 'Please enter a valid number of coaches (>0)');
        return;
      }
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const StationScoreCardScreen()),
      );
    } else {
      showSnackBar(context, 'Please fill all required fields to continue.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InspectionProvider>(
      builder: (context, inspectionProvider, child) {
        _updateDateDisplay(
          inspectionProvider.stationInspectionData.date,
          (text) => _selectedDateText = text,
        );
        _updateDateDisplay(
          inspectionProvider.stationInspectionData.dateOfInspection,
          (text) => _selectedInspectionDateText = text,
        );
        _updateTimeDisplay(
          inspectionProvider.stationInspectionData.arrivalTime,
          (text) => _selectedArrivalTimeText = text,
        );
        _updateTimeDisplay(
          inspectionProvider.stationInspectionData.depTime,
          (text) => _selectedDepTimeText = text,
        );

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: GradientAppBar(title: 'Station Inspection Details'),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  verticalSpace(height: 20),
                  _buildTextField(
                    controller: _woNoController,
                    labelText: 'W.O. No.',
                    icon: Icons.description,
                    onChanged: inspectionProvider.updateStationWoNo,
                  ),
                  verticalSpace(height: 25),
                  _buildDateSelectionField(
                    context: context,
                    onTap: () =>
                        _selectDate(context, inspectionProvider, false),
                    selectedText: _selectedDateText,
                    labelText: 'Date',
                    icon: Icons.calendar_month,
                    validator: (value) =>
                        inspectionProvider.stationInspectionData.date == null
                        ? 'Date is required'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _nameOfWorkController,
                    labelText: 'Name of Work',
                    icon: Icons.work,
                    onChanged: inspectionProvider.updateStationNameOfWork,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _nameOfContractorController,
                    labelText: 'Name of Contractor*',
                    icon: Icons.business,
                    onChanged: inspectionProvider.updateStationNameOfContractor,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Contractor Name is required'
                        : null,
                    isMandatory: true,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _nameOfSupervisorController,
                    labelText: 'Name of Supervisor*',
                    icon: Icons.supervisor_account,
                    onChanged: inspectionProvider.updateStationNameOfSupervisor,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Supervisor Name is required'
                        : null,
                    isMandatory: true,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _designationController,
                    labelText: 'Designation',
                    icon: Icons.badge,
                    onChanged: inspectionProvider.updateStationDesignation,
                  ),
                  const SizedBox(height: 16),
                  _buildDateSelectionField(
                    context: context,
                    onTap: () => _selectDate(context, inspectionProvider, true),
                    selectedText: _selectedInspectionDateText,
                    labelText: 'Date of Inspection*',
                    icon: Icons.calendar_month,
                    validator: (value) =>
                        inspectionProvider
                                .stationInspectionData
                                .dateOfInspection ==
                            null
                        ? 'Inspection Date is required'
                        : null,
                    isMandatory: true,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _trainNoController,
                    labelText: 'Train No.',
                    icon: Icons.train,
                    onChanged: inspectionProvider.updateStationTrainNo,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimeSelectionField(
                          context: context,
                          onTap: () =>
                              _selectTime(context, inspectionProvider, true),
                          selectedText: _selectedArrivalTimeText,
                          labelText: 'Arrival Time',
                          icon: Icons.access_time,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTimeSelectionField(
                          context: context,
                          onTap: () =>
                              _selectTime(context, inspectionProvider, false),
                          selectedText: _selectedDepTimeText,
                          labelText: 'Dep. Time',
                          icon: Icons.access_time,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _totalNoOfCoachesController,
                    labelText: 'Total Coaches in Train*',
                    icon: Icons.directions_railway,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      inspectionProvider.updateStationTotalNoOfCoaches(
                        int.tryParse(value),
                      );
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Total coaches is required';
                      }
                      if (int.tryParse(value) == null ||
                          int.parse(value) <= 0) {
                        return 'Please enter a valid number (>0)';
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
                ? Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 12),
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
                    ? Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 12),
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
