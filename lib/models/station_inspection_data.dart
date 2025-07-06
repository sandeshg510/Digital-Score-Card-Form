// lib/models/station_inspection_data.dart

import 'package:flutter/material.dart';

// Helper for default coach columns
const List<String> defaultCoachColumns = [
  'C1',
  'C2',
  'C3',
  'C4',
  'C5',
  'C6',
  'C7',
  'C8',
  'C9',
  'C10',
  'C11',
  'C12',
  'C13',
];

class StationInspectionData {
  final String? woNo;
  final DateTime? date;
  final String? nameOfWork;
  final String? nameOfContractor;
  final String? nameOfSupervisor;
  final String? designation;
  final DateTime? dateOfInspection;
  final String? trainNo;
  final TimeOfDay? arrivalTime;
  final TimeOfDay? depTime;
  final int? noOfCoachesAttended;
  final int? totalNoOfCoaches;
  final List<StationSection> sections;
  final List<String> coachColumns; // List of coach IDs (e.g., C1, C2, ...)

  StationInspectionData({
    this.woNo,
    this.date,
    this.nameOfWork,
    this.nameOfContractor,
    this.nameOfSupervisor,
    this.designation,
    this.dateOfInspection,
    this.trainNo,
    this.arrivalTime,
    this.depTime,
    this.noOfCoachesAttended,
    this.totalNoOfCoaches,
    required this.sections,
    required this.coachColumns,
  });

  factory StationInspectionData.initial() {
    return StationInspectionData(
      woNo: null,
      date: null,
      nameOfWork: null,
      nameOfContractor: null,
      nameOfSupervisor: null,
      designation: null,
      dateOfInspection: null,
      trainNo: null,
      arrivalTime: null,
      depTime: null,
      noOfCoachesAttended: null,
      totalNoOfCoaches: null,
      coachColumns: defaultCoachColumns, // Initialize with default coaches
      sections: [
        StationSection(
          name:
              '', // Empty name for the main section to avoid extra heading in UI
          parameters: [
            StationParameter(
              name:
                  'Toilet cleaning complete including pan with High Pressure Jet machine, cleaning wiping of wash basin, mirror & shelves, , Spraying of Air Freshener & Mosquito Repellent',
              subParameters: [
                StationSubParameter(
                  id: 'T1',
                  name: 'Toilet 1',
                  coachIds: defaultCoachColumns,
                  scores: {
                    for (var coachId in defaultCoachColumns) coachId: null,
                  },
                ),
                StationSubParameter(
                  id: 'T2',
                  name: 'Toilet 2',
                  coachIds: defaultCoachColumns,
                  scores: {
                    for (var coachId in defaultCoachColumns) coachId: null,
                  },
                ),
                StationSubParameter(
                  id: 'T3',
                  name: 'Toilet 3',
                  coachIds: defaultCoachColumns,
                  scores: {
                    for (var coachId in defaultCoachColumns) coachId: null,
                  },
                ),
                StationSubParameter(
                  id: 'T4',
                  name: 'Toilet 4',
                  coachIds: defaultCoachColumns,
                  scores: {
                    for (var coachId in defaultCoachColumns) coachId: null,
                  },
                ),
              ],
              remarks: null,
            ),
            StationParameter(
              name:
                  'Cleaning & wiping of outside washbasin, mirror & shelves in door way area',
              subParameters: [
                StationSubParameter(
                  id: 'B1',
                  name: 'Basin 1',
                  coachIds: defaultCoachColumns,
                  scores: {
                    for (var coachId in defaultCoachColumns) coachId: null,
                  },
                ),
                StationSubParameter(
                  id: 'B2',
                  name: 'Basin 2',
                  coachIds: defaultCoachColumns,
                  scores: {
                    for (var coachId in defaultCoachColumns) coachId: null,
                  },
                ),
              ],
              remarks: null,
            ),
            StationParameter(
              name:
                  'Vestibule area, Doorway area, area between two toilets and footsteps.',
              subParameters: [
                StationSubParameter(
                  id: 'D1',
                  name: 'Doorway Area 1',
                  coachIds: defaultCoachColumns,
                  scores: {
                    for (var coachId in defaultCoachColumns) coachId: null,
                  },
                ),
                StationSubParameter(
                  id: 'D2',
                  name: 'Doorway Area 2',
                  coachIds: defaultCoachColumns,
                  scores: {
                    for (var coachId in defaultCoachColumns) coachId: null,
                  },
                ),
              ],
              remarks: null,
            ),
            StationParameter(
              name: 'Disposal of collected waste from Coaches & AC Bins.',
              subParameters: [
                StationSubParameter(
                  id: 'Main', // Changed from 'D3' to 'Main' as per your example, assuming a single point
                  name: 'Disposal of collected waste',
                  coachIds: defaultCoachColumns,
                  scores: {
                    for (var coachId in defaultCoachColumns) coachId: null,
                  },
                ),
              ],
              remarks: null,
            ),
          ],
        ),
      ],
    );
  }

