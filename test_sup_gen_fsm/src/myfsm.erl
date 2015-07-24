%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. 七月 2015 18:13
%%%-------------------------------------------------------------------
-module(myfsm).
-author("EricLw").

-behaviour(gen_fsm).

%% API
-export([start_link/1, button/1, unlock/2, open/2, send/1, sync_send/1, sync_button/0, unlock/3,  close/2]).

%% gen_fsm callbacks
-export([init/1,
	handle_event/3,
	handle_sync_event/4,
	handle_info/3,
	terminate/3,
	code_change/4]).

-define(SERVER, mydoor).

-record(state, {}).

%%%===================================================================
%%% API
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% Creates a gen_fsm process which calls Module:init/1 to
%% initialize. To ensure a synchronized start-up procedure, this
%% function does not return until Module:init/1 has returned.
%%
%% @end
%%--------------------------------------------------------------------
start_link(Code) ->
	%%gen_fsm:start_link({local, ?SERVER}, ?MODULE, lists:reverse(Code), []).
	gen_fsm:start_link({local, ?SERVER}, ?MODULE, lists:reverse(Code), [{timeout, 1000}]).
button(Digital)->
	gen_fsm:send_event(?SERVER,{button,Digital}).
sync_button()->
	gen_fsm:sync_send_event(?SERVER,open).
	%%gen_fsm:sync_send_event(?SERVER,close,1000).
send(Data)->
	gen_fsm:send_all_state_event(?SERVER,{send,Data}).
sync_send(Data)->
	Res = gen_fsm:sync_send_all_state_event(?SERVER,{send,Data}),
	io:format("~p~n",[Res]),
	gen_fsm:sync_send_all_state_event(?SERVER,{send,Data ++ "_timeout"},3000).


