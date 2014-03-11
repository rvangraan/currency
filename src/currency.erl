%%% @author Rudolph van Graan <rvg@wyemac.lan>
%%% @copyright (C) 2013, Rudolph van Graan
%%% @doc
%%%
%%% @end
%%% Created : 23 Oct 2013 by Rudolph van Graan <rvg@wyemac.lan>

-module(currency).

-export([less_than/2,
         equal/2,
         add/2,
         sub/2,
         greater_than/2,
	 from_string/1]).

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

%%================================================================================================
sub(Amount1 = #currency{},Amount2 = #currency{}) ->
    Dec1 = to_decimal(Amount1),
    Dec2 = to_decimal(Amount2),
    from_decimal(decimal:sub(Dec1,Dec2)).

sub_test_() ->
    [?_assertMatch(#currency{decimals=2,major=7,minor=50},
		   sub(
		     #currency{decimals=2,major=10,minor=0}, 
		     #currency{decimals=2,major=2,minor=50})),
     ?_assertExit(badarg,
		   sub(
		     #currency{currency=840, decimals=2,major=10,minor=0}, 
		     #currency{currency=826, decimals=2,major=2,minor=50}))
    ].

%%================================================================================================

add(Amount1 = #currency{},Amount2 = #currency{}) ->
    Dec1 = to_decimal(Amount1),
    Dec2 = to_decimal(Amount2),
    from_decimal(decimal:add(Dec1,Dec2)).

add_test_() ->
    [?_assertMatch(#currency{decimals=2,major=12,minor=50},
		   add(
		     #currency{decimals=2,major=10,minor=0},
		     #currency{decimals=2,major=2,minor=50}))].

%%================================================================================================

from_string(String) when is_list(String) ->
    N = count_decimal_points(String),
    case {valid_decimal_digits(String),N} of
	{true,0} ->
	    from_string(N,String);
	{true,1} ->
	    from_string(N,String);
	{_,_} ->
	    exit(badarg)
    end.
from_string(0,IntegerString) ->
    #currency{decimals=0,
	      major = list_to_integer(IntegerString),
	      minor = 0};
from_string(1,[$.|Decimals]) ->
    #currency{decimals=length(Decimals),
	      major = 0,
	      minor = list_to_integer(Decimals)};
from_string(1,String) when is_list(String) ->
    case string:tokens(String,".") of
	[IntegerString,FractionString] ->
	    #currency{decimals=length(FractionString),
		      major = list_to_integer(IntegerString),
		      minor = list_to_integer(FractionString)};
	[IntegerString] ->
	    #currency{decimals=0,
		      major = list_to_integer(IntegerString),
		      minor = 0}
    end.


count_decimal_points(String) when is_list(String) ->
     lists:foldl(fun($., Count) -> Count + 1;
		    (_C, Count) -> Count end, 0, 
		 String).

valid_decimal_digits(String) ->
    lists:all(fun($.) -> true;
		 (Digit) when Digit >= $0, Digit =< $9 -> true;
		 (_Any) -> false
	      end, String).



from_string_test_() ->
    [?_assertMatch(#currency{decimals=2,major=12,minor=50},
		   from_string("12.50")),
     ?_assertMatch(#currency{decimals=0,major=12,minor=0},
		   from_string("12.")),
     ?_assertMatch(#currency{decimals=0,major=12,minor=0},
		   from_string("12")),
     ?_assertMatch(#currency{decimals=1,major=12,minor=0},
		   from_string("12.0")),
     ?_assertMatch(#currency{decimals=1,major=0,minor=0},
		   from_string(".0")),
     ?_assertMatch(#currency{decimals=2,major=0,minor=10},
		   from_string(".10"))
		  ].
