-module(game).
-export([startGame/0,
geraValoresPlayers/0,
geraValoresPlanetas/0,
loop/2,
alteraPosicaoPlaneta/2,
alteraPosicaoPlayer/2,
unique_random_value/3,
generate_unique_positions/3,
generate_unique_positions/5,
retirar_primeiro/1,
get_first/1]).

retirar_primeiro([_ | Tail]) ->
    Tail.

get_first([H|_]) ->
    H.

startGame() -> 
    receive
        {startGame, PlayerList} when length(PlayerList) =:= 2 ->
            {Planeta1,Planeta2,Planeta3,Planeta4} = geraValoresPlanetas(),
            PlanetasMap = #{},
            maps:put(1, Planeta1, PlanetasMap),  
            maps:put(2, Planeta2, PlanetasMap),
            maps:put(3, Planeta3, PlanetasMap),
            maps:put(4, Planeta4, PlanetasMap),
            {Player1,Player2,_,_} = geraValoresPlayers(),
            PlayersMap = #{},
            maps:put(get_first(PlayerList), Player1, PlanetasMap),  
            PlayerList2 = retirar_primeiro(PlayerList),
            maps:put(get_first(PlayerList2), Player2, PlanetasMap),
	        register(?MODULE,spawn(fun() -> loop(PlayersMap,PlanetasMap) end));
        {startGame, PlayerList} when length(PlayerList) =:= 3 ->
            {Planeta1,Planeta2,Planeta3,Planeta4} = geraValoresPlanetas(),
            PlanetasMap = #{},
            maps:put(1, Planeta1, PlanetasMap),  
            maps:put(2, Planeta2, PlanetasMap),
            maps:put(3, Planeta3, PlanetasMap),
            maps:put(4, Planeta4, PlanetasMap),
            {Player1,Player2,Player3,_} = geraValoresPlayers(),
            PlayersMap = #{},
            maps:put(get_first(PlayerList), Player1, PlanetasMap),  
            PlayerList2 = retirar_primeiro(PlayerList),
            maps:put(get_first(PlayerList2), Player2, PlanetasMap),
            PlayerList3 = retirar_primeiro(PlayerList2),
            maps:put(get_first(PlayerList3), Player3, PlanetasMap),
	        register(?MODULE,spawn(fun() -> loop(PlayersMap,PlanetasMap) end));
        {startGame, PlayerList} when length(PlayerList) =:= 4 ->
            {Planeta1,Planeta2,Planeta3,Planeta4} = geraValoresPlanetas(),
            PlanetasMap = #{},
            maps:put(1, Planeta1, PlanetasMap),  
            maps:put(2, Planeta2, PlanetasMap),  
            maps:put(3, Planeta3, PlanetasMap),
            maps:put(4, Planeta4, PlanetasMap),    
            {Player1,Player2,Player3,Player4} = geraValoresPlayers(),
            PlayersMap = #{},
            maps:put(get_first(PlayerList), Player1, PlanetasMap),  
            PlayerList2 = retirar_primeiro(PlayerList),
            maps:put(get_first(PlayerList2), Player2, PlanetasMap),
            PlayerList3 = retirar_primeiro(PlayerList2),
            maps:put(get_first(PlayerList3), Player3, PlanetasMap),
            PlayerList4 = retirar_primeiro(PlayerList3),
            maps:put(get_first(PlayerList4), Player4, PlanetasMap),
	        register(?MODULE,spawn(fun() -> loop(PlayersMap,PlanetasMap) end))
    end.

% Função para gerar um valor único
unique_random_value(Min, Max, ExistingValues) ->
    rand:seed(erlang:monotonic_time(), erlang:unique_integer(), erlang:phash2(self())),
    Value = Min + rand:uniform(Max - Min + 1) - 1,
    case sets:is_element(Value, ExistingValues) of
        true -> unique_random_value(Min, Max, ExistingValues); % Gera novamente se o valor já existe
        false -> Value
    end.

% Função para gerar uma lista de posições únicos
generate_unique_positions(Min, Max, Count) ->
    generate_unique_positions(Min, Max, Count, sets:new(), []).

generate_unique_positions(_Min, _Max, 0, _ExistingValues, Positions) ->
    Positions;
generate_unique_positions(Min, Max, Count, ExistingValues, Positions) ->
    Value = unique_random_value(Min, Max, ExistingValues),
    generate_unique_positions(Min, Max, Count - 1, sets:add_element(Value, ExistingValues), [Value | Positions]).

geraValoresPlayers()->
    %Player : {PosicaoX,PosicaoY,Angulo,velocidade,aceleração} 
    % Inicializar o gerador de números aleatórios
    rand:seed(erlang:monotonic_time(), erlang:unique_integer(), erlang:phash2(self())),

    MinX = 900,
    MaxX = 1080,
    MinY = 50,
    MaxY = 670,

    % Gerar posições únicas para X e Y
    PosicoesX = generate_unique_positions(MinX, MaxX, 4),
    PosicoesY = generate_unique_positions(MinY, MaxY, 4),
    [Posicao1X, Posicao2X, Posicao3X, Posicao4X] = PosicoesX,
    [Posicao1Y, Posicao2Y, Posicao3Y, Posicao4Y] = PosicoesY,
    Velocidade1 = 0,
    Velocidade2 = 0,
    Velocidade3 = 0,
    Velocidade4 = 0,
    Acel1 = 0,
    Acel2 = 0,
    Acel3 = 0,
    Acel4 = 0,
    Angle1 = math:atan2(360 - Posicao1Y, 560 - Posicao1X),
    Angle2 = math:atan2(360 - Posicao2Y, 560 - Posicao2X),
    Angle3 = math:atan2(360 - Posicao3Y, 560 - Posicao3X),
    Angle4 = math:atan2(360 - Posicao4Y, 560 - Posicao4X),
    Planeta1 = {Posicao1X,Posicao1Y,Angle1,Velocidade1,Acel1},
    Planeta2 = {Posicao2X,Posicao2Y,Angle2,Velocidade2,Acel2},
    Planeta3 = {Posicao3X,Posicao3Y,Angle3,Velocidade3,Acel3},
    Planeta4 = {Posicao4X,Posicao4Y,Angle4,Velocidade4,Acel4},
    {Planeta1,Planeta2,Planeta3,Planeta4}.

