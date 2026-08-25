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
%%
%% List of resource ids as locations:
%%   {% ambit_map ids=my_ids_var width="900px" height="500px" %}
%%
%% Resource ids combined with explicit locations:
%%   {% ambit_map ids=my_ids_var locations=my_locations_var %}
%%
%% Use id/lat+lon as map centre only, without placing a marker:
%%   {% ambit_map id=m.rsc.headquarters.id ids=branch_ids show_center_marker=false %}

%% Copyright 2024-2026 Maas-Maarten Zeeman
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
    {Latitude, Longitude} = case get_latlong(Params, Context) of
        {Lat, Lng} -> {Lat, Lng};
        _ -> {undefined, undefined}
    end,
    ExplicitLocations = normalize_locations(proplists:get_value(locations, Params)),
    IdLocations = ids_to_locations(proplists:get_value(ids, Params), Context),
    Locations = IdLocations ++ ExplicitLocations,
    HasLocation = is_float(Latitude) andalso is_float(Longitude),
    HasLocations = is_list(Locations) andalso Locations =/= [],
    SelectOnMap = z_convert:to_bool(proplists:get_value(select_on_map, Params, false)),
    case HasLocation orelse HasLocations orelse SelectOnMap of
        true ->
            Zoom   = z_convert:to_integer(proplists:get_value(zoom,   Params, 15)),
            Width  = proplists:get_value(width,  Params, <<"700px">>),
            Height = proplists:get_value(height, Params, <<"480px">>),
            ShowCenterMarker = z_convert:to_bool(
                                   proplists:get_value(show_center_marker, Params, true)),
            LatFieldId = proplists:get_value(lat_field_id, Params, undefined),
            LngFieldId = proplists:get_value(lng_field_id, Params, undefined),
            Vars0 = [
                {has_location, HasLocation},
                {show_center_marker, ShowCenterMarker},
                {select_on_map, SelectOnMap},
                {lat_field_id, LatFieldId},
                {lng_field_id, LngFieldId},
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
                            {m_rsc:p(RId, location_lat, Context), m_rsc:p(RId, location_lng, Context)}
                    end
            end;
        Lat ->
            {catch z_convert:to_float(Lat), catch z_convert:to_float(proplists:get_value(longitude, Params))}
    end.

normalize_locations(Locations) when is_list(Locations) ->
    [ Loc || Loc <- [normalize_location(Location) || Location <- Locations], Loc =/= undefined ];
normalize_locations(_) ->
    [].

%% @doc Resolve a list of resource ids to location maps.
%%      Each id is looked up via m_rsc; resources without a computed location
%%      are silently skipped.
ids_to_locations(Ids, Context) when is_list(Ids) ->
    lists:filtermap(
        fun(Id) ->
                case m_rsc:rid(Id, Context) of
                    undefined ->
                        false;
                    RId ->
                        case {m_rsc:p(RId, location_lat, Context), m_rsc:p(RId, location_lng, Context)} of
                            {Lat, Lon} when is_float(Lat), is_float(Lon) ->
                                Vars = #{ id => RId },
                                case z_template_compiler_runtime:map_template({cat, <<"_ambit_map_marker.tpl">>}, Vars, Context) of
                                    {ok, Template} ->
                                        Html = render_block(html, Template, Vars, Context),
                                        PopupHtml = render_block(popup_html, Template, Vars, Context),
                                        {true, #{lat => Lat,
                                                 lon => Lon,
                                                 html => Html,
                                                 popup_html => PopupHtml }};
                                    {error, enoent} ->
                                        ?LOG_ERROR(#{
                                                     text => <<"Missing map marker template">>,
                                                     in => mod_ambit,
                                                     result => error,
                                                     reason => enoent,
                                                     template => <<"_ambit_marker_template.tpl">>,
                                                     id => Id
                                                    }),
                                        false
                                end;
                            _ ->
                                false
                        end
                end
        end,
        Ids);
ids_to_locations(_, _Context) ->
    [].

normalize_location(Location) when is_map(Location); is_list(Location) ->
    Lat = get_location_value(Location, lat),
    Lon = get_location_value(Location, lon),
    Title = z_convert:to_binary(get_location_value(Location, title, <<>>)),
    Url = sanitize_location_url(z_convert:to_binary(get_location_value(Location, url, <<>>))),

    #{lat => Lat, lon => Lon, title => Title, url => Url};
normalize_location(_) ->
    undefined.

get_location_value(Location, Key) ->
    get_location_value(Location, Key, undefined).

get_location_value(Location, Key, Default) when is_map(Location) ->
    KeyBin = atom_to_binary(Key, utf8),
    maps:get(Key, Location, maps:get(KeyBin, Location, Default));
get_location_value(Location, Key, Default) when is_list(Location) ->
    KeyBin = atom_to_binary(Key, utf8),
    proplists:get_value(Key, Location, proplists:get_value(KeyBin, Location, Default)).

sanitize_location_url(<<"/", _/binary>> = Url) -> Url;
sanitize_location_url(<<"#", _/binary>> = Url) -> Url;
sanitize_location_url(<<"http://", _/binary>> = Url) -> Url;
sanitize_location_url(<<"https://", _/binary>> = Url) -> Url;
sanitize_location_url(_) -> <<"#">>.

render_block(Block, Template, Vars, Context) ->
    {Output, _RenderState} = z_template:render_block_to_iolist(Block, Template, Vars, Context),
    z_string:trim(iolist_to_binary(Output)).

