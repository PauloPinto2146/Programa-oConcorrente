-module(match_manager).
-export([start/0]).

start() -> 
	register(?MODULE,spawn(fun() -> loop(#{}) end)). 

create_match(Match_Name,Lider) ->
	level_system ! {get_level,Lider,self()},
	receive
		{receive_level,Nivel,From}->
			Nivel;
	?MODULE ! {create_match,Match_name,Lider,Nivel,self()},
	PlayerMap = maps:new(),
	Lobby = spawn(fun()->lobby(maps:put(Lider,{0,Nivel},PlayerCount)) end),
	receive
		{Res,?MODULE} -> Res;
		{match_exists,From}->
			io:format("ERROR:Match_Already_Exists")
	end.

delete_match(Match_Name,Lider) ->
	?MODULE ! {delete_match,Match_name,Username,self()}
	receive
		{Res,?MODULE} -> Res;
		{cant_delete,From}->
			io:format("ERROR:Cant_delete_match")
	end.

add_player(Username,Nivel)->
	?MODULE ! {add_player,Match_name,Username,Nivel,self()}
	receive
		{Res,?MODULE} -> Res;
		{already_in,From}->
			io:format("ERROR:Player_Already_in_Match");
		{full,From}->
			io:format("ERROR:Lobby_is_full");
		{match_doesnt_exist1,From}->
			io:format("ERROR:Match_Doesnt_Exists");
		{match_in_progess1,From}->
			io:format("ERROR:Match_in_progress");
		{match_ended1,From}->
			io:format("ERROR:Match_ended")
	end.

remove_player(LiderUsername,KickedPlayer)->
	?MODULE ! {remove_player,Match_name,LiderUsername,KickedPlayer,self()}
	receive
		{Res,?MODULE} -> Res;
		{player_not_found,From}->
			io:format("ERROR:Player_Not_Found");
		{not_leader,self()} ->
			io:format("Error:You_are_not_the_leader_of_the_lobby");
		%{match_doesnt_exist2,From}->
			%io:format("ERROR:Match_Doesnt_Exists");
		%{match_in_progess2,From}->
			%io:format("ERROR:Match_in_progress");
		%{match_ended2,From}->
			%io:format("ERROR:Match_ended")
	end.

leave_lobby(Match_Name,Username)->
	?MODULE ! {leave_lobby,Match_name,Username,self()}
	receive
		{Res,?MODULE} -> Res;
		{match_not_found, ?MODULE} -> io:format("ERROR:Match_not_found")
	end.

ready(Match_Name,Username)->
	?MODULE ! {ready,Match_Name,Username,self()}.

unready(Match_Name,Username)->
	?MODULE ! {unready,Match_Name,Username,self()}.
	receive
		{player_not_found, ?MODULE} -> io:format("ERROR:Match_not_found")
	end.

start_game(Match_Name)->.

lobby(PlayerMap) when length(PlayerMap) =:= 4->
	{start}.

lobby(PlayerMap)-> %Proprio Lobby de jogadores
	%	PlayerMap : Jogadores, Se é o lider (0 - Não, 1 - Sim), disponibilidade (0 - Not Ready // 1 - Ready) e Nivel
	receive
		{add_player,Username}->
			map:put(Username,{0,0,Nivel},PlayerMap)
			if
				map:is_key(Username,PlayerMap)->
					From ! {already_in,?MODULE},
					lobby(PlayerMap); 
				PLayerMap.length() == 4 ->	
					From ! {full, ?MODULE},
						lobby(PlayerMap);
						%Provavelmente não eficiente
				Nivel == LeaderLevel ->
					lobby(map:update(Match_name,{0,PlayerCount+1,map:put(Username,0,PlayerMap)},PlayerMap));
				Nivel +1 == LeaderLevel ->
							lobby(map:update(Match_name,{0,PlayerCount+1,map:put(Username,0,PlayerMap)},PlayerMap));
				Nivel -1 == LeaderLevel ->
							lobby(map:update(Match_name,{0,PlayerCount+1,map:put(Username,0,PlayerMap)},PlayerMap));
		{remove_player,Match_name,LiderUsername,KickedPlayer,From}->
			case maps:is_key(KickedPlayer,PlayerMap) of
				true ->
					if
						LiderUsername == Lider ->
							lobby(map:remove(KickedPlayer,PlayerMap)),
						LiderUsername /= Lider ->
							From ! {not_leader,self()},
							lobby(PlayerMap);
				false ->
					From ! {player_not_found,?MODULE},
					lobby(PlayerMap);
		{ready,Match_Name,Username,From} ->
			case maps:find(Username,PlayerMap) of
				{ok,{_,Disp,Nivel}}->
					maps:update(Username,{1,Nivel},PlayerMap),
					lobby(PlayerMap);
				_->
					From ! {player_not_found,self()}
		{unready,Match_Name,Username,From} ->
			case maps:find(Username,PlayerMap) of
				{ok,{_,Disp,_}}->
					maps:update(Username,{_,0,_},PlayerMap),
					lobby(PlayerMap);
				_->
					From ! {player_not_found,self()}
	end.

lobbies(Map)-> 
	% Map de lobbies com informação sobre
	%	KEY	
	%   - Nome do lobby
	%	VALUE
	%	- Líder
	%	- Nivel do Lobby (=NivelLider)
	%	- Estado
	%		(0- Em espera 1- A decorrer 2 - Acabou)
	receive 
		{create_match,Match_name,Lider,Nivel,From} ->
			case maps:find(Match_name,Map) of
				true ->
					From ! {match_exists,?MODULE},
					loop(Map);
				false ->
					From ! {ok,?MODULE},
					PlayerMap = maps:new(),
					loop(map:put(Match_name,{Lider,Nivel,0,0,maps:put(Lider,0,PlayerMap)},Map))
			end;
		{delete_match,Match_name,Lider,From} ->
			case maps:find(Match_name,Map) of
				{ok,{LiderUsername,_,_,_,_}} -> 
					if
						LiderUsername == Lider ->
							From ! {ok,?MODULE},
							loop(map:remove(Match_name,Map));
					end,
				_->
					From ! {cant_delete, ?MODULE},
					loop(Map)
			end;
		%{add_player,Match_name,Username,Nivel,From}->
		%	case maps:find(Match_name,Map) of
		%		{ok,{0,LeaderLevel,PlayerCount,PlayerMap} ->
		%			if
		%				map:is_key(Username,PlayerMap)->
		%					From ! {already_in,?MODULE},
		%					loop(Map); 
		%				PlayerCount == 4 ->	
		%					From ! {full, ?MODULE},
		%					loop(Map);
		%				%Provavelmente não eficiente
		%				if PlayerCount < 4 and Nivel == LeaderLevel ->
		%					loop(map:update(Match_name,{0,PlayerCount+1,map:put(Username,0,PlayerMap)},Map));
		%				if PlayerCount < 4 and Nivel +1 == LeaderLevel ->
		%					loop(map:update(Match_name,{0,PlayerCount+1,map:put(Username,0,PlayerMap)},Map));
		%				if PlayerCount < 4 and Nivel -1 == LeaderLevel ->
		%					loop(map:update(Match_name,{0,PlayerCount+1,map:put(Username,0,PlayerMap)},Map));
		%		%CASO EM QUE ESTÁ JÁ A DECORRER OU JÁ ACABOU
		%		{ok,{1,_,_}} ->
		%			From ! {match_in_progess1,?MODULE},
		%			loop(Map);
		%		{ok,{2,_,_}} ->
		%			From ! {match_ended1,?MODULE},
		%			loop(Map)
		%		_ ->
		%			From ! {match_doesnt_exist1,?MODULE},
		%			loop(Map);
		%	end;
		%{remove_player,Match_name,LiderUsername,KickedPlayer,From}->
		%	case maps:find(Match_name,Map) of
		%		{ok,{0,Lider,LeaderLevel,PlayerCount,PlayerMap}} ->
		%			if
		%				LiderUsername == Lider ->
		%					loop(map:update(Match_name,{0,LiderUsername,LeaderLevel,PlayerCount-1,map:remove(KickedPlayer,PlayerMap)},Map));
		%		{ok,{1,_,_}} ->
		%			From ! {match_in_progess2,?MODULE},
		%			loop(Map);
		%		{ok,{2,_,_}} ->
		%			From ! {match_ended2,?MODULE},
		%			loop(Map)
		%		_ ->
		%			From ! {match_doesnt_exist2,?MODULE},
		%			loop(Map);
		%	end;
		%{leave_lobby,Match_name,Username,From}->
		%	case maps:find(Match_name,Map) of
		%		{ok,{0,Lider,PlayerCount,PlayerMap}}->
		%			if
		%				Lider == Username ->
		%					?MODULE ! {delete_match,Match_name,self()},
		%				Lider /= Username ->
		%					loop(map:update(Match_name,{0,Lider,PlayerCount-1,map:remove(Username,PlayerMap)},Map));
		%			end
		%		_->
		%			From ! {match_not_found,?MODULE}
	end.

%Falta começar o jogo quando estão todos prontos
%Falta restringir o nivel dos jogadores ao entrar nos lobbies

%Game = spawn(fun()->game() end),