  // --- CopyWith method (essential for immutability and state management) ---
  StationInspectionData copyWith({
    String? woNo,
    DateTime? date,
    String? nameOfWork,
    String? nameOfContractor,
    String? nameOfSupervisor,
    String? designation,
    DateTime? dateOfInspection,
    String? trainNo,
    TimeOfDay? arrivalTime,
    TimeOfDay? depTime,
    int? noOfCoachesAttended,
    int? totalNoOfCoaches,
    List<StationSection>? sections,
    List<String>? coachColumns,
  }) {
    return StationInspectionData(
      woNo: woNo ?? this.woNo,
      date: date ?? this.date,
      nameOfWork: nameOfWork ?? this.nameOfWork,
      nameOfContractor: nameOfContractor ?? this.nameOfContractor,
      nameOfSupervisor: nameOfSupervisor ?? this.nameOfSupervisor,
      designation: designation ?? this.designation,
      dateOfInspection: dateOfInspection ?? this.dateOfInspection,
      trainNo: trainNo ?? this.trainNo,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      depTime: depTime ?? this.depTime,
      noOfCoachesAttended: noOfCoachesAttended ?? this.noOfCoachesAttended,
      totalNoOfCoaches: totalNoOfCoaches ?? this.totalNoOfCoaches,
      sections: sections ?? this.sections,
      coachColumns: coachColumns ?? this.coachColumns,
    );
  }

  // --- toJson method (for sending data to backend) ---
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'woNo': woNo,
      'date': date?.toIso8601String(),
      'nameOfWork': nameOfWork,
      'nameOfContractor': nameOfContractor,
      'nameOfSupervisor': nameOfSupervisor,
      'designation': designation,
      'dateOfInspection': dateOfInspection?.toIso8601String(),
      'trainNo': trainNo,
      'arrivalTime': arrivalTime != null
          ? '${arrivalTime!.hour}:${arrivalTime!.minute}'
          : null,
      'depTime': depTime != null ? '${depTime!.hour}:${depTime!.minute}' : null,
      'noOfCoachesAttended': noOfCoachesAttended,
      'totalNoOfCoaches': totalNoOfCoaches,
      'coachColumns': coachColumns,
      'sections': sections.map((s) => s.toJson()).toList(),
    };
    return data;
  }
}

class StationSection {
  final String name;
  final List<StationParameter> parameters;

  StationSection({required this.name, required this.parameters});

  StationSection copyWith({String? name, List<StationParameter>? parameters}) {
    return StationSection(
      name: name ?? this.name,
      parameters: parameters ?? this.parameters,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'parameters': parameters.map((p) => p.toJson()).toList(),
    };
  }
}

class StationParameter {
  final String name;
  final List<StationSubParameter> subParameters;
  final String? remarks;

  StationParameter({
    required this.name,
    required this.subParameters,
    this.remarks,
  });

  StationParameter copyWith({
    String? name,
    List<StationSubParameter>? subParameters,
    String? remarks,
  }) {
    return StationParameter(
      name: name ?? this.name,
      subParameters: subParameters ?? this.subParameters,
      remarks: remarks ?? this.remarks,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'subParameters': subParameters.map((sp) => sp.toJson()).toList(),
      'remarks': remarks,
    };
  }
}

class StationSubParameter {
  final String id; // e.g., T1, B1, D1
  final String name; // e.g., Toilet 1, Basin 1
  final List<String> coachIds; // Coaches this sub-parameter applies to
  final Map<String, int?>
  scores; // Map of coachId to score (e.g., {'C1': 8, 'C2': 5})

  StationSubParameter({
    required this.id,
    required this.name,
    required this.coachIds,
    required this.scores,
  });

  StationSubParameter copyWith({
    String? id,
    String? name,
    List<String>? coachIds,
    Map<String, int?>? scores,
  }) {
    return StationSubParameter(
      id: id ?? this.id,
      name: name ?? this.name,
      coachIds: coachIds ?? this.coachIds,
      scores: scores ?? this.scores,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'coachIds': coachIds, 'scores': scores};
  }
}
