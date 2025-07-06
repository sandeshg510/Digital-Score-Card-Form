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

  void updateStationNoOfCoachesAttended(int value) {
    _stationInspectionData = _stationInspectionData.copyWith(
      noOfCoachesAttended: value,
    );
    notifyListeners();
  }

  void updateStationTotalNoOfCoaches(int value) {
    _stationInspectionData = _stationInspectionData.copyWith(
      totalNoOfCoaches: value,
    );
    notifyListeners();
  }

  void updateStationSubParameterScore(
    String sectionName,
    String parameterName,
    String subParameterId,
    String coachId,
    int? score,
  ) {
    final updatedSections = _stationInspectionData.sections.map((section) {
      if (section.name == sectionName) {
        final updatedParameters = section.parameters.map((parameter) {
          if (parameter.name == parameterName) {
            final updatedSubParameters = parameter.subParameters.map((
              subParam,
            ) {
              if (subParam.id == subParameterId) {
                final newScores = Map<String, int?>.from(subParam.scores);
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

  // NEW METHOD: Fill empty scores for a specific coach with 0
  void fillEmptyScoresWithZero(String coachId) {
    final updatedSections = _stationInspectionData.sections.map((section) {
      final updatedParameters = section.parameters.map((parameter) {
        final updatedSubParameters = parameter.subParameters.map((subParam) {
          // Only update if this sub-parameter applies to the current coach
          if (subParam.coachIds.contains(coachId)) {
            final newScores = Map<String, int?>.from(subParam.scores);
            if (newScores[coachId] == null) {
              newScores[coachId] = 0; // Set to 0 if currently null
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
    // notifyListeners() is called in the UI after this, so no need here if only called internally before tab change
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

  // --- Coach Inspection Data Update Methods (unchanged) ---
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

  // --- Reset Forms (unchanged) ---
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
    // Renamed for clarity
    // Header validation is done on the previous screen
    // This checks if ALL scores for ALL coaches are non-null (i.e., scored or set to 0)
    for (var section in _stationInspectionData.sections) {
      for (var parameter in section.parameters) {
        for (var subParameter in parameter.subParameters) {
          for (var coachId in subParameter.coachIds) {
            if (subParameter.scores[coachId] == null) {
              return false; // Found an unscored parameter
            }
          }
        }
      }
    }
    return true; // All parameters are scored (either manually or set to 0)
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
