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

-module(m_geodata).
-author("Maas-Maarten Zeeman <mmzeeman@xs4all.nl>").

-behaviour(zotonic_model).

-include_lib("zotonic_core/include/zotonic.hrl").

-export([m_get/3]).

%% pc4
m_get([<<"postcode">>, Pc4 | Rest], _Msg, Context) when byte_size(Pc4) == 4 ->
    case ambit_geodata:postcode4(Pc4, Context) of
        {ok, Results} ->
            {ok, {Results, Rest}};
        {error, _} = Error ->
            Error
    end;
%% pc6
m_get([<<"postcode">>, Pc6 | Rest], _Msg, Context) when byte_size(Pc6) == 6 ->
    case ambit_geodata:postcode6(Pc6, Context) of
        {ok, Results} ->
            {ok, {Results, Rest}};
        {error, _} = Error ->
            Error
    end;

m_get(Path, _Msg, _Context) ->
    ?LOG_WARNING(#{ text => "Unknown path", path => Path }),
    {error, unknown_path}.




