%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 30. 六月 2015 18:30
%%%-------------------------------------------------------------------
-module(my_handle).
-author("Administrator").

%% API
-export([add_child/1]).

add_child(Sup) ->
	case Sup of
		add1 ->
			Spec = get_Spec(1),
			test_sup_sup:start_child(Spec);
		add_sup ->
			Spec = get_Spec(2),
			test_sup_sup:start_child(Spec);
		add2 ->
			add_sup:start_child([]);
		common ->
			Spec = get_Spec(3),
			test_sup_sup:start_child(Spec);
		myevent ->
			Spec = get_Spec(4),
			test_sup_sup:start_child(Spec);
		_ ->
			ok
	end.

get_Spec(No)->
	Spec = case No of
		1 ->{add1, {add1, start_link, []}, temporary, 10000, worker, [add1]};
        2 ->{add_sup, {add_sup, start_link, []}, permanent, brutal_kill, supervisor, [add_sup]};
        3 ->{common, {common, start_link, []}, permanent, 10000, worker, [common]};
        4 ->{myevent, {myevent, start_link, []}, permanent, brutal_kill, worker, [myevent]};
		_ ->{undefined, {add, start_link, []}, temporary, brutal_kill, worker, [add]}
	end,
	Spec.
