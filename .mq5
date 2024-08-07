//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+

// Reference

#include "src//BooleanEnums.mqh"

#include "src//baseOnTask//TaskManager.mqh"

#include "src//detect//DetectOrders.mqh"
#include "src//detect//DetectPositions.mqh"

#include "src//filterOperativeDays//FilterByCSVFile.mqh"
#include "src//filterOperativeDays//FilterByDayWeek.mqh"

#include "src//prices//InstitutionalArithmeticPrices.mqh"
#include "src//prices//LimitsByIndex.mqh"
#include "src//prices//LimitsByTimeRange.mqh"

#include "src//profitProtection//BreakEven.mqh"
#include "src//profitProtection//TrailingStop.mqh"

#include "src//remove//RemOrderByLocationPrice.mqh"
#include "src//remove//RemOrderByType.mqh"
#include "src//remove//RemPositionByType.mqh"

#include "src//time//SectionTime.mqh"
#include "src//time//TimeHelper.mqh"
#include "src//time//TimeLapseTree.mqh"

#include "src//transaction//Transaction.mqh"

#include "test/TimeExecution.mqh"
