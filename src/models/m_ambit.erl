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

%% @doc Zotonic template model for ambit geographic search.
%%
%% Template usage examples:
%%
%%   Find resources near a lat/lon point:
%%
%%     {% with m.ambit.nearby[lat=52.3][lon=4.9][radius=10] as results %}
%%         {% for id in results %}{{ id }}{% endfor %}
%%     {% endwith %}
%%
%%   Find resources within an ambit cell:
%%
%%     {% with m.ambit.within[cell=some_cell] as results %}
%%         {% for id in results %}{{ id }}{% endfor %}
%%     {% endwith %}
%%
%%   Get the ambit cell for a coordinate:
%%
%%     {% with m.ambit.cell[lat=52.3][lon=4.9] as cell %}
%%         {{ cell }}
%%     {% endwith %}

-module(m_ambit).
-author("Maas-Maarten Zeeman <mmzeeman@xs4all.nl>").

-behaviour(zotonic_model).

-include_lib("zotonic_core/include/zotonic.hrl").

-export([m_get/3]).


%% ---------------------------------------------------------------------------
%% zotonic_model callbacks
%% ---------------------------------------------------------------------------

%% @doc Handle template model lookups.
%%
%%   Supported path patterns:
%%   * `[<<"nearby">> | Rest]' — search for resources near a lat/lon point
%%   * `[<<"within">> | Rest]' — search for resources within a cell
%%   * `[<<"cell">>   | Rest]' — convert lat/lon to an ambit cell
%%
%% @spec m_get([binary()], Msg :: term(), z:context()) ->
%%           {ok, {term(), [binary()]}} | {error, term()}
-spec m_get([binary()], term(), z:context()) ->
        {ok, {term(), [binary()]}} | {error, term()}.
m_get([<<"nearby">> | Rest], Msg, Context) ->
    Args   = get_args(Msg),
    Lat    = maps:get(<<"lat">>,    Args, undefined),
    Lon    = maps:get(<<"lon">>,    Args, undefined),
    Radius = maps:get(<<"radius">>, Args, undefined),
    Results = z_search:query_(
        [{search, {ambit_nearby, [{lat, Lat}, {lon, Lon}, {radius, Radius}]}}],
        Context),
    {ok, {Results, Rest}};

m_get([<<"within">> | Rest], Msg, Context) ->
    Args = get_args(Msg),
    Cell = maps:get(<<"cell">>, Args, undefined),
    Results = z_search:query_(
        [{search, {ambit_within, [{cell, Cell}]}}],
        Context),
    {ok, {Results, Rest}};

m_get([<<"cell">> | Rest], Msg, _Context) ->
    Args = get_args(Msg),
    Lat  = maps:get(<<"lat">>, Args, undefined),
    Lon  = maps:get(<<"lon">>, Args, undefined),
    case {Lat, Lon} of
        {undefined, _} -> {error, missing_lat};
        {_, undefined} -> {error, missing_lon};
        _ ->
            case z_ambit:lat_lon_to_cell(Lat, Lon) of
                {ok, Cell}     -> {ok, {Cell, Rest}};
                {error, _} = E -> E
            end
    end;

m_get(Path, _Msg, _Context) ->
    logger:info("[m_ambit] unknown path: ~p", [Path]),
    {error, unknown}.


%% ---------------------------------------------------------------------------
%% Private helpers
%% ---------------------------------------------------------------------------

%% @private
%% @doc Extract the payload map from the model Msg term.
-spec get_args(term()) -> map().
get_args(Msg) when is_map(Msg) ->
    maps:get(payload, Msg, #{});
get_args(_) ->
    #{}.
