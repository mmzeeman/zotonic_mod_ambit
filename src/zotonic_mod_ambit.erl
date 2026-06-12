%% @author Maas-Maarten Zeeman <mmzeeman@xs4all.nl>
%% @copyright 2024 Maas-Maarten Zeeman
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.

%% @doc Zotonic module for geographic indexing and search using ambit
%%      icosahedral triangular cells.

-module(zotonic_mod_ambit).
-author("Maas-Maarten Zeeman <mmzeeman@xs4all.nl>").

-mod_title("Ambit Geographic Search").
-mod_description("Geographic indexing and search using ambit icosahedral triangular cells.").
-mod_prio(500).
-mod_depends([]).
-mod_provides([]).

-behaviour(gen_server).

-include_lib("zotonic_core/include/zotonic.hrl").

%% API
-export([start_link/1]).

%% gen_server callbacks
-export([
    init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3
]).

%% Zotonic observer callbacks
-export([
    observe_rsc_update_done/2,
    observe_search_query/2
]).

-record(state, {context :: z:context()}).


%% ---------------------------------------------------------------------------
%% API
%% ---------------------------------------------------------------------------

%% @doc Start the module gen_server.
%% @spec start_link(Args :: proplists:proplist()) -> {ok, pid()} | {error, term()}
-spec start_link(proplists:proplist()) -> {ok, pid()} | {error, term()}.
start_link(Args) ->
    Context = proplists:get_value(context, Args),
    gen_server:start_link(?MODULE, [Context], []).


%% ---------------------------------------------------------------------------
%% gen_server callbacks
%% ---------------------------------------------------------------------------

%% @doc Initialise the gen_server state.
-spec init([z:context()]) -> {ok, #state{}}.
init([Context]) ->
    logger:info("[zotonic_mod_ambit] starting on site ~p", [z_context:site(Context)]),
    {ok, #state{context = Context}}.

%% @doc Handle synchronous calls.
-spec handle_call(term(), {pid(), term()}, #state{}) -> {reply, term(), #state{}}.
handle_call(Request, _From, State) ->
    logger:warning("[zotonic_mod_ambit] unexpected call: ~p", [Request]),
    {reply, {error, unknown_call}, State}.

%% @doc Handle asynchronous casts.
-spec handle_cast(term(), #state{}) -> {noreply, #state{}}.
handle_cast(Msg, State) ->
    logger:warning("[zotonic_mod_ambit] unexpected cast: ~p", [Msg]),
    {noreply, State}.

%% @doc Handle other messages.
-spec handle_info(term(), #state{}) -> {noreply, #state{}}.
handle_info(Info, State) ->
    logger:warning("[zotonic_mod_ambit] unexpected info: ~p", [Info]),
    {noreply, State}.

%% @doc Clean up on termination.
-spec terminate(term(), #state{}) -> ok.
terminate(_Reason, _State) ->
    ok.

%% @doc Handle code upgrades.
-spec code_change(term(), #state{}, term()) -> {ok, #state{}}.
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


%% ---------------------------------------------------------------------------
%% Zotonic observer callbacks
%% ---------------------------------------------------------------------------

%% @doc Called after a resource has been updated.  Indexes the resource's
%%      geographic location in ambit.
%% @spec observe_rsc_update_done(#rsc_update_done{}, z:context()) -> ok
-spec observe_rsc_update_done(#rsc_update_done{}, z:context()) -> ok.
observe_rsc_update_done(#rsc_update_done{id = Id, post_props = Props}, Context) ->
    z_ambit:index_resource(Id, Props, Context).

%% @doc Handle search queries.  Recognises `ambit_nearby' and `ambit_within'
%%      search types and delegates to the corresponding `z_ambit' functions.
%%      Returns `undefined' for all other query types.
%% @spec observe_search_query({atom(), term()}, z:context()) ->
%%           undefined | #search_sql{}
-spec observe_search_query({atom(), term()}, z:context()) ->
        undefined | #search_sql{}.
observe_search_query({search_query, {ambit_nearby, Args}, _OffsetLimit}, Context) ->
    z_ambit:search_nearby(Args, Context);
observe_search_query({search_query, {ambit_within, Args}, _OffsetLimit}, Context) ->
    z_ambit:search_within(Args, Context);
observe_search_query(_Other, _Context) ->
    undefined.
