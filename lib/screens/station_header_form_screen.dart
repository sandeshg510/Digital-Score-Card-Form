// lib/screens/station_header_form_screen.dart

import 'package:digital_score_card_form_for_inspection/screens/station_score_card_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/inspection_provider.dart';

class StationHeaderFormScreen extends StatefulWidget {
  const StationHeaderFormScreen({super.key});

  @override
  State<StationHeaderFormScreen> createState() =>
      _StationHeaderFormScreenState();
}

class _StationHeaderFormScreenState extends State<StationHeaderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _woNoController = TextEditingController();
  final TextEditingController _nameOfWorkController = TextEditingController();
  final TextEditingController _nameOfContractorController =
      TextEditingController();
  final TextEditingController _nameOfSupervisorController =
      TextEditingController();
  final TextEditingController _designationController = TextEditingController();
  final TextEditingController _trainNoController = TextEditingController();
  // Removed _noOfCoachesAttendedController as it will be calculated
  // final TextEditingController _noOfCoachesAttendedController = TextEditingController();
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
    // No longer initializing _noOfCoachesAttendedController
    // _noOfCoachesAttendedController.text = provider.stationInspectionData.noOfCoachesAttended?.toString() ?? '';
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

  // Helper function to update date display text
  void _updateDateDisplay(DateTime? date, Function(String) setText) {
    if (date != null) {
      setText("${date.day}/${date.month}/${date.year}");
    }
  }

  // Helper function to update time display text using context
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
    // No longer disposing _noOfCoachesAttendedController
    // _noOfCoachesAttendedController.dispose();
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
      // Validate that totalNoOfCoaches is entered and is positive
      if (provider.stationInspectionData.totalNoOfCoaches == null ||
          provider.stationInspectionData.totalNoOfCoaches! <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid number of coaches (>0)'),
          ),
        );
        return;
      }
      // All required header fields are valid, navigate to the scoring page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const StationScoreCardScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields to continue.'),
        ),
      );
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
          appBar: AppBar(
            title: const Text(
              'Station Inspection',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            centerTitle: true,
            elevation: 1,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Work Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _woNoController,
                            label: 'W.O. No.',
                            onChanged: inspectionProvider.updateStationWoNo,
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () =>
                                _selectDate(context, inspectionProvider, false),
                            child: AbsorbPointer(
                              child: _buildTextField(
                                controller: TextEditingController(
                                  text: _selectedDateText,
                                ),
                                label: 'Date',
                                suffix: Icons.calendar_today,
                                validator: (_) =>
                                    inspectionProvider
                                            .stationInspectionData
                                            .date ==
                                        null
                                    ? 'Date is required'
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _nameOfWorkController,
                            label: 'Name of Work',
                            onChanged:
                                inspectionProvider.updateStationNameOfWork,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _nameOfContractorController,
                            label: 'Name of Contractor',
                            onChanged: inspectionProvider
                                .updateStationNameOfContractor,
                            validator: (v) => v == null || v.isEmpty
                                ? 'Contractor Name is required'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _nameOfSupervisorController,
                            label: 'Name of Supervisor',
                            onChanged: inspectionProvider
                                .updateStationNameOfSupervisor,
                            validator: (v) => v == null || v.isEmpty
                                ? 'Supervisor Name is required'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _designationController,
                            label: 'Designation',
                            onChanged:
                                inspectionProvider.updateStationDesignation,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Train Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () =>
                                _selectDate(context, inspectionProvider, true),
                            child: AbsorbPointer(
                              child: _buildTextField(
                                controller: TextEditingController(
                                  text: _selectedInspectionDateText,
                                ),
                                label: 'Date of Inspection',
                                suffix: Icons.calendar_today,
                                validator: (_) =>
                                    inspectionProvider
                                            .stationInspectionData
                                            .dateOfInspection ==
                                        null
                                    ? 'Inspection Date is required'
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _trainNoController,
                            label: 'Train No.',
                            onChanged: inspectionProvider.updateStationTrainNo,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _selectTime(
                                    context,
                                    inspectionProvider,
                                    true,
                                  ),
                                  child: AbsorbPointer(
                                    child: _buildTextField(
                                      controller: TextEditingController(
                                        text: _selectedArrivalTimeText,
                                      ),
                                      label: 'Arrival Time',
                                      suffix: Icons.access_time,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _selectTime(
                                    context,
                                    inspectionProvider,
                                    false,
                                  ),
                                  child: AbsorbPointer(
                                    child: _buildTextField(
                                      controller: TextEditingController(
                                        text: _selectedDepTimeText,
                                      ),
                                      label: 'Departure Time',
                                      suffix: Icons.access_time,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _totalNoOfCoachesController,
                            label: 'Total No. of Coaches',
                            keyboardType: TextInputType.number,
                            onChanged: (v) => inspectionProvider
                                .updateStationTotalNoOfCoaches(int.tryParse(v)),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Total coaches is required';
                              }
                              if (int.tryParse(value) == null ||
                                  int.parse(value) <= 0) {
                                return 'Enter a valid number (>0)';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _navigateToCoaches,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Continue'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
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
    required String label,
    IconData? suffix,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        suffixIcon: suffix != null ? Icon(suffix) : null,
      ),
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
    );
  }
}
