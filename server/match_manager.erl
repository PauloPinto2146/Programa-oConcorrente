-module(match_manager).
-export([start/0,
		loop/1]).

start()->
	receive {start}->
		register(?MODULE,spawn(fun() -> loop(#{}) end))
	end.

loop(Map)->.