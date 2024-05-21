-module(game).
-export([start/0]).

start(Players) -> 
	register(?MODULE,spawn(fun() -> loop(Players) end)).

%Constante força da gravidade: Servidor ou Cliente??

loop(Players)->
    %Posição dos jogadores no espaço - ecran = 1080, 720
    %Aceleração
    %Receber 
    .