-module(game).
-export([startGame/1,
geraValoresPlayers/1,
geraValoresPlanetas/0,
loop/3,
alteraPosicaoPlaneta/2,
alteraPosicaoPlayer/1,
get_player_by_socket/2,
receive_keys/1,
atualiza_com_keys/2,
clean_string/2,
get_player_by_Pid/2,
check_collision/2,
check_collisionP/1,
check_collision_PP/2,
check_collisions_PP/2,
check_collisions_player_planet/3,
get_Sockets/1]).
-import(level_system, [lose_game/1,win_game/2]).
-import(jogador, [startJogador/0]).

startGame(PlayerMap) -> 
    Size = maps:size(PlayerMap),
    case Size of 
        2 ->
            {Planeta1,Planeta2,Planeta3,Planeta4} = geraValoresPlanetas(),
            PlanetasMap = #{1 =>Planeta1,2 =>Planeta2,3 =>Planeta3,4 =>Planeta4},
            {PlayerValue1,PlayerValue2} = geraValoresPlayers(2),
            {_,_,_,_,_,Pid1,_,_} = PlayerValue1,
            {_,_,_,_,_,Pid2,_,_} = PlayerValue2,
            [Username1,Username2] = maps:keys(PlayerMap),
            [SocketFrom1,SocketFrom2] = maps:values(PlayerMap),
            [Socket1,From1] = SocketFrom1,
            [Socket2,From2] = SocketFrom2,
            PlayersMap = #{{Username1,Socket1,From1} => PlayerValue1, {Username2,Socket2,From2} => PlayerValue2},
            PidPartida = spawn(fun() -> loop(PlayersMap,PlanetasMap,125) end),
            From1 ! {partida_pid,PidPartida, Pid1},
            From2 ! {partida_pid,PidPartida, Pid2};
        3 ->
            {Planeta1,Planeta2,Planeta3,Planeta4} = geraValoresPlanetas(),
            PlanetasMap = #{1 =>Planeta1,2 =>Planeta2,3 =>Planeta3,4 =>Planeta4},
            {PlayerValue1,PlayerValue2,PlayerValue3} = geraValoresPlayers(3),
            {_,_,_,_,_,Pid1,_,_} = PlayerValue1,
            {_,_,_,_,_,Pid2,_,_} = PlayerValue2,
            {_,_,_,_,_,Pid3,_,_} = PlayerValue3,
            [Username1,Username2,Username3] = maps:keys(PlayerMap),
            [SocketFrom1,SocketFrom2,SocketFrom3] = maps:values(PlayerMap),
            [Socket1,From1] = SocketFrom1,
            [Socket2,From2] = SocketFrom2,
            [Socket3,From3] = SocketFrom3,
            PlayersMap = #{{Username1,Socket1,From1} => PlayerValue1, {Username2,Socket2,From2} => PlayerValue2,
                            {Username3,Socket3,From3} => PlayerValue3},
            PidPartida = register(?MODULE,spawn(fun() -> loop(PlayersMap,PlanetasMap,125) end)),
            From1 ! {partida_pid,PidPartida, Pid1},
            From2 ! {partida_pid,PidPartida, Pid2},
            From3 ! {partida_pid,PidPartida, Pid3};
        4 ->
            {Planeta1,Planeta2,Planeta3,Planeta4} = geraValoresPlanetas(),
            PlanetasMap = #{1 =>Planeta1,2 =>Planeta2,3 =>Planeta3,4 =>Planeta4}, 
            {PlayerValue1,PlayerValue2,PlayerValue3,PlayerValue4} = geraValoresPlayers(4),
            {_,_,_,_,_,Pid1,_,_} = PlayerValue1,
            {_,_,_,_,_,Pid2,_,_} = PlayerValue2,
            {_,_,_,_,_,Pid3,_,_} = PlayerValue3,
            {_,_,_,_,_,Pid4,_,_} = PlayerValue4,
            [Username1,Username2,Username3,Username4] = maps:keys(PlayerMap),
            [SocketFrom1,SocketFrom2,SocketFrom3,SocketFrom4] = maps:values(PlayerMap),
            [Socket1,From1] = SocketFrom1,
            [Socket2,From2] = SocketFrom2,
            [Socket3,From3] = SocketFrom3,
            [Socket4,From4] = SocketFrom4,
            PlayersMap = #{{Username1,Socket1,From1} => PlayerValue1, {Username2,Socket2,From2} => PlayerValue2,
                            {Username3,Socket3,From3} => PlayerValue3,{Username4,Socket4,From4} => PlayerValue4},
            PidPartida = register(?MODULE,spawn(fun() -> loop(PlayersMap,PlanetasMap,125) end)),
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
    Posicao2Y = 670,
    Posicao3Y = 50,
    Posicao4Y = 670,
    Angle1 = -math:pi()/4,
    Angle2 = 3*math:pi()/4,
    Angle3 = -(3*math:pi()/4),
    Angle4 = math:pi()/4,
    %{PlayerUsername,Socket,Pid} : {Combustivel,Angulo,velocidade,VeX,VeY,Pid,PosicaoX,PosicaoY} 
    case Number of
        2->
            Pid1 = startJogador(),
            Pid2 = startJogador(),
            Player1 = {100,Angle1,0,0,0,Pid1,Posicao1X,Posicao1Y},
            Player2 = {100,Angle2,0,0,0,Pid2,Posicao2X,Posicao2Y},
            {Player1,Player2};
        3->
            Pid1 = startJogador(),
            Pid2 = startJogador(),
            Pid3 = startJogador(),
            Player1 = {100,Angle1,0,0,0,Pid1,Posicao1X,Posicao1Y},
            Player2 = {100,Angle2,0,0,0,Pid2,Posicao2X,Posicao2Y},
            Player3 = {100,Angle3,0,0,0,Pid3,Posicao3X,Posicao3Y},
            {Player1,Player2,Player3};
        4->
            Pid1 = startJogador(),
            Pid2 = startJogador(),
            Pid3 = startJogador(),
            Pid4 = startJogador(),
            Player1 = {100,Angle1,0,0,0,Pid1,Posicao1X,Posicao1Y},
            Player2 = {100,Angle2,0,0,0,Pid2,Posicao2X,Posicao2Y},
            Player3 = {100,Angle3,0,0,0,Pid3,Posicao3X,Posicao3Y},
            Player4 = {100,Angle4,0,0,0,Pid4,Posicao4X,Posicao4Y},
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
    Raio1 = 7.5,
    Raio2 = 12.5,
    Raio3 = 15,
    Raio4 = 18,
    Planeta1 = {Velocidade1,Angle1,Raio1,120},
    Planeta2 = {Velocidade2,Angle2,Raio2,220},
    Planeta3 = {Velocidade3,Angle3,Raio3,280},
    Planeta4 = {Velocidade4,Angle4,Raio4,340},
    {Planeta1,Planeta2,Planeta3,Planeta4}.

