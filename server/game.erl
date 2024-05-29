-module(game).
-export([startGame/1,
geraValoresPlayers/1,
geraValoresPlanetas/0,
loop/2,
alteraPosicaoPlaneta/2,
alteraPosicaoPlayer/1,
get_player_by_socket/2,
receive_keys/1,
atualiza_com_keys/2,
clean_string/2,
get_player_by_Pid/2,
check_collision/3,
get_Sockets/1]).
-import(level_system, [lose_game/2,win_game/2]).
-import(jogador, [startJogador/0]).

startGame(PlayerMap) -> 
    Size = maps:size(PlayerMap),
    case Size of 
        2 ->
            {Planeta1,Planeta2,Planeta3,Planeta4} = geraValoresPlanetas(),
            PlanetasMap = #{1 =>Planeta1,2 =>Planeta2,3 =>Planeta3,4 =>Planeta4},
            {PlayerValue1,PlayerValue2} = geraValoresPlayers(2),
            {_,_,_,_,Pid1,_,_} = PlayerValue1,
            {_,_,_,_,Pid2,_,_} = PlayerValue2,
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
            {_,_,_,_,Pid1,_,_} = PlayerValue1,
            {_,_,_,_,Pid2,_,_} = PlayerValue2,
            {_,_,_,_,Pid3,_,_} = PlayerValue3,
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
            {_,_,_,_,Pid1,_,_} = PlayerValue1,
            {_,_,_,_,Pid2,_,_} = PlayerValue2,
            {_,_,_,_,Pid3,_,_} = PlayerValue3,
            {_,_,_,_,Pid4,_,_} = PlayerValue4,
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
            Player1 = {100,Angle1,Velocidade1,Acel1,Pid1,Posicao1X,Posicao1Y},
            Player2 = {100,Angle2,Velocidade2,Acel2,Pid2,Posicao2X,Posicao2Y},
            {Player1,Player2};
        3->
            Pid1 = startJogador(),
            Pid2 = startJogador(),
            Pid3 = startJogador(),
            Player1 = {100,Angle1,Velocidade1,Acel1,Pid1,Posicao1X,Posicao1Y},
            Player2 = {100,Angle2,Velocidade2,Acel2,Pid2,Posicao2X,Posicao2Y},
            Player3 = {100,Angle3,Velocidade3,Acel3,Pid3,Posicao3X,Posicao3Y},
            {Player1,Player2,Player3};
        4->
            Pid1 = startJogador(),
            Pid2 = startJogador(),
            Pid3 = startJogador(),
            Pid4 = startJogador(),
            Player1 = {100,Angle1,Velocidade1,Acel1,Pid1,Posicao1X,Posicao1Y},
            Player2 = {100,Angle2,Velocidade2,Acel2,Pid2,Posicao2X,Posicao2Y},
            Player3 = {100,Angle3,Velocidade3,Acel3,Pid3,Posicao3X,Posicao3Y},
            Player4 = {100,Angle4,Velocidade4,Acel4,Pid4,Posicao4X,Posicao4Y},
            {Player1,Player2,Player3,Player4}
    end.

%gerador de números aleatórios
geraValoresPlanetas()->
    %Planeta : Angulo,Velocidade,raio,DistSol
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
    Planeta1 = {Velocidade1,Angle1,Raio1,120},
    Planeta2 = {Velocidade2,Angle2,Raio2,220},
    Planeta3 = {Velocidade3,Angle3,Raio3,280},
    Planeta4 = {Velocidade4,Angle4,Raio4,340},
    {Planeta1,Planeta2,Planeta3,Planeta4}.

