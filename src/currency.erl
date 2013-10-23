%%% @author Rudolph van Graan <rvg@wyemac.lan>
%%% @copyright (C) 2013, Rudolph van Graan
%%% @doc
%%%
%%% @end
%%% Created : 23 Oct 2013 by Rudolph van Graan <rvg@wyemac.lan>

-module(currency).

-include("../include/currency.hrl").
-include_lib("decimal/include/decimal.hrl").
-include_lib("eunit/include/eunit.hrl").

%%================================================================================================

less_than(Amount1 = #currency{},Amount2 = #currency{}) ->
    Dec1 = to_decimal(Amount1),
    Dec2 = to_decimal(Amount2),
    decimal:less_than(Dec1,Dec2).

less_than_test_() ->
    [?_assertMatch(true,
		   less_than(
		     #currency{decimals=2,major=1,minor=1},
		     #currency{decimals=2,major=1,minor=2})),
     ?_assertThrow(incompatible_units,
		   less_than(
		     #currency{currency=1,decimals=2,major=1,minor=1},
		     #currency{currency=2,decimals=2,major=1,minor=0}))
     ].


%%================================================================================================
	
greater_than(Amount1 = #currency{},Amount2 = #currency{}) ->
    Dec1 = to_decimal(Amount1),
    Dec2 = to_decimal(Amount2),
    decimal:greater_than(Dec1,Dec2).

greater_than_test_() ->
    [?_assertMatch(true,
		   greater_than(
		     #currency{decimals=2,major=1,minor=1},
		     #currency{decimals=2,major=1,minor=0})),
     ?_assertThrow(incompatible_units,
		   greater_than(
		     #currency{currency=1,decimals=2,major=1,minor=1},
		     #currency{currency=2,decimals=2,major=1,minor=0}))
     ].


%%================================================================================================

equal(Amount1 = #currency{currency=CurrencyNum},Amount2 = #currency{currency=CurrencyNum}) ->
    Dec1 = to_decimal(Amount1),
    Dec2 = to_decimal(Amount2),
    decimal:equal(Dec1,Dec2);
equal(_Amount1,_Amount2) ->
    false.


equal_test_() ->
    [?_assertMatch(true,
		   equal(
		     #currency{decimals=2,major=1,minor=0},
		     #currency{decimals=2,major=1,minor=0})),
     ?_assertMatch(true,
		   equal(
		     #currency{decimals=1,major=1,minor=1},
		     #currency{decimals=2,major=1,minor=10})),
     ?_assertMatch(false,
		   equal(
		     #currency{currency=710,decimals=1,major=1,minor=1},
		     #currency{currency=711,decimals=2,major=1,minor=10}))
    
    ].

%%================================================================================================

to_decimal(#currency{currency=CurrencyNum,
		     decimals=Decimals,
		     major   = Major,
		     minor   = Minor}) ->
    #decimal{unit      = {currency,CurrencyNum},
	     scale     = Decimals,
	     value     = Major,
	     fraction  = Minor}.

to_decimal_test_() ->
    [?_assertMatch(#decimal{unit = {currency,999},
			    value = 0,
			    scale = 0,
			    fraction = 0},
		   to_decimal(#currency{decimals=0,major=0,minor=0}))
    ].


%%================================================================================================


from_decimal(#decimal{unit = {currency,CurrencyNum},
		      value = Value,
		      scale = Scale,
		      fraction = Fraction}) ->
    #currency{currency = CurrencyNum,
	      decimals = Scale,
	      major    = Value,
	      minor    = Fraction};
from_decimal(#decimal{}) ->
    throw(badarg).



%%================================================================================================


from_decimal_test_() ->
    [
     ?_assertThrow(badarg,from_decimal(#decimal{unit=scale,scale=2,value=1,fraction=0})),
     ?_assertMatch(#currency{currency=123,decimals=2,major=1,minor=0},
		   from_decimal(#decimal{unit={currency,123},scale=2,value=1,fraction=0}))
    ].
