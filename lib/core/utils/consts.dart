final holdFilters = ['All', 'Hold', 'Un-Hold'];
final reportsFilters = [
  'All',
  'Hold',
  'Under-Prep',
  'Under-Assemp',
  'Under-Weld',
  'Under-Visual',
  'Production-Done',
  'Production-Remaining',
  'Under-Follow-Up',
  'Under-Painting',
  'Under-Galva',
  'Dispatch-Yard',
  'Dispatched',
];
productionFilter(String title, bool isDispatch) => [
      'All',
      isDispatch ? 'Dispatch-Yard' : 'Under-$title',
      'Hold',
      isDispatch ? 'Dispatched' : 'Done'
    ];
