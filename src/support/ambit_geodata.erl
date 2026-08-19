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


-module(ambit_geodata).
-author("Maas-Maarten Zeeman <mmzeeman@xs4all.nl>").

-include_lib("zotonic_core/include/zotonic.hrl").

-export([
    postcode4/2,
    postcode6/2
]).

%postcode4(Pc4, _Context) ->
%    Url = io_lib:format(
%        "https://api.pdok.nl/cbs/wijken-buurten-2024/ogc/v1/collections/postcodegebieden/items?postcode=~s",
%        [Pc4]
%    ),
%    get_geojson(lists:flatten(Url)).

% postcode4(Pc4, _Context) ->
%     Url = io_lib:format(
%         "https://api.pdok.nl/bzk/locatieserver/search/v3_1/free?q=~s&fq=type:postcode",
%         [Pc4]
%    ),
%     get_geojson(lists:flatten(Url)).

%postcode4(Pc4, _Context) ->
%    Url = io_lib:format(
%        "https://public.opendatasoft.com/api/records/1.0/search/?dataset=georef-netherlands-postcode-pc4&q=pc4:~s",
%        [Pc4]
%    ),
%    get_geojson(lists:flatten(Url)).

%postcode4(Pc4, _Context) ->
%    Url = io_lib:format(
%        "https://public.opendatasoft.com/api/explore/v2.1/catalog/datasets/georef-netherlands-postcode-pc4/records?where=postcode%3D%22~s%22",
%        [Pc4]
%    ),
%    get_geojson(lists:flatten(Url)).

%postcode4(Pc4, _Context) ->
%    % Gets address data for a 4-digit postcode with coordinates
%    Url = io_lib:format(
%        "http://api.postcodedata.nl/v1/postcode/?postcode=~s&ref=your-domain.nl&type=json",
%        [Pc4]
%    ),
%    get_geojson(lists:flatten(Url)).

postcode4(Pc4, _Context) ->
    Url = io_lib:format(
        "https://public.opendatasoft.com/api/records/1.0/search/?dataset=georef-netherlands-postcode-pc4&q=pc4_code:~s&rows=1&format=json",
        [Pc4]
    ),
    get_geojson(lists:flatten(Url)).

postcode6(Pc6, _Context) ->
    {ok, #{}}.

%%
%% Helpers
%%

get_geojson(Url) ->
    ?DEBUG(Url),
    httpc:request(get, {Url, [{"accept", "application/geo+json"}]}, [], []).
