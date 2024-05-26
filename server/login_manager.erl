-module(login_manager).
-export([startLoginManager/0,
		create_account/2,
		close_account/2,
		login/2,
		logout/1,
		loop/1]).

startLoginManager() -> 
	register(?MODULE,spawn(fun() -> loop(#{}) end)).

create_account(Username, Passwd) ->% ok | user_exists.
	?MODULE ! {create_account,Username,Passwd,self()},
	receive
		{ok,?MODULE} -> {ok,created_Account};
		{user_exists,_} -> {"ERROR:User_Already_Exists"}
	end.
close_account(Username, Passwd) -> %ok | invalid.
	?MODULE ! {create_account,Username,Passwd,self()},
	receive
		{ok,?MODULE} -> {ok,closed_account};
		{invalid, ?MODULE} -> {"ERROR:Invalid_Username"}
	end.
login(Username, Passwd) -> %ok | invalid.
	?MODULE ! {login,Username,Passwd,self()},
	receive
		{ok,?MODULE} -> {ok,login};
		{invalid, ?MODULE} -> {"ERROR:Invalid_Username_for_Login"}
	end.
logout(Username) -> %ok.
	?MODULE ! {logout,Username,self()},
	receive
		{ok,_} -> 
			{ok,logout};
		{invalid_Username,_} -> 
			{"invalid_Username"}
	end.

loop(Map) ->
	receive 
		{create_account,Username,Passwd,From} ->
			case maps:is_key(Username,Map) of
				true ->
					From ! {user_exists,?MODULE},
					loop(Map);
				false ->
					From ! {ok,?MODULE},
					level_system ! {new_player,Username,?MODULE},
					loop(maps:put(Username,{Passwd,1},Map))
					%Password, 
					%nivel
			end;
		{close_account,Username,Passwd,From} ->
			case maps:find(Username,Map) of
				%{ok,{Pass,_}} when Pass =:= Passwd -> 
				{ok,{Passwd,_}} ->
					From ! {ok,?MODULE},
					loop(maps:remove(Username,Map));
				_ ->
					From ! {invalid, ?MODULE},
					loop(Map)
			end;
		{login,Username,Passwd,From}->
			case maps:find(Username,Map) of
				{ok,{Passwd,Nivel}} ->
					From ! {ok,?MODULE},
					loop(maps:update(Username,{Passwd,Nivel},Map));
				_ ->
					From ! {invalid, ?MODULE},
					loop(Map)
			end;
		{logout,Username,From}->
			case maps:find(Username,Map) of
				{ok,{_,_}} ->
					From ! {ok,?MODULE},
					loop(Map);
				_ ->
					From ! {invalid_Username, ?MODULE},
					loop(Map)
			end
	end.