-module(lobby_manager).
-export([startLobbyManager/0,
		find_Lobby/3,
		cancel_find/2,
		start_game/1]).

startLobbyManager() -> 
	register(?MODULE,spawn(fun() -> lobby(#{}) end)). 

%Lobby = spawn(fun()->lobby(maps:put(Nivel,LiderUsername,PlayerMap)) end),

find_Lobby(Username,Nivel,Socket)->
	?MODULE ! {find_Lobby,Username,Nivel,Socket,self()},
	io:format("EXECUTADO FIND_LOBBY\n"),
	receive
		{first_in_lobby,?MODULE} -> 
			{firstInLobby,Socket};
		{startingGame,?MODULE}->
			{startingGame,Socket};
		{full}->
			{"ERROR:Lobby_found_but_full"},
			find_Lobby(Username,Nivel,Socket)
	end.

cancel_find(LobbyLevel,Player)->
	?MODULE ! {remove_player,LobbyLevel,Player,self()},
	receive
		{cancel_find} -> cancel_find;
		{startingGame, ?MODULE}->
			startingGame;
		{player_not_found}->
			"ERROR:Player_Not_Found"
	end.

find_Room(PlayerLevel, LobbyMap) ->
	%casos:
		%	Nivel N pode entrar em lobbies do tipo:
		%	{N-1,N+1} : list(Jogadores)
		%	{N-2,N}	: list(Jogadores) - Atualiza Max-1
		%	{N,N+2} : list(Jogadores) - Atualiza Min+1
		%	{N-1,N} : list(Jogadores)
		% 	{N,N+1} : list(Jogadores)
	case maps:find({PlayerLevel - 1, PlayerLevel + 1}, LobbyMap) of
		{ok, PlayerMap} -> 
			{ok, PlayerMap, {PlayerLevel - 1, PlayerLevel + 1}};
		error ->
			case maps:find({PlayerLevel - 2, PlayerLevel}, LobbyMap) of
				{ok, PlayerMap} -> 
					{ok,PlayerMap, {PlayerLevel - 2, PlayerLevel-1}};
				error ->
					case maps:find({PlayerLevel, PlayerLevel + 2}, LobbyMap) of
						{ok, PlayerMap} -> 
							{ok, PlayerMap, {PlayerLevel+1, PlayerLevel + 2}};
						error ->
							case maps:find({PlayerLevel - 1, PlayerLevel}, LobbyMap) of
								{ok, PlayerMap} -> 
									{ok, PlayerMap, {PlayerLevel - 1, PlayerLevel}};
								error ->
									case maps:find({PlayerLevel, PlayerLevel + 1}, LobbyMap) of
										{ok, PlayerMap} -> 
											{ok, PlayerMap, {PlayerLevel, PlayerLevel + 1}};
										error -> error
									end
							end
					end
			end
	end.

%find_key_by_value(Map, Value) ->
%	lists:foldl(fun({Key, Val}, Acc) ->
%						case Val =:= Value of
%							true -> Key;
%							false -> Acc
%						end
%				end, not_found, maps:to_list(Map)).

start_game(PlayerMap) ->
	Sockets = maps:values(PlayerMap),
	lists:foreach(fun(Socket) -> gen_tcp:send(Socket,"game_started") end, Sockets),
	game ! {startGame, PlayerMap},
	io:format("Starting game with players: ~p~n", [maps:keys(PlayerMap)]).

lobby(LobbyMap)-> %Lobbies de jogadores
	%LobbyMap = {MinLevel,MaxLevel} : {Jogador1:Socket1,Jogador2:Socket2,Jogador3:Socket3,Jogador4:Socket4}
	receive
		{find_Lobby,Username,PlayerLevel,Socket,From}->
		case find_Room(PlayerLevel, LobbyMap) of
			{ok, PlayerMap, NewLevel} ->
				NewPlayerMap = maps:put(Username, Socket, PlayerMap),
                    case length(maps:values(NewPlayerMap)) of
                        4 ->
                            From ! {startingGame,?MODULE},
                            start_game(NewPlayerMap),
                            lobby(maps:remove(NewLevel, LobbyMap));
                        3 ->
                            erlang:send_after(5000, ?MODULE, {check_lobby_timeout, NewLevel, 3}),
                            lobby(maps:update(NewLevel, NewPlayerMap , LobbyMap));
                        2 ->
                            erlang:send_after(5000, ?MODULE, {check_lobby_timeout, NewLevel, 2}),
                            lobby(maps:update(NewLevel, NewPlayerMap, LobbyMap));
                        _ ->
                            lobby(maps:update(NewLevel, NewPlayerMap, LobbyMap))
                    end;
            error ->
                From ! {first_in_lobby, ?MODULE},
                ?MODULE ! {create_lobby, PlayerLevel, Username, Socket},
                lobby(LobbyMap)
		end;
		{cancel_find,PlayerLevel,RemovedPlayer,From}->
			case find_Room(PlayerLevel, LobbyMap) of
			{ok, PlayerMap, From} ->
                    case length(PlayerMap) of
						1 ->
							From ! {canceled_find},
                            lobby(maps:remove(PlayerLevel, LobbyMap));
                        _ ->
							From ! {canceled_find},
                            NewPlayerList = lists:delete(RemovedPlayer, PlayerMap),
                            lobby(maps:update(PlayerLevel, NewPlayerList, LobbyMap))
                    end;
				_ ->
					From ! {player_not_found,?MODULE},
					lobby(LobbyMap)
			end;
		{create_lobby,PlayerLevel,Username,Socket}->
			level_system ! {get_level,Username},
			receive
				{receive_level,Nivel}->
					Nivel
			end,
			NewMap = #{},
			maps:put(Username,Socket,NewMap),
			lobby(maps:put({PlayerLevel-1,PlayerLevel+1},NewMap,LobbyMap));
		%{remove_lobby, OldPlayerMap}->
		%	LobbyLevel = find_key_by_value(OldPlayerMap,LobbyMap),
		%	NewPlayerMap = maps:remove(LobbyLevel, LobbyMap),
		%	lobby(NewPlayerMap);
		{check_lobby_timeout, Level,Number} ->
			%Se for igual o numero de jogadores lança startgame, senão
            case maps:find(Level, LobbyMap) of
				{ok,NewPlayerMap}->
					case length(NewPlayerMap) of
						Number ->
							?MODULE ! {startingGame, ?MODULE},
							start_game(NewPlayerMap),
							lobby(NewPlayerMap);
						_ ->
							lobby(NewPlayerMap)
					end;
            	error ->
                    lobby(LobbyMap)
            end
	end.