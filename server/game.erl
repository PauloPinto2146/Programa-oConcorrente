-module(game).
-export([startGame/1,
geraValoresPlayers/1,
geraValoresPlanetas/0,
loop/2,
alteraPosicaoPlaneta/2,
alteraPosicaoPlayer/2,
get_player_by_socket/2,
receive_keys/1,
atualiza_com_keys/2,
clean_string/2,
get_Sockets/1]).
-import(level_system, [lose_game/1,win_game/1]).
-import(jogador, [startJogador/0]).

startGame(PlayerMap) -> 
    Size = maps:size(PlayerMap),
    case Size of 
        2 ->
            {Planeta1,Planeta2,Planeta3,Planeta4} = geraValoresPlanetas(),
            PlanetasMap = #{1 =>Planeta1,2 =>Planeta2,3 =>Planeta3,4 =>Planeta4},
            {PlayerValue1,PlayerValue2} = geraValoresPlayers(2),
            {_,_,_,_,Pid1} = PlayerValue1,
            {_,_,_,_,Pid2} = PlayerValue2,
            [Username1,Username2] = maps:keys(PlayerMap),
            [SocketFrom1,SocketFrom2] = maps:values(PlayerMap),
            [Socket1,From1] = SocketFrom1,
            [Socket2,From2] = SocketFrom2,
            PlayersMap = #{{Username1,Socket1,From1} => PlayerValue1, {Username2,Socket2,From2} => PlayerValue2},
            PidPartida = spawn(fun() -> loop(PlayersMap,PlanetasMap) end),
            From1 ! {partida_pid,PidPartida, Pid1},
            From2 ! {partida_pid,PidPartida, Pid2};
        3 ->
            {Planeta1,Planeta2,Planeta3,Planeta4} = geraValoresPlanetas(),
            PlanetasMap = #{1 =>Planeta1,2 =>Planeta2,3 =>Planeta3,4 =>Planeta4},
            {PlayerValue1,PlayerValue2,PlayerValue3} = geraValoresPlayers(3),
            {_,_,_,_,Pid1} = PlayerValue1,
            {_,_,_,_,Pid2} = PlayerValue2,
            {_,_,_,_,Pid3} = PlayerValue3,
            [Username1,Username2,Username3] = maps:keys(PlayerMap),
            [SocketFrom1,SocketFrom2,SocketFrom3] = maps:values(PlayerMap),
            [Socket1,From1] = SocketFrom1,
            [Socket2,From2] = SocketFrom2,
            [Socket3,From3] = SocketFrom3,
            PlayersMap = #{{Username1,Socket1,From1} => PlayerValue1, {Username2,Socket2,From2} => PlayerValue2,
                            {Username3,Socket3,From3} => PlayerValue3},
	        PidPartida = spawn(fun() -> loop(PlayersMap,PlanetasMap) end),
            From1 ! {partida_pid,PidPartida, Pid1},
            From2 ! {partida_pid,PidPartida, Pid2},
            From3 ! {partida_pid,PidPartida, Pid3};
        4 ->
            {Planeta1,Planeta2,Planeta3,Planeta4} = geraValoresPlanetas(),
            PlanetasMap = #{1 =>Planeta1,2 =>Planeta2,3 =>Planeta3,4 =>Planeta4}, 
            {PlayerValue1,PlayerValue2,PlayerValue3,PlayerValue4} = geraValoresPlayers(4),
            {_,_,_,_,Pid1} = PlayerValue1,
            {_,_,_,_,Pid2} = PlayerValue2,
            {_,_,_,_,Pid3} = PlayerValue3,
            {_,_,_,_,Pid4} = PlayerValue4,
            [Username1,Username2,Username3,Username4] = maps:keys(PlayerMap),
            [SocketFrom1,SocketFrom2,SocketFrom3,SocketFrom4] = maps:values(PlayerMap),
            [Socket1,From1] = SocketFrom1,
            [Socket2,From2] = SocketFrom2,
            [Socket3,From3] = SocketFrom3,
            [Socket4,From4] = SocketFrom4,
            PlayersMap = #{{Username1,Socket1,From1} => PlayerValue1, {Username2,Socket2,From2} => PlayerValue2,
                            {Username3,Socket3,From3} => PlayerValue3,{Username4,Socket4,From4} => PlayerValue4},
            PidPartida =  spawn(fun() -> loop(PlayersMap,PlanetasMap) end),
            From1 ! {partida_pid,PidPartida, Pid1},
            From2 ! {partida_pid,PidPartida, Pid2},
            From3 ! {partida_pid,PidPartida, Pid3},
            From4 ! {partida_pid,PidPartida, Pid4}
    end.

