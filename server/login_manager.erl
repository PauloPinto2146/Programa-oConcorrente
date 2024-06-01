-module(login_manager).
-export([startLoginManager/0,
		create_account/2,
		close_account/2,
		login/2,
		logout/1,
		loop/1,
		level_up/2,
		level_down/2]).

startLoginManager() -> 
	register(?MODULE,spawn(fun() -> loop(#{"VieirinhaHardcore" => {"veiraPass",99},
										  "Piriu" => {"piriuPass",99},
										  "ZeCarlos" => {"zeCarlosPass",5},
										  "Tunico" => {"tunicoPass",2}}) end)).

level_up(Username,Level)->
	?MODULE ! {level_up,Username,Level,self()},
	receive
		{ok,?MODULE} -> {ok,created_Account};
		{invalid_Username,_} -> {"ERROR:Unvalid Username"}
	end.

level_down(Username,Level)->
	?MODULE ! {level_down,Username,Level,self()},
	receive
		{ok,?MODULE} -> {ok,created_Account};
		{invalid_Username,_} -> {"ERROR:Unvalid Username"}
	end.

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
	%Username => {Password,Nivel}
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
			end;
		{close_account,Username,Passwd,From} ->
			case maps:find(Username,Map) of
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
			end;
		{level_up,Username,Level,From}->
			case maps:find(Username,Map) of
				{ok,{Pass,_}} ->
					loop(maps:put(Username,{Pass,Level},Map)),
					From ! {ok,?MODULE};
				_ ->
					From ! {invalid_Username, ?MODULE},
					loop(Map)
			end;
		{level_down,Username,Level,From}->
		case maps:find(Username,Map) of
				{ok,{Pass,_}} ->
					loop(maps:put(Username,{Pass,Level},Map)),
					From ! {ok,?MODULE};
				_ ->
					From ! {invalid_Username, ?MODULE},
					loop(Map)
		end
	end.