%POSICAO PLAYERS
alteraPosicaoPlayer({Combustivel,Angulo,Velocidade,VeX,VeY,Pid,PosicaoX,PosicaoY})->
    %Aceleração ou constante ou 0
    if 
        Velocidade > 0 ->
            NewVelocidade = Velocidade - 0.05;
        Velocidade =< 0 ->
            NewVelocidade = Velocidade
    end,
    if 
        VeX > 0 ->
            NewVeX = VeX - 0.1;
        VeX < 0 ->
            NewVeX = VeX + 0.1;
        VeX == 0 ->
            NewVeX = VeX 
    end,
    if 
        VeY > 0 ->
            NewVeY = VeY - 0.3;
        VeY < 0 ->
            NewVeY = VeY + 0.3;
        VeY == 0 ->
            NewVeY = VeY
    end,
    {TempPosicaoX, TempPosicaoY} =
        if 
            PosicaoX >= 540 andalso PosicaoY >= 360 ->
                {PosicaoX - 0.5, PosicaoY - 0.32};
            PosicaoX >= 540 andalso PosicaoY =< 360 ->
                {PosicaoX - 0.5, PosicaoY + 0.32};
            PosicaoX =< 540 andalso PosicaoY >= 360 ->
                {PosicaoX + 0.5, PosicaoY - 0.32};
            true -> % PosicaoX =< 560 andalso PosicaoY =< 360
                {PosicaoX + 0.5, PosicaoY + 0.32}
        end,
    NewPosicaoX = 
        if 
            TempPosicaoX > 1080 ->
                1080;
            TempPosicaoX < 0 ->
                0;
            true ->
                TempPosicaoX
        end,
    NewPosicaoY = 
        if 
            TempPosicaoY > 720 ->
                720;
            TempPosicaoY < 0 ->
                0;
            true ->
                TempPosicaoY
        end,
    {Combustivel,Angulo,NewVelocidade,NewVeX,NewVeY,Pid,NewPosicaoX,NewPosicaoY}.
    
