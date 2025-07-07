import 'package:flutter/material.dart';

enum Section {
  AGREEMENT_NO,
  AGREEMENT_DATE,
  DATE_OF_INSPECTION,
  NAME_OF_CONTRACTOR,
  NAME_OF_SUPERVISOR,
  TRAIN_NO,
  COACH_NO_IN_RAKE,
  TIME_WORK_STARTED,
  TIME_WORK_COMPLETED,
  TOTAL_COACHES_FOR_SCORING,
  INACCESSIBLE_COACHES,
  TOILET_COMPLETE_CLEANLINESS_T1,
  TOILET_COMPLETE_CLEANLINESS_T2,
  TOILET_COMPLETE_CLEANLINESS_T3,
  TOILET_COMPLETE_CLEANLINESS_T4,

  CLEANING_WIPING_MIRRORS_B1,
  DUSTBINS_B2,
  DOORWAY_AREA_B3,

  DISPOSAL_OF_GARBAGE_D1,
  DISPOSAL_OF_GARBAGE_D2,
}

extension SectionExtension on Section {
  String get displayName {
    switch (this) {
      case Section.TOILET_COMPLETE_CLEANLINESS_T1:
        return 'T1 - Toilet Floor Cleanliness';
      case Section.TOILET_COMPLETE_CLEANLINESS_T2:
        return 'T2 - Toilet Walls & Fittings Cleanliness';
      case Section.TOILET_COMPLETE_CLEANLINESS_T3:
        return 'T3 - Toilet Commode/Pan Cleanliness';
      case Section.TOILET_COMPLETE_CLEANLINESS_T4:
        return 'T4 - Toilet Wash Basin & Mirror Cleanliness';
      case Section.CLEANING_WIPING_MIRRORS_B1:
        return 'B1 - Cleaning & wiping of mirrors & shakes in short vestibule etc.';
      case Section.DUSTBINS_B2:
        return 'B2 - Dustbins Cleanliness';
      case Section.DOORWAY_AREA_B3:
        return 'B3 - Doorway, Under seats, Toilets & Footpaths Cleanliness';
      case Section.DISPOSAL_OF_GARBAGE_D1:
        return 'D1 - Garbage Collected from coaches & AC Bins';
      case Section.DISPOSAL_OF_GARBAGE_D2:
        return 'D2 - Garbage Disposed from coaches & AC Bins';
      default:
        return name.replaceAll('_', ' ').toTitleCase();
    }
  }

  int? get maxMarks {
    switch (this) {
      case Section.TOILET_COMPLETE_CLEANLINESS_T1:
        return 1;
      case Section.TOILET_COMPLETE_CLEANLINESS_T2:
        return 1;
      case Section.TOILET_COMPLETE_CLEANLINESS_T3:
        return 1;
      case Section.TOILET_COMPLETE_CLEANLINESS_T4:
        return 1;
      case Section.CLEANING_WIPING_MIRRORS_B1:
        return 1;
      case Section.DUSTBINS_B2:
        return 1;
      case Section.DOORWAY_AREA_B3:
        return 1;
      case Section.DISPOSAL_OF_GARBAGE_D1:
        return 1;
      case Section.DISPOSAL_OF_GARBAGE_D2:
        return 1;
      default:
        return null;
    }
  }

  String? get itemCode {
    switch (this) {
      case Section.TOILET_COMPLETE_CLEANLINESS_T1:
        return 'T1';
      case Section.TOILET_COMPLETE_CLEANLINESS_T2:
        return 'T2';
      case Section.TOILET_COMPLETE_CLEANLINESS_T3:
        return 'T3';
      case Section.TOILET_COMPLETE_CLEANLINESS_T4:
        return 'T4';
      case Section.CLEANING_WIPING_MIRRORS_B1:
        return 'B1';
      case Section.DUSTBINS_B2:
        return 'B2';
      case Section.DOORWAY_AREA_B3:
        return 'B3';
      case Section.DISPOSAL_OF_GARBAGE_D1:
        return 'D1';
      case Section.DISPOSAL_OF_GARBAGE_D2:
        return 'D2';
      default:
        return null;
    }
  }
}

extension StringExtension on String {
  String toTitleCase() {
    if (isEmpty) return this;
    return split(' ')
        .map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }
}

class CoachColumnData {
  String coachNo;
  Map<Section, int?> scores;
  String? remarks;
  int? totalScoreObtained;

  CoachColumnData({
    required this.coachNo,
    Map<Section, int?>? scores,
    this.remarks,
    this.totalScoreObtained,
  }) : scores = scores ?? {};

  int calculateTotalScoreObtained() {
    int total = 0;
    scores.forEach((section, score) {
      if (score != null && section.maxMarks != null) {
        total += score;
      }
    });
    return total;
  }

  int getTotalPossibleScore() {
    int totalMax = 0;
    Section.values.forEach((section) {
      if (section.maxMarks != null) {
        totalMax += section.maxMarks!;
      }
    });
    return totalMax;
  }
}

class CoachCleaningInspectionData {
  String? agreementNo;
  DateTime? agreementDate;
  DateTime? dateOfInspection;
  String? nameOfContractor;
  String? nameOfSupervisor;
  String? trainNo;
  int? coachNoInRake;
  TimeOfDay? timeWorkStarted;
  TimeOfDay? timeWorkCompleted;
  int? totalNoOfCoaches;
  String? inaccessibleCoaches;
  String? overallRemarks;

  List<CoachColumnData> coachColumns;

  CoachCleaningInspectionData({
    this.agreementNo,
    this.agreementDate,
    this.dateOfInspection,
    this.nameOfContractor,
    this.nameOfSupervisor,
    this.trainNo,
    this.coachNoInRake,
    this.timeWorkStarted,
    this.timeWorkCompleted,
    this.totalNoOfCoaches,
    this.inaccessibleCoaches,
    this.overallRemarks,
    List<CoachColumnData>? coachColumns,
  }) : coachColumns = coachColumns ?? [];

  List<Section> get scoringParameters {
    return Section.values.where((s) => s.maxMarks != null).toList();
  }

  String? get coachNo {
    return coachNoInRake?.toString();
  }

  String? get timeOfInspection {
    if (dateOfInspection != null && timeWorkStarted != null) {
      final dt = DateTime(
        dateOfInspection!.year,
        dateOfInspection!.month,
        dateOfInspection!.day,
        timeWorkStarted!.hour,
        timeWorkStarted!.minute,
      );
      return '${dt.day}/${dt.month}/${dt.year} ${timeWorkStarted!.hour.toString().padLeft(2, '0')}:${timeWorkStarted!.minute.toString().padLeft(2, '0')}';
    }
    return null;
  }

  String? get supervisorName {
    return nameOfSupervisor;
  }

  String? get remarks {
    return overallRemarks;
  }

  int get grandTotalScoreObtained {
    return coachColumns.fold(
      0,
      (sum, coach) => sum + (coach.totalScoreObtained ?? 0),
    );
  }

  int get grandTotalPossibleScore {
    if (coachColumns.isEmpty) return 0;
    return coachColumns.length * coachColumns.first.getTotalPossibleScore();
  }
}
