-module(lobby_manager).
-export([startLobbyManager/0,
		find_Lobby/2,
		cancel_find/2]).

startLobbyManager() -> 
	register(?MODULE,spawn(fun() -> lobby([]) end)). 

%Lobby = spawn(fun()->lobby(maps:put(Nivel,LiderUsername,PlayerMap)) end),

find_Lobby(Username,Nivel)->
	?MODULE ! {find_Lobby,Username,Nivel,self()},
	receive
		{first_in_lobby,?MODULE} -> {firstInLobby};
		{startingGame, ?MODULE} -> {startinGame};
		{full}->
			{"ERROR:Lobby_found_but_full"},
			find_Lobby(Username,Nivel)
	end.

cancel_find(LobbyLevel,Player)->
	?MODULE ! {remove_player,LobbyLevel,Player,self()},
	receive
		{Res,?MODULE} -> Res;
		{player_not_found}->
			io:format("ERROR:Player_Not_Found")
	end.

find_lobby(PlayerLevel, PlayerMap) ->
	%casos:
		%	Nivel N pode entrar em lobbies do tipo:
		%	{N-1,N+1} : list(Jogadores)
		%	{N-2,N}	: list(Jogadores) - Atualiza Max-1
		%	{N,N+2} : list(Jogadores) - Atualiza Min+1
		%	{N-1,N} : list(Jogadores)
		% 	{N,N+1} : list(Jogadores)
	case maps:find({PlayerLevel - 1, PlayerLevel + 1}, PlayerMap) of
		{ok, PlayerList} -> {ok, PlayerList, {PlayerLevel - 1, PlayerLevel + 1}};
	error ->
		case maps:find({PlayerLevel - 2, PlayerLevel}, PlayerMap) of
			{ok, PlayerList} -> {ok, PlayerList, {PlayerLevel - 2, PlayerLevel-1}};
		error ->
			case maps:find({PlayerLevel, PlayerLevel + 2}, PlayerMap) of
				{ok, PlayerList} -> {ok, PlayerList, {PlayerLevel+1, PlayerLevel + 2}};
			error ->
				case maps:find({PlayerLevel - 1, PlayerLevel}, PlayerMap) of
					{ok, PlayerList} -> {ok, PlayerList, {PlayerLevel - 1, PlayerLevel}};
				error ->
					case maps:find({PlayerLevel, PlayerLevel + 1}, PlayerMap) of
						{ok, PlayerList} -> {ok, PlayerList, {PlayerLevel, PlayerLevel + 1}};
					error -> error
					end
				end
			end
		end
	end.

lobby(PlayerMap)-> %Lobbies de jogadores
	%PlayerMap = {MinLevel,MaxLevel} : list(Jogadores)
	receive
		{find_Lobby,Username,PlayerLevel,From}->
		case find_lobby(PlayerLevel, PlayerMap) of
			{ok, PlayerList, NewLevel} ->
				case length(PlayerList) of
					3 ->
						lobby(maps:update(NewLevel, lists:append([Username], PlayerList), PlayerMap));
					2 ->
						lobby(maps:update(NewLevel, lists:append([Username], PlayerList), PlayerMap));
					1 ->
						NewPlayerList = lists:append([Username], PlayerList),
						spawn(fun() -> 
							receive 
								after 5000 -> 
									game ! {startGame, NewPlayerList}
							end
						end),
						UpdatedPlayerMap = maps:update(NewLevel, NewPlayerList, PlayerMap),
						lobby(UpdatedPlayerMap);
					_ ->
						From ! {full, ?MODULE},
						lobby(PlayerMap)
				end;
			error ->
				From ! {first_in_lobby, ?MODULE},
				?MODULE ! {create_lobby, PlayerLevel,Username},
				lobby(PlayerMap)
		end;
		{cancel_find,PlayerLevel,RemovedPlayer,From}->
			case find_lobby(PlayerLevel, PlayerMap) of
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
		{create_lobby,PlayerLevel,Username}->
			level_system ! {get_level,Username},
			receive
				{receive_level,Nivel}->
					Nivel
			end,
			lobby(maps:put({PlayerLevel-1,PlayerLevel+1},[Username],PlayerMap))
	end.