-module(enter).
-author("EricLw").


%% API
-export([start_link/0, init/1]).
%% API
-export([ add1/2, add2/2, add3/2]).

%% gen_server callbacks
-export([
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

start_link() ->
	proc_lib:start_link(?SERVER, init, [self()]).

add1(Num1, Num2)->
	io:format("~nsync start~n"),
	Res = gen_server:call(?SERVER, {add1, Num1, Num2}),
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

init(Person) ->
	proc_lib:init_ack(Person, {ok, self()}),
	register(?MODULE, self()),
	gen_server:enter_loop(?MODULE, [], #state{},{local,?MODULE}).

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
	io:format("sleep end~n"),
	{reply, {ok, add1, Num}, State};
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
handle_info({add3, Num1, Num2}, State) ->
	Num = Num1 / Num2,
	io:format("~n~p~n", [Num]),
	timer:sleep(3000),
	io:format("sleep end~n"),
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