% Função para gerar um valor único

% Função para gerar uma lista de posições únicos
geraValoresPlayers(Number)->
    %Player : {PosicaoX,PosicaoY,Angulo,velocidade,aceleração} 

    Posicao1X = 50,
    Posicao2X = 1030,
    Posicao3X = 1030,
    Posicao4X = 50,
    Posicao1Y = 50,
    Posicao2Y = 690,
    Posicao3Y = 50,
    Posicao4Y = 690,

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
    case Number of
        2->
            Pid1 = startJogador(),
            Pid2 = startJogador(),
            Player1 = {100,Angle1,Velocidade1,Acel1,Pid1},
            Player2 = {100,Angle2,Velocidade2,Acel2,Pid2},
            {Player1,Player2};
        3->
            Pid1 = startJogador(),
            Pid2 = startJogador(),
            Pid3 = startJogador(),
            Player1 = {100,Angle1,Velocidade1,Acel1,Pid1},
            Player2 = {100,Angle2,Velocidade2,Acel2,Pid2},
            Player3 = {100,Angle3,Velocidade3,Acel3,Pid3},
            {Player1,Player2,Player3};
        4->
            Pid1 = startJogador(),
            Pid2 = startJogador(),
            Pid3 = startJogador(),
            Pid4 = startJogador(),
            Player1 = {100,Angle1,Velocidade1,Acel1,Pid1},
            Player2 = {100,Angle2,Velocidade2,Acel2,Pid2},
            Player3 = {100,Angle3,Velocidade3,Acel3,Pid3},
            Player4 = {100,Angle4,Velocidade4,Acel4,Pid4},
            {Player1,Player2,Player3,Player4}
    end.

%gerador de números aleatórios
geraValoresPlanetas()->
    %Planeta : PosiçãoX,PosicaoY,Angulo,Velocidade,DistSol,Tamanho
    Angle1 = (rand:uniform(361) - 1) * math:pi()/180,
    Angle2 = (rand:uniform(361) - 1) * math:pi()/180,
    Angle3 = (rand:uniform(361) - 1) * math:pi()/180,
    Angle4 = (rand:uniform(361) - 1) * math:pi()/180,
    Velocidade1 = 0.005 + rand:uniform() * (0.04 - 0.005),
    Velocidade2 = 0.001 + rand:uniform() * (0.02 - 0.001),
    Velocidade3 = 0.0008 + rand:uniform() * (0.012 - 0.0008),
    Velocidade4 = 0.0005 + rand:uniform() * (0.008 - 0.0005),
    Raio1 = 15,
    Raio2 = 25,
    Raio3 = 30,
    Raio4 = 36,
    %PosicaoX,PosicaoY,DistanciaDoSol
    Planeta1 = {Velocidade1,Angle1,Raio1},
    Planeta2 = {Velocidade2,Angle2,Raio2},
    Planeta3 = {Velocidade3,Angle3,Raio3},
    Planeta4 = {Velocidade4,Angle4,Raio4},
    {Planeta1,Planeta2,Planeta3,Planeta4}.

%POSICAO PLAYERS
alteraPosicaoPlayer(_,{Combustivel,Angulo,Velocidade,Aceleracao,Pid})->
    %Aceleração ou constante ou 0
    NewVelocidade = Velocidade + Aceleracao / 10 - 0.1,
    NewAceleracao = Aceleracao - Aceleracao / 10,
    %Em 1 segundo a Velocidade=1 vai para 0 e avança 5.2 unidades no ecra
    {Combustivel,Angulo,NewVelocidade,NewAceleracao,Pid}.
    
