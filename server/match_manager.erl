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

room(Sockets) ->
	receive
	{new_user, Sock} ->
		io:format("new user~n", []),
		room([Sock | Sockets]);
	{tcp, _, Data} ->
		io:format("received ~p~n", [Data]),
		[gen_tcp:send(Socket, Data) || Socket <- Sockets],
		room(Sockets);
	{tcp_closed, Sock} ->
		io:format("user disconnected~n", []),
		room(Sockets -- [Sock]);
	{tcp_error, Sock, _} ->
		io:format("tcp error~n", []),
		room(Sockets -- [Sock])
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