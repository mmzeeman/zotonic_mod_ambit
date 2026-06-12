%% @author Maas-Maarten Zeeman <mmzeeman@xs4all.nl>
%% @copyright 2024 Maas-Maarten Zeeman
%% @doc Show an interactive Leaflet map for a location.
%%      Use as: {% ambit_map id=id %} or {% ambit_map latitude=52.0 longitude=4.3 %}

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
    case get_latlong(Params, Context) of
        {Latitude, Longitude} when is_float(Latitude), is_float(Longitude) ->
            Zoom   = z_convert:to_integer(proplists:get_value(zoom,   Params, 15)),
            Width  = proplists:get_value(width,  Params, <<"700px">>),
            Height = proplists:get_value(height, Params, <<"480px">>),
            Vars = [
                    {location_lat, Latitude},
                    {location_lng, Longitude},
                    {zoom,         Zoom},
                    {width,        Width},
                    {height,       Height}
                    | Params
            ],
            {Html, _Context} = z_template:render_to_iolist("_ambit_map.tpl", Vars, Context),
            {ok, Html};
        _ ->
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
