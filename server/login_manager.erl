-module(login_manager).
-export([startLoginManager/0,
		create_account/2,
		close_account/2,
		login/2,
		logout/1,
		online/0,
		loop/1]).

startLoginManager() -> 
	register(?MODULE,spawn(fun() -> loop(#{}) end)).
create_account(Username, Passwd) ->% ok | user_exists.
	?MODULE ! {create_account,Username,Passwd,self()}, %lança para o loop
	receive
		{Res,?MODULE} -> Res;
		{user_exists,?MODULE} -> io:format("ERROR:User_Already_Exists")
	end.
close_account(Username, Passwd) -> %ok | invalid.
	?MODULE ! {create_account,Username,Passwd,self()},
	receive
		{Res,?MODULE} -> Res;
		{invalid, ?MODULE} -> io:format("ERROR:Invalid_Username")
	end.
login(Username, Passwd) -> %ok | invalid.
	?MODULE ! {login,Username,Passwd,self()},
	receive
		{Res,?MODULE} -> Res;
		{invalid, ?MODULE} -> io:format("ERROR:Invalid_Username_for_Login")
	end.
logout(Username) -> %ok.
	?MODULE ! {login,Username,self()},
	receive
		{Res,?MODULE} -> Res end.

online() -> %[Username].
	?MODULE ! {online,self()},
	receive
		{Res,?MODULE} -> Res end.

loop(Map) ->
	receive 
		{create_account,Username,Passwd,From} ->
			case maps:is_key(Username,Map) of
				true ->
					From ! {user_exists,?MODULE},
					level_system ! {create_account,Username,Passwd},
					loop(Map);
				false ->
					From ! {ok,?MODULE},
					loop(map:put(Username,{Passwd,0},Map))
					%Password, 
					%nivel
			end;
		{close_account,Username,Passwd,From} ->
			case maps:find(Username,Map) of
				%{ok,{Pass,_}} when Pass =:= Passwd -> 
				{ok,{Passwd,_}} ->
					From ! {ok,?MODULE},
					loop(map:remove(Username,Map));
				_ ->
					From ! {invalid, ?MODULE},
					loop(Map)
			end;
		{login,Username,Passwd,From}->
			case maps:find(Username,Map) of
				{ok,{Passwd,Nivel}} ->
					From ! {ok,?MODULE},
					loop(map:update(Username,{Passwd,Nivel},Map));
				_ ->
					From ! {invalid, ?MODULE},
					loop(Map)
			end;
		{logout,Username,From}->
			case maps:find(Username,Map) of
				%{ok,{Pass,_}} when Pass =:= Passwd -> 
				{ok,{Passwd,true,On}} ->
					From ! {ok,?MODULE},
					loop(map:update(Username,{Passwd,false,On},Map));
				_ ->
					From ! {invalid, ?MODULE},
					loop(Map)
			end;
		{online, From} ->
				Fun = fun(Username,{_,true,_,_,_,_},Acc) -> 
					[Username|Acc]; 
					(_,_,Acc) -> Acc end,
                Users = maps:fold(Fun,{},Map),
                % ou apenas [User || {User,{_,true}} <- maps:to_list(Map)]
				From ! {Users,?MODULE},
			    loop(Map)
	end.