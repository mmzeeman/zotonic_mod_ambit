%% @author Maas-Maarten Zeeman <mmzeeman@xs4all.nl>
%% @copyright 2026 Maas-Maarten Zeeman 
%% @doc Geographic indexing and search using ambit icosahedral triangular cells.

%% Copyright 2026 Maas-Maarten Zeeman 
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


-module(mod_ambit).

-mod_title("Geographic indexing and search based on Ambit").
-mod_description("Module for geographic indexing and search using ambit icosahedral triangular cells.").

-include_lib("zotonic_core/include/zotonic.hrl").

-export([
    init/1,
    observe_custom_pivot/2,
    observe_rsc_get/3
]).

init(Context) ->
    ok = z_pivot_rsc:define_custom_pivot(?MODULE,
                                         [#column_def{ name = ambit_code, type = <<"TEXT">>}],
                                         Context),

    ok.

observe_rsc_get(#rsc_get{}, Props, _Context) ->
    Props.

observe_custom_pivot(#custom_pivot{ id = Id }, Context) ->
    custom_pivot(Id, Context).

custom_pivot(Id, Context) ->
    case get_location(Id, Context) of
        undefined ->
            case m_rsc:p_no_acl(Id, ambit_code, Context) of
                Code when is_binary(Code) ->
                    {?MODULE, [{ambit_code, Code}]};
                _ ->
                    Locations = m_rsc:o(Id, has_location, Context),
                    case find_location(Locations, Context) of
                        undefined ->
                            case find_ambit_code(Locations, Context) of
                                undefined ->
                                    none;
                                Code ->
                                    {?MODULE, [{ambit_code, Code}]}
                            end;
                        {Lat, Lng} ->
                            Code = ambit:encode({Lat, Lng}, 24),
                            {?MODULE, [{ambit_code, Code}]}
                    end
            end;
        {Lat, Lng} ->
            Code = ambit:encode({Lat, Lng}, 24),
            {?MODULE, [{ambit_code, Code}]}
    end.

get_location(Id, Context) ->
    case {catch z_convert:to_float(m_rsc:p_no_acl(Id, location_lat, Context)),
          catch z_convert:to_float(m_rsc:p_no_acl(Id, location_lng, Context))}
    of
        {Lat, Lng} when is_float(Lat), is_float(Lng) ->
            {Lat, Lng};
        _ ->
            undefined
    end.


find_location([], _Context) ->
    undefined;
find_location([H|T], Context) ->
    case get_location(H, Context) of
        undefined ->
            find_location(T, Context);
        Location ->
            Location
    end.

find_ambit_code([], _Context) ->
    undefined;
find_ambit_code([H|T], Context) ->
    case m_rsc:p_no_acl(H, ambit_code, Context) of
        Code when is_binary(Code) ->
            Code;
        _ ->
            find_ambit_code(T, Context)
    end.

