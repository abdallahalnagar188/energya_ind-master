import 'package:energya_ind/core/helper/providers/excel_provider.dart';

List<List<String>> getHoldFilteredData(ExcelProvider ex, int selectedState) {
  switch (selectedState) {
    case 1:
      ex.updateRowsBasedOnFilter("Hold");

      return ex.holdExcelData;
    case 2:
      ex.updateRowsBasedOnFilter("Un-Hold");
      return ex.unHoldExcelData;
    default:
      ex.updateRowsBasedOnFilter("All");
      return ex.allExcelData;
  }
}

List<List<String>> getProductionFilteredData(
  ExcelProvider ex,
  int selectedState,
  String title,
  bool isDispatch,
) {
  switch (selectedState) {
    case 1:
      ex.updateRowsBasedOnFilter("Under-$title", currentStep: title);

      return ex.underExcelData;
    case 2:
      ex.updateRowsBasedOnFilter("Hold", currentStep: title);
      return ex.holdExcelData;
    case 3:
      ex.updateRowsBasedOnFilter(isDispatch ? "Dispatched" : "Done",
          currentStep: title);
      return isDispatch ? ex.dispatchedExcelData : ex.doneExcelData;
    default:
      ex.updateRowsBasedOnFilter("All", currentStep: title);
      return ex.allExcelData;
  }
}
