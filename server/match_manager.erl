-module(match_manager).
-export([start/0]).

start() -> 
	%SomeHostInNet = "localhost" 
	%Criar servidor - Porta Localhost
	MatchPid = spawn(fun() -> server(8080) end).

stop(Server) -> Server ! stop.

server(Port) ->
	{ok, LSock} = gen_tcp:listen(Port, [binary, {packet, line}, {reuseaddr, true}]),
	Room = spawn(fun() -> room([]) end),
	spawn(fun()-> acceptor(LSock,Room)end),
	receive stop -> ok end.

acceptor(LSock, Room) ->
	{ok, Sock} = gen_tcp:accept(LSock),
	spawn(fun() -> acceptor(LSock, Room) end),
	Room ! {enter, self()},
	user(Sock, Room).

room(Pids) ->
	receive
	{enter, Pid} ->
		io:format("user entered~n", []),
		room([Pid | Pids]);
	{line, Data} = Msg ->
		io:format("received ~p~n", [Data]),
		[Pid ! Msg || Pid <- Pids],
		room(Pids);
	{leave, Pid} ->
		io:format("user left~n", []),
		room(Pids -- [Pid])
	end.

user(Sock, Room) ->
	receive
	{line, Data} ->
		gen_tcp:send(Sock, Data),
		%Lança para Java o Socket que tem que ser processado onde pode ter informação sobre o que quer fazer
		%O Java processa e lança novamente o Socket da função que quer fazer do Erlang
		user(Sock, Room);
	{tcp, _, Data} ->
		Room ! {line, Data},
		user(Sock, Room);
	{tcp_closed, _} ->
		Room ! {leave, self()};
	{tcp_error, _, _} ->
		Room ! {leave, self()}
	end.