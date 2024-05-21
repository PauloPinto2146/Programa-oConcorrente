-module(servidor).
-export([server/0,user/2]).
-import(login_manager, [startLoginManager/0,logout/1,login/2,createAccount/2,
		closeAccount/2]).
-import(lobby_manager, [startLobbyManager/0,find_Lobby/2,cancel_find/2]).
-import(level_system, [startLevelSystem/0,win_game/1,lose_game/1,
		print_top_players/2]).
-import(game, [startGame/0]).

compile() ->
    Modules = [login_manager, lobby_manager, level_system, game, servidor],
    lists:foreach(fun(M) -> compile:file(M) end, Modules).

server() ->
	{ok, LSock} = gen_tcp:listen(8080, [binary, {packet, line}, {reuseaddr, true}]),
	compile(),
	startLoginManager(),
	startLobbyManager(),
	startLevelSystem(),
	spawn(fun()-> acceptor(LSock)end),
	receive stop -> ok end.

acceptor(LSock) ->
	{ok, Sock} = gen_tcp:accept(LSock),
	spawn(fun() -> acceptor(LSock) end),
	user(Sock,0).

user(Sock,Loggedin) ->
	receive
	{line, Data} ->
		gen_tcp:send(Sock, Data),
		%Lança para Java o Socket que tem que ser processado onde pode ter informação sobre o que quer fazer
		%O Java processa e lança novamente o Socket da função que quer fazer do Erlang
		%segundo codigos de protocolo
		user(Sock,Loggedin);
	{tcp, _, Data} when Loggedin =:= 1 ->
		case string:tokens(Data, " ") of
			%Quando está Logged in	
			["01",Username]->%Logout Protocol Code - 01
				logout(Username);	
			["03", Username, Password] -> %Close Account Protocol Code - 03
				closeAccount(Username,Password);
			["10", Username, Nivel] -> %Find Lobby Protocol Code - 10
				find_Lobby(Username,Nivel);
			["11", LobbyLevel,Player]-> %Cancel Finding Lobby Protocol Code - 11
				cancel_find(LobbyLevel,Player);
			["20",Username] -> %Win game Protocol Code - 20
				win_game(Username);
			["21",Username] -> %Lose game Protocol Code - 21
				lose_game(Username)
		end,
		user(Sock,Loggedin);
	{tcp, _, Data} when Loggedin =:= 0 ->
		case string:tokens(Data, " ") of
			["00", Username, Password] -> %Login Protocol Code - 00
           		login(Username, Password),
				user(Sock,1);	
			["02", Username, Password] -> %Register Protocol Code - 02
				createAccount(Username,Password),
				user(Sock,1)
		end;
	{tcp_closed, _} ->
		io:format("Foi-se");
	{tcp_error, _, _} ->
		io:format("Error");
	{error, Type} -> %Erros de protocolo
		case Type of 
			0 ->
				gen_tcp:send(Sock,"Tipo de erro")
		end
	end.