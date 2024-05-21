-module(game).
-export([startGame/0]).

startGame(Players) -> 
	register(?MODULE,spawn(fun() -> loop(Players) end)).

%Constante força da gravidade: Servidor ou Cliente??

loop(Players)->
    %Posição dos jogadores no espaço - ecran = 1080, 720
    %Aceleração
    %Receber 
    .