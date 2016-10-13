-module(exerltion_traces).
-export([crunch_numbers/0]).

crunch_numbers() ->
    undefined /= ets:info(data_table, size),
    crunch_all_numbers().

crunch_all_numbers() ->
    case goanna_api:pull_all_traces() of
        [] ->
            ok;
        Traces ->
            % {trace,<11704.104.0>,call,{timer,sleep,[1000]},{erl_eval,do_apply,6}}
            % {trace, _, call, {M,F,A},{_,_,_}}
            lists:foreach(
                fun({_, {trace,_Pid,call,{M,F,_Args},{_,_,_}}}) ->
                    inc(M,F);
                (S) ->
                    io:format("~p~n",[S])
            end, Traces),
        crunch_all_numbers()
    end.

inc(M,F) ->
    io:format("."),
    try
        ets:update_counter(data_table, {M,F}, {2, 1})
    catch
        error:badarg ->
            true = ets:insert(data_table, {{M,F}, 1})
    end.