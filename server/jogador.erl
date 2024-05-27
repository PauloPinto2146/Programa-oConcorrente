-module(jogador).
-export([startJogador/0]).

startJogador()->
    spawn(fun() -> loop(#{"ESQUERDO"=>0,"DIREITO"=>0,"CENTRAL"=>0}) end). 

loop(Keys)->
    %{ESQUERDO=>0,CENTRO=>0,DIREITO=>0}
    receive
        {check_keys,From}->
            From ! {receive_keys,Keys},
            loop(Keys);
        purp_esquerdo_pressionado->
            loop(maps:update("ESQUERDO", 1, Keys));
		purp_direito_pressionado->
            loop(maps:update("DIREITO", 1, Keys));
        purp_central_pressionado->
            loop(maps:update("CENTRAL", 1, Keys));
        purp_esquerdo_despressionado->
            loop(maps:update("ESQUERDO", 0, Keys));
        purp_direito_despressionado->
            loop(maps:update("DIREITO", 0, Keys));
        purp_central_despressionado->
			loop(maps:update("CENTRAL", 0, Keys))
    end.
