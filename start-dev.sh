#!/bin/sh
cd `dirname $0`
exec erl -sname exerltion -config $PWD/sys.config -pa $PWD/ebin $PWD/deps/*/ebin $PWD/test -boot start_sasl -cookie exerltion -s exerltion start -proto_dist hawk_tcp -hidden