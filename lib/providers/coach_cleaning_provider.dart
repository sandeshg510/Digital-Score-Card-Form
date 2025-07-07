// lib/providers/coach_cleaning_provider.dart

import 'package:flutter/material.dart';

import '../models/coach_inspection_data.dart'; // Import the data model

class CoachCleaningProvider with ChangeNotifier {
  CoachCleaningInspectionData _coachCleaningInspectionData =
      CoachCleaningInspectionData();

  CoachCleaningInspectionData get coachCleaningInspectionData =>
      _coachCleaningInspectionData;

  // --- Methods to update header data ---

  void updateCoachCleaningAgreementNo(String? agreementNo) {
    _coachCleaningInspectionData.agreementNo = agreementNo;
    notifyListeners();
  }

  void updateCoachCleaningAgreementDate(DateTime? date) {
    _coachCleaningInspectionData.agreementDate = date;
    notifyListeners();
  }

  void updateCoachCleaningDateOfInspection(DateTime? date) {
    _coachCleaningInspectionData.dateOfInspection = date;
    notifyListeners();
  }

  void updateCoachCleaningNameOfContractor(String? name) {
    _coachCleaningInspectionData.nameOfContractor = name;
    notifyListeners();
  }

  void updateCoachCleaningNameOfSupervisor(String? name) {
    _coachCleaningInspectionData.nameOfSupervisor = name;
    notifyListeners();
  }

  void updateCoachCleaningTrainNo(String? trainNo) {
    _coachCleaningInspectionData.trainNo = trainNo;
    notifyListeners();
  }

  void updateCoachCleaningCoachNoInRake(int? coachNo) {
    _coachCleaningInspectionData.coachNoInRake = coachNo;
    notifyListeners();
  }

  void updateCoachCleaningTimeWorkStarted(TimeOfDay? time) {
    _coachCleaningInspectionData.timeWorkStarted = time;
    notifyListeners();
  }

  void updateCoachCleaningTimeWorkCompleted(TimeOfDay? time) {
    _coachCleaningInspectionData.timeWorkCompleted = time;
    notifyListeners();
  }

  void updateInaccessibleCoaches(String? inaccessible) {
    _coachCleaningInspectionData.inaccessibleCoaches = inaccessible;
    notifyListeners();
  }

  // --- Methods for CoachColumnData (scoring) ---

  void generateCoachCleaningCoachColumns(int numberOfCoaches) {
    if (numberOfCoaches < 0) numberOfCoaches = 0;

    _coachCleaningInspectionData.totalNoOfCoaches =
        numberOfCoaches; // Update total count in header data

    List<CoachColumnData> newCoachColumns = [];

    for (int i = 0; i < numberOfCoaches; i++) {
      if (i < _coachCleaningInspectionData.coachColumns.length) {
        newCoachColumns.add(_coachCleaningInspectionData.coachColumns[i]);
      } else {
        newCoachColumns.add(
          CoachColumnData(
            coachNo: 'C${i + 1}', // Default naming convention for tabs
            scores: {}, // Initialize with empty map for scores
            remarks: '',
            totalScoreObtained: 0, // Initialize to 0
          ),
        );
      }
    }
    _coachCleaningInspectionData.coachColumns = newCoachColumns;
    notifyListeners();
  }

  void updateCoachColumnData(
    int index,
    CoachColumnData updatedCoachColumnData,
  ) {
    if (index >= 0 &&
        index < _coachCleaningInspectionData.coachColumns.length) {
      // Recalculate total marks obtained for the updated coach column
      updatedCoachColumnData.totalScoreObtained = updatedCoachColumnData
          .calculateTotalScoreObtained(); // Changed to int
      _coachCleaningInspectionData.coachColumns[index] = updatedCoachColumnData;
      notifyListeners();
    }
  }

  void resetCoachCleaningData() {
    _coachCleaningInspectionData = CoachCleaningInspectionData();
    notifyListeners();
  }
}
