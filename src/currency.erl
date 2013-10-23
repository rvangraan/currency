%%% @author Rudolph van Graan <rvg@wyemac.lan>
%%% @copyright (C) 2013, Rudolph van Graan
%%% @doc
%%%
%%% @end
%%% Created : 23 Oct 2013 by Rudolph van Graan <rvg@wyemac.lan>

-module(currency).

-include_lib("currency/include/currency.hrl").
-include_lib("decimal/include/decimal.hrl").
-include_lib("eunit/include/eunit.hrl").

%%================================================================================================

less_than(Amount1 = #currency{currency=CurrencyNum},Amount2 = #currency{currency=CurrencyNum}) ->
    Dec1 = to_decimal(Amount1),
    Dec2 = to_decimal(Amount2),
    decimal:less_than(Dec1,Dec2).

%%================================================================================================
	
greater_than(Amount1 = #currency{currency=CurrencyNum},Amount2 = #currency{currency=CurrencyNum}) ->
    Dec1 = to_decimal(Amount1),
    Dec2 = to_decimal(Amount2),
    decimal:greater_than(Dec1,Dec2).
	
%%================================================================================================

equal(Amount1 = #currency{currency=CurrencyNum},Amount2 = #currency{currency=CurrencyNum}) ->
    decimal:equal(Dec1,Dec2).
    
%%================================================================================================

to_decimal(#currency{currency=CurrencyNum,
		     decimals=Decimals,
		     major   = Major,
		     minor   = Minor}) ->
    #decimal{unit      = {currency,CurrencyNum},
	     decimals  = Decimals,
	     magnitude = Major,
	     fraction  = Minor}.
