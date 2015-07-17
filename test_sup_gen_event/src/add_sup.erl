%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 30. 六月 2015 20:18
%%%-------------------------------------------------------------------
-module(add_sup).
-include("ets_arg.hrl").
-author("Administrator").

-behaviour(supervisor).

%% API
-export([start_link/0, start_child/1]).

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
	{ok, Pid} = supervisor:start_link({local, ?SERVER}, ?MODULE, []),
	case ets:lookup(?ETS, ?MODULE) of
		Object -> load_dynamic_proc(Object)
	end,
	{ok, Pid}.

start_child(_Type) ->
	{ok, Pid} = supervisor:start_child(?MODULE, []),
	case _Type of
		restart -> ok;
		_->ets:insert(?ETS,{?MODULE, ?SIMPLE, []})
	end,
	{ok, Pid}.

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
	MaxRestarts = 2,
	MaxSecondsBetweenRestarts = 100,
	
	SupFlags = {RestartStrategy, MaxRestarts, MaxSecondsBetweenRestarts},
	
	Restart = permanent,
	Shutdown = brutal_kill,
	Type = worker,
	
	AChild = {add2, {add2, start_link, []},
		Restart, Shutdown, Type, [add2]},
	
	{ok, {SupFlags, [AChild]}}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
load_dynamic_proc([])->
	ok;
load_dynamic_proc([H|T]) ->
	start_child(restart),
	load_dynamic_proc(T),
	{ok, H}.