newPosicaoPlayers(PlayersMap)->
    NewPlayerMap = maps:map(fun(_Player,Posicao) ->                     
                    alteraPosicaoPlayer(Posicao) end, PlayersMap),
    NewPlayerMap.

%POSICAO PLANETAS
alteraPosicaoPlaneta(_,{Velocidade,Angulo,Raio,DistSol})->
    NewAngulo = Angulo+Velocidade,
    {Velocidade,NewAngulo,Raio,DistSol}.

newPosicaoPlanetas(PlanetMap) ->
    NewPlanetMap = maps:map(fun(Planet,Posicao) -> alteraPosicaoPlaneta(Planet, Posicao) end, PlanetMap),
    NewPlanetMap.
    
get_Sockets(PlayerMap) ->
    Players = maps:keys(PlayerMap),
    SocketList = lists:map(fun({_,Socket,_}) -> Socket end, Players),
    SocketList.

get_player_by_Pid(Pid, [{Player,Socket,Pid} | _Tail]) ->
    {Player,Socket,Pid};
get_player_by_Pid(Pid, [_Head | Tail]) ->
    get_player_by_Pid(Pid, Tail);
get_player_by_Pid(_Pid, []) ->
    undefined.

get_player_by_socket(Socket, [{Player, Socket,Pid} | _Tail]) ->
    {Player, Socket,Pid};
get_player_by_socket(Socket, [_Head | Tail]) ->
    get_player_by_socket(Socket, Tail);
get_player_by_socket(_Socket, []) ->
    undefined.

atualiza_com_keys(_,Value)->
    {Combustivel,Angulo,Velocidade,VeX,VeY,Pid,PosicaoX,PosicaoY} = Value,
    Pid ! {check_keys,self()},
    receive
        {receive_keys,Keys}->
            Esq = maps:get("ESQUERDO",Keys), 
            Dir = maps:get("DIREITO",Keys),
            Centr = maps:get("CENTRAL",Keys),
            if 
            Combustivel > 0 ->
                {
                    Combustivel-((Esq+Dir+Centr)* 0.1),
                    Angulo + ((Esq-Dir)*2),
                    Velocidade + (Centr*0.1),
                    VeX,
                    VeY,
                    Pid, 
                    PosicaoX + (math:cos(Angulo*(math:pi()/180))*Velocidade) + VeX,
                    PosicaoY - (math:sin(Angulo*(math:pi()/180))*Velocidade) + VeY
                };
            Combustivel =< 0 ->
                {
                    Combustivel-((Esq+Dir+Centr)* 0.001),
                    Angulo,
                    Velocidade,
                    VeX,
                    VeY,
                    Pid, 
                    PosicaoX + (math:cos(Angulo*(math:pi()/180))*Velocidade)+ VeX,
                    PosicaoY - (math:sin(Angulo*(math:pi()/180))*Velocidade)+ VeY
                }
            end
    end.

