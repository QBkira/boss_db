-module(boss_db_sup).
-author('emmiller@gmail.com').

-behaviour(supervisor).

-export([start_link/0, start_link/1]).

-export([init/1]).

start_link() ->
    start_link([]).

start_link(StartArgs) ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, StartArgs).

init(StartArgs) ->
    DBConnumber    = proplists:get_value(db_con_num, StartArgs, 10),
    DBMaxConnumber = proplists:get_value(db_max_con_num, StartArgs, 20),

    lager:info("Start Database sup con :~p. max_con: ~p", [DBConnumber, DBMaxConnumber]),
    Args = [{name, {local, boss_db_pool}},
        {worker_module, boss_db_controller},
        {size, DBConnumber}, {max_overflow, DBMaxConnumber}|StartArgs],
    PoolSpec = {db_controller, {poolboy, start_link, [Args]}, permanent, 2000, worker, [poolboy]},
    {ok, {{one_for_one, 10, 10}, [PoolSpec]}}.
