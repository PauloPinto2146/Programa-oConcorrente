-module(lobby_manager).
-export([startLobbyManager/0,
		find_Lobby/3,
		cancel_find/2]).

startLobbyManager() -> 
	register(?MODULE,spawn(fun() -> lobby([]) end)). 

%Lobby = spawn(fun()->lobby(maps:put(Nivel,LiderUsername,PlayerMap)) end),

find_Lobby(Username,Nivel,Socket)->
	?MODULE ! {find_Lobby,Username,Nivel,Socket,self()},
	receive
		{first_in_lobby,?MODULE} -> {firstInLobby,Socket};
		{startingGame, ?MODULE} -> {startinGame};
		{full}->
			{"ERROR:Lobby_found_but_full"},
			find_Lobby(Username,Nivel,Socket)
	end.

cancel_find(LobbyLevel,Player)->
	?MODULE ! {remove_player,LobbyLevel,Player,self()},
	receive
		{Res,?MODULE} -> Res;
		{player_not_found}->
			io:format("ERROR:Player_Not_Found")
	end.

find_Room(PlayerLevel, PlayerMap) ->
	%casos:
		%	Nivel N pode entrar em lobbies do tipo:
		%	{N-1,N+1} : list(Jogadores)
		%	{N-2,N}	: list(Jogadores) - Atualiza Max-1
		%	{N,N+2} : list(Jogadores) - Atualiza Min+1
		%	{N-1,N} : list(Jogadores)
		% 	{N,N+1} : list(Jogadores)
	case maps:find({PlayerLevel - 1, PlayerLevel + 1}, PlayerMap) of
		{ok, {PlayerList,SocketPrimeiroJogador}} -> 
			{ok, {PlayerList,SocketPrimeiroJogador}, {PlayerLevel - 1, PlayerLevel + 1}};
	error ->
		case maps:find({PlayerLevel - 2, PlayerLevel}, PlayerMap) of
			{ok, {PlayerList,SocketPrimeiroJogador}} -> 
				{ok,{PlayerList,SocketPrimeiroJogador}, {PlayerLevel - 2, PlayerLevel-1}};
		error ->
			case maps:find({PlayerLevel, PlayerLevel + 2}, PlayerMap) of
				{ok, {PlayerList,SocketPrimeiroJogador}} -> 
					{ok, {PlayerList,SocketPrimeiroJogador}, {PlayerLevel+1, PlayerLevel + 2}};
			error ->
				case maps:find({PlayerLevel - 1, PlayerLevel}, PlayerMap) of
					{ok, {PlayerList,SocketPrimeiroJogador}} -> 
						{ok, {PlayerList,SocketPrimeiroJogador}, {PlayerLevel - 1, PlayerLevel}};
				error ->
					case maps:find({PlayerLevel, PlayerLevel + 1}, PlayerMap) of
						{ok, {PlayerList,SocketPrimeiroJogador}} -> 
							{ok, {PlayerList,SocketPrimeiroJogador}, {PlayerLevel, PlayerLevel + 1}};
					error -> error
					end
				end
			end
		end
	end.

find_key_by_value(PlayerMap, PlayerList) ->
	{Key, _} = lists:keyfind(PlayerList, 2, maps:to_list(PlayerMap)),
	Key.

lobby(PlayerMap)-> %Lobbies de jogadores
	%PlayerMap = {MinLevel,MaxLevel} : {list(Jogadores),SocketPrimeiroJogador}
	receive
		{find_Lobby,Username,PlayerLevel,SocketPrimeiroJogador,From}->
		case find_Room(PlayerLevel, PlayerMap) of
			{ok, {PlayerList,SocketPrimeiroJogador}, NewLevel} ->
				case length(PlayerList) of
					3 ->
						lobby(maps:update(NewLevel, lists:append([Username], PlayerList), PlayerMap));
					2 ->
						lobby(maps:update(NewLevel, lists:append([Username], PlayerList), PlayerMap));
					1 ->
						lobby(maps:update(NewLevel, lists:append([Username], PlayerList), PlayerMap)),
						gen_tcp:send(SocketPrimeiroJogador,"stopWaiting"),
						spawn(fun() -> 
							receive 
								after 5000 -> 
									{NewPlayerList,SocketPrimeiroJogador} = maps:get(NewLevel,PlayerMap),
									game ! {startGame, NewPlayerList},
									?MODULE ! {remove_lobby, NewPlayerList}
							end
						end);
					_ ->
						From ! {full, ?MODULE},
						lobby(PlayerMap)
				end;
			error ->
				From ! {first_in_lobby, ?MODULE},
				?MODULE ! {create_lobby, PlayerLevel,Username,SocketPrimeiroJogador},
				lobby(PlayerMap)
		end;
		{cancel_find,PlayerLevel,RemovedPlayer,From}->
			case find_Room(PlayerLevel, PlayerMap) of
			{ok, PlayerList, _} ->
                    case length(PlayerList) of
						1 ->
                            lobby(maps:remove(PlayerLevel, PlayerMap));
                        _ ->
                            NewPlayerList = lists:delete(RemovedPlayer, PlayerList),
                            lobby(maps:update(PlayerLevel, NewPlayerList, PlayerMap))
                    end;
				_ ->
					From ! {player_not_found,?MODULE},
					lobby(PlayerMap)
			end;
		{create_lobby,PlayerLevel,Username,SocketPrimeiroJogador}->
			level_system ! {get_level,Username},
			receive
				{receive_level,Nivel}->
					Nivel
			end,
			lobby(maps:put({PlayerLevel-1,PlayerLevel+1},{[Username],SocketPrimeiroJogador},PlayerMap));
		{remove_lobby, NewPlayerList}->
			LobbyLevel = find_key_by_value(PlayerMap, NewPlayerList),
			NewPlayerMap = maps:remove(LobbyLevel, PlayerMap),
			lobby(NewPlayerMap)
	end.