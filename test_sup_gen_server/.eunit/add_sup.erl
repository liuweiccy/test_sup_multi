%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 30. 六月 2015 20:18
%%%-------------------------------------------------------------------
-module(add_sup).
-author("Administrator").

-behaviour(supervisor).

%% API
-export([start_link/0, start_child/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%%===================================================================
%%% API functions
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% Starts the supervisor
%%
%% @end
%%--------------------------------------------------------------------
-spec(start_link() ->
	{ok, Pid :: pid()} | ignore | {error, Reason :: term()}).
start_link() ->
	supervisor:start_link({local, ?SERVER}, ?MODULE, []).

start_child() ->
	supervisor:start_child(?MODULE, []).

%%%===================================================================
%%% Supervisor callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Whenever a supervisor is started using supervisor:start_link/[2,3],
%% this function is called by the new process to find out about
%% restart strategy, maximum restart frequency and child
%% specifications.
%%
%% @end
%%--------------------------------------------------------------------
-spec(init(Args :: term()) ->
	{ok, {SupFlags :: {RestartStrategy :: supervisor:strategy(),
		MaxR :: non_neg_integer(), MaxT :: non_neg_integer()},
		[ChildSpec :: supervisor:child_spec()]
	}} |
	ignore |
	{error, Reason :: term()}).
init([]) ->
	RestartStrategy = simple_one_for_one,
	MaxRestarts = 1000,
	MaxSecondsBetweenRestarts = 3600,
	
	SupFlags = {RestartStrategy, MaxRestarts, MaxSecondsBetweenRestarts},
	
	Restart = permanent,
	Shutdown = 2000,
	Type = worker,
	
	AChild = {add2, {add2, start_link, []},
		Restart, Shutdown, Type, [add2]},
	
	{ok, {SupFlags, [AChild]}}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
