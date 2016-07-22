//+------------------------------------------------------------------+ 
//| EA+EA.mq4 | //| Evgen_cv | //| Evgen_cv@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Evgen_cv"
#property link "evgen_cv@mail.ru"

//--- imput parameters
extern int periodLong      = 169.0;
extern int periodShot      = 144.0;
extern int Tral_Stop       = 15; 
extern int Tral_Step       = 1;
extern int Magic           = 123;
extern int Slippage        = 5;
extern int MustPointMA     = 2000;
static datetime prevtime   = 0;
int    digits;
double SL;


//+------------------------------------------------------------------+ 
//| expert initialization function | 
//+------------------------------------------------------------------+ 
int init()
  {
   digits   = MarketInfo( Symbol(), MODE_DIGITS);
   //_Point    = MarketInfo(Symbol(), MODE_Point);
   if(Digits == 3 || Digits == 5)
     {
     Tral_Step *= 10;
     Tral_Stop *= 10; 
     Slippage  *= 10;
     }
   return(0);
  }
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }
//+------------------------------------------------------------------+
//int CountBuy()
//   {
//   int count =0;
//   for(int i=OrdersTotal()-1;i>=0;i--)
//     {
//      if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
//      {
//      if(OrderSymbol() == Symbol() && OrderMagicNumber()==Magic && OrderType() == OP_BUY )
//        {
//        count +=1; 
//        }
//      }
//     }
//   return(count);
//   }  
//+------------------------------------------------------------------+
//int CountSell()
//   {
//   int count =0;
//   for(int i=OrdersTotal()-1;i>=0;i--)
//     {
//      if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
//      {
//      if(OrderSymbol() == Symbol() && OrderMagicNumber()==Magic && OrderType() == OP_SELL )
//        {
//        count +=1; 
//        }
//      }
//     }
//   return(count);
//   } 
//+------------------------------------------------------------------+
//void TStop()
//   { 
//   if(CountBuy()+CountSell == 0)
//     {
//      return;
//     }
//   }
//+------------------------------------------------------------------+
void Tralling()
   {
   bool checkModyfy = False;
   string info ="";
   for(int i=0; i < OrdersTotal(); i++)
     {
      if(OrderSelect(i, SELECT_BY_POS,MODE_TRADES))
        {
        //Print(OrderType());
         if(OrderSymbol() == Symbol())
           {
            if(OrderType() == OP_BUY)
              {
              if(Bid>OrderOpenPrice()+Tral_Stop*_Point)
                {
                SL = NormalizeDouble(Bid - Tral_Stop*_Point,Digits);
                if(OrderStopLoss() < NormalizeDouble(Bid-(Tral_Stop+Tral_Step)*_Point,Digits))
                checkModyfy = OrderModify(OrderTicket(),OrderOpenPrice(),SL,0,0);
                }
              }
            if(OrderType() == OP_SELL)
              {
              if(Ask<OrderOpenPrice()-Tral_Stop*_Point)
               { 
               SL = NormalizeDouble(Ask+Tral_Stop*_Point,Digits);
               Print("Sl- "+SL+"  OrderStopLoss()-"+OrderStopLoss());
               if (NormalizeDouble(Ask+(Tral_Stop+Tral_Step)*_Point,Digits) < OrderStopLoss() || OrderStopLoss()==0 )
               
               checkModyfy = OrderModify(OrderTicket(),OrderOpenPrice(),SL,0,0);
               }
              }
              info = string(OrderMagicNumber())+ " "+ DoubleToStr(OrderProfit(),2) + "\n"+ info; 
           }
        } 
     }
     Comment(info);
   }
//+------------------------------------------------------------------+   
void Info()
  {
   WindowRedraw();
  }   
//+------------------------------------------------------------------+
int CreateOrder(string arr = "")
  { 
   int ticket  ;
   double price,stoploss,takeprofit;   
   string comment=""; 
   double minstoplevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
//--- размещаем рыночный ордер на покупку 1 лота
   if (arr == "sell")
      {
         price=Bid;
         stoploss=NormalizeDouble(Ask+(Tral_Stop)*_Point,Digits);
         takeprofit=NormalizeDouble(Ask-(minstoplevel+Tral_Stop)*_Point,Digits);
         ticket=OrderSend(Symbol(),OP_SELL,1,price,Slippage,0,0,comment,0,0,clrGreen);
      }
   if(arr == "buy")
     {
         price=Ask;
         stoploss=NormalizeDouble(Bid-(Tral_Stop)*_Point,Digits);
         takeprofit=NormalizeDouble(Bid+(minstoplevel+Tral_Stop)*_Point,Digits);
         ticket=OrderSend(Symbol(),OP_BUY,1,price,Slippage,0,0,comment,0,0,clrRed);
     }
   if(ticket<0)
     {
      Print("OrderSend завершилась с ошибкой #",GetLastError());
     }
   else
      Print("Функция OrderSend успешно выполнена");
 return(ticket);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   double shortEma,longEma;
   double minMa,maxMa;
   double priceClose,priceOpen;

   Tralling();
   if(Time[0] == prevtime)   return(0);      //ждем нового бара
   prevtime = Time[0]; 
   //если появился новый бар , включаемся
   Info();

   shortEma    = iMA(NULL,0,periodShot,0,MODE_EMA,PRICE_OPEN,0);
   longEma     = iMA(NULL,0,periodLong,0,MODE_EMA,PRICE_OPEN,0);
   priceClose  = Close[1];
   priceOpen   = Open[1];  
   minMa       = MathAbs((priceClose - MathMin(shortEma,longEma))/_Point);
   maxMa       = MathAbs((MathMax(shortEma,longEma)-priceClose)/_Point);


                     
   if(priceOpen>shortEma && priceOpen>longEma && shortEma>priceClose && longEma>priceClose && minMa <= MustPointMA)
       {
       //CreateOrder("sell");      
       }
   if(priceClose>shortEma && priceClose>longEma && shortEma>priceOpen && longEma>priceOpen && maxMa <=MustPointMA)
       {
       //CreateOrder("buy");
       }

   return(0);
  }
  
  
  
  
  
  
//+------------------------------------------------------------------+
