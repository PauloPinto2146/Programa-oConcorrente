-module(lobby_manager).
-export([startLobbyManager/0,
		find_Lobby/3,
		cancel_find/2,
		start_game/1,
		send_info/2]).
-import(game, [startGame/1]).
startLobbyManager() -> 
	register(?MODULE,spawn(fun() -> lobby(#{}) end)). 

%Lobby = spawn(fun()->lobby(maps:put(Nivel,LiderUsername,PlayerMap)) end),

find_Lobby(Username,Nivel,Socket)->
	?MODULE ! {find_Lobby,Username,Nivel,Socket,self()},
	receive
		{first_in_lobby,_} -> 
			{firstInLobby,Socket};
		{startingGame,_}->
			io:format("Jogo vai começar!\n"),
			{startingGame,Socket};
		{full}->
			{"ERROR:Lobby_found_but_full"},
			find_Lobby(Username,Nivel,Socket)
	end.

cancel_find(PlayerLevel,RemovedPlayer)->
	?MODULE ! {please_cancel,PlayerLevel,RemovedPlayer,self()},
	receive
		{cancelled_find} -> cancelled_find;
		{startingGame, ?MODULE}->
			startingGame;
		{player_not_found}->
			"ERROR:Player_Not_Found"
	end.

find_Room(Nivel, LobbyMap) ->
	%casos:
		%	Nivel N pode entrar em lobbies do tipo:
		%	{N-1,N+1} : list(Jogadores)
		%	{N-2,N}	: list(Jogadores) - Atualiza Max-1
		%	{N,N+2} : list(Jogadores) - Atualiza Min+1
		%	{N-1,N} : list(Jogadores)
		% 	{N,N+1} : list(Jogadores)
	case maps:find({Nivel - 1, Nivel + 1}, LobbyMap) of
		{ok, PlayerMap} -> 
			io:format("FOUND ROOM!\n"),
			{ok, PlayerMap, {Nivel - 1, Nivel + 1}};
		error ->
			case maps:find({Nivel - 2, Nivel}, LobbyMap) of
				{ok, PlayerMap} -> 
					io:format("FOUND ROOM!\n"),
					{ok,PlayerMap, {Nivel - 2, Nivel-1}};
				error ->
					case maps:find({Nivel, Nivel + 2}, LobbyMap) of
						{ok, PlayerMap} -> 
							io:format("FOUND ROOM!\n"),
							{ok, PlayerMap, {Nivel+1, Nivel + 2}};
						error ->
							case maps:find({Nivel - 1, Nivel}, LobbyMap) of
								{ok, PlayerMap} -> 
									io:format("FOUND ROOM!\n"),
									{ok, PlayerMap, {Nivel - 1, Nivel}};
								error ->
									case maps:find({Nivel, Nivel + 1}, LobbyMap) of
										{ok, PlayerMap} -> 
											io:format("FOUND ROOM!\n"),
											{ok, PlayerMap, {Nivel, Nivel + 1}};
										error -> 
											io:format("Did not find room\n"),
											error
									end
							end
					end
			end
	end.
send_starting_game([])->
	io:format("Sent to everyone start game message\n");
send_starting_game([From|T])->
	From ! {startingGame, ?MODULE},
	send_starting_game(T).

avisa_start_game(PlayerMap)->
	SocketsFroms = maps:values(PlayerMap),
	Froms = lists:map(fun(V) -> lists:last(V) end, SocketsFroms),
	send_starting_game(Froms).

send_info([],_)->
	io:format("Todos os jogadores estão na partida!\n");
send_info([Socket|Sockets],NumeroJogador)->
	%Str = io_lib:format("<<~p>>",[NumeroJogador]),
	gen_tcp:send(Socket,<<121,NumeroJogador>>),
	send_info(Sockets,NumeroJogador+1).

start_game(PlayerMap) ->
	SocketsFroms = maps:values(PlayerMap),
	Sockets = lists:map(fun([H|_]) -> H end, SocketsFroms),
	send_info(Sockets, 1),
	io:format("Starting game with players: ~p~n", [maps:keys(PlayerMap)]),
	startGame(PlayerMap).

lobby(LobbyMap)-> %Lobbies de jogadores
	%LobbyMap = {MinLevel,MaxLevel} : {Jogador1:[Socket1,From1],Jogador2:[Socket2,From2],
									%  Jogador3:[Socket3,From3],Jogador4:[Socket4,From4]}
	io:format("~p~n", [LobbyMap]),
	receive
		{please_cancel,Nivel,RemovedPlayer,From}->
			io:format("RECEBI please_cancel\n"),
			{PlayerLevel,_} = string:to_integer(Nivel),
			case find_Room(PlayerLevel, LobbyMap) of
				{ok, PlayerMap,MaxMinLevel} ->
						case maps:size(PlayerMap) of
							1 ->
								From ! {cancelled_find},
								io:format("Removi um Lobby\n"),
								lobby(maps:remove(MaxMinLevel, LobbyMap));
							_ ->
								From ! {cancelled_find},
								lobby(maps:put(MaxMinLevel, maps:remove(RemovedPlayer, PlayerMap), LobbyMap))
						end;
				_ ->
					From ! {player_not_found,From},
					io:format("Player_Not_found"),
					lobby(LobbyMap)
			end;
		{find_Lobby,Username,PlayerLevel,Socket,From}->
			case find_Room(PlayerLevel, LobbyMap) of
				{ok, PlayerMap, NewLevel} ->
					NewPlayerMap = maps:put(Username, [Socket,From], PlayerMap),
					case length(maps:values(NewPlayerMap)) of
						4 ->
							start_game(NewPlayerMap),
							avisa_start_game(NewPlayerMap),
							lobby(maps:remove(NewLevel, LobbyMap));
						3 ->
							erlang:send_after(5000, ?MODULE, {check_lobby_timeout, NewLevel, 3}),
							lobby(maps:put(NewLevel, NewPlayerMap, LobbyMap));
						2 ->
							erlang:send_after(5000, ?MODULE, {check_lobby_timeout, NewLevel, 2}),
							lobby(maps:put(NewLevel, NewPlayerMap, LobbyMap));
						_ ->
							lobby(maps:put(NewLevel, NewPlayerMap, LobbyMap))
					end;
				error ->
						From ! {first_in_lobby, ?MODULE},
						NewMap = #{Username => [Socket,From]},
						io:format("Criei novo lobby\n"),
						lobby(maps:put({PlayerLevel-1,PlayerLevel+1},NewMap,LobbyMap))
			end;
		{check_lobby_timeout, Level,Number} ->
			%Se for igual o numero de jogadores lança startgame, senão
            case maps:find(Level, LobbyMap) of
				{ok,NewPlayerMap}->
					case maps:size(NewPlayerMap) of
						Number ->
							start_game(NewPlayerMap),
							avisa_start_game(NewPlayerMap),
							lobby(maps:remove(Level,LobbyMap));
						_ ->
							lobby(LobbyMap)
					end;
            	error ->
                    lobby(LobbyMap)
            end
	end.