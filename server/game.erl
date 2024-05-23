-module(game).
-export([startGame/0,geraValoresPlanetas/0,loop/2,alteraPosicaoPlanet/2,alteraPosicaoPlayer/2]).

startGame() -> 
    receive
        {startGame, PlayerList} when length(PlayerList) =:= 2 ->
            {Planeta1,Planeta2,Planeta3,Planeta4} = geraValoresPlanetas(),
            PlanetasMap = #{},
            maps:put(1, Planeta1, PlanetasMap),  
            maps:put(2, Planeta2, PlanetasMap),
            maps:put(3, Planeta3, PlanetasMap),
            maps:put(4, Planeta4, PlanetasMap),
            PlayersMap = #{},      
	        register(?MODULE,spawn(fun() -> loop(PlayersMap,PlanetasMap) end));
        {startGame, PlayerList} when length(PlayerList) =:= 3 ->
            {Planeta1,Planeta2,Planeta3,Planeta4} = geraValoresPlanetas(),
            PlanetasMap = #{},
            maps:put(1, Planeta1, PlanetasMap),  
            maps:put(2, Planeta2, PlanetasMap),
            maps:put(3, Planeta3, PlanetasMap),
            maps:put(4, Planeta4, PlanetasMap),
            PlayersMap = #{},    
	        register(?MODULE,spawn(fun() -> loop(PlayersMap,PlanetasMap) end));
        {startGame, PlayerList} when length(PlayerList) =:= 4 ->
            {Planeta1,Planeta2,Planeta3,Planeta4} = geraValoresPlanetas(),
            PlanetasMap = #{},
            maps:put(1, Planeta1, PlanetasMap),  
            maps:put(2, Planeta2, PlanetasMap),  
            maps:put(3, Planeta3, PlanetasMap),
            maps:put(4, Planeta4, PlanetasMap),    
            PlayersMap = #{},
	        register(?MODULE,spawn(fun() -> loop(PlayersMap,PlanetasMap) end))
    end.

%gerador de números aleatórios
geraValoresPlanetas()->
    %Planetas
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
    Posicao1X = 540+math:cos(Angle1)*120,
    Posicao1Y = 360+math:cos(Angle1)*120,
    Valor1 = 120,
    Posicao2X = 540+math:cos(Angle2)*120,
    Posicao2Y = 360+math:cos(Angle2)*220,
    Valor2 = 220,
    Posicao3X = 540+math:cos(Angle3)*120,
    Posicao3Y = 360+math:cos(Angle3)*280,
    Valor3 = 280,
    Posicao4X = 540+math:cos(Angle4)*120,
    Posicao4Y = 360+math:cos(Angle4)*340,
    Valor4 = 340,
    Planeta1 = {Posicao1X,Posicao1Y,Velocidade1,Angle1,Valor1},
    Planeta2 = {Posicao2X,Posicao2Y,Velocidade2,Angle2,Valor2},
    Planeta3 = {Posicao3X,Posicao3Y,Velocidade3,Angle3,Valor3},
    Planeta4 = {Posicao4X,Posicao4Y,Velocidade4,Angle4,Valor4},
    {Planeta1,Planeta2,Planeta3,Planeta4}.

alteraPosicaoPlayer(_,{PosicaoX,PosicaoY,Angulo,Velocidade,Aceleracao})->
    %Aceleração ou constante ou 0
    NewVelocidade = Velocidade + Aceleracao / 10 - 0.1, 
    %Em 1 segundo a Velocidade=1 vai para 0 e avança 5.2 unidades no ecra
    NewPosicaoX = PosicaoX + Velocidade * Angulo,
    NewPosicaoY = PosicaoY + Velocidade * Angulo,
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

alteraPosicaoPlanet(Planeta,{_,_,Angulo,Velocidade,DistSol})->
    NewPosicaoX = 540 + math:cos(Angulo) * DistSol,
    NewPosicaoY = 360 + math:sin(Angulo) * DistSol,
    NewAngulo = Angulo+Velocidade,
    {Planeta,{NewPosicaoX,NewPosicaoY,NewAngulo,Velocidade}}.

newPosicaoPlanets(PlanetMap) ->
    maps:fold(
        fun(Planeta, {PosicaoX,PosicaoY,Angulo,Velocidade,DistSol}, Acc) ->
            NovaPosicao = alteraPosicaoPlanet(Planeta, {PosicaoX,PosicaoY,Angulo,Velocidade,DistSol}),
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
        loop(newPosicaoPlayers(PlayersMap), newPosicaoPlanets(PlanetMap))
    end.