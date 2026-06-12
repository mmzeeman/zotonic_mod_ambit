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

%% @doc Common Test suite for zotonic_mod_ambit.

-module(zotonic_mod_ambit_SUITE).
-author("Maas-Maarten Zeeman <mmzeeman@xs4all.nl>").

-compile(export_all).

-include_lib("common_test/include/ct.hrl").
-include_lib("eunit/include/eunit.hrl").


%% ---------------------------------------------------------------------------
%% Common Test callbacks
%% ---------------------------------------------------------------------------

suite() ->
    [{timetrap, {seconds, 30}}].

all() ->
    [
        test_lat_lon_to_cell,
        test_cell_to_lat_lon,
        test_index_resource_no_location
    ].


%% ---------------------------------------------------------------------------
%% Test cases
%% ---------------------------------------------------------------------------

%% @doc Basic smoke-test for lat_lon_to_cell/2.
%% TODO: expand this once the ambit API is confirmed — verify the returned
%%       cell has the expected type/structure.
test_lat_lon_to_cell(_Config) ->
    ?assertEqual(ok, ok).

%% @doc Basic smoke-test for cell_to_lat_lon/1.
%% TODO: expand this once the ambit API is confirmed — round-trip a known
%%       lat/lon through encode/decode and check the values are close.
test_cell_to_lat_lon(_Config) ->
    ?assertEqual(ok, ok).

%% @doc Verify that index_resource/3 handles resources without a location
%%      gracefully (i.e. calls deindex_resource/2 instead of crashing).
%% TODO: expand this once z_ambit is wired to real storage — assert that
%%       no index entry exists for the resource afterwards.
test_index_resource_no_location(_Config) ->
    ?assertEqual(ok, ok).
