//+------------------------------------------------------------------+
//|                                                      LineHandler |
//|                                         Copyright 2024, DavdCsam |
//|                                      https://github.com/davdcsam |
//+------------------------------------------------------------------+

// Include the Lines class from the Lines library
#include "Lines.mqh";

// Group of inputs for the line generator
input group "Lines Generator"

// Start of the line in currency units
input double input_start_line = 10000; // Start [Currrency]

// Initial addition to the start of the line in currency units
input double input_start_add_line = 40; // Init Add [Currrency]

// End of the line in currency units
input double input_end_line= 20000; // End  [Currrency]

// Step size for the line in currency units
input double input_step_line = 100; // Step [Currrency]

// Addition to the line in currency units
input double input_add_line = 10; // Add [Currrency]

// Boolean to check if comments should be shown
input bool input_show_comment_lines_handler = true; // Show Comment

// Boolean to check if lines should be printed
input bool input_print_lines_generated = true; // Print Lines

// String to store the comment for the line handler
string comment_lines_handler;

// Instance of the Lines class
Lines lines(MathAbs(input_start_line), MathAbs(input_start_add_line), MathAbs(input_end_line), MathAbs(input_step_line), MathAbs(input_add_line));

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

// Function to generate a comment based on the result of the line check
string comment_enum_check_line(ENUM_CHECK_LINE_GENERATOR enum_result)
  {
   string result;

// Switch case to handle different types of results
   switch(enum_result)
     {
      case CHECK_ARG_LINE_GENERATOR_PASSED:
         result = StringFormat(
                     "%s: Arguments passed the check.",
                     EnumToString(enum_result)
                  );
         break;
      case ERR_NO_ENOUGH_STEP:
         result = StringFormat(
                     "%s: Step %s is bigger than diference betwen start %s and end %s.",
                     EnumToString(enum_result),
                     DoubleToString(input_step_line, _Digits),
                     DoubleToString(input_start_line, _Digits),
                     DoubleToString(input_end_line, _Digits)
                  );
         break;
      case ERR_START_OVER_END:
         result = StringFormat(
                     "%s: Start value %s is greater than end value %s.",
                     EnumToString(enum_result),
                     DoubleToString(input_start_line, _Digits),
                     DoubleToString(input_end_line, _Digits)
                  );
         break;
      case ERR_ADD_OVER_STEP:
         result = StringFormat(
                     "%s: Add value %s is greater than step value %s.",
                     EnumToString(enum_result),
                     DoubleToString(input_add_line, _Digits),
                     DoubleToString(input_step_line, _Digits)
                  );
         break;
      case ERR_PRICE_OUT_LINES:
         result = StringFormat(
                     "%s: Price %s is out inputs %s to %s",
                     EnumToString(enum_result),
                     DoubleToString(iClose(_Symbol, PERIOD_CURRENT, 0), _Digits),
                     DoubleToString(input_start_line, _Digits),
                     DoubleToString(input_end_line, _Digits)
                  );
         break;
      default:
         result = "Unknown error.";
         break;
     }

   return(result);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

// Function to update the comment for the line handler
void update_comment_lines()
  {
// If comments should be shown
   if(input_show_comment_lines_handler)
     {
      // Get the type of near lines based on the current close price
      ENUM_TYPE_NEAR_LINES type_near_lines = lines.GetNearLines(
            iClose(_Symbol, PERIOD_CURRENT, 0)
                                             );

      // Switch case to handle different types of near lines
      switch(type_near_lines)
        {
         // If the type of near lines is TYPE_BETWEN_PARALELS
         case TYPE_BETWEN_PARALELS:
            // Set the comment for the line handler to show the upper and lower buy and sell points
            comment_lines_handler = StringFormat(
                                       "\n Upper Sell %s, Upper Buy %s\n Lower Sell %s, Lower Buy %s\n",
                                       DoubleToString(lines.upper_sell, _Digits),
                                       DoubleToString(lines.upper_buy, _Digits),
                                       DoubleToString(lines.lower_sell, _Digits),
                                       DoubleToString(lines.lower_buy, _Digits)
                                    );
            break;
         // If the type of near lines is TYPE_INSIDE_PARALEL
         case TYPE_INSIDE_PARALEL:
            // Set the comment for the line handler to show the middle buy and sell points
            comment_lines_handler = StringFormat(
                                       "\n Upper Buy %s\n Upper Sell %s, Lower Buy %s\n Lower Sell %s\n",
                                       DoubleToString(lines.upper_buy, _Digits),
                                       DoubleToString(lines.upper_sell, _Digits),
                                       DoubleToString(lines.lower_buy, _Digits),
                                       DoubleToString(lines.lower_sell, _Digits)
                                    );
            break;
         // If the type of near lines is ERR_INVALID_LINES
         case ERR_INVALID_LINES:
            // Set the comment for the line handler to show an error message
            comment_lines_handler = "\n Invalid Lines \n";
            break;
        }
     }
// If comments should not be shown
   else
     {
      // Set the comment for the line handler to an empty string
      comment_lines_handler = "";
     }
  }
//+------------------------------------------------------------------+