%POSICAO PLAYERS
alteraPosicaoPlayer({Combustivel,Angulo,Velocidade,Aceleracao,Pid,PosicaoX,PosicaoY})->
    %Aceleração ou constante ou 0
    NewVelocidade = Velocidade + Aceleracao / 10,
    NewAceleracao = Aceleracao - Aceleracao / 10,
    if 
        Angulo > 0 ->
            NewAngulo = Angulo - 0.02;
        Angulo < 0 ->
            NewAngulo = Angulo + 0.02;
        Angulo == 0 ->
            NewAngulo = Angulo
    end,
    if 
        PosicaoX >= 560 andalso PosicaoY >= 360 ->
            NewPosicaoX = PosicaoX - 0.5,
            NewPosicaoY = PosicaoY - 0.3;
        PosicaoX >= 560 andalso PosicaoY =< 360 ->
            NewPosicaoX = PosicaoX - 0.5,
            NewPosicaoY = PosicaoY + 0.3;
        PosicaoX =< 560 andalso PosicaoY >= 360 ->
            NewPosicaoX = PosicaoX + 0.5,
            NewPosicaoY = PosicaoY - 0.3;
        PosicaoX =< 560 andalso PosicaoY =< 360 ->
            NewPosicaoX = PosicaoX + 0.5,
            NewPosicaoY = PosicaoY + 0.3
    end,
    %Em 1 segundo a Velocidade=1 vai para 0 e avança 5.2 unidades no ecra
    {Combustivel,NewAngulo,NewVelocidade,NewAceleracao,Pid,NewPosicaoX,NewPosicaoY}.
    
newPosicaoPlayers(PlayersMap)->
    NewPlayerMap = maps:map(fun(_Player,Posicao) ->                     
                    alteraPosicaoPlayer(Posicao) end, PlayersMap),
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

get_player_by_Pid(Pid, [{Player,Socket,Pid} | _Tail]) ->
    {Player,Socket,Pid};
get_player_by_Pid(Pid, [_Head | Tail]) ->
    get_player_by_Pid(Pid, Tail);
get_player_by_Pid(_Pid, []) ->
    undefined.

get_player_by_socket(Socket, [{Player, Socket,_} | _Tail]) ->
        Player;
get_player_by_socket(Socket, [_Head | Tail]) ->
        get_player_by_socket(Socket, Tail);
get_player_by_socket(_Socket, []) ->
        undefined.

atualiza_com_keys(_,Value)->
    {Combustivel,Angulo,Velocidade,Aceleracao,Pid,PosicaoX,PosicaoY} = Value,
    Pid ! {check_keys,self()},
    receive
        {receive_keys,Keys}->
            Esq = maps:get("ESQUERDO",Keys), 
            Dir = maps:get("DIREITO",Keys),
            Centr = maps:get("CENTRAL",Keys),
                {
                    Combustivel-((Esq+Dir+Centr)* 0.1),
                    Angulo + ((Esq-Dir)*0.05),
                    Velocidade,
                    Aceleracao + (Centr*0.2),
                    Pid, 
                    PosicaoX + (math:cos(Angulo)*Velocidade),
                    PosicaoY + (math:sin(Angulo)*Velocidade)
                }
    end.

within_radius(PosicaoX, PosicaoY, Posicao1X, Posicao1Y, Raio1) ->
    DistSquared = math:pow(PosicaoX - Posicao1X, 2) + math:pow(PosicaoY - Posicao1Y, 2),
    RaioSquared = math:pow(Raio1, 2),
    DistSquared < RaioSquared.

