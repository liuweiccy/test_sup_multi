
-module(test_sup_sup).

-behaviour(supervisor).

%% API
-export([start_link/0, start_child/1]).

%% Supervisor callbacks
-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

start_child(Spec) ->
	supervisor:start_child(?MODULE, Spec).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->
    {ok, { {one_for_one, 5, 10}, [
	    {add, {add,start_link,[]},
		    permanent,10000,
		    worker,[add]
	    },
	    {common, {common, start_link, []}, permanent, 1000, worker, [common]}
    ]} }.

