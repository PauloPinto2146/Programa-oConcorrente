-module(match_manager).
-export([start/0]).

start() -> 
	register(?MODULE,spawn(fun() -> loop(#{}) end)). 

create_match(Match_Name,Lider) ->
	?MODULE ! {create_match,Match_name,Lider,self()}
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

add_player(Username)->
	?MODULE ! {add_player,Match_name,Username,self()}
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
		{match_doesnt_exist2,From}->
			io:format("ERROR:Match_Doesnt_Exists");
		{match_in_progess2,From}->
			io:format("ERROR:Match_in_progress");
		{match_ended2,From}->
			io:format("ERROR:Match_ended")
	end.

leave_lobby(Match_Name,Username)->
	?MODULE ! {leave_lobby,Match_name,Username,self()}
	receive
		{Res,?MODULE} -> Res;
		{match_not_found, ?MODULE} -> io:format("ERROR:Match_not_found")
	end.

start_game(Match_Name)->.

loop(Map)-> 
	%Map de lobbies com informação sobre
	%	- Nome
	%	- Líder
	%	- Estado 
	%		0- Em espera 1- A decorrer 2 - Acabou)
	%	- Quantidade de Jogadores 
	%	- Quais Jogadores e disponibilidade (0 - Not Ready // 1 - Ready)
	receive 
		{create_match,Match_name,Lider,From} ->
			case maps:is_key(Match_name,Map) of
				true ->
					From ! {match_exists,?MODULE},
					loop(Map);
				false ->
					From ! {ok,?MODULE},
					loop(map:put(Match_name,{Lider,0,0,#{Username=>0}},Map))
			end;
		{delete_match,Match_name,Lider,From} ->
			case maps:find(Match_name,Map) of
				{ok,{LiderUsername,_,_,_}} -> 
					if
						LiderUsername == Lider ->
							From ! {ok,?MODULE},
							loop(map:remove(Match_name,Map));
					end,
				_->
					From ! {cant_delete, ?MODULE},
					loop(Map)
			end;
		{add_player,Match_name,Username,From}->
			case maps:find(Match_name,Map) of
				%TEM QUE TER NIVEL +-1 NIVEL DO LIDER
				{ok,{0,PlayerCount,PlayerMap} ->
					if
						map:is_key(Username,PlayerMap)->
							From ! {already_in,?MODULE},
							loop(Map); 
						PlayerCount < 4 ->
							loop(map:update(Match_name,{0,PlayerCount+1,map:put(Username,0,PlayerMap)},Map));
						PlayerCount == 4 ->	
							From ! {full, ?MODULE},
							loop(Map);
				_ ->
					From ! {match_doesnt_exist1,?MODULE},
					loop(Map);
				%CASO EM QUE ESTÁ JÁ A DECORRER OU JÁ ACABOU
				{ok,{1,_,_}} ->
					From ! {match_in_progess1,?MODULE},
					loop(Map);
				{ok,{2,_,_}} ->
					From ! {match_ended1,?MODULE},
					loop(Map)
			end;
		{remove_player,Match_name,LiderUsername,KickedPlayer,From}->
			case maps:find(Match_name,Map) of
				{ok,{0,Lider,PlayerCount,PlayerMap}} ->
					if
						LiderUsername == Lider ->
							loop(map:update(Match_name,{0,LiderUsername,PlayerCount-1,map:remove(KickedPlayer,PlayerMap)},Map));
				{ok,{1,_,_}} ->
					From ! {match_in_progess2,?MODULE},
					loop(Map);
				{ok,{2,_,_}} ->
					From ! {match_ended2,?MODULE},
					loop(Map)
				_ ->
					From ! {match_doesnt_exist2,?MODULE},
					loop(Map);
			end;
		{leave_lobby,Match_name,Username,From}->
			case maps:find(Match_name,Map) of
				{ok,{0,Lider,PlayerCount,PlayerMap}}->
					if
						Lider == Username ->
							?MODULE ! {delete_match,Match_name,self()},
						Lider /= Username ->
							loop(map:update(Match_name,{0,Lider,PlayerCount-1,map:remove(Username,PlayerMap)},Map));
					end
				_->
					From ! {match_not_found,?MODULE}
	end.