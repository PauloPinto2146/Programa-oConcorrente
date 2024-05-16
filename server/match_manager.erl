-module(match_manager).
-export([start/1]).

start(Port) -> 
	receive
		{create_match,PlayerList}->
			%Cria servidor e manda para cada jogador
			MatchPid = spawn(fun() -> server(Port,PlayerList) end),
			lists:foreach(fun(Player) -> 
							Player ! {match_pid, MatchPid}
						end, PlayerList),
			MatchPid
	end.

stop(Server) -> Server ! stop.

server(Port,PlayerList) ->
	{ok, LSock} = gen_tcp:listen(Port, [binary, {packet, line}, {reuseaddr, true}]),
	Room = spawn(fun()-> game(PlayerList) end),
	spawn(fun() -> acceptor(LSock, Room) end),
	receive stop -> ok end.

acceptor(LSock, Room) ->
	{ok, Sock} = gen_tcp:accept(LSock),
	spawn(fun() -> acceptor(LSock, Room) end),
	Room ! {enter, self()},
	user(Sock, Room).

game(Jogadores)->
	receive
		{enter, Jogador} ->
			io:format("user entered˜n", []),
			game([Jogador | Jogadores]);
		{line, Data} = Msg ->
			io:format("received ˜p˜n", [Data]),
		[Jogador ! Msg || Jogador <- Jogadores],
			game(Jogadores);
		{leave, Jogador} ->
		io:format("user left˜n", []),
			game(Jogadores -- [Jogador])
	end.

user(Sock, Room) ->
	receive
	{line, Data} ->
		gen_tcp:send(Sock, Data),
		user(Sock, Room);
	{tcp, _, Data} ->
		Room ! {line, Data},
		user(Sock, Room);
	{tcp_closed, _} ->
		Room ! {leave, self()};
	{tcp_error, _, _} ->
		Room ! {leave, self()}
	end.