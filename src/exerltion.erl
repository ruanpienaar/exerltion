-module(exerltion).
-export([
    start/0,
    stop/1,
    record/2,
    record/3,
    clear/1
]).
-include("exerltion.hrl").

start() ->
    [ case application:start(X) of
        ok ->
            ok;
        {error,{already_started,X}} ->
            ok
      end
     || X <-
        [asn1,
         crypto,
         public_key,
         ssl,
         compiler,
         inets,
         syntax_tools,
         sasl,
         goldrush,
         lager,
         goanna,
         exerltion]
    ].

record(Node, Cookie) ->
    %% TODO: allow multiple nodes.......
    record(Node, Cookie, 10*1000).

record(Node, Cookie, MSecs) ->
    case goanna_api:add_node(Node, Cookie, tcpip_port) of
        {ok,_Pid} ->
            ok;
        {error,{already_started,_Pid}} ->
            ok
    end,
    timer:sleep(500),
    %% TODO: implement, and use sync add node...
    AllList = rpc:call(Node, code, all_loaded, []),
    A = [ Mod || {Mod, _Path} <- AllList, not lists:member(Mod, sensitive_modules()) ],
    goanna_api:trace_modules(A),
    timer:apply_after(MSecs, ?MODULE, stop, [Node]).

stop(Node) ->
    ?EMERGENCY("!!!~n~n~n STOP ~n~n~n!!!"),
    ok = goanna_api:stop_trace(),
    ok = exerltion_traces:crunch_numbers(),
    goanna_api:remove_node(Node).

clear(Node) ->
    %% TODO: clear ets table..
    ok.

sensitive_modules() ->
    [
        io,
        erl_distribution,
        edlin,
        error_handler,
        io_lib,
        filename,
        unicode,
        orddict,
        gb_sets,
        inet_db,
        inet,
        ordsets,
        group,
        gen,
        erl_scan,
        kernel,
        erl_eval,
        queue,
        ets,
        lists,
        sets,
        inet_udp,
        io_lib_pretty,
        code,
        ram_file,
        dict,
        binary,
        gen_event,
        heart,
        io_lib_format,
        erl_lint,
        erl_anno,
        kernel_config,
        gen_server,
        proc_lib,
        application,
        global,
        otp_internal,
        erl_internal,
        code_server,
        file_server,
        beam_lib,
        epp,
        os,
        rpc,
        c,
        file_io_server,
        inet_config,
        user_drv,
        inet_parse,
        hipe_unified_loader,
        error_logger,
        standard_error,
        global_group,
        shell,
        file,
        proplists,
        net_kernel,
        error_logger_tty_h,
        supervisor_bridge,
        gb_trees,
        application_master,
        erl_parse,
        edlin_expand,
        supervisor,
        application_controller,
        user_sup,

        erts_internal,
        prim_file,
        erlang,
        erl_prim_loader,
        init,
        dbg,
        prim_inet,
        inet_tcp_dist,
        dist_util

    ].