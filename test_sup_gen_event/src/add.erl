%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 30. 六月 2015 18:19
%%%-------------------------------------------------------------------
-module(add).
-author("Administrator").

-behaviour(gen_server).

%% API
-export([start_link/0, add1/2, add2/2, add3/2, add4/3, add5/3, add6/2, add7/2, add8/2, add9/2, add10/2, hibernate/0, exit/1]).

%% gen_server callbacks
-export([init/1,
	handle_call/3,
	handle_cast/2,
	handle_info/2,
	terminate/2,
	code_change/3]).

-define(SERVER, ?MODULE).

-record(state, {}).

%%%===================================================================
%%% API
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%%
%% @end
%%--------------------------------------------------------------------
-spec(start_link() ->
	{ok, Pid :: pid()} | ignore | {error, Reason :: term()}).
start_link() ->
	gen_server:start({local, ?SERVER}, ?MODULE, [], [{spawn_opt,[link,{priority, low},{fullsweep_after, 1024},{min_heap_size, 1024},{min_bin_vheap_size, 1024}]}]).

add1(Num1, Num2)->
	io:format("~nsync start~n"),
	Res = gen_server:call(?SERVER, {add1, Num1, Num2},100),
	io:format("~nsync end~n"),
	Res.

add2(Num1, Num2) ->
	io:format("~nasync start~n"),
	 Res = gen_server:cast(?SERVER, {add2, Num1, Num2}),
	io:format("~nasync end~n"),
	Res.

add3(Num1, Num2) ->
	io:format("~nsend start~n"),
	Res = erlang:send(?SERVER, {add3, Num1, Num2}),
	io:format("~nsend end~n"),
	Res.

add4(Node, Num1, Num2) ->
	io:format("~nsync start~n"),
	Res = gen_server:multi_call([Node], ?SERVER, {add1, Num1, Num2}),
	io:format("~nsync end~n"),
	Res.

add5(Node,Num1, Num2) ->
	io:format("~nasync start~n"),
	Res = gen_server:abcast([Node],?SERVER, {add2, Num1, Num2}),
	io:format("~nasync end~n"),
	Res.

add6( Num1, Num2) ->
	io:format("~nsync start~n"),
	Res = gen_server:multi_call(?SERVER, {add1, Num1, Num2}),
	io:format("~nsync end~n"),
	Res.

add7(Num1, Num2) ->
	io:format("~nasync start~n"),
	Res = gen_server:abcast(?SERVER, {add2, Num1, Num2}),
	io:format("~nasync end~n"),
	Res.
add8(Num1, Num2)->
	io:format("~nsync start~n"),
	Res = gen_server:call({?SERVER, local_node@liuwei}, {add1, Num1, Num2}),
	io:format("~nsync end~n"),
	Res.

add9( Num1, Num2) ->
	io:format("~nsync start~n"),
	Res = gen_server:multi_call(nodes(),?SERVER, {add1, Num1, Num2}, 1000),
	io:format("~nsync end~n"),
	Res.

add10(Num1, Num2)->
	io:format("~nsync start~n"),
	Res = gen_server:call(?SERVER, {noreply, Num1, Num2}),
	io:format("~nsync end~n"),
	Res.
hibernate() ->
	proc_lib:hibernate(?MODULE, add1, [1,5]).

exit(Msg) ->
	link(whereis(?MODULE)),
	erlang:exit(Msg).
%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Initializes the server
%%
%% @spec init(Args) -> {ok, State} |
%%                     {ok, State, Timeout} |
%%                     ignore |
%%                     {stop, Reason}
%% @end
%%--------------------------------------------------------------------
-spec(init(Args :: term()) ->
	{ok, State :: #state{}} | {ok, State :: #state{}, timeout() | hibernate} |
	{stop, Reason :: term()} | ignore).
init([]) ->
	%%timer:sleep(3000),
	%%process_flag(trap_exit, true),
	%%erlang:send_after(2000,?SERVER,{add3, 1, 1}),
	%%{ok, #state{}, hibernate}.
	%%{ok, #state{},3000}.
	{ok, #state{}}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling call messages
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_call(Request :: term(), From :: {pid(), Tag :: term()},
	State :: #state{}) ->
	{reply, Reply :: term(), NewState :: #state{}} |
	{reply, Reply :: term(), NewState :: #state{}, timeout() | hibernate} |
	{noreply, NewState :: #state{}} |
	{noreply, NewState :: #state{}, timeout() | hibernate} |
	{stop, Reason :: term(), Reply :: term(), NewState :: #state{}} |
	{stop, Reason :: term(), NewState :: #state{}}).

handle_call({add1, Num1, Num2}, _From, State) ->
	Num = Num1 + Num2,
	timer:sleep(3000),
	%%io:format("sleep end~n"),
	%%erlang:send_after(2000,?SERVER,{add3, 1, 1}),
	{reply, {ok, add1, Num}, State};
	%%{stop, i_like,{ok, add1_i_like, Num}, State};
handle_call({noreply, Num1, Num2}, _From, State) ->
	Num = Num1 + Num2,
	timer:sleep(3000),
	io:format("sleep end~n"),
	gen_server:reply(_From, {ok, gen_server_reply,Num}),
	{noreply,  State};
handle_call(_Request, _From, State) ->
	{reply, ok, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling cast messages
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_cast(Request :: term(), State :: #state{}) ->
	{noreply, NewState :: #state{}} |
	{noreply, NewState :: #state{}, timeout() | hibernate} |
	{stop, Reason :: term(), NewState :: #state{}}).
handle_cast({add2, Num1, Num2}, State) ->
	Num = Num1 + Num2,
	io:format("~n~p~n", [Num]),
	timer:sleep(3000),
	io:format("sleep end~n"),
	{noreply, State};
handle_cast(_Request, State) ->
	{noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling all non call/cast messages
%%
%% @spec handle_info(Info, State) -> {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
-spec(handle_info(Info :: timeout() | term(), State :: #state{}) ->
	{noreply, NewState :: #state{}} |
	{noreply, NewState :: #state{}, timeout() | hibernate} |
	{stop, Reason :: term(), NewState :: #state{}}).
handle_info(timeout, State) ->
	io:format("~ntimeout__ericlw~n"),
	{noreply, State};
handle_info(stop, State) ->
	io:format("stop"),
	{stop, normal_ericlw, State};
handle_info({add3, Num1, Num2}, State) ->
	Num = Num1 / Num2,
	io:format("~n~p~n", [Num]),
	timer:sleep(3000),
	io:format("sleep end~n"),
	{noreply, State};
handle_info({'EXIT', From, Reson}, State) ->
	io:format("~p~p~n",[From, Reson]),
	{noreply, State};
handle_info(_Info, State) ->
	{noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
%%
%% @spec terminate(Reason, State) -> void()
%% @end
%%--------------------------------------------------------------------
-spec(terminate(Reason :: (normal | shutdown | {shutdown, term()} | term()),
	State :: #state{}) -> term()).
terminate(_Reason, _State) ->
	timer:sleep(3000),
	io:format("~nclean up~n"),
	ok.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Convert process state when code is changed
%%
%% @spec code_change(OldVsn, State, Extra) -> {ok, NewState}
%% @end
%%--------------------------------------------------------------------
-spec(code_change(OldVsn :: term() | {down, term()}, State :: #state{},
	Extra :: term()) ->
	{ok, NewState :: #state{}} | {error, Reason :: term()}).
code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
