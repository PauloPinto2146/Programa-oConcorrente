-module(servidor).
-export([server/0,user/2]).
-import(login_manager, [startLoginManager/0,logout/1,login/2,create_account/2,
		close_account/2]).
-import(lobby_manager, [startLobbyManager/0,find_Lobby/2,cancel_find/2]).
-import(level_system, [startLevelSystem/0,win_game/1,lose_game/1,
		print_top_players/2]).
-import(game, [startGame/0]).

compile() ->
    Modules = [login_manager, lobby_manager, level_system, game, servidor],
    lists:foreach(fun(M) -> compile:file(M) end, Modules).

server() ->
	compile(),
	startLoginManager(),
	startLobbyManager(),
	startLevelSystem(),
	{ok, LSock} = gen_tcp:listen(8080, [binary, {active, false}]),
	spawn(fun()-> acceptor(LSock)end),
	receive stop -> ok end.

acceptor(LSock) ->
	{ok, Sock} = gen_tcp:accept(LSock),
	io:format("Utilizador conectado\n"),
	spawn(fun() -> acceptor(LSock) end),
	user(Sock,0).

user(Sock,Loggedin) ->
	inet:setopts(Sock, [{active,once}]),
	receive
	{line, Data} ->
		gen_tcp:send(Sock, Data),
		%Lança para Java o Socket que tem que ser processado onde pode ter informação sobre o que quer fazer
		%O Java processa e lança novamente o Socket da função que quer fazer do Erlang
		%segundo codigos de protocolo
		user(Sock,Loggedin);
	{tcp, _, Data} when Loggedin =:= 1 ->
		io:format("~p\n",[Data]),
		case string:split(binary_to_list(Data), " ",all) of
			%Quando está Logged in	
			["01",Username]->%Logout Protocol Code - 01
				io:format("Recebido Socket 01\n"),
				logout(Username),
				user(Sock,1);
			["03", Username, Password] -> %Close Account Protocol Code - 03
				io:format("Recebido Socket 03\n"),
				close_account(Username,Password),
				user(Sock,1);
			["10", Username, Nivel] -> %Find Lobby Protocol Code - 10
				io:format("Recebido Socket 10\n"),
				find_Lobby(Username,Nivel),
				user(Sock,1);
			["11", LobbyLevel,Player]-> %Cancel Finding Lobby Protocol Code - 11
				io:format("Recebido Socket 11\n"),
				cancel_find(LobbyLevel,Player),
				user(Sock,1);
			["20",Username] -> %Win game Protocol Code - 20
			io:format("Recebido Socket 20\n"),
				win_game(Username),
				user(Sock,1);
			["21",Username] -> %Lose game Protocol Code - 21
				io:format("Recebido Socket 21\n"),
				lose_game(Username),
				user(Sock,1)
		end,
		user(Sock,Loggedin);
	{tcp, _, Data} when Loggedin =:= 0 ->
		io:format("~p\n",[Data]),
		case string:split(binary_to_list(Data), " ",all) of
			["00", Username, Password] -> %Login Protocol Code - 00
				io:format("Recebido Socket 00\n"),
           		login(Username, Password),
				user(Sock,1);	
			["02", Username, Password] -> %Register Protocol Code - 02
				io:format("Username:~p\n",[Username]),
				io:format("Password:~p\n",[Password]),
				io:format("Recebido Socket 02\n"),
				create_account(Username,Password),
				user(Sock,1)
		end;
	{tcp_closed, _} ->
		io:format("Foi-se\n");
	{tcp_error, _, _} ->
		io:format("Error\n");
	{error, Type} -> %Erros de protocolo
		case Type of 
			0 ->
				gen_tcp:send(Sock,"Tipo de erro")
		end
	end.