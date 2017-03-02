-module(exerltion_traces).
-export([crunch_numbers/1]).

crunch_numbers(TopXnum) ->
    NowSecs = calendar:datetime_to_gregorian_seconds(calendar:now_to_datetime(now())),
    TblName = list_to_atom("data_table_" ++ integer_to_list(NowSecs)),
    TblName = ets:new(TblName, [public, named_table]),
    ok = crunch_all_numbers(TblName),
    print_sorted_top_results(TblName,TopXnum),
    TblName.

crunch_all_numbers(T) ->
    case goanna_api:pull_all_traces() of
        [] ->
            ok;
        Traces ->
            %% TODO: create counts for call, exceptins, spawns, links etc etc etc
            lists:foreach(
                fun({_, {trace_ts,_Pid,call,{M,F,_Args},{_,_,_},_}}) ->
                    inc(T,M,F);
                (_) ->
                    ok
            end, Traces),
        crunch_all_numbers(T)
    end.

inc(T,M,F) ->
    try
        ets:update_counter(T, {M,F}, {2, 1})
    catch
        error:badarg ->
            true = ets:insert(T, {{M,F}, 1})
    end.

print_sorted_top_results(T,TopXnum) ->
    Sorted = sort(T),
    io:format("~n.............................~n"),
    print_top(T,Sorted, 0, TopXnum).

print_top(_,[], _, _) ->
    io:format("~n.............................~n");
print_top(_, _ ,_, 0) ->
    io:format("~n.............................~n");
print_top(T, [{{M,F},Count}|R], Nmr, TopXnum) when TopXnum>0 ->
    NewNmr = Nmr+1,
    io:format("~p) ~p:~p #~p\n", [NewNmr, M, F, Count]),
    print_top(T, R, NewNmr, TopXnum-1).

sort(T) ->
    lists:sort(fun(
        {{_Ma,_Fa},Counta},
        {{_Mb,_Fb},Countb}) ->
            Countb =< Counta
    end, ets:tab2list(T)).