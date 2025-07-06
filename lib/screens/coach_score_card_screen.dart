// lib/screens/coach_score_card_screen.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../providers/inspection_provider.dart';

class CoachScoreCardScreen extends StatefulWidget {
  const CoachScoreCardScreen({super.key});

  @override
  State<CoachScoreCardScreen> createState() => _CoachScoreCardScreenState();
}

class _CoachScoreCardScreenState extends State<CoachScoreCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _agreementNoAndDateController =
      TextEditingController();
  final TextEditingController _nameOfContractorController =
      TextEditingController();
  final TextEditingController _nameOfSupervisorController =
      TextEditingController();
  final TextEditingController _trainNoController = TextEditingController();
  final TextEditingController _noOfCoachesAttendedController =
      TextEditingController();

  String _selectedDateOfInspectionText = "Select Date of Inspection";
  String _selectedTimeWorkStartedText = "Select Time";
  String _selectedTimeWorkCompletedText = "Select Time";

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<InspectionProvider>(context, listen: false);
    _agreementNoAndDateController.text =
        provider.coachInspectionData.agreementNoAndDate ?? '';
    _nameOfContractorController.text =
        provider.coachInspectionData.nameOfContractor ?? '';
    _nameOfSupervisorController.text =
        provider.coachInspectionData.nameOfSupervisor ?? '';
    _trainNoController.text = provider.coachInspectionData.trainNo ?? '';
    _noOfCoachesAttendedController.text =
        provider.coachInspectionData.noOfCoachesAttended?.toString() ?? '';

    // Initial display update for dates and times
    _updateDateDisplay(
      provider.coachInspectionData.dateOfInspection,
      (text) => _selectedDateOfInspectionText = text,
    );
    _updateTimeDisplay(
      provider.coachInspectionData.timeWorkStarted,
      (text) => _selectedTimeWorkStartedText = text,
    );
    _updateTimeDisplay(
      provider.coachInspectionData.timeWorkCompleted,
      (text) => _selectedTimeWorkCompletedText = text,
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
      setText(time.format(context)); // **FIX: Pass context here**
    }
  }

  @override
  void dispose() {
    _agreementNoAndDateController.dispose();
    _nameOfContractorController.dispose();
    _nameOfSupervisorController.dispose();
    _trainNoController.dispose();
    _noOfCoachesAttendedController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
    BuildContext context,
    InspectionProvider provider,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          provider.coachInspectionData.dateOfInspection ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null &&
        picked != provider.coachInspectionData.dateOfInspection) {
      provider.updateCoachDateOfInspection(picked);
      setState(() {
        _selectedDateOfInspectionText =
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _selectTime(
    BuildContext context,
    InspectionProvider provider,
    bool isStartedTime,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartedTime
          ? provider.coachInspectionData.timeWorkStarted ?? TimeOfDay.now()
          : provider.coachInspectionData.timeWorkCompleted ?? TimeOfDay.now(),
    );
    if (picked != null) {
      if (isStartedTime) {
        if (picked != provider.coachInspectionData.timeWorkStarted) {
          provider.updateCoachTimeWorkStarted(picked);
          setState(() {
            _selectedTimeWorkStartedText = picked.format(
              context,
            ); // **FIX: Pass context here**
          });
        }
      } else {
        if (picked != provider.coachInspectionData.timeWorkCompleted) {
          provider.updateCoachTimeWorkCompleted(picked);
          setState(() {
            _selectedTimeWorkCompletedText = picked.format(
              context,
            ); // **FIX: Pass context here**
          });
        }
      }
    }
  }

  Future<void> _submitForm() async {
    final provider = Provider.of<InspectionProvider>(context, listen: false);

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields.')),
      );
      return;
    }

    if (!provider.isCoachFormValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please ensure all required header fields and all parameters are scored.',
          ),
        ),
      );
      return;
    }

    try {
      final jsonData = provider.coachInspectionData.toJson();
      final url = Uri.parse(
        'https://httpbin.org/post',
      ); // Use httpbin.org for testing
      // final url = Uri.parse('https://webhook.site/YOUR_UNIQUE_WEBHOOK_URL'); // Replace with your webhook.site URL

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(jsonData),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Coach Form submitted successfully!')),
        );
        print('Coach Submission Successful: ${response.body}');
        provider.resetCoachForm();
        _agreementNoAndDateController.clear();
        _nameOfContractorController.clear();
        _nameOfSupervisorController.clear();
        _trainNoController.clear();
        _noOfCoachesAttendedController.clear();
        setState(() {
          _selectedDateOfInspectionText = "Select Date of Inspection";
          _selectedTimeWorkStartedText = "Select Time";
          _selectedTimeWorkCompletedText = "Select Time";
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Coach Form submission failed: ${response.statusCode}',
            ),
          ),
        );
        print('Coach Submission Failed: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred during Coach Form submission: $e'),
        ),
      );
      print('Error during Coach submission: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InspectionProvider>(
      builder: (context, inspectionProvider, child) {
        // Update display text for dates and times based on provider data
        // These calls now correctly pass the `context` from the builder
        _updateDateDisplay(
          inspectionProvider.coachInspectionData.dateOfInspection,
          (text) => _selectedDateOfInspectionText = text,
        );
        _updateTimeDisplay(
          inspectionProvider.coachInspectionData.timeWorkStarted,
          (text) => _selectedTimeWorkStartedText = text,
        );
        _updateTimeDisplay(
          inspectionProvider.coachInspectionData.timeWorkCompleted,
          (text) => _selectedTimeWorkCompletedText = text,
        );

        return Scaffold(
          appBar: AppBar(title: const Text('Coach Cleaning Score Card')),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header Fields ---
                  TextFormField(
                    controller: _agreementNoAndDateController,
                    decoration: const InputDecoration(
                      labelText: 'Agreement No. & Date',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: inspectionProvider.updateCoachAgreementNoAndDate,
                  ),
                  const SizedBox(height: 16.0),
                  GestureDetector(
                    onTap: () => _selectDate(context, inspectionProvider),
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: TextEditingController(
                          text: _selectedDateOfInspectionText,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Date of Inspection',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        validator: (value) =>
                            inspectionProvider
                                    .coachInspectionData
                                    .dateOfInspection ==
                                null
                            ? 'Date is required'
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _nameOfContractorController,
                    decoration: const InputDecoration(
                      labelText: 'Name of Contractor',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: inspectionProvider.updateCoachNameOfContractor,
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
                    onChanged: inspectionProvider.updateCoachNameOfSupervisor,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Supervisor Name is required'
                        : null,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _trainNoController,
                    decoration: const InputDecoration(
                      labelText: 'Train No.',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: inspectionProvider.updateCoachTrainNo,
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
                                text: _selectedTimeWorkStartedText,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Time Work Started',
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
                                text: _selectedTimeWorkCompletedText,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Time Work Completed',
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
                      labelText: 'No. of Coaches attended',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      inspectionProvider.updateCoachNoOfCoachesAttended(
                        int.tryParse(value) ?? 0,
                      );
                    },
                  ),

                  const SizedBox(height: 24.0),

                  // --- Parameters for Coach Cleaning (no sections, just a list) ---
                  Text(
                    'Platform Return Activities',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  ...inspectionProvider.coachInspectionData.parameters.map((
                    parameter,
                  ) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            parameter.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          DropdownButtonFormField<int>(
                            value: parameter.score,
                            decoration: const InputDecoration(
                              labelText: 'Score (0-3)',
                              border: OutlineInputBorder(),
                            ),
                            items:
                                List.generate(
                                      4,
                                      (index) => index,
                                    ) // Scores 0, 1, 2, 3
                                    .map(
                                      (score) => DropdownMenuItem<int>(
                                        value: score,
                                        child: Text('$score'),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (int? newValue) {
                              inspectionProvider.updateCoachParameterScore(
                                parameter.name,
                                newValue,
                              );
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Score is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8.0),
                          TextFormField(
                            initialValue: parameter.remarks,
                            decoration: const InputDecoration(
                              labelText: 'Remarks (Optional)',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 2,
                            onChanged: (value) {
                              inspectionProvider.updateCoachParameterRemarks(
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

                  Center(
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      child: const Text('Submit Coach Inspection'),
                    ),
                  ),
                  const SizedBox(height: 20.0), // Space after button
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