%%%===================================================================
%%% gen_fsm callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Whenever a gen_fsm is started using gen_fsm:start/[3,4] or
%% gen_fsm:start_link/[3,4], this function is called by the new
%% process to initialize.
%%
%% @end
%%--------------------------------------------------------------------
-spec(init(Args :: term()) ->
	{ok, StateName :: atom(), StateData :: #state{}} |
	{ok, StateName :: atom(), StateData :: #state{}, timeout() | hibernate} |
	{stop, Reason :: term()} | ignore).
init(Code) ->
	%%timer:sleep(2000),
	%%{stop, Code}.
	%%ignore.
	{ok, unlock, {[],Code}}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% There should be one instance of this function for each possible
%% state name. Whenever a gen_fsm receives an event sent using
%% gen_fsm:send_event/2, the instance of this function with the same
%% name as the current state name StateName is called to handle
%% the event. It is also called if a timeout occurs.
%%
%% @end
%%--------------------------------------------------------------------
unlock({button,Digital}, {SoFar,Code}) ->
	case [Digital|SoFar] of
		    Code ->
			    io:format("Pass OK!~n"),
				do_unlock(),
			    {next_state, open, {[], Code},3000};
			InComplet when length(InComplet) < length(Code) ->
				io:format("Input:~p,InComplet~p,Code:~p~n",[Digital,[Digital|SoFar],Code]),
				{next_state, unlock, {InComplet, Code}};
			_Worng ->
				io:format("ReInput Password!~n"),
				{next_state, unlock, {[], Code}}
	end.

open({button,Data}, State) ->
	do_lock(),
	io:format("~p~n",[Data]),
	timer:sleep(1000),
	{next_state, unlock, State};
open(timeout, State) ->
	do_lock(),
	timer:sleep(1000),
	{next_state, unlock, State}.
%%--------------------------------------------------------------------
%% @private
%% @doc
%% There should be one instance of this function for each possible
%% state name. Whenever a gen_fsm receives an event sent using
%% gen_fsm:sync_send_event/[2,3], the instance of this function with
%% the same name as the current state name StateName is called to
%% handle the event.
%%
%% @end
%%--------------------------------------------------------------------
-spec(unlock(Event :: term(), From :: {pid(), term()},
	State :: #state{}) ->
	{next_state, NextStateName :: atom(), NextState :: #state{}} |
	{next_state, NextStateName :: atom(), NextState :: #state{},
		timeout() | hibernate} |
	{reply, Reply, NextStateName :: atom(), NextState :: #state{}} |
	{reply, Reply, NextStateName :: atom(), NextState :: #state{},
		timeout() | hibernate} |
	{stop, Reason :: normal | term(), NewState :: #state{}} |
	{stop, Reason :: normal | term(), Reply :: term(),
		NewState :: #state{}}).
unlock(open, _From, State) ->
	do_unlock(),
	gen_fsm:send_event_after(2500, {button, 48}),
	io:format("~p~p~n",[_From,State]),
	gen_fsm:reply(_From, {ok,"Successfly!"}),
	{next_state, close, State,1000}.
	%%Reply = ok,
	%%{reply, Reply, open, State,3000}.

close(timeout ,State) ->
	do_lock(),
	io:format("~p~p~n",["timeout",State]),
	{next_state, open, State, 1000}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Whenever a gen_fsm receives an event sent using
%% gen_fsm:send_all_state_event/2, this function is called to handle
%% the event.
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_event(Event :: term(), StateName :: atom(),
	StateData :: #state{}) ->
	{next_state, NextStateName :: atom(), NewStateData :: #state{}} |
	{next_state, NextStateName :: atom(), NewStateData :: #state{},
		timeout() | hibernate} |
	{stop, Reason :: term(), NewStateData :: #state{}}).
handle_event({send,Data}, StateName, State) ->
	io:format("Send Data:~p,StateName:~p,State,~p~n",[Data,StateName,State]),
	{next_state, StateName, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Whenever a gen_fsm receives an event sent using
%% gen_fsm:sync_send_all_state_event/[2,3], this function is called
%% to handle the event.
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_sync_event(Event :: term(), From :: {pid(), Tag :: term()},
	StateName :: atom(), StateData :: term()) ->
	{reply, Reply :: term(), NextStateName :: atom(), NewStateData :: term()} |
	{reply, Reply :: term(), NextStateName :: atom(), NewStateData :: term(),
		timeout() | hibernate} |
	{next_state, NextStateName :: atom(), NewStateData :: term()} |
	{next_state, NextStateName :: atom(), NewStateData :: term(),
		timeout() | hibernate} |
	{stop, Reason :: term(), Reply :: term(), NewStateData :: term()} |
	{stop, Reason :: term(), NewStateData :: term()}).
handle_sync_event({send,Data}, _From, StateName, State) ->
	timer:sleep(2000),
	{reply, {Data,StateName,State,_From}, StateName, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_fsm when it receives any
%% message other than a synchronous or asynchronous event
%% (or a system message).
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_info(Info :: term(), StateName :: atom(),
	StateData :: term()) ->
	{next_state, NextStateName :: atom(), NewStateData :: term()} |
	{next_state, NextStateName :: atom(), NewStateData :: term(),
		timeout() | hibernate} |
	{stop, Reason :: normal | term(), NewStateData :: term()}).
handle_info(_Info, StateName, State) ->
	{next_state, StateName, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_fsm when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_fsm terminates with
%% Reason. The return value is ignored.
%%
%% @end
%%--------------------------------------------------------------------
-spec(terminate(Reason :: normal | shutdown | {shutdown, term()}
| term(), StateName :: atom(), StateData :: term()) -> term()).
terminate(_Reason, _StateName, _State) ->
	io:format("myfsm::terminate:~p~n,~p~n,~p~n",[_Reason,_StateName,_State]),
	ok.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Convert process state when code is changed
%%
%% @end
%%--------------------------------------------------------------------
-spec(code_change(OldVsn :: term() | {down, term()}, StateName :: atom(),
	StateData :: #state{}, Extra :: term()) ->
	{ok, NextStateName :: atom(), NewStateData :: #state{}}).
code_change(_OldVsn, StateName, State, _Extra) ->
	{ok, StateName, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
do_lock()->
	io:format("The door closed!").

do_unlock()->
	io:format("The door opened!").


