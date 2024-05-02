//+------------------------------------------------------------------+
//|                                          ProfitProtectionHandler |
//|                                         Copyright 2024, DavdCsam |
//|                                      https://github.com/davdcsam |
//+------------------------------------------------------------------+

// Include the ProfitProtection class from the ProfitProtection library
#include "ProfitProtection.mqh";

// Group of inputs for the profit protection
input group "Profit Protection";

// Boolean to check if comments should be shown
input bool input_show_profit_protection_handler_comment = true; // Show Comment

// String to store the comment for the profit protection handler
string comment_profit_protection_handler;

// Group of inputs for the break even
input group "  Break Even";

// Boolean to check if break even is active
input bool input_active_break_even = true; // Active

// Activation percent for the break even
input uchar input_break_even_activation_percent = 50; // Activation Percent

// Deviation percent from the open price for the break even
input uchar input_break_even_devation_percent_from_open_price = 0; // Deviation Percent From Open Price

// Instance of the BreakEven class
BreakEven break_even(input_break_even_activation_percent, input_break_even_devation_percent_from_open_price);

// Group of inputs for the trailing stop
input group "Trailing Stop";

// Boolean to check if trailing stop is active
input bool input_active_trailing_stop = false; // Active

// Activation percent for the trailing stop
input uchar input_trailing_stop_activation_percent = 50; // Activation Percent

// Deviation percent from the current price for the trailing stop
input uchar input_trailing_stop_devation_percent_from_current_price = 30; // Deviation Percent From Current Price

// Instance of the TrailingStop class
TrailingStop trailing_stop(input_trailing_stop_activation_percent, input_trailing_stop_devation_percent_from_current_price);

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
// Function to update the comment for the profit protection handler
void update_comment_profit_protection()
  {
   // If comments should be shown
   if(input_show_profit_protection_handler_comment)
     {
      string comment_break_even;
      string comment_trailing_stop;

      // If break even is active
      if(input_active_break_even)
         // Set the comment for the break even
         comment_break_even = StringFormat(
                                 " BreakEven: %s\n Activation Percent: %d\n Deviation Percent From Open Price: %d",
                                 input_active_break_even ? "Allowed" : "Prohibited",
                                 input_break_even_activation_percent,
                                 input_break_even_devation_percent_from_open_price
                              );
      else
         // Set the comment for the break even to an empty string
         comment_break_even = "";

      // If trailing stop is active
      if(input_active_trailing_stop)
         // Set the comment for the trailing stop
         comment_trailing_stop = StringFormat(
                                    " TrailingStop: %s\n Activation Percent: %d\n Deviation Percent From Current Price: %d",
                                    input_active_trailing_stop ? "Allowed" : "Prohibited",
                                    input_trailing_stop_activation_percent,
                                    input_trailing_stop_devation_percent_from_current_price
                                 );
      else
         // Set the comment for the trailing stop to an empty string
         comment_trailing_stop = "";

      // Set the comment for the profit protection handler
      comment_profit_protection_handler = StringFormat(
                                             "\n%s\n%s\n",
                                             comment_break_even,
                                             comment_trailing_stop
                                          );
     }
   // If comments should not be shown
   else
      // Set the comment for the profit protection handler to an empty string
      comment_profit_protection_handler = "";
  }
//+------------------------------------------------------------------+
