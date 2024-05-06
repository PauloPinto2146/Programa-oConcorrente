-module(lobby_manager).
-export([start/0,
		find_Lobby/2,
		cancel_find/2,
		lobby/1]).

start() -> 
	register(?MODULE,spawn(fun() -> lobby(#{}) end)). 

%Lobby = spawn(fun()->lobby(maps:put(Nivel,LiderUsername,PlayerMap)) end),

find_Lobby(Username,Nivel)->
	?MODULE ! {add_player,Username,Nivel,self()},
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
	%PlayerMap = Lobby : list(Jogadores)
	receive
		{find_Lobby,Username,PlayerLevel,From}->
			case {maps:find(PlayerLevel, PlayerMap), 
     			 maps:find(PlayerLevel + 1, PlayerMap), 
     			 maps:find(PlayerLevel - 1, PlayerMap)} of
				{ok,PlayerList}	->
					case length(PlayerList) of
						4 ->
                            From ! {full, ?MODULE},
                            ?MODULE ! {create_lobby, Username, PlayerLevel},
                            lobby(PlayerMap);
                        3 ->
                            spawn(fun() -> receive after 5000 -> match_manager ! start end end),
                            NewPlayerList = lists:append([Username], PlayerList),
                            lobby(maps:remove(PlayerLevel, NewPlayerList));
                        _ ->
                            NewPlayerList = lists:append([Username], PlayerList),
                            lobby(maps:update(PlayerLevel, NewPlayerList, PlayerMap))
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