newPosicaoPlayers(PlayersMap)->
    NewPlayerMap = maps:map(fun(Player,Posicao) -> alteraPosicaoPlayer(Player, lists:last(maps:values(Posicao))) end, PlayersMap),
    NewPlayerMap.

%POSICAO PLANETAS
alteraPosicaoPlaneta(_,{Velocidade,Angulo,Raio})->
    NewAngulo = Angulo+Velocidade,
    {Velocidade,NewAngulo,Raio}.

newPosicaoPlanetas(PlanetMap) ->
    NewPlanetMap = maps:map(fun(Planet,Posicao) -> alteraPosicaoPlaneta(Planet, Posicao) end, PlanetMap),
    NewPlanetMap.
    
get_Sockets(PlayerMap)->
    Players = maps:keys(PlayerMap),
    SocketList = lists:map(fun({_,Socket,_})->Socket end, Players),
    SocketList.

get_player_by_socket(Socket, [{Player, Socket,_} | _Tail]) ->
        Player;
get_player_by_socket(Socket, [_Head | Tail]) ->
        get_player_by_socket(Socket, Tail);
get_player_by_socket(_Socket, []) ->
        undefined.

atualiza_com_keys(Key,Value)->
    {Combustivel,Angulo,Velocidade,Aceleracao,Pid} = Value,
    Pid ! {check_keys,self()},
    receive
        {receive_keys,Keys}->
            Esq= maps:get("ESQUERDO",Keys),
            Dir= maps:get("DIREITO",Keys),
            Centr= maps:get("CENTRAL",Keys),
            
            #{Key=>{
                Combustivel-((Esq+Dir+Centr)* 0.1),
                Angulo + (Esq-Dir),
                Velocidade,
                Aceleracao + (Centr*0.5),
                Pid
                }
            }
    end.

receive_keys(PlayersMap)->
    maps:map(fun(Key,Value) -> atualiza_com_keys(Key,Value) end,PlayersMap).

clean_string(PlayersMap,PlanetMap)->
    ListPosicaoPlanetas = maps:values(PlanetMap),
    StrPlanetas = lists:flatten(io_lib:format("~p", [ListPosicaoPlanetas])),
    CleanStrPlanetas = lists:flatten(string:replace(StrPlanetas, "\n", "", all)),
    
    ListPosicaoPlayers = maps:values(PlayersMap),
    StrPlayers = lists:flatten(io_lib:format("~p", [ListPosicaoPlayers])),
    CleanStrPlayers = lists:flatten(string:replace(StrPlayers, "\n", "", all)),

    CleanStrPlanetas++","++CleanStrPlayers.

loop(PlayersMap,PlanetMap)->
    %{PlayerUsername,Socket,Pid} : {Combustivel,Angulo,velocidade,aceleração,Pid} 
    %aceleração = velocidade_vetorial / alteração_do_tempo
    %Posição dos jogadores no espaço - ecran = 1080, 720
    %Planeta : {Velocidade,Angulo,DistSol}
    receive
        {disconnected,Sock}->
            Players = maps:keys(PlayersMap),
            Player = get_player_by_socket(Sock,Players),
            lose_game(Player),
            loop(maps:remove(Player,PlayersMap),PlanetMap)
        after 40 -> %tps = 25
            NewPlayerMap = receive_keys(PlayersMap),
            case maps:size(NewPlayerMap) of 
                1 ->
                    {Player,_}= maps:keys(NewPlayerMap),
                    win_game(Player);
                _ ->
                    Sockets = get_Sockets(NewPlayerMap),
                    CleantStr = clean_string(PlayersMap,PlanetMap),

                    lists:foreach(fun(Socket) -> gen_tcp:send(Socket,CleantStr) end, Sockets),

                    loop(newPosicaoPlayers(NewPlayerMap), newPosicaoPlanetas(PlanetMap))
        end
    end.

% PRECISAR DE ATUALIZAR RECEBENDO SOCKETS DE POSIÇÕES
% LANÇAR SOCKETS DE ATUALIZAÇÃO