within_radius(X,Y,XC,YC,Raio1,Raio2) ->
    D = math:pow(X - XC, 2) + math:pow(Y - YC, 2),
    R = math:pow(Raio1+Raio2, 2),
    D =< R.

check_collision(PlayersMap, PlanetMap) ->
    Players = maps:keys(PlayersMap), %[{Player1},{Player2},{Player3},...]
    Valores = maps:values(PlayersMap), %[{valor1},{valor2},{valor3},...]
    ValoresPlanetas = maps:values(PlanetMap), %[{valor1},{valor2},{valor3},...]
    check_collisions_player_planet(Players, Valores,ValoresPlanetas).

check_collisionP(PlayersMap) ->
    PlayersList = maps:to_list(PlayersMap),
    check_collisions_PP(PlayersList, PlayersList).

check_collisions_PP([], _PlayersList)->
    ok;
check_collisions_PP([Player | RestPl],PlayersList) when is_tuple(Player) ->
    check_collision_PP(Player,PlayersList),
    check_collisions_PP(RestPl,PlayersList).

check_collision_PP(_Player,[])->
    ok;
check_collision_PP({Key1,Value1},[{Key2,Value2}|RestPL2])->
    {Player1,Socket1,From1} = Key1,
    {Player2,Socket2,From2} = Key2,
    case {Player1,Socket1,From1} of 
        {Player2,Socket2,From2} ->
            check_collision_PP({{Player1, Socket1, From1}, Value1},RestPL2);
        _ ->
            {_,Angulo2,Velocidade2,_,_,_,X2,Y2} = Value2,
            {_,Angulo1,Velocidade1,_,_,_,X1,Y1} = Value1,
            NewVeX1 = Velocidade2 * math:cos(Angulo2),
            NewVeY1 = Velocidade2 * math:sin(Angulo2),
            NewVeX2 = Velocidade1 * math:cos(Angulo1),
            NewVeY2 = Velocidade1 * math:sin(Angulo1),
            case within_radius(X1,Y1,X2,Y2,17.5,17.5) of
                true ->
                    io:format("Collision detected between player ~p and ~p\n", [Player1,Player2]),
                    K1 = {Player1, Socket1, From1},
                    K2 = {Player1, Socket1, From1},
                    self() ! {colision,K1,K2,NewVeX1,NewVeY1,NewVeX2,NewVeY2};
                false -> 
                    ok
            end,
            check_collision_PP({{Player1,Socket1,From1}, Value1},RestPL2)
    end.
    

check_collisions_player_planet([],[], _PlanetMap) ->
    ok; % Se não houver mais players, retorna ok
check_collisions_player_planet([Player | RestPl],[Valor| RestVal], ValoresPlanetas) ->
    check_collision_player_planet(Player,Valor, ValoresPlanetas),
    check_collisions_player_planet(RestPl,RestVal, ValoresPlanetas).

check_collision_player_planet(_Player,_Valor, []) ->
    ok; % Se não houver mais planetas, retorna ok
check_collision_player_planet(Player, Valor, [Planet | Rest]) ->
    {_,_,_,_,_,_,X,Y} = Valor,
    {_,Angulo,Raio,DistSol} = Planet,
    XC = 540 + math:cos(Angulo) * DistSol,
    YC = 360 + math:sin(Angulo) * DistSol,
    case within_radius(X,Y,XC,YC,17.5, Raio) of
        true ->
            io:format("Collision detected with planet: ~p\n", [Player]),
            self() ! {lost, Player};
        false -> 
            ok
    end,
    case  within_radius(X,Y,540,360,17.5,75) of
        true ->
            io:format("Collision detected with sun: ~p\n", [Player]),
            self() ! {lost, Player};
        false -> 
            ok
    end,
    check_collision_player_planet(Player, Valor, Rest).    

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

