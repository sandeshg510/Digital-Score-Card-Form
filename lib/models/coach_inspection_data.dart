// lib/models/coach_cleaning_inspection_data.dart

import 'package:flutter/material.dart'; // For TimeOfDay

enum Section {
  // Header details (not scoring sections, but part of the overall data)
  AGREEMENT_NO,
  AGREEMENT_DATE,
  DATE_OF_INSPECTION,
  NAME_OF_CONTRACTOR,
  NAME_OF_SUPERVISOR,
  TRAIN_NO,
  COACH_NO_IN_RAKE, // This is for the single coach number in the header
  TIME_WORK_STARTED,
  TIME_WORK_COMPLETED,
  TOTAL_COACHES_FOR_SCORING, // This is for the total count of coaches
  INACCESSIBLE_COACHES, // Added based on A_1_SCORE CARD (1).jpg
  // Scoring Sections based on A_1_SCORE CARD (1).jpg
  TOILET_COMPLETE_CLEANLINESS_T1, // T1 - Floor
  TOILET_COMPLETE_CLEANLINESS_T2, // T2 - Walls & fittings
  TOILET_COMPLETE_CLEANLINESS_T3, // T3 - Commode/Pan
  TOILET_COMPLETE_CLEANLINESS_T4, // T4 - Wash Basin & Mirror

  CLEANING_WIPING_MIRRORS_B1, // B1 - Cleaning & wiping of mirrors & shakes in short vestibule etc.
  DUSTBINS_B2, // B2 - Dustbins
  DOORWAY_AREA_B3, // B3 - Doorway area, area under seats, toilets and footpaths

  DISPOSAL_OF_GARBAGE_D1, // D1 - Garbage collected
  DISPOSAL_OF_GARBAGE_D2, // D2 - Garbage disposed
}

// Extension to get display name and max marks for Section enum
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
    // These max marks need to be confirmed based on your actual scoring logic.
    // Assuming each scoring item is out of 1 for a total of 9 items, making total 9.
    // If the total score for the scorecard is 15 as implied by A_1_SCORE CARD (1).jpg,
    // then these values will need to be adjusted to sum up to 15.
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
        return null; // Not a scoring section
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

// Helper for title case conversion
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
  String coachNo; // e.g., "C1", "C2", etc.
  Map<Section, int?>
  scores; // Scores for each section (e.g., {Section.TOILET_T1: 1})
  String? remarks; // Remarks specific to this coach
  int?
  totalScoreObtained; // Calculated total for this coach for display on the card

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
  DateTime? dateOfInspection; // Used for Date of Inspection
  String? nameOfContractor;
  String? nameOfSupervisor;
  String? trainNo;
  int?
  coachNoInRake; // This is the single coach number from the header form (if applicable)
  TimeOfDay? timeWorkStarted;
  TimeOfDay? timeWorkCompleted;
  int?
  totalNoOfCoaches; // The number of coaches entered to generate tabs for scoring
  String? inaccessibleCoaches; // From A_1_SCORE CARD (1).jpg
  String?
  overallRemarks; // NEW: If you need an overall remarks field for the entire inspection

  List<CoachColumnData> coachColumns; // List of individual coach scorecards

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
    this.overallRemarks, // Initialize new field
    List<CoachColumnData>? coachColumns,
  }) : coachColumns = coachColumns ?? [];

  // Getters for PDF service and display (addressing "getter isn't defined" errors)
  List<Section> get scoringParameters {
    // Addresses 'parameters' getter error
    return Section.values.where((s) => s.maxMarks != null).toList();
  }

  String? get coachNo {
    // Addresses 'coachNo' getter error
    return coachNoInRake?.toString();
  }

  String? get timeOfInspection {
    // Addresses 'timeOfInspection' getter error
    // This getter is ambiguous if referring to a single time.
    // It's safer to use dateOfInspection, timeWorkStarted, timeWorkCompleted directly.
    // However, if the PDF service specifically calls `inspectionData.timeOfInspection`,
    // this provides a fallback by combining date and start time.
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
    // Addresses 'supervisorName' getter error
    return nameOfSupervisor;
  }

  String? get remarks {
    // Addresses 'remarks' getter error
    // This getter is provided if you intend to have a single "overallRemarks" for the inspection.
    // If remarks are strictly per coach, then remove this getter and ensure PDF access coach.remarks.
    return overallRemarks;
  }

  // The errors for 'items', 'totalMaxMarks', 'totalMarksObtained' at the InspectionData level
  // likely mean the PDF was trying to sum them up. We use grandTotalScoreObtained
  // and grandTotalPossibleScore for the overall summary.
  // Individual coach's total would be accessed via coachColumnData.totalScoreObtained and coachColumnData.getTotalPossibleScore()

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
