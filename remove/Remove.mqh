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
protected:
   // Trade object
   CTrade            trade;

   // DetectOrders and Detect Positions objects
   DetectOrders      detectOrders;
   DetectPositions   detectPositions;

   // Variables to store magic number, symbol
   ulong             magic;
   string            symbol;

   // Function to remove orders from an array
   bool              RemoveOrdersFromCArray(CArrayLong& orders_to_delete)
     {
      bool result = true;
      for(int i=0; i < orders_to_delete.Total(); i++)
        {
         if(!detectOrders.IsValidOrder(orders_to_delete.At(i)))
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
         if(!detectPositions.IsValidPosition(positions_to_delete.At(i)))
            continue;

         if(!trade.PositionClose(positions_to_delete.At(i)))
            result = false;
        }
      return(result);
     }

   // Function to update attributes for DetectOrders and DetectPositions objects
   void              UpdateAtrToDetect(ulong magic_arg, string symbol_arg)
     {
      detectOrders.UpdateAtr(symbol_arg, magic_arg);
      detectPositions.UpdateAtr(symbol_arg, magic_arg);
     }

public:
   // Constructor for the Remove class
                     Remove() {}

   // Function to update attributes
   void              UpdateAtr(ulong magic_arg, string symbol_arg)
     {
      magic = magic_arg;
      symbol = symbol_arg;
      UpdateAtrToDetect(magic_arg, symbol_arg);
     }

   // Function to remove pending orders
   void              RemovePendingOrders()
     {
      // If there are no orders, return
      if(!OrdersTotal())
         return;

      // Update the orders
      detectOrders.UpdateOrders();

      // Remove the orders from the array
      RemoveOrdersFromCArray(detectOrders.orderTickets);
     }

   // Function to remove positions
   void              RemovePositions()
     {
      // If there are no positions, return
      if(!PositionsTotal())
         return;

      // Update the positions
      detectPositions.UpdatePositions();

      // Remove the positions from the array
      RemovePositionsFromCArray(detectPositions.positionsTickets);
     }

  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class RemoveByOrderType : public Remove
  {
public:
   enum ENUM_MODES
     {
      MODE_REMOVE_SAME_TYPE, // Remove the same type
      MODE_REMOVE_OPPOSITE_TYPE//
     };
private:
   // Use to disable VerifyPositionAndRemoveOppositeArray method
   bool              internal_flag_buy;
   bool              internal_flag_sell;
   ENUM_MODES        mode;

protected:
   void              ProcessOrder(ulong &ticket)
     {
      if(sell_order_tickets.SearchLinear(ticket) != -1)
        {
         if(mode == MODE_REMOVE_SAME_TYPE)
           {
            HandleOrder(ticket, "sell_order_tickets", sell_order_tickets, buy_order_tickets);
            internal_flag_sell = false;
            return;
           }

         HandleOrder(ticket, "buy_order_tickets", sell_order_tickets, buy_order_tickets);
         internal_flag_sell = false;
        }

      if(buy_order_tickets.SearchLinear(ticket) != -1)
        {
         if(mode == MODE_REMOVE_SAME_TYPE)
           {
            HandleOrder(ticket, "buy_order_tickets", buy_order_tickets, sell_order_tickets);
            internal_flag_buy = false;
            return;
           }

         HandleOrder(ticket, "sell_order_tickets", buy_order_tickets, sell_order_tickets);
         internal_flag_sell = false;
        }
     }

   void              HandleOrder(ulong ticket, string orderType, CArrayLong &primaryTickets, CArrayLong &secondaryTickets)
     {
      UpdateOrders();

      if(!RemoveOrdersFromCArray(mode == MODE_REMOVE_SAME_TYPE ? primaryTickets : secondaryTickets))
        {
         PrintFormat("Failed removing orders in %s. Err: %d", GetLastError(), orderType);
         return;
        }

      PrintFormat("Removed orders in %s.", orderType);
     }

public:
                     RemoveByOrderType(ENUM_MODES mode_arg = NULL): Remove()
     {
      mode = mode_arg == NULL ? MODE_REMOVE_SAME_TYPE : mode_arg;
     };

   // Arrays to store order tickets
   CArrayLong        buy_order_tickets;
   CArrayLong        sell_order_tickets;

   // Function to update orders by order type
   void              UpdateOrders()
     {
      // Shutdown the order tickets arrays
      detectOrders.orderTickets.Shutdown();
      buy_order_tickets.Shutdown();
      sell_order_tickets.Shutdown();

      int orders_total = OrdersTotal();
      if(!orders_total)
        {
         return;
        }


      // Loop through each order
      for(int i=0; i < orders_total; i++)
        {
         // Get the ticket for the order
         ulong ticket = OrderGetTicket(i);

         // If the order is not valid, continue to the next order
         if(!detectOrders.IsValidOrder(ticket))
            continue;

         // Add the ticket to the order tickets array
         detectOrders.orderTickets.Add(ticket);

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
   void              VerifyPositionAndRemove()
     {
      // If neither internal flag is set, return early
      if(!internal_flag_buy && !internal_flag_sell)
         return;

      int positions_total = PositionsTotal();
      if(positions_total == 0)
         return;

      // Loop through each position
      for(int i = 0; i < positions_total; i++)
        {
         ulong ticket = PositionGetTicket(i);

         // If the position is not valid, continue to the next position
         if(!detectPositions.IsValidPosition(ticket))
            continue;

         ProcessOrder(ticket);
        }
     }
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class RemoveByLocationPrice : public Remove
  {
private:
   // Arrays to store order tickets
   CArrayLong        upper_order_tickets;
   CArrayLong        lower_order_tickets;

   // Variable to store middle value
   double            middle;

   // Use to activate VerifyPositionAndRemoveOppositeArray method
   bool              internal_flag;
public:
                     RemoveByLocationPrice(void) : Remove() {};

   // Function to update attributes
   void              UpdateAtr(double upper_line_arg, double lower_line_arg, ulong magic_arg, string symbol_arg)
     {
      middle = (upper_line_arg + lower_line_arg) / 2;
      magic = magic_arg;
      symbol = symbol_arg;
      UpdateAtrToDetect(magic_arg, symbol_arg);
     }

   // Function to update orders
   void              UpdateOrders()
     {
      // Shutdown the order tickets arrays
      detectOrders.orderTickets.Shutdown();
      upper_order_tickets.Shutdown();
      lower_order_tickets.Shutdown();

      int orders_total = OrdersTotal();
      if(!orders_total)
        {
         return;
        }

      // Loop through each order
      for(int i=0; i < orders_total; i++)
        {
         // Get the ticket for the order
         ulong ticket = OrderGetTicket(i);

         // If the order is not valid, continue to the next order
         if(!detectOrders.IsValidOrder(ticket))
            continue;

         // Add the ticket to the order tickets array
         detectOrders.orderTickets.Add(ticket);

         // If the open price of the order is greater than the middle value, add the ticket to the upper order tickets array
         // Otherwise, add the ticket to the lower order tickets array
         if(OrderGetDouble(ORDER_PRICE_OPEN) > middle)
            upper_order_tickets.Add(ticket);
         else
            lower_order_tickets.Add(ticket);

         // Set the internal flag to true
         internal_flag = true;
        }
     }

   // Function to verify position and remove opposite array
   void              VerifyPositionAndRemove()
     {
      // If the internal flag is not set, return
      if(!internal_flag)
         return;

      int positions_total = PositionsTotal();
      if(!positions_total)
        {
         return;
        }

      // Loop through each position
      for(int i = 0; i < positions_total; i++)
        {
         // Get the ticket for the position
         ulong ticket = PositionGetTicket(i);

         // If the position is not valid, continue to the next position
         if(!detectPositions.IsValidPosition(ticket))
            continue;

         // If the ticket is found in the upper order tickets
         if(upper_order_tickets.SearchLinear(ticket) != -1)
           {
            // If the orders are removed from the lower order tickets, print that they were removed
            if(RemoveOrdersFromCArray(lower_order_tickets))
               PrintFormat("Removed orders in lower_order_tickets.", ticket);
            else
               // If the orders are not removed, print that the removal failed
               PrintFormat("Failed removing orders in lower_order_tickers. Err: ", GetLastError());

            // Set the internal flag to false
            internal_flag = false;
           }

         // If the ticket is found in the lower order tickets
         if(lower_order_tickets.SearchLinear(ticket) != -1)
           {
            // If the orders are removed from the upper order tickets, print that they were removed
            if(RemoveOrdersFromCArray(upper_order_tickets))
               PrintFormat("Removed orders in upper_order_tickets.", ticket);
            else
               // If the orders are not removed, print that the removal failed
               PrintFormat("Failed removing orders in upper_order_tickets. Err: ", GetLastError());

            // Set the internal flag to false
            internal_flag = false;
           }
        }
     }
  };

//+------------------------------------------------------------------+
