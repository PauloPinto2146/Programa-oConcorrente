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
		{Res,?MODULE} -> Res;
		{full}->
			io:format("ERROR:Lobby_is_full")
	end.

cancel_find(LobbyLevel,Player)->
	?MODULE ! {remove_player,LobbyLevel,Player,self()},
	receive
		{Res,?MODULE} -> Res;
		{player_not_found}->
			io:format("ERROR:Player_Not_Found")
	end.

lobby(PlayerMap)-> %Lobbies de jogadores
	%PlayerMap = LobbyLevel : list(Jogadores)
	receive
		%Se entrar level 2 e level 3 só pode entrar 2 ou 3
		{find_Lobby,Username,PlayerLevel,From}->
			case {maps:find(PlayerLevel, PlayerMap), 
     			 maps:find(PlayerLevel + 1, PlayerMap), 
     			 maps:find(PlayerLevel - 1, PlayerMap)} of
				{ok, PlayerList}	->
					case length(PlayerList) of
						%Se tem 2 dá 5seg para entrar até 4 
                        3 ->
                            NewPlayerList = lists:append([Username], PlayerList),
                            lobby(maps:remove(PlayerLevel, NewPlayerList));
						2 ->
							NewPlayerList = lists:append([Username], PlayerList),
							lobby(maps:remove(PlayerLevel, NewPlayerList));
                        1 ->
                            NewPlayerList = lists:append([Username], PlayerList),
							spawn(fun() -> 
									receive after 5000 -> 
										match_manager ! {create_match,PlayerList}
									end
								end),
                            lobby(maps:update(PlayerLevel, NewPlayerList, PlayerMap));
						_ ->
							From ! {full, ?MODULE},
							lobby(PlayerMap)
                    end;
				_->
					?MODULE ! {create_lobby,Username,PlayerLevel},
					lobby(PlayerMap)
			end;
		{cancel_find,PlayerLevel,RemovedPlayer,From}->
			case {maps:find(PlayerLevel, PlayerMap), 
     			maps:find(PlayerLevel + 1, PlayerMap), 
     			maps:find(PlayerLevel - 1, PlayerMap)} of
				{ok,PlayerList} ->
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
		{create_lobby,LobbyLevel,Username}->
			level_system ! {get_level,Username},
			receive
				{receive_level,Nivel}->
					Nivel
			end,
			lobby(maps:put(LobbyLevel,[Username],PlayerMap))
	end.