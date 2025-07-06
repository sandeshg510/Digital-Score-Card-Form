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
  final TextEditingController _noOfCoachesAttendedController =
      TextEditingController();
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
    _noOfCoachesAttendedController.text =
        provider.stationInspectionData.noOfCoachesAttended?.toString() ?? '';
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
    _noOfCoachesAttendedController.dispose();
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
          appBar: AppBar(title: const Text('Station Inspection Details')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _woNoController,
                    decoration: const InputDecoration(
                      labelText: 'W.O. No.',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: inspectionProvider.updateStationWoNo,
                  ),
                  const SizedBox(height: 16.0),
                  GestureDetector(
                    onTap: () =>
                        _selectDate(context, inspectionProvider, false),
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: TextEditingController(
                          text: _selectedDateText,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        validator: (value) =>
                            inspectionProvider.stationInspectionData.date ==
                                null
                            ? 'Date is required'
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _nameOfWorkController,
                    decoration: const InputDecoration(
                      labelText: 'Name of Work',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: inspectionProvider.updateStationNameOfWork,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _nameOfContractorController,
                    decoration: const InputDecoration(
                      labelText: 'Name of Contractor',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: inspectionProvider.updateStationNameOfContractor,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Contractor Name is required'
                        : null,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _nameOfSupervisorController,
                    decoration: const InputDecoration(
                      labelText: 'Name of Supervisor',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: inspectionProvider.updateStationNameOfSupervisor,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Supervisor Name is required'
                        : null,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _designationController,
                    decoration: const InputDecoration(
                      labelText: 'Designation',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: inspectionProvider.updateStationDesignation,
                  ),
                  const SizedBox(height: 16.0),
                  GestureDetector(
                    onTap: () => _selectDate(context, inspectionProvider, true),
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: TextEditingController(
                          text: _selectedInspectionDateText,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Date of Inspection',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        validator: (value) =>
                            inspectionProvider
                                    .stationInspectionData
                                    .dateOfInspection ==
                                null
                            ? 'Inspection Date is required'
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _trainNoController,
                    decoration: const InputDecoration(
                      labelText: 'Train No.',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: inspectionProvider.updateStationTrainNo,
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              _selectTime(context, inspectionProvider, true),
                          child: AbsorbPointer(
                            child: TextFormField(
                              controller: TextEditingController(
                                text: _selectedArrivalTimeText,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Arrival Time',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.access_time),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              _selectTime(context, inspectionProvider, false),
                          child: AbsorbPointer(
                            child: TextFormField(
                              controller: TextEditingController(
                                text: _selectedDepTimeText,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Dep. Time',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.access_time),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _noOfCoachesAttendedController,
                    decoration: const InputDecoration(
                      labelText: 'No. of Coaches attended by contractor',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      inspectionProvider.updateStationNoOfCoachesAttended(
                        int.tryParse(value) ?? 0,
                      );
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _totalNoOfCoachesController,
                    decoration: const InputDecoration(
                      labelText: 'Total No. of Coaches in the train',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      inspectionProvider.updateStationTotalNoOfCoaches(
                        int.tryParse(value) ?? 0,
                      );
                    },
                  ),
                  const SizedBox(height: 24.0),
                  ElevatedButton(
                    onPressed: _navigateToCoaches,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    child: const Text('Continue to Coach Scoring'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
