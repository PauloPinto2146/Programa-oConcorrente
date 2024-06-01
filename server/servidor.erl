-module(servidor).
-export([start/0,user/4,is_substring/2]).
-import(login_manager, [startLoginManager/0,logout/1,login/2,create_account/2,
		close_account/2]).
-import(lobby_manager, [startLobbyManager/0,find_Lobby/3,cancel_find/2]).
-import(level_system, [startLevelSystem/0,win_game/1,lose_game/1,get_level/1,top10/0,
		print_top_players/2]).
-import(game, [startGame/1]).
-import(jogador,[startJogador/0]).

compile() ->
    Modules = [login_manager, lobby_manager, level_system, game, servidor,jogador],
    lists:foreach(fun(M) -> compile:file(M) end, Modules).

is_substring(SubStr, Str) when is_list(SubStr), is_list(Str) ->
	SubStr == Str orelse is_substring_rec(SubStr, Str).
	
is_substring_rec(_, []) ->
	false;
is_substring_rec(SubStr, Str) ->
	case lists:prefix(SubStr, Str) of
		true -> true;
		false -> is_substring_rec(SubStr, tl(Str))
	end.

start() ->
	register(servidor,self()),
	compile(),
	io:format("Compiled\n"),
	startLoginManager(),
	io:format("Started Login Manager\n"),
	startLobbyManager(),
	io:format("Started Lobby Manager\n"),
	startLevelSystem(),
	io:format("Started Level System\n"),
	{ok, LSock} = gen_tcp:listen(8080, [binary, {active, false}]),
	spawn(fun()-> acceptor(LSock)end),
	receive stop -> ok end.

acceptor(LSock) ->
	{ok, Sock} = gen_tcp:accept(LSock),
	io:format("Utilizador conectado\n"),
	spawn(fun() -> acceptor(LSock) end),
	user(Sock,0,null,null).

