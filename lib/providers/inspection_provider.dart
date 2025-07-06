// lib/providers/inspection_provider.dart

import 'package:flutter/material.dart';

import '../models/coach_inspection_data.dart';
import '../models/station_inspection_data.dart';

class InspectionProvider with ChangeNotifier {
  StationInspectionData _stationInspectionData =
      StationInspectionData.initial();
  CoachInspectionData _coachInspectionData = CoachInspectionData.initial();

  StationInspectionData get stationInspectionData => _stationInspectionData;
  CoachInspectionData get coachInspectionData => _coachInspectionData;

  // --- Station Inspection Data Update Methods ---
  void updateStationWoNo(String value) {
    _stationInspectionData = _stationInspectionData.copyWith(woNo: value);
    notifyListeners();
  }

  void updateStationDate(DateTime value) {
    _stationInspectionData = _stationInspectionData.copyWith(date: value);
    notifyListeners();
  }

  void updateStationNameOfWork(String value) {
    _stationInspectionData = _stationInspectionData.copyWith(nameOfWork: value);
    notifyListeners();
  }

  void updateStationNameOfContractor(String value) {
    _stationInspectionData = _stationInspectionData.copyWith(
      nameOfContractor: value,
    );
    notifyListeners();
  }

  void updateStationNameOfSupervisor(String value) {
    _stationInspectionData = _stationInspectionData.copyWith(
      nameOfSupervisor: value,
    );
    notifyListeners();
  }

  void updateStationDesignation(String value) {
    _stationInspectionData = _stationInspectionData.copyWith(
      designation: value,
    );
    notifyListeners();
  }

  void updateStationDateOfInspection(DateTime value) {
    _stationInspectionData = _stationInspectionData.copyWith(
      dateOfInspection: value,
    );
    notifyListeners();
  }

  void updateStationTrainNo(String value) {
    _stationInspectionData = _stationInspectionData.copyWith(trainNo: value);
    notifyListeners();
  }

  void updateStationArrivalTime(TimeOfDay value) {
    _stationInspectionData = _stationInspectionData.copyWith(
      arrivalTime: value,
    );
    notifyListeners();
  }

  void updateStationDepTime(TimeOfDay value) {
    _stationInspectionData = _stationInspectionData.copyWith(depTime: value);
    notifyListeners();
  }

  // Changed to accept int? for better null safety
  void updateStationNoOfCoachesAttended(int? value) {
    _stationInspectionData = _stationInspectionData.copyWith(
      noOfCoachesAttended: value,
    );
    notifyListeners();
  }

  void updateStationTotalNoOfCoaches(int? value) {
    List<String> newCoachColumns = [];
    List<StationSection> newSections = [];

    // Only generate coaches and sections if value is positive
    if (value != null && value > 0) {
      for (int i = 1; i <= value; i++) {
        newCoachColumns.add('C$i');
      }
      // Re-create sections and sub-parameters with the new coach list
      newSections = _createInitialStationSections(newCoachColumns);
    }

    _stationInspectionData = _stationInspectionData.copyWith(
      totalNoOfCoaches: value,
      coachColumns: newCoachColumns,
      sections: newSections,
      noOfCoachesAttended: null, // Reset when total coaches change
    );
    notifyListeners();
  }

  // Changed score type to int?
  void updateStationSubParameterScore(
    String sectionName,
    String parameterName,
    String subParameterId,
    String coachId,
    int? score,
  ) {
    final updatedSections = _stationInspectionData.sections.map((section) {
      if (section.name == sectionName) {
        // Assuming section.name is unique or effectively filtered
        final updatedParameters = section.parameters.map((parameter) {
          if (parameter.name == parameterName) {
            // Assuming parameter.name is unique per section
            final updatedSubParameters = parameter.subParameters.map((
              subParam,
            ) {
              if (subParam.id == subParameterId) {
                // subParam.id should be unique per parameter
                final newScores = Map<String, int?>.from(
                  subParam.scores,
                ); // Changed to int?
                newScores[coachId] = score;
                return subParam.copyWith(scores: newScores);
              }
              return subParam;
            }).toList();
            return parameter.copyWith(subParameters: updatedSubParameters);
          }
          return parameter;
        }).toList();
        return section.copyWith(parameters: updatedParameters);
      }
      return section;
    }).toList();
    _stationInspectionData = _stationInspectionData.copyWith(
      sections: updatedSections,
    );
    notifyListeners();
  }