check_coll2(PlayersMap,PlanetMap)->
    {Player1,Player2} = maps:keys(PlayersMap),
    PlayerListReturn = [],
    %Calcular coordenadas dos planetas
    [Planeta1,Planeta2,Planeta3,Planeta4] = maps:values(PlanetMap),
    {_,Angle1,Raio1,DistSol1} = Planeta1,
    {_,Angle2,Raio2,DistSol2} = Planeta2,
    {_,Angle3,Raio3,DistSol3} = Planeta3,
    {_,Angle4,Raio4,DistSol4} = Planeta4,
    Posicao1X = math:cos(Angle1) * DistSol1,Posicao1Y = math:sin(Angle1) * DistSol1,
    Posicao2X = math:cos(Angle2) * DistSol2,Posicao2Y = math:sin(Angle2) * DistSol2,
    Posicao3X = math:cos(Angle3) * DistSol3,Posicao3Y = math:sin(Angle3) * DistSol3,
    Posicao4X = math:cos(Angle4) * DistSol4,Posicao4Y = math:sin(Angle4) * DistSol4,
    {_,_,_,_,_,PosicaoX,PosicaoY} = maps:get(Player1,PlayersMap),
    {_,_,_,_,_,PosicaoX2,PosicaoY2} = maps:get(Player2,PlayersMap),
    Check1 = within_radius(PosicaoX, PosicaoY, Posicao1X, Posicao1Y, Raio1),
    Check2 = within_radius(PosicaoX, PosicaoY, Posicao2X, Posicao2Y, Raio2),
    Check3 = within_radius(PosicaoX, PosicaoY, Posicao3X, Posicao3Y, Raio3),
    Check4 = within_radius(PosicaoX, PosicaoY, Posicao4X, Posicao4Y, Raio4),
    case {Check1,Check2,Check3,Check4} of 
        {false,false,false,false} ->
            PlayerListReturn = [];
        _ ->
            lists:append(Player1,PlayerListReturn)
    end,
    Check4 = within_radius(PosicaoX2, PosicaoY2, Posicao1X, Posicao1Y, Raio1),
    Check5 = within_radius(PosicaoX2, PosicaoY2, Posicao2X, Posicao2Y, Raio2),
    Check6 = within_radius(PosicaoX2, PosicaoY2, Posicao3X, Posicao3Y, Raio3),
    Check7 = within_radius(PosicaoX2, PosicaoY2, Posicao4X, Posicao4Y, Raio4),
    case {Check4,Check5,Check6,Check7} of 
        {false,false,false,false} ->
            PlayerListReturn = [];
        _ ->
            lists:append(Player1,PlayerListReturn)
    end,
    PlayerListReturn.

check_collision(PlayersMap,PlanetMap) ->
    case check_coll2(PlayersMap, PlanetMap) of 
        [] ->
            noColisions;
        PlayerList ->
            PlayerList
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

send_lose_game(Player,Socket,PlayersMap,PlanetMap)->
    lose_game(Player,Socket),
    loop(maps:remove(Player,PlayersMap),PlanetMap).

loop(PlayersMap,PlanetMap)->
    %{PlayerUsername,Socket,Pid} : {Combustivel,Angulo,velocidade,aceleração,Pid,PosicaoX,PosicaoY} 
    %aceleração = velocidade_vetorial / alteração_do_tempo
    %Posição dos jogadores no espaço - ecran = 1080, 720
    %Planeta : {Velocidade,Angulo,raio,DistSol}
    receive
        {disconnected,Sock,From}->
            Players = maps:keys(PlayersMap),
            Player = get_player_by_socket(Sock,Players),
            lose_game(Player,From),
            loop(maps:remove(Player,PlayersMap),PlanetMap)
    after 40 -> %tps = 25
        %Players = maps:keys(PlayersMap),
        io:format("self : ~p\n",[self()]),
        CheckList = check_collision(PlayersMap,PlanetMap),
        case CheckList of
            []->
                NewPlayerMap = receive_keys(PlayersMap),
                    case maps:size(NewPlayerMap) of 
                        1 ->
                            {Player,_,From}= maps:keys(NewPlayerMap),
                            win_game(Player,From);
                        _ ->
                            Sockets = get_Sockets(NewPlayerMap),
                            CleantStr = clean_string(PlayersMap,PlanetMap),
                            lists:foreach(fun(Socket) -> gen_tcp:send(Socket,CleantStr) end, Sockets),
                                
                            loop(newPosicaoPlayers(NewPlayerMap), newPosicaoPlanetas(PlanetMap));
            PlayerList ->
                list:foreach(fun({Player,Socket,_},PlayersMap,PlanetaMap) -> 
                    send_lose_game(Player,Socket,PlayersMap,PlanetaMap) end, PlayerList)
            end
        end
    end.