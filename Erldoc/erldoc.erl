-module(erldoc).

-export([start/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start([ArgPath]) ->
	{ok, [{OutputDir, Paths}]} = file:consult(ArgPath),
	A = [{X, OutputDir} || X <- Paths],
	Len = length(A),
	Pid = self(),
	lists:foreach(fun(X) -> spawn_link(fun() -> process_file(Pid, X) end) end, A),
	process_results(Len).

process_file(Pid, {Path, OutputDir}) ->
	{DocName, Doc} = edoc:get_doc(Path),
	Str = lists:flatten(xmerl:export_simple([Doc], xmerl_xml)),
	OutputPath = OutputDir ++ "/" ++ atom_to_list(DocName) ++ ".xml",
	file:write_file(OutputPath, Str),
	Pid ! {ok, Path}.
	
process_results(0) ->
	io:format("~nDone!~n");
process_results(N) ->
	receive 
		_Any ->
			process_results(N - 1)
	end.