  // Renamed from fillEmptyScoresWithZero for clarity
  void fillEmptyScoresWithDefaultMark(String coachId) {
    final updatedSections = _stationInspectionData.sections.map((section) {
      final updatedParameters = section.parameters.map((parameter) {
        final updatedSubParameters = parameter.subParameters.map((subParam) {
          // Only update if this sub-parameter applies to the current coach
          if (subParam.coachIds.contains(coachId)) {
            final newScores = Map<String, int?>.from(subParam.scores);
            if (newScores[coachId] == null) {
              newScores[coachId] = 0; // Default to 0
            }
            return subParam.copyWith(scores: newScores);
          }
          return subParam;
        }).toList();
        return parameter.copyWith(subParameters: updatedSubParameters);
      }).toList();
      return section.copyWith(parameters: updatedParameters);
    }).toList();
    _stationInspectionData = _stationInspectionData.copyWith(
      sections: updatedSections,
    );
    // After filling scores, recalculate the number of attended coaches
    calculateNoOfCoachesAttended();
    // No notifyListeners here as it's typically called before a final action like PDF generation
  }

  void updateStationParameterRemarks(
    String sectionName,
    String parameterName,
    String? remarks,
  ) {
    final updatedSections = _stationInspectionData.sections.map((section) {
      if (section.name == sectionName) {
        final updatedParameters = section.parameters.map((param) {
          if (param.name == parameterName) {
            return param.copyWith(remarks: remarks);
          }
          return param;
        }).toList();
        return section.copyWith(parameters: updatedParameters);
      }
      return section;
    }).toList();
    _stationInspectionData = _stationInspectionData.copyWith(
      sections: updatedSections,
    );
    notifyListeners();
  }

  // --- Coach Inspection Data Update Methods (unchanged from previous context) ---
  void updateCoachAgreementNoAndDate(String value) {
    _coachInspectionData = _coachInspectionData.copyWith(
      agreementNoAndDate: value,
    );
    notifyListeners();
  }

  void updateCoachDateOfInspection(DateTime value) {
    _coachInspectionData = _coachInspectionData.copyWith(
      dateOfInspection: value,
    );
    notifyListeners();
  }

  void updateCoachNameOfContractor(String value) {
    _coachInspectionData = _coachInspectionData.copyWith(
      nameOfContractor: value,
    );
    notifyListeners();
  }

  void updateCoachNameOfSupervisor(String value) {
    _coachInspectionData = _coachInspectionData.copyWith(
      nameOfSupervisor: value,
    );
    notifyListeners();
  }

  void updateCoachTrainNo(String value) {
    _coachInspectionData = _coachInspectionData.copyWith(trainNo: value);
    notifyListeners();
  }

  void updateCoachTimeWorkStarted(TimeOfDay value) {
    _coachInspectionData = _coachInspectionData.copyWith(
      timeWorkStarted: value,
    );
    notifyListeners();
  }

  void updateCoachTimeWorkCompleted(TimeOfDay value) {
    _coachInspectionData = _coachInspectionData.copyWith(
      timeWorkCompleted: value,
    );
    notifyListeners();
  }

  void updateCoachNoOfCoachesAttended(int value) {
    _coachInspectionData = _coachInspectionData.copyWith(
      noOfCoachesAttended: value,
    );
    notifyListeners();
  }

  void updateCoachParameterScore(String parameterName, int? score) {
    final updatedParameters = _coachInspectionData.parameters.map((param) {
      if (param.name == parameterName) {
        return param.copyWith(score: score);
      }
      return param;
    }).toList();
    _coachInspectionData = _coachInspectionData.copyWith(
      parameters: updatedParameters,
    );
    notifyListeners();
  }

  void updateCoachParameterRemarks(String parameterName, String? remarks) {
    final updatedParameters = _coachInspectionData.parameters.map((param) {
      if (param.name == parameterName) {
        return param.copyWith(remarks: remarks);
      }
      return param;
    }).toList();
    _coachInspectionData = _coachInspectionData.copyWith(
      parameters: updatedParameters,
    );
    notifyListeners();
  }

  // --- Reset Forms ---
  void resetStationForm() {
    _stationInspectionData = StationInspectionData.initial();
    notifyListeners();
  }

  void resetCoachForm() {
    _coachInspectionData = CoachInspectionData.initial();
    notifyListeners();
  }

  // --- Validation Logic (station form: only for final submission) ---
  bool isStationFormValidForSubmission() {
    // Check if totalNoOfCoaches is set and > 0
    if (_stationInspectionData.totalNoOfCoaches == null ||
        _stationInspectionData.totalNoOfCoaches! <= 0) {
      return false;
    }

    // Now check if ALL scores for ALL relevant coaches are non-null (i.e., scored or set to 0 by fillEmptyScoresWithDefaultMark)
    // Iterate through the coaches that are supposed to be attended
    for (String coachId in _stationInspectionData.coachColumns) {
      bool coachHasAnyNullScore = false;
      for (var section in _stationInspectionData.sections) {
        for (var parameter in section.parameters) {
          for (var subParameter in parameter.subParameters) {
            if (subParameter.coachIds.contains(coachId)) {
              // Only check if this sub-parameter applies to the coach
              if (subParameter.scores[coachId] == null) {
                coachHasAnyNullScore = true;
                break; // Found a null score for this coach
              }
            }
          }
          if (coachHasAnyNullScore) break;
        }
        if (coachHasAnyNullScore) break;
      }
      if (coachHasAnyNullScore) {
        return false; // Found a coach with at least one null score
      }
    }
    return true; // All coaches that are supposed to be scored, have non-null scores.
  }

