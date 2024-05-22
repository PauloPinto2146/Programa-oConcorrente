-module(game).
-export([startGame/0]).

startGame() -> 
    receive
        {{startGame, PlayerList}} ->
	        register(?MODULE,spawn(fun() -> loop(PlayerList) end))
    end.

%Constante força da gravidade: Servidor ou Cliente??

loop(Players)->
    %Posição dos jogadores no espaço - ecran = 1080, 720
    %Aceleração
    %Receber 
    receive
        {Players}->
            Players
    end.