user(Sock,Mode,PidJogador,PidPartida) ->
	%Mode : 0 - Not Logged in // 1 - Logged in // 2 - Gaming
	inet:setopts(Sock, [{active,once}]),
	receive
	{partida_pid,NewPidPartida, NewPidJogador}->
		user(Sock,2,NewPidJogador,NewPidPartida);
	{lose_game_server,Username,_Socket}->  %Lose game Protocol Code - 21
		io:format("vou entrar no lose game\n"),
		case lose_game(Username) of
			{level_down} ->
				io:format("Leveled down\n"),
				NewLevel = get_level(Username),
				Str = io_lib:format("new_level, ~p", NewLevel),
				gen_tcp:send(Sock,Str);
			{ok} ->
				io:format("ok\n"),
				ok;
			{invalid}->
				io:format("Invalid\n"),
				gen_tcp:send(Sock,"Error"),
				io:format("ERROR dropping level\n")
		end,
		io:format("vou lancar sock lost\n"),
		gen_tcp:send(Sock,"lost"),
		io:format("Lancado Socket lost ao socket ~p\n",[Sock]),
		user(Sock,1,null,null);
	{line, Data} ->
		gen_tcp:send(Sock, Data),
		user(Sock,Mode,null,null);
	{tcp, _, Data} when Mode =:= 2 ->
		%Quando está a jogar
		DataString = binary_to_list(Data),
		case is_substring("30", DataString) of 
			true -> 
				PidJogador ! purp_esquerdo_pressionado;
			_ -> 
				ok
		end,
		case is_substring("31", DataString) of
			true -> 
				PidJogador ! purp_direito_pressionado;
			_ -> 
				ok
		end,
		case is_substring("32", DataString) of
			true -> 
				PidJogador ! purp_central_pressionado;
			_->
				ok
		end,
		case is_substring("40", DataString) of
			true -> 
				PidJogador ! purp_esquerdo_despressionado;
			_->
				ok
		end,
		case is_substring("41", DataString) of
			true -> 
				PidJogador ! purp_direito_despressionado;
			_->
				ok
		end,
		case is_substring("42", DataString) of
			true -> 
				PidJogador ! purp_central_despressionado;
			_->
				ok
		end,
		user(Sock,2,PidJogador,PidPartida);
	{tcp, _, Data} when Mode =:= 1 ->
		case string:split(binary_to_list(Data), " ",all) of
			["30"]->
				user(Sock,1,null,null);
			["31"]->
				user(Sock,1,null,null);
			["32"]->
				user(Sock,1,null,null);
			["40"]->
				user(Sock,1,null,null);
			["41"]->
				user(Sock,1,null,null);
			["42"]->
				user(Sock,1,null,null);
			%Quando está Logged in	
			["00", _, _] -> %Login Protocol Error Code - 00
				io:format("Sent Login Failure"),
				gen_tcp:send(Sock,"Error 00"),
				user(Sock,0,null,null);
			["02", _, _] -> %Register Protocol Error Code - 02
				io:format("Sent CreateAccount Failure"),
				gen_tcp:send(Sock,"Error 01"),
				user(Sock,0,null,null);
			["01",Username]->%Logout Protocol Code - 01
				io:format("Recebido Socket 01\n"),
				case logout(Username) of
					{ok,_}->
						gen_tcp:send(Sock,"logged_out"),
						io:format("~p logged out\n",[Username]),
						user(Sock,0,null,null);
					{"invalid_Username",_}->
						gen_tcp:send(Sock,"ERROR:01"),
						io:format("Invalid Username"),
						user(Sock,0,null,null)
				end;
			["03", Username, Password] -> %Close Account Protocol Code - 03
				io:format("Recebido Socket 03\n"),
				case close_account(Username,Password) of
					{ok,closed_account} ->
						gen_tcp:send(Sock,"closed_account"),
						io:format("Sent closed_account Sucess\n"),
						user(Sock,0,null,null);
					{"ERROR:Invalid_Username"} ->
						gen_tcp:send(Sock,"Error 02"),
						io:format("Sent closed_account Failure\n"),
						user(Sock,1,null,null)
				end;
			["10", Username] -> %Find Lobby Protocol Code - 10
				case get_level(Username) of
					{Username,Level} ->
						PlayerLevel = Level,
						io:format("Recebido Socket 10 (find_lobby)\n"),
						case find_Lobby(Username,PlayerLevel,Sock) of
							{firstInLobby,Socket}->
								gen_tcp:send(Socket,"firstInLobby"),
								io:format("~p is first in lobby\n",[Username]),
								user(Socket,1,null,null);
							{startingGame,Socket}->
								io:format("Started a new game\n"),
								user(Socket,2,null,null);
							{"ERROR:Lobby_found_but_full"}->
								gen_tcp:send(Sock,"ERROR:Lobby_found_but_full"),
								io:format("~p found a full lobby\n",[Username]),
								user(Sock,1,null,null)
						end;
					{Username,error} ->
						gen_tcp:send(Sock,"Error 00"),
						io:format("ERROR\n"),
						user(Sock,1,null,null)
				end;
			["11", LobbyLevel,Player]-> %Cancel Finding Lobby Protocol Code - 11
				io:format("Recebido Socket 11 (cancel_find) \n"),
				case cancel_find(LobbyLevel,Player) of
					cancelled_find ->
						gen_tcp:send(Sock,"Cancelled_find"),
						io:format("Cancelled find for player ~p\n",[Player]),
						user(Sock,1,null,null);
					"ERROR:Player_Not_Found" ->
						gen_tcp:send(Sock,"Error 11"),
						io:format("ERROR 11 - cancel find\n"),
						user(Sock,1,null,null)
				end;
			["20",Username] -> %Win game Protocol Code - 20
			io:format("Recebido Socket 20\n"),
				case win_game(Username) of
					level_up ->
						NewLevel = get_level(Username),
						Str = io_lib:format("new_level, ~p", NewLevel),
						gen_tcp:send(Sock,Str);
					ok ->
						ok;
					invalid->
						gen_tcp:send(Sock,"Error"),
						io:format("ERROR leveling up\n")
				end,
				io:format("~p won the game\n",[Username]),
				user(Sock,1,null,null);
			["50"] ->
				io:format("Recebi socket 50\n"),
				Top10Str = top10(),
				io:format("~p\n",Top10Str),
				io_lib:format("top10list,~p",Top10Str),
				gen_tcp:send(Sock,Top10Str);
			_ ->
				user(Sock,1,null,null)
		end;
	{tcp, _, Data} when Mode =:= 0 ->
		io:format("~p\n",[Data]),
		case string:split(binary_to_list(Data), " ",all) of
			["50"] ->
				io:format("Entrei no 50\n"),
				Top10Str = top10(),
				io:format("top10: ~p\n",[Top10Str]),
				io_lib:format("top10list,~p",[Top10Str]),
				io:format("lancei top10\n"),
				gen_tcp:send(Sock,Top10Str);
			["10", _Username] ->
				user(Sock,0,null,null);
			["00", Username, Password] -> %Login Protocol Code - 00
				case get_level(Username) of
					{Username,Level} ->
						Level,
						io:format("Recebido Socket 00\n"),
						if 
							Username == "Username"->
								gen_tcp:send(Sock,"Error 00"),
								io:format("Sent Login Failure\n");
							Username =/= "Username"->
								case login(Username, Password) of
									{ok,login}->
										Str = io_lib:format("Logged_in, ~p", [Level]),
										gen_tcp:send(Sock,Str),
										io:format("Sent Login Sucess\n"),
										user(Sock,1,null,null);
									{"ERROR:Invalid_Username_for_Login"}->
										gen_tcp:send(Sock,"Error 00"),
										io:format("Sent Login Failure\n"),
										user(Sock,0,null,null)
								end
							end;
					{Username,error} ->
						gen_tcp:send(Sock,"Error 00"),
						io:format("Sent Login Failure\n"),
						user(Sock,0,null,null)
				end;
			["02", Username, Password] -> %Register Protocol Code - 02
				io:format("Username:~p\n",[Username]),
				io:format("Password:~p\n",[Password]),
				io:format("Recebido Socket 02\n"),
				case create_account(Username,Password) of
					{ok,created_Account} ->
						gen_tcp:send(Sock,"created_Account"),
						io:format("Sent created_Account Sucess\n"),
						%Cria new_player(Username) automaticamente 
						user(Sock,1,null,null);
					{"ERROR:User_Already_Exists"} ->
						gen_tcp:send(Sock,"Error 01"),
						io:format("Sent created_Account Failure\n"),
						user(Sock,0,null,null)
				end;
			_ ->
				user(Sock,0,null,null)
		end;
	{tcp_closed, _} when Mode =:= 2->
		case {Mode, PidPartida} of
        {2, Pid} when is_pid(Pid) ->
            Pid ! {disconnected, Sock, PidJogador},
            io:format("Utilizador desconectado\n");
        {2, _} ->
            io:format("Utilizador desconectado\n");
        _ ->
            io:format("Utilizador desconectado\n")
		end;
	{tcp_closed, _} when Mode =:= 1->
		io:format("Utilizador desconectado\n");
	{tcp_closed, _} when Mode =:= 0->
		io:format("Utilizador desconectado\n");
	{tcp_error, _, _} ->
		io:format("Error\n")
	end.