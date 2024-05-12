//+------------------------------------------------------------------+
//|                                                       Remove.mqh |
//|                                         Copyright 2023, davdcsam |
//|                                      https://github.com/davdcsam |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, davdcsam"
#property link      "https://github.com/davdcsam"
#property version   "1.00"

#include <Arrays/ArrayLong.mqh>
#include <Trade/Trade.mqh>
#include "..//detect//DetectOrders.mqh";
#include "..//detect//DetectPositions.mqh";

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
// Class to handle removal of orders and positions
class Remove
  {
private:
   // Trade object
   CTrade            trade;

   // Arrays to store order tickets
   CArrayLong        buy_order_tickets;
   CArrayLong        sell_order_tickets;

   // DetectOrders and DetectPositions objects
   DetectOrders      detect_orders;
   DetectPositions   detect_positions;

   // Variables to store magic number, symbol, and internal flag
   ulong             magic;
   string            symbol;
   bool              internal_flag_buy; // Use to disable the VerifyPositionAndRemoveOppositeArray method
   bool              internal_flag_sell; // Use to disable VerifyPositionAndRemoveOppositeArray method


   // Function to remove orders from an array
   bool              RemoveOrdersFromCArray(CArrayLong& orders_to_delete)
     {
      bool result = true;
      for(int i=0; i < orders_to_delete.Total(); i++)
        {
         if(!detect_orders.IsValidOrder(orders_to_delete.At(i)))
            continue;

         if(!trade.OrderDelete(orders_to_delete.At(i)))
            result = false;
        }
      return(result);
     }

   // Function to remove positions from an array
   bool              RemovePositionsFromCArray(CArrayLong& positions_to_delete)
     {
      bool result = true;
      for(int i=0; i < positions_to_delete.Total(); i++)
        {
         if(!detect_positions.IsValidPosition(positions_to_delete.At(i)))
            continue;

         if(!trade.PositionClose(positions_to_delete.At(i)))
            result = false;
        }
      return(result);
     }

public:
   // Constructor for the Remove class
                     Remove() {}

   // Function to update attributes for DetectOrders and DetectPositions objects
   void              UpdateAtrToDetect(ulong magic_arg, string symbol_arg)
     {
      detect_orders.UpdateAtr(symbol_arg, magic_arg);
      detect_positions.UpdateAtr(symbol_arg, magic_arg);
     }

   // Function to update attributes
   void              UpdateAtr(ulong magic_arg, string symbol_arg)
     {
      magic = magic_arg;
      symbol = symbol_arg;
      UpdateAtrToDetect(magic_arg, symbol_arg);
     }

   // Function to update orders
   void              UpdateOrders()
     {
      // Shutdown the order tickets arrays
      detect_orders.order_tickets.Shutdown();
      buy_order_tickets.Shutdown();
      sell_order_tickets.Shutdown();

      // Loop through each order
      for(int i=0; i < OrdersTotal(); i++)
        {
         // Get the ticket for the order
         ulong ticket = OrderGetTicket(i);

         // If the order is not valid, continue to the next order
         if(!detect_orders.IsValidOrder(ticket))
            continue;

         // Add the ticket to the order tickets array
         detect_orders.order_tickets.Add(ticket);

         // Filter the orders to buys and sells
         switch((int)OrderGetInteger(ORDER_TYPE))
           {
            case ORDER_TYPE_BUY_STOP:
               buy_order_tickets.Add(ticket);
               break;
            case ORDER_TYPE_SELL_LIMIT:
               sell_order_tickets.Add(ticket);
               break;
            case ORDER_TYPE_BUY_LIMIT:
               buy_order_tickets.Add(ticket);
               break;
            case ORDER_TYPE_SELL_STOP:
               sell_order_tickets.Add(ticket);
               break;
           }

         // Set the internal flag to true
         internal_flag_buy = true;
         internal_flag_sell = true;
        }
     }

   // Function to verify position and remove the same extra orders type
   void              VerifyPositionAndRemoveByOrderType()
     {
      // If the internal flags is not set, return
      if(!internal_flag_buy && !internal_flag_sell)
         return;

      // Loop through each position
      for(int i = 0; i < PositionsTotal(); i++)
        {
         // Get the ticket for the position
         ulong ticket = PositionGetTicket(i);

         // If the position is not valid, continue to the next position
         if(!detect_positions.IsValidPosition(ticket))
            continue;

         // If the ticket is not found in the sell order tickets, remove its tickets
         if(sell_order_tickets.SearchLinear(ticket) != -1)
           {
            UpdateOrders();

            // Print that the position was found in the sell order tickets
            PrintFormat("Position %d found in sell_order_tickets.", ticket);

            // If the orders are removed from the sell order tickets, print that they were removed
            if(RemoveOrdersFromCArray(sell_order_tickets))
               PrintFormat("Removed orders in sell_order_tickets.", ticket);
            else
               // If the orders are not removed, print that the removal failed
               PrintFormat("Failed removing orders in sell_order_tickers. Err: ", GetLastError());

            // Set the internal flag to false
            internal_flag_sell = false;
           }

         // If the ticket is not found in the buy order tickets, remove its tickets
         if(buy_order_tickets.SearchLinear(ticket) != -1)
           {
            UpdateOrders();

            // Print that the position was found in the buy order tickets
            PrintFormat("Position %d found in buy_order_tickets.", ticket);

            // If the orders are removed from the buy order tickets, print that they were removed
            if(RemoveOrdersFromCArray(buy_order_tickets))
               PrintFormat("Removed orders in buy_order_tickets.", ticket);
            else
               // If the orders are not removed, print that the removal failed
               PrintFormat("Failed removing orders in buy_order_tickets. Err: ", GetLastError());

            // Set the internal flag to false
            internal_flag_buy = false;
           }
        }
     }

   // Function to remove pending orders
   void              RemovePendingOrders()
     {
      // If there are no orders, return
      if(!OrdersTotal())
         return;

      // Update the orders
      detect_orders.UpdateOrders();

      // Remove the orders from the array
      RemoveOrdersFromCArray(detect_orders.order_tickets);
     }

   // Function to remove positions
   void              RemovePositions()
     {
      // If there are no positions, return
      if(!PositionsTotal())
         return;

      // Update the positions
      detect_positions.UpdatePositions();

      // Remove the positions from the array
      RemovePositionsFromCArray(detect_positions.positions_tickets);
     }

  };
//+------------------------------------------------------------------+