%gerador de números aleatórios
geraValoresPlanetas()->
    %Planeta : PosiçãoX,PosicaoY,Angulo,Velocidade,DistSol,Tamanho
    rand:seed(exsplus, os:timestamp()),
    Angle1 = (rand:uniform(361) - 1) * math:pi()/180,
    Angle2 = (rand:uniform(361) - 1) * math:pi()/180,
    Angle3 = (rand:uniform(361) - 1) * math:pi()/180,
    Angle4 = (rand:uniform(361) - 1) * math:pi()/180,
    Velocidade1 = 0.005 + rand:uniform() * (0.04 - 0.005),
    Velocidade2 = -(0.001 + rand:uniform() * (0.02 - 0.001)),
    Velocidade3 = 0.0008 + rand:uniform() * (0.012 - 0.0008),
    Velocidade4 = -(0.0005 + rand:uniform() * (0.008 - 0.0005)),
    %PosicaoX,PosicaoY,DistanciaDoSol
    Valor1 = 120,
    Posicao1X = 540+math:cos(Angle1)*Valor1,
    Posicao1Y = 360+math:cos(Angle1)*Valor1,
    Valor2 = 220,
    Posicao2X = 540+math:cos(Angle2)*Valor2,
    Posicao2Y = 360+math:cos(Angle2)*Valor2,
    Valor3 = 280,
    Posicao3X = 540+math:cos(Angle3)*Valor3,
    Posicao3Y = 360+math:cos(Angle3)*Valor3,
    Valor4 = 340,
    Posicao4X = 540+math:cos(Angle4)*Valor4,
    Posicao4Y = 360+math:cos(Angle4)*Valor4,
    Planeta1 = {Posicao1X,Posicao1Y,Velocidade1,Angle1,Valor1},
    Planeta2 = {Posicao2X,Posicao2Y,Velocidade2,Angle2,Valor2},
    Planeta3 = {Posicao3X,Posicao3Y,Velocidade3,Angle3,Valor3},
    Planeta4 = {Posicao4X,Posicao4Y,Velocidade4,Angle4,Valor4},
    {Planeta1,Planeta2,Planeta3,Planeta4}.

alteraPosicaoPlayer(_,{PosicaoX,PosicaoY,Angulo,Velocidade,Aceleracao})->
    %Aceleração ou constante ou 0
    NewVelocidade = Velocidade + Aceleracao / 10 - 0.1, 
    ForcaGravidade = 0.5,
    %Em 1 segundo a Velocidade=1 vai para 0 e avança 5.2 unidades no ecra
    NewPosicaoX = PosicaoX + Velocidade * Angulo - ForcaGravidade,
    NewPosicaoY = PosicaoY + Velocidade * Angulo - ForcaGravidade,
    {NewPosicaoX,NewPosicaoY,Angulo,NewVelocidade,Aceleracao-Aceleracao/10}.


newPosicaoPlayers(PlayersMap)->
    maps:fold(
        fun(Player, {PosicaoX,PosicaoY, Angulo, Velocidade, Aceleracao}, Acc) ->
            NovosAtributos = alteraPosicaoPlayer(Player, {PosicaoX,PosicaoY, Angulo, Velocidade, Aceleracao}),
            maps:put(Player, NovosAtributos, Acc)
        end,
        #{},
        PlayersMap
    ).

alteraPosicaoPlaneta(Planeta,{_,_,Angulo,Velocidade,DistSol})->
    NewPosicaoX = 540 + math:cos(Angulo) * DistSol,
    NewPosicaoY = 360 + math:sin(Angulo) * DistSol,
    NewAngulo = Angulo+Velocidade,
    {Planeta,{NewPosicaoX,NewPosicaoY,NewAngulo,Velocidade}}.

newPosicaoPlanetas(PlanetMap) ->
    maps:fold(
        fun(Planeta, {PosicaoX,PosicaoY,Angulo,Velocidade,DistSol}, Acc) ->
            NovaPosicao = 
                alteraPosicaoPlaneta(Planeta, {PosicaoX,PosicaoY,Angulo,Velocidade,DistSol}),
            maps:put(Planeta, NovaPosicao, Acc)
        end,
        #{},
        PlanetMap
    ).

loop(PlayersMap,PlanetMap)->
    %PlayerUsername : {PosicaoX,PosicaoY,Angulo,velocidade,aceleração} 
    %aceleração = velocidade_vetorial / alteração_do_tempo
    %Posição dos jogadores no espaço - ecran = 1080, 720
    %Planeta : PosiçãoX,PosicaoY,Angulo,Velocidade,DistSol,Tamanho

    receive
    after 1000/10 -> %tps = 10
        loop(newPosicaoPlayers(PlayersMap), newPosicaoPlanetas(PlanetMap))
    end.


% PRECISAR DE ATUALIZAR RECEBENDO SOCKETS DE POSIÇÕES