-module(test_sup_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
	application:start(sasl),
    test_sup_sup:start_link().

stop(_State) ->
    ok.