  // This method will calculate the number of coaches that have at least one score (not null)
  void calculateNoOfCoachesAttended() {
    int attendedCount = 0;
    // Iterate over the coach IDs that are currently in the data
    for (String coachId in _stationInspectionData.coachColumns) {
      bool coachHasAnyScore = false;
      for (StationSection section in _stationInspectionData.sections) {
        for (StationParameter parameter in section.parameters) {
          for (StationSubParameter subParameter in parameter.subParameters) {
            // Check if this sub-parameter applies to the current coach
            if (subParameter.coachIds.contains(coachId)) {
              final score = subParameter.scores[coachId];
              if (score != null) {
                // If any score for this coach is not null, it's considered attended
                coachHasAnyScore = true;
                break; // Move to the next coach once one score is found
              }
            }
          }
          if (coachHasAnyScore) break;
        }
        if (coachHasAnyScore) {
          attendedCount++;
          break; // Move to the next coach in coachColumns after finding at least one score
        }
      }
    }
    // Update the provider's state with the calculated count
    _stationInspectionData = _stationInspectionData.copyWith(
      noOfCoachesAttended: attendedCount,
    );
    notifyListeners(); // Notify listeners to update UI if this value is displayed
  }

  // This method will only sum integer scores
  int calculateTotalScoreForCoach(String coachId) {
    int totalScore = 0;
    for (var section in _stationInspectionData.sections) {
      for (var parameter in section.parameters) {
        for (var subParameter in parameter.subParameters) {
          if (subParameter.coachIds.contains(coachId)) {
            final score = subParameter.scores[coachId];
            if (score != null) {
              // Only add if it's a valid number
              totalScore += score;
            }
          }
        }
      }
    }
    return totalScore;
  }

  bool isCoachFormValid() {
    if (_coachInspectionData.nameOfContractor == null ||
        _coachInspectionData.nameOfContractor!.isEmpty ||
        _coachInspectionData.dateOfInspection == null ||
        _coachInspectionData.nameOfSupervisor == null ||
        _coachInspectionData.nameOfSupervisor!.isEmpty) {
      return false;
    }
    for (var parameter in _coachInspectionData.parameters) {
      if (parameter.score == null) {
        return false;
      }
    }
    return true;
  }
}

// Helper function moved from StationInspectionData model for provider to use
// This creates the initial structure of sections/parameters/subparameters for new coaches
List<StationSection> _createInitialStationSections(List<String> coachColumns) {
  return [
    StationSection(
      name: '', // Empty name for the main section to avoid extra heading in UI
      parameters: [
        StationParameter(
          name:
              'Toilet cleaning complete including pan with High Pressure Jet machine, cleaning wiping of wash basin, mirror & shelves, , Spraying of Air Freshener & Mosquito Repellent',
          subParameters: [
            StationSubParameter(
              id: 'T1',
              name: 'Toilet 1',
              coachIds: coachColumns,
              scores: {for (var coachId in coachColumns) coachId: null},
            ),
            StationSubParameter(
              id: 'T2',
              name: 'Toilet 2',
              coachIds: coachColumns,
              scores: {for (var coachId in coachColumns) coachId: null},
            ),
            StationSubParameter(
              id: 'T3',
              name: 'Toilet 3',
              coachIds: coachColumns,
              scores: {for (var coachId in coachColumns) coachId: null},
            ),
            StationSubParameter(
              id: 'T4',
              name: 'Toilet 4',
              coachIds: coachColumns,
              scores: {for (var coachId in coachColumns) coachId: null},
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
              coachIds: coachColumns,
              scores: {for (var coachId in coachColumns) coachId: null},
            ),
            StationSubParameter(
              id: 'B2',
              name: 'Basin 2',
              coachIds: coachColumns,
              scores: {for (var coachId in coachColumns) coachId: null},
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
              coachIds: coachColumns,
              scores: {for (var coachId in coachColumns) coachId: null},
            ),
            StationSubParameter(
              id: 'D2',
              name: 'Doorway Area 2',
              coachIds: coachColumns,
              scores: {for (var coachId in coachColumns) coachId: null},
            ),
          ],
          remarks: null,
        ),
        StationParameter(
          name: 'Disposal of collected waste from Coaches & AC Bins.',
          subParameters: [
            StationSubParameter(
              id: 'Main',
              name: 'Disposal of collected waste',
              coachIds: coachColumns,
              scores: {for (var coachId in coachColumns) coachId: null},
            ),
          ],
          remarks: null,
        ),
      ],
    ),
  ];
}
