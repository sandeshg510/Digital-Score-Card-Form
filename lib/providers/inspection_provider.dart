import 'package:flutter/material.dart';

import '../models/station_inspection_data.dart';

class InspectionProvider extends ChangeNotifier {
  StationInspectionData _stationInspectionData =
      StationInspectionData.initial();

  StationInspectionData get stationInspectionData => _stationInspectionData;

  void updateStationWoNo(String? woNo) {
    _stationInspectionData = _stationInspectionData.copyWith(woNo: woNo);
    notifyListeners();
  }

  void updateStationDate(DateTime? date) {
    _stationInspectionData = _stationInspectionData.copyWith(date: date);
    notifyListeners();
  }

  void updateStationNameOfWork(String? nameOfWork) {
    _stationInspectionData = _stationInspectionData.copyWith(
      nameOfWork: nameOfWork,
    );
    notifyListeners();
  }

  void updateStationNameOfContractor(String? nameOfContractor) {
    _stationInspectionData = _stationInspectionData.copyWith(
      nameOfContractor: nameOfContractor,
    );
    notifyListeners();
  }

  void updateStationNameOfSupervisor(String? nameOfSupervisor) {
    _stationInspectionData = _stationInspectionData.copyWith(
      nameOfSupervisor: nameOfSupervisor,
    );
    notifyListeners();
  }

  void updateStationDesignation(String? designation) {
    _stationInspectionData = _stationInspectionData.copyWith(
      designation: designation,
    );
    notifyListeners();
  }

  void updateStationDateOfInspection(DateTime? dateOfInspection) {
    _stationInspectionData = _stationInspectionData.copyWith(
      dateOfInspection: dateOfInspection,
    );
    notifyListeners();
  }

  void updateStationTrainNo(String? trainNo) {
    _stationInspectionData = _stationInspectionData.copyWith(trainNo: trainNo);
    notifyListeners();
  }

  void updateStationArrivalTime(TimeOfDay? arrivalTime) {
    _stationInspectionData = _stationInspectionData.copyWith(
      arrivalTime: arrivalTime,
    );
    notifyListeners();
  }

  void updateStationDepTime(TimeOfDay? depTime) {
    _stationInspectionData = _stationInspectionData.copyWith(depTime: depTime);
    notifyListeners();
  }

  void updateStationTotalNoOfCoaches(int? totalNoOfCoaches) {
    _stationInspectionData = _stationInspectionData.copyWith(
      totalNoOfCoaches: totalNoOfCoaches,
    );
    if (totalNoOfCoaches != null && totalNoOfCoaches > 0) {
      _generateStationCoachColumns(totalNoOfCoaches);
      _reinitializeStationSectionsWithCoaches();
    } else {
      _stationInspectionData = _stationInspectionData.copyWith(
        coachColumns: [],
      );
      _reinitializeStationSectionsWithCoaches(); // Reset sections if no coaches
    }
    notifyListeners();
  }

  void _generateStationCoachColumns(int count) {
    List<String> newCoachColumns = List.generate(
      count,
      (index) => 'C${index + 1}',
    );
    _stationInspectionData = _stationInspectionData.copyWith(
      coachColumns: newCoachColumns,
    );
  }

  void _reinitializeStationSectionsWithCoaches() {
    _stationInspectionData = _stationInspectionData.copyWith(
      sections: _createInitialStationSections(
        _stationInspectionData.coachColumns,
      ), // Use helper
    );
  }

  void updateStationSubParameterScore(
    String sectionName,
    String parameterName,
    String subParameterId,
    String coachId,
    int? newScore,
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
                newScores[coachId] = newScore;
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

  void updateStationParameterRemarks(
    String sectionName,
    String parameterName,
    String? newRemarks,
  ) {
    final updatedSections = _stationInspectionData.sections.map((section) {
      if (section.name == sectionName) {
        final updatedParameters = section.parameters.map((parameter) {
          if (parameter.name == parameterName) {
            return parameter.copyWith(remarks: newRemarks);
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

  int calculateTotalScoreForCoach(String coachId) {
    int total = 0;
    for (var section in _stationInspectionData.sections) {
      for (var parameter in section.parameters) {
        for (var subParam in parameter.subParameters) {
          if (subParam.coachIds.contains(coachId)) {
            total += subParam.scores[coachId] ?? 0;
          }
        }
      }
    }
    return total;
  }

  void fillEmptyScoresWithDefaultMark(String coachId) {
    final updatedSections = _stationInspectionData.sections.map((section) {
      final updatedParameters = section.parameters.map((parameter) {
        final updatedSubParameters = parameter.subParameters.map((subParam) {
          if (subParam.coachIds.contains(coachId) &&
              subParam.scores[coachId] == null) {
            final newScores = Map<String, int?>.from(subParam.scores);
            newScores[coachId] = 0; // Default to 0 if not scored
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
  }

  void calculateNoOfCoachesAttended() {
    int coachesAttended = 0;
    if (_stationInspectionData.coachColumns.isNotEmpty) {
      for (String coachId in _stationInspectionData.coachColumns) {
        bool isCoachAttended = false;
        for (var section in _stationInspectionData.sections) {
          for (var parameter in section.parameters) {
            for (var subParam in parameter.subParameters) {
              if (subParam.coachIds.contains(coachId) &&
                  subParam.scores[coachId] != null) {
                isCoachAttended = true;
                break;
              }
            }
            if (isCoachAttended) break;
          }
          if (isCoachAttended) break;
        }
        if (isCoachAttended) {
          coachesAttended++;
        }
      }
    }
    _stationInspectionData = _stationInspectionData.copyWith(
      noOfCoachesAttended: coachesAttended,
    );
    notifyListeners();
  }

  bool isStationFormValidForSubmission() {
    for (String coachId in _stationInspectionData.coachColumns) {
      for (var section in _stationInspectionData.sections) {
        for (var parameter in section.parameters) {
          for (var subParam in parameter.subParameters) {
            if (subParam.coachIds.contains(coachId) &&
                subParam.scores[coachId] == null) {
              return false;
            }
          }
        }
      }
    }
    return true;
  }

  void resetStationForm() {
    _stationInspectionData = StationInspectionData.initial();
    notifyListeners();
  }

  List<StationSection> _createInitialStationSections(
    List<String> coachColumns,
  ) {
    return [
      StationSection(
        name: '',
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
}
