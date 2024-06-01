-module(level_system).
-export([startLevelSystem/0,
		new_player/1,
		top10/0,
		print_top_players/3,
		map_tolist_level/1,
		win_game/1,
		lose_game/1,
		get_level/1,
		loop/1]).
-import(login_manager,[level_up/2,level_down/2]).

%Level 1 - 1 partida ganha
%Level 2 - 2 partidas ganhas
%Level 3 - 3 partidas ganhas 
%...

%Username
	%Nivel
	%Partidas ganhas no nivel
	%Partidas ganhas totais
	%Partidas perdidas totais
	%Partidas perdidas consecutivamente

startLevelSystem() -> 
    register(?MODULE, spawn(fun() -> loop(#{"VieirinhaHardcore" => {99,32,464,90,0},
			"Piriu" => {99,32,464,90,1},
			"ZeCarlos" => {5,12,21,12,4},
			"Tunico" => {2,2,56,14,0}}) end)).

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
		{level_up,?MODULE} -> level_up;
		{ok,?MODULE} -> ok;
		{invalid,?MODULE} -> invalid
	end.

lose_game(Username)->
	io:format("Entrei no lose_game\n"),
	?MODULE ! {lose_game,Username,self()},
	receive
		{level_down,_From} -> 
			io:format("Entrei no leveldown\n"),
			{level_down};
		{ok,_From} -> 
			io:format("Entrei no ok\n"),
			{ok};
		{invalid,_From} -> 
			io:format("Entrei no invalido\n"),
			{invalid}
	end.

top10()->
	?MODULE ! {top10,self()},
	receive
		{Top10List,?MODULE} -> Top10List
	end.

print_top_players(_, 0,Res) ->
    Res;
print_top_players([{Player,Nivel,DerrCons} | Tail], Count,Res) ->
	%Primeiro criterio - nivel
	%Segundo criterio - Derrotas consecutivas
    NewRes = lists:append([Player,Nivel,DerrCons],Res),
    print_top_players(Tail, Count - 1, NewRes).

map_tolist_level(PlayerMap)->
	maps:fold(fun(Username, {Nivel, _, _, DerrCons}, Acc) -> maps:put(Username, Nivel, DerrCons, Acc) end, #{}, PlayerMap).

get_level(Username)->
	?MODULE ! {get_map,self()},
	receive
		{receive_map,Map}->
			PlayerMap = Map
	end,
	case maps:find(Username,PlayerMap) of
		{ok,{Level,_,_,_,_}} ->
			{Username,Level};
		error ->
			{Username,error}
	end.

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
					loop(maps:put(Username,{1,0,0,0,0},Map))
			end;
		{win_game,Username,From}->
			case maps:find(Username,Map) of
				{ok,{Level,WinsPerLevel,Wins,Losses,_}} ->
					if Wins == Level ->
						level_up(Username,Level),
						From ! {level_up,?MODULE},
						loop(maps:update(Username,{Level+1,0,Wins+1,Losses,0},Map));
					Wins < Level ->
						From ! {ok,?MODULE},
						loop(maps:update(Username,{Level,WinsPerLevel+1,Wins+1,Losses,0},Map))
					end;
				_ ->
					From ! {invalid, ?MODULE},
					loop(Map)
			end;
		{lose_game,Username,From}->
			case maps:find(Username,Map) of
				{ok,{Level,WinsPerLevel,Wins,Losses,LossesCons}} ->
					if LossesCons >= Level/2 andalso Level > 1 ->
						From ! {level_down,?MODULE},
						level_down(Username,Level),
						loop(maps:update(Username,{Level-1,WinsPerLevel,Wins,Losses+1,0},Map));
					LossesCons < Level/2 ->
						From ! {ok,?MODULE},
						loop(maps:update(Username,{Level,WinsPerLevel,Wins,Losses+1,LossesCons+1},Map));
					Level =< 1 ->
						From ! {ok,?MODULE},
						loop(maps:update(Username,{Level,WinsPerLevel,Wins,Losses+1,LossesCons+1},Map))
				end;
				_ ->
					From ! {invalid, ?MODULE},
					loop(Map)
			end;
		{top10,From}->
			Map_only_level = map_tolist_level(Map),
			List = maps:to_list(Map_only_level),
			Sp = lists:keysort(2,List),
			CompareFun = fun({_, _, Losses1}, {_, _, Losses2}) -> Losses1 >= Losses2 end,
			SortedPlayers = lists:sort(CompareFun,Sp),
    		Top10 = print_top_players(SortedPlayers, 10,[]),
			From ! Top10,
    		loop(Map);
    	{get_map,From}->
			From ! {receive_map,Map},
			loop(Map)
	end.

