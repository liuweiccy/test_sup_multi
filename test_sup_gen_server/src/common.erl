%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 01. 七月 2015 10:49
%%%-------------------------------------------------------------------
-module(common).
-author("Administrator").

%% API
-export([start_link/0, start_loop/2]).

start_link() ->
	Res = proc_lib:start_link(?MODULE, start_loop, [self(), ?MODULE]),
	Res.

start_loop(Parent,Name) ->
	register(Name, self()),
	proc_lib:init_ack(Parent, {ok, self()}),
	loop().

loop()->
	receive
		Args ->
			io:format("args:~p~n",[Args])
	end.


