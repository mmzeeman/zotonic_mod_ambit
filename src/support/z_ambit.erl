%% @author Maas-Maarten Zeeman <mmzeeman@xs4all.nl>
%% @copyright 2026 Maas-Maarten Zeeman
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

%% @doc Support utilities for ambit geographic indexing and search.

-module(z_ambit).
-author("Maas-Maarten Zeeman <mmzeeman@xs4all.nl>").

-include_lib("zotonic_core/include/zotonic.hrl").

-export([
    index_resource/3,
    deindex_resource/2,
    search_nearby/2,
    search_within/2,
    lat_lon_to_cell/2,
    cell_to_lat_lon/1,
    cells_within_radius/3
]).


%% ---------------------------------------------------------------------------
%% Exported functions
%% ---------------------------------------------------------------------------

%% @doc Index a resource's geographic location into ambit.
%%      Extracts `location_lat' and `location_lng' from the Props map.
%%      If both are present the resource is encoded to a cell and stored;
%%      otherwise any existing index entry is removed.
%% @spec index_resource(integer(), map(), z:context()) -> ok
-spec index_resource(integer(), map(), z:context()) -> ok.
index_resource(Id, Props, Context) ->
    case get_location(Props) of
        {ok, {Lat, Lon}} ->
            Cell = lat_lon_to_cell(Lat, Lon),
            store_cell(Id, Cell, Context);
        undefined ->
            deindex_resource(Id, Context)
    end.

%% @doc Remove a resource from the geographic index.
%% @spec deindex_resource(integer(), z:context()) -> ok
-spec deindex_resource(integer(), z:context()) -> ok.
deindex_resource(_Id, _Context) ->
    %% TODO: remove the stored cell for Id from the data store
    ok.

%% @doc Search for resources near a lat/lon point within a given radius (km).
%%      Reads `lat', `lon', and `radius' from Args.
%%      Returns `undefined' until the ambit API is wired up.
%% @spec search_nearby(proplists:proplist(), z:context()) ->
%%           undefined | #search_sql{}
-spec search_nearby(proplists:proplist(), z:context()) ->
        undefined | #search_sql{}.
search_nearby(Args, _Context) ->
    _Lat    = proplists:get_value(lat,    Args),
    _Lon    = proplists:get_value(lon,    Args),
    _Radius = proplists:get_value(radius, Args),
    %% TODO: build a #search_sql{} using cells_within_radius/3 and a JOIN
    undefined.

%% @doc Search for resources that share a specific ambit cell.
%%      Reads `cell' from Args.
%%      Returns `undefined' until the ambit API is wired up.
%% @spec search_within(proplists:proplist(), z:context()) ->
%%           undefined | #search_sql{}
-spec search_within(proplists:proplist(), z:context()) ->
        undefined | #search_sql{}.
search_within(Args, _Context) ->
    _Cell = proplists:get_value(cell, Args),
    %% TODO: build a #search_sql{} that matches resources stored in _Cell
    undefined.

%% @doc Encode a latitude/longitude pair to an ambit cell identifier.
%% @spec lat_lon_to_cell(float(), float()) -> {ok, term()} | {error, term()}
-spec lat_lon_to_cell(float(), float()) -> {ok, term()} | {error, term()}.
lat_lon_to_cell(Lat, Lon) ->
    %% TODO: replace with the actual ambit:encode/2 call once API is confirmed
    try ambit:encode(Lat, Lon) of
        Cell -> {ok, Cell}
    catch
        Class:Reason -> {error, {Class, Reason}}
    end.

%% @doc Decode an ambit cell identifier back to a {Lat, Lon} centroid.
%% @spec cell_to_lat_lon(term()) -> {ok, {float(), float()}} | {error, term()}
-spec cell_to_lat_lon(term()) -> {ok, {float(), float()}} | {error, term()}.
cell_to_lat_lon(Cell) ->
    %% TODO: replace with the actual ambit:decode/1 call once API is confirmed
    try ambit:decode(Cell) of
        LatLon -> {ok, LatLon}
    catch
        Class:Reason -> {error, {Class, Reason}}
    end.

%% @doc Return all ambit cells that overlap with a circle of RadiusKm km
%%      centred on (Lat, Lon).
%% @spec cells_within_radius(float(), float(), float()) -> {ok, [term()]} | {error, term()}
-spec cells_within_radius(float(), float(), float()) -> {ok, [term()]} | {error, term()}.
cells_within_radius(Lat, Lon, RadiusKm) ->
    %% TODO: replace with the actual ambit:cells_within/3 call once API is confirmed
    try ambit:cells_within(Lat, Lon, RadiusKm) of
        Cells -> {ok, Cells}
    catch
        Class:Reason -> {error, {Class, Reason}}
    end.


%% ---------------------------------------------------------------------------
%% Private helpers
%% ---------------------------------------------------------------------------

%% @private
%% @doc Extract location from a Props map using binary keys.
%%      Returns {ok, {Lat, Lon}} when both values are present, undefined otherwise.
-spec get_location(map()) -> {ok, {float(), float()}} | undefined.
get_location(Props) when is_map(Props) ->
    case {maps:get(<<"location_lat">>, Props, undefined),
          maps:get(<<"location_lng">>, Props, undefined)} of
        {Lat, Lon} when is_number(Lat), is_number(Lon) ->
            {ok, {float(Lat), float(Lon)}};
        _ ->
            undefined
    end;
get_location(_) ->
    undefined.

%% @private
%% @doc Store an ambit cell for a resource.
-spec store_cell(integer(), term(), z:context()) -> ok.
store_cell(_Id, _Cell, _Context) ->
    %% TODO: persist the cell for _Id (e.g. via m_rsc custom property or a
    %%       dedicated pivot table)
    ok.