loop(PlayersMap,PlanetMap,Countdown)->
    %{PlayerUsername,Socket,Pid} : {Combustivel,Angulo,velocidade,VeX,VeY,Pid,PosicaoX,PosicaoY} 
    %aceleração = velocidade_vetorial / alteração_do_tempo
    %Posição dos jogadores no espaço - ecran = 1080, 720
    %Planeta : {Velocidade,Angulo,raio,DistSol}
    receive
        {disconnected,Sock,From}->
            Players = maps:keys(PlayersMap),
            Player = get_player_by_socket(Sock,Players),
            {Username,Socket,PidJogador} = Player,
            lose_game(Username),
            PidJogador ! {lose_game_server,Username,Socket},
            NewPlayerMap = maps:remove(Player,PlayersMap),
            loop(NewPlayerMap,PlanetMap,Countdown);
        {lost, Player}->
            {Username,Socket,PidJogador} = Player,
            PidJogador ! {lose_game_server,Username,Socket},
            NewPlayerMap = maps:remove(Player,PlayersMap),
            io:format("NewPlayerMap: ~p~n",[NewPlayerMap]),
            loop(NewPlayerMap,PlanetMap,Countdown);
        {colision,K1,K2,NewVeX1,NewVeY1,NewVeX2,NewVeY2}->
            {C1,A1,V1,_,_,Pid1,PX1,PY1} = maps:get(K1, PlayersMap),
            {C2,A2,V2,_,_,Pid2,PX2,PY2} = maps:get(K2, PlayersMap),
            NewX1 = PX2 + (math:cos(A2*(math:pi()/180))*V2) + NewVeX2*2,
            NewY1 = PY2 - (math:sin(A2*(math:pi()/180))*V2) + NewVeY2*2,
            NewX2 = PX1 + (math:cos(A1*(math:pi()/180))*V1) + NewVeX1*2,
            NewY2 = PY1 - (math:sin(A1*(math:pi()/180))*V1) + NewVeY1*2,
            P1 = {C1,A1,V1,NewVeX1,NewVeY1,Pid1,NewX1,NewY1},
            P2 = {C2,A1,V2,NewVeX2,NewVeY2,Pid2,NewX2,NewY2},
            PM = maps:put(K1, P1, PlayersMap),
            NewPlayersMap = maps:put(K2, P2, PM),
            loop(NewPlayersMap,PlanetMap,Countdown)
    after 40 -> %tps = 25
        NewPlayerMap = receive_keys(PlayersMap),
        check_collision(NewPlayerMap,PlanetMap),
        check_collisionP(NewPlayerMap),
        timer:sleep(8),
            case maps:size(NewPlayerMap) of 
                1 ->
                    case Countdown of
                        0 ->
                            [{Player,Socket,From}] = maps:keys(NewPlayerMap),
                            gen_tcp:send(Socket,"win"),
                            Str = io_lib:format("20, ~p", [Player]),
                            From ! Str;
                        _ ->
                            Sockets = get_Sockets(NewPlayerMap),
                            CleantStr = clean_string(PlayersMap,PlanetMap),
                            lists:foreach(fun(Socket) -> gen_tcp:send(Socket,CleantStr) end, Sockets),  
                            loop(newPosicaoPlayers(NewPlayerMap), newPosicaoPlanetas(PlanetMap),Countdown-1)
                    end;
                _ ->
                    Sockets = get_Sockets(NewPlayerMap),
                    CleantStr = clean_string(PlayersMap,PlanetMap),
                    lists:foreach(fun(Socket) -> gen_tcp:send(Socket,CleantStr) end, Sockets),                            
                    loop(newPosicaoPlayers(NewPlayerMap), newPosicaoPlanetas(PlanetMap),Countdown)
            end
    end.