// lib/models/coach_inspection_data.dart

import 'package:flutter/material.dart'; // For TimeOfDay

class CoachParameter {
  final String name;
  int?
  score; // Nullable: 0-3 (Very Good-3, Satisfactory-2, Poor-1, Not attended-0)
  String?
  remarks; // Optional remarks (not explicitly in PDF, but assignment implies)

  CoachParameter({required this.name, this.score, this.remarks});

  CoachParameter copyWith({int? score, String? remarks}) {
    return CoachParameter(
      name: this.name,
      score: score ?? this.score,
      remarks: remarks ?? this.remarks,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'score': score, 'remarks': remarks};
  }
}

class CoachInspectionData {
  String? agreementNoAndDate;
  DateTime? dateOfInspection;
  String? nameOfContractor;
  String? nameOfSupervisor;
  String? trainNo;
  TimeOfDay? timeWorkStarted;
  TimeOfDay? timeWorkCompleted;
  int? noOfCoachesAttended;
  List<CoachParameter> parameters;

  CoachInspectionData({
    this.agreementNoAndDate,
    this.dateOfInspection,
    this.nameOfContractor,
    this.nameOfSupervisor,
    this.trainNo,
    this.timeWorkStarted,
    this.timeWorkCompleted,
    this.noOfCoachesAttended,
    required this.parameters,
  });

  factory CoachInspectionData.initial() {
    return CoachInspectionData(
      parameters: [
        CoachParameter(
          name:
              'Cleaning & wiping of toilet area And fittings including washbasin, mirror & shelves etc.',
        ),
        CoachParameter(
          name: 'Cleaning & wiping of fittings in AC coaches etc.',
        ),
        CoachParameter(
          name:
              'Interior Cleaning of vestibules, doorways, gangways, vestibules etc.',
        ),
        CoachParameter(
          name:
              'Cleaning & wiping if required of window glasses, mirror & Amenity fittings.',
        ),
        CoachParameter(
          name:
              'Floor including area under the seats/berths etc & wiping of floor.',
        ),
        CoachParameter(name: 'Disposal of garbage'),
      ],
    );
  }

  CoachInspectionData copyWith({
    String? agreementNoAndDate,
    DateTime? dateOfInspection,
    String? nameOfContractor,
    String? nameOfSupervisor,
    String? trainNo,
    TimeOfDay? timeWorkStarted,
    TimeOfDay? timeWorkCompleted,
    int? noOfCoachesAttended,
    List<CoachParameter>? parameters,
  }) {
    return CoachInspectionData(
      agreementNoAndDate: agreementNoAndDate ?? this.agreementNoAndDate,
      dateOfInspection: dateOfInspection ?? this.dateOfInspection,
      nameOfContractor: nameOfContractor ?? this.nameOfContractor,
      nameOfSupervisor: nameOfSupervisor ?? this.nameOfSupervisor,
      trainNo: trainNo ?? this.trainNo,
      timeWorkStarted: timeWorkStarted ?? this.timeWorkStarted,
      timeWorkCompleted: timeWorkCompleted ?? this.timeWorkCompleted,
      noOfCoachesAttended: noOfCoachesAttended ?? this.noOfCoachesAttended,
      parameters:
          parameters ?? this.parameters.map((p) => p.copyWith()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'agreementNoAndDate': agreementNoAndDate,
      'dateOfInspection': dateOfInspection?.toIso8601String(),
      'nameOfContractor': nameOfContractor,
      'nameOfSupervisor': nameOfSupervisor,
      'trainNo': trainNo,
      // Convert TimeOfDay to a simple string representation for JSON
      'timeWorkStarted': timeWorkStarted != null
          ? '${timeWorkStarted!.hour}:${timeWorkStarted!.minute}'
          : null,
      'timeWorkCompleted': timeWorkCompleted != null
          ? '${timeWorkCompleted!.hour}:${timeWorkCompleted!.minute}'
          : null,
      'noOfCoachesAttended': noOfCoachesAttended,
      'parameters': parameters.map((p) => p.toJson()).toList(),
    };
  }
}
