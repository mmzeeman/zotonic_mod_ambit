%% @author Maas-Maarten Zeeman <mmzeeman@xs4all.nl>
%% @copyright 2024 Maas-Maarten Zeeman
%% @doc Show an interactive Leaflet map for one or more locations.
%%
%% Single location (unchanged):
%%   {% ambit_map latitude=52.3 longitude=4.9 zoom=13 %}
%%
%% List of locations:
%%   {% ambit_map locations=my_locations_var width="900px" height="500px" %}
%%
%% Both (centre + list):
%%   {% ambit_map latitude=52.3 longitude=4.9 locations=my_locations_var %}

%% Copyright 2024 Maas-Maarten Zeeman
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

-module(scomp_ambit_ambit_map).
-author('Maas-Maarten Zeeman <mmzeeman@xs4all.nl>').
-behaviour(zotonic_scomp).

-export([vary/2, render/3]).

-include_lib("zotonic_core/include/zotonic.hrl").

vary(_Params, _Context) -> nocache.

render(Params, _Vars, Context) ->
    {Latitude, Longitude} = get_latlong(Params, Context),
    Locations = proplists:get_value(locations, Params),
    HasLocation = is_float(Latitude) andalso is_float(Longitude),
    HasLocations = is_list(Locations) andalso Locations =/= [],
    case HasLocation orelse HasLocations of
        true ->
            Zoom   = z_convert:to_integer(proplists:get_value(zoom,   Params, 15)),
            Width  = proplists:get_value(width,  Params, <<"700px">>),
            Height = proplists:get_value(height, Params, <<"480px">>),
            Vars0 = [
                {has_location, HasLocation},
                {zoom,   Zoom},
                {width,  Width},
                {height, Height}
                | Params
            ],
            Vars1 = case HasLocation of
                true -> [{location_lat, Latitude}, {location_lng, Longitude} | Vars0];
                false -> Vars0
            end,
            Vars = case HasLocations of
                true -> [{locations, Locations} | Vars1];
                false -> Vars1
            end,
            {ok, z_template:render("_ambit_map.tpl", Vars, Context)};
        false ->
            {ok, <<>>}
    end.

get_latlong(Params, Context) ->
    case proplists:get_value(latitude, Params) of
        undefined ->
            case proplists:get_value(id, Params) of
                undefined ->
                    {undefined, undefined};
                Id ->
                    case m_rsc:rid(Id, Context) of
                        undefined ->
                            {undefined, undefined};
                        RId ->
                            {m_rsc:p(RId, computed_location_lat, Context),
                             m_rsc:p(RId, computed_location_lng, Context)}
                    end
            end;
        Lat ->
            {catch z_convert:to_float(Lat),
             catch z_convert:to_float(proplists:get_value(longitude, Params))}
    end.
