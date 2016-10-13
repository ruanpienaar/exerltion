-module(exerltion_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

-include("exerltion.hrl").

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    exerltion_sup:start_link().

stop(_State) ->
    ok.
