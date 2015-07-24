%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 02. 七月 2015 18:07
%%%-------------------------------------------------------------------
-module(myevent).
-author("Administrator").

-behaviour(gen_event).

%% API
-export([start_link/0,
	add_handler/0, notity/0, notityerr/0, call/0, callerr/0, senderr/0, send/0, delete/0, notity_sync/0, count/0, swap/0, stop/0, add_sup_handler/0, delete/1]).

%% gen_event callbacks
-export([init/1,
	handle_event/2,
	handle_call/2,
	handle_info/2,
	terminate/2,
	code_change/3]).

-define(SERVER, liuweiEventManager).

-record(state, {}).

%%%===================================================================
%%% gen_event callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% Creates an event manager
%%
%% @end
%%--------------------------------------------------------------------
-spec(start_link() -> {ok, pid()} | {error, {already_started, pid()}}).
start_link() ->
	{Flag,Pid} = gen_event:start_link({local, ?SERVER}),
	case Flag =:= ok of
		true ->
			%%add_handler(),
			{Flag,Pid};
		false ->
			{Flag,Pid}
	end.

%%--------------------------------------------------------------------
%% @doc
%% Adds an event handler
%%
%% @end
%%--------------------------------------------------------------------
-spec(add_handler() -> ok | {'EXIT', Reason :: term()} | term()).
add_handler() ->
	gen_event:add_handler(?SERVER, ?MODULE, []).
	%%gen_event:add_sup_handler(?SERVER, myerror, []),
	%%gen_event:add_handler(?SERVER, myerror, []).

add_sup_handler()->
	gen_event:add_sup_handler(?SERVER, myerror, ["add_sup_handler:myerror"]).

swap() ->
	%%gen_event:swap_sup_handler(?SERVER,{myerror,nomal_swap},{?MODULE,[]}).
	gen_event:swap_handler(?SERVER,{myerror,normal_swap},{?MODULE,[]}).

notity()->
	gen_event:notify(?SERVER,liuwei).
notity_sync()->
	gen_event:sync_notify(?SERVER,liuwei_sync).

notityerr()->
	io:format("self:~p~n",[self()]),
	gen_event:notify(?SERVER,liuwei_err).

call() ->
	gen_event:call(?SERVER,?MODULE,callinfo).
callerr() ->
	gen_event:call(?SERVER,myerror,callerr).

send() ->
	erlang:send(?SERVER,info).
senderr() ->
	erlang:send(?SERVER,infoerr).

delete()->
	gen_event:delete_handler(?SERVER,myerror,[]).
delete(Handler)->
	gen_event:delete_handler(?SERVER,Handler,[]).

count()->
	Handlers = gen_event:which_handlers(?SERVER),
	io:format("handles count:~p~n",[erlang:length(Handlers)]),
	Handlers.

stop()->
	gen_event:stop(?SERVER).
%%%===================================================================
%%% gen_event callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Whenever a new event handler is added to an event manager,
%% this function is called to initialize the event handler.
%%
%% @end
%%--------------------------------------------------------------------
-spec(init(InitArgs :: term()) ->
	{ok, State :: #state{}} |
	{ok, State :: #state{}, hibernate} |
	{error, Reason :: term()}).
init(_Args) ->
	process_flag(trap_exit, true),
	timer:sleep(2000),
	io:format("Args:~p~n",[_Args]),
	{ok, #state{}}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Whenever an event manager receives an event sent using
%% gen_event:notify/2 or gen_event:sync_notify/2, this function is
%% called for each installed event handler to handle the event.
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_event(Event :: term(), State :: #state{}) ->
	{ok, NewState :: #state{}} |
	{ok, NewState :: #state{}, hibernate} |
	{swap_handler, Args1 :: term(), NewState :: #state{},
		Handler2 :: (atom() | {atom(), Id :: term()}), Args2 :: term()} |
	remove_handler).
handle_event(_Event, State) ->
	%%timer:sleep(2000),
	io:format("Event:~p~n",[_Event]),
	%%remove_handler.
	%%{swap_handler,[],State,myerror,[]}.
	{ok, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Whenever an event manager receives a request sent using
%% gen_event:call/3,4, this function is called for the specified
%% event handler to handle the request.
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_call(Request :: term(), State :: #state{}) ->
	{ok, Reply :: term(), NewState :: #state{}} |
	{ok, Reply :: term(), NewState :: #state{}, hibernate} |
	{swap_handler, Reply :: term(), Args1 :: term(), NewState :: #state{},
		Handler2 :: (atom() | {atom(), Id :: term()}), Args2 :: term()} |
	{remove_handler, Reply :: term()}).
handle_call(_Request, State) ->
	%%timer:sleep(2000),
	io:format("myevent::call:~p~n",[_Request]),
	Reply = ok,
	{ok, Reply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called for each installed event handler when
%% an event manager receives any other message than an event or a
%% synchronous request (or a system message).
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_info(Info :: term(), State :: #state{}) ->
	{ok, NewState :: #state{}} |
	{ok, NewState :: #state{}, hibernate} |
	{swap_handler, Args1 :: term(), NewState :: #state{},
		Handler2 :: (atom() | {atom(), Id :: term()}), Args2 :: term()} |
	remove_handler).
handle_info(_Info, State) ->
	io:format("myevent::info:~p~n",[_Info]),
	{ok, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Whenever an event handler is deleted from an event manager, this
%% function is called. It should be the opposite of Module:init/1 and
%% do any necessary cleaning up.
%%
%% @spec terminate(Reason, State) -> void()
%% @end
%%--------------------------------------------------------------------
-spec(terminate(Args :: (term() | {stop, Reason :: term()} | stop |
remove_handler | {error, {'EXIT', Reason :: term()}} |
{error, term()}), State :: term()) -> term()).
terminate(_Arg, _State) ->
	io:format("myevent::terminate:~p~n",[_Arg]),
	ok.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Convert process state when code is changed
%%
%% @end
%%--------------------------------------------------------------------
-spec(code_change(OldVsn :: term() | {down, term()}, State :: #state{},
	Extra :: term()) ->
	{ok, NewState :: #state{}}).
code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
