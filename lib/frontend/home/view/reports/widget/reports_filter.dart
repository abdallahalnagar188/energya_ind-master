import 'package:energya_ind/core/helper/providers/excel_provider.dart';
import 'package:energya_ind/core/models/authority_model.dart';

List<List<String>> getReportFilteredData(ExcelProvider ex, int selectedState) {
  switch (selectedState) {
    case 1:
      ex.filterExcelData("Hold");
      return ex.holdExcelData;
    case 2:
      ex.filterExcelData(AuthorityModel.authos[8].name);
      return ex.underExcelData;
    case 3:
      ex.filterExcelData(AuthorityModel.authos[0].name);
      return ex.underExcelData;
    case 4:
      ex.filterExcelData(AuthorityModel.authos[1].name);
      return ex.underExcelData;
    case 5:
      ex.filterExcelData(AuthorityModel.authos[2].name);
      return ex.underExcelData;
    case 6:
      ex.filterExcelData(AuthorityModel.authos[3].name);
      return ex.underExcelData;
    case 7:
      ex.filterExcelData(AuthorityModel.authos[3].name);
      return ex.doneExcelData;
    case 8:
      ex.filterExcelData(AuthorityModel.authos[3].name);
      return [ex.headerRow] +
          ex.allExcelData
              .where((item) => !ex.doneExcelData.contains(item))
              .toList();
    case 9:
      ex.filterExcelData(AuthorityModel.authos[4].name);
      return ex.underExcelData;
    case 10:
      ex.filterExcelData(AuthorityModel.authos[5].name);
      return ex.underExcelData;
    case 11:
      ex.filterExcelData(AuthorityModel.authos[7].name);
      return ex.underExcelData;
    case 12:
      ex.filterExcelData(AuthorityModel.authos[6].name);
      return ex.underExcelData;

    case 13:
      ex.updateRowsBasedOnFilter("");
      return ex.dispatchedExcelData;
    default:
      ex.updateRowsBasedOnFilter("All");
      return ex.allExcelData;
  }
}
