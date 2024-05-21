-module(level_system).
-export([startLevelSystem/0,
		new_player/1,
		top10/0,
		print_top_players/2,
		map_tolist_level/1,
		loop/1]).

%Level 1 - 1 partida ganha
%Level 2 - 2 partidas ganhas
%Level 3 - 3 partidas ganhas 
%...

startLevelSystem() -> 
    register(?MODULE, spawn(fun() -> loop(#{}) end)).

new_player(Username) -> %Quando nova conta é criada é criado também o perfil do jogador
	receive
		{create_account,Username,login_manager}->
			?MODULE ! {new_player,Username,self()};
		{user_exists,Username,?MODULE}->
			io:format("ERROR:Couldnt_create_new_player_profile");
		{Res,?MODULE} -> Res
	end.

win_game(Username)-> %Quando ganha jogo precisa atualizar
	?MODULE ! {win_game,Username,self()},
	receive
		{Res,?MODULE} -> Res;
		{won_game,?MODULE} -> io:format("YOU WIN!")
	end.

lose_game(Username)->
	?MODULE ! {lose_game,Username,self()},
	receive
		{Res,?MODULE} -> Res;
		{lost_game,?MODULE} -> io:format("YOU LOST!")
	end.

top10()->
	?MODULE ! {top10},
	receive
		{Res,?MODULE} -> Res
	end.

print_top_players(_, 0) ->
    ok;
print_top_players([{Player, Nivel,_,_,_} | Tail], Count) ->
    io:format("~s: Nível ~B~n", [Player, Nivel]),
    print_top_players(Tail, Count - 1).

map_tolist_level(PlayerMap)->
	maps:fold(fun(Username, {Nivel, _, _, _}, Acc) -> maps:put(Username, Nivel, Acc) end, #{}, PlayerMap).

loop(Map)->
	%Username
	%Nivel
	%Partidas ganhas no nivel
	%Partidas ganhas totais
	%Partidas perdidas totais
	%Partidas perdidas consecutivamente
	receive
		{new_player,Username,From}->
			case maps:is_key(Username,Map) of
				true ->
					From ! {user_exists,?MODULE},
					loop(Map);
				false ->
					From ! {ok,?MODULE},
					loop(map:put(Username,{1,0,0,0,0},Map))
			end;
		{win_game,Username,From}->
			case maps:find(Username,Map) of
				{ok,{Level,WinsPerLevel,Wins,Losses,_}} ->
					if Wins == Level ->
						loop(map:update(Username,{Level+1,0,Wins+1,Losses,0},Map));
					Wins < Level ->
						From ! {ok,?MODULE},
						loop(map:update(Username,{Level,WinsPerLevel+1,Wins+1,Losses,0},Map))
					end;
				_ ->
					From ! {invalid, ?MODULE},
					loop(Map)
			end;
		{lose_game,Username,From}->
			case maps:find(Username,Map) of
				{ok,{Level,WinsPerLevel,Wins,Losses,LossesCons}} ->
					if LossesCons == Level/2 ->
						loop(map:update(Username,{Level-1,WinsPerLevel,Wins,Losses+1,0},Map));
					LossesCons < Level/2 ->
						From ! {ok,?MODULE},
						loop(map:update(Username,{Level,WinsPerLevel,Wins,Losses+1,LossesCons+1},Map))
				end;
				_ ->
					From ! {invalid, ?MODULE},
					loop(Map)
			end;
		{top10}->
			Map_only_level = map_tolist_level(Map),
			List = maps:to_list(Map_only_level),
			SortedPlayers = lists:keysort(2,List),
    		print_top_players(SortedPlayers, 10),
    		loop(Map);
    	{get_level,Username,From}->
    		Level = maps:get(Username,Map),
    		From ! {receive_level,Level,self()}
	end.

