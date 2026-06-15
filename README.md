# zotonic_mod_ambit

Geographic indexing and search for [Zotonic](http://zotonic.com) using
[ambit](https://github.com/mmzeeman/ambit) icosahedral triangular cells.

---

## Description

`zotonic_mod_ambit` integrates the `ambit` library into Zotonic to provide
fast, cell-based geographic search.  Resources that have a latitude/longitude
are automatically indexed into an ambit cell when they are saved.  You can
then search for resources that are *nearby* a point or *within* a specific cell
directly from Erlang or from Zotonic templates via the `m.ambit` model.

---

## Features

* Automatic indexing of resources on `rsc_update_done` notification
* `ambit_nearby` search — find resources within a radius of a lat/lon point
* `ambit_within` search — find resources that share an ambit cell
* Zotonic template model `m.ambit` exposing all queries
* Pure stub implementation ready to wire up to the real `ambit` library

---

## Installation

Add `zotonic_mod_ambit` to your Zotonic site's module list and enable it from
the admin panel, or add it to your site's `deps` in `rebar.config`:

```erlang
{zotonic_mod_ambit, {git, "https://github.com/mmzeeman/zotonic_mod_ambit", {branch, "main"}}}
```

Make sure `ambit` is available as well (see `rebar.config` for the placeholder
dependency entry).

---

## Erlang API

```erlang
%% Index a resource manually
z_ambit:index_resource(ResourceId, Props, Context)

%% Remove a resource from the geographic index
z_ambit:deindex_resource(ResourceId, Context)

%% Find resources near a point
z_ambit:search_nearby([{lat, 52.3}, {lon, 4.9}, {radius, 10}], Context)

%% Find resources within a cell
z_ambit:search_within([{cell, Cell}], Context)

%% Encode a lat/lon pair to an ambit cell
Cell = z_ambit:lat_lon_to_cell(52.3, 4.9)

%% Decode a cell back to a lat/lon centroid
{Lat, Lon} = z_ambit:cell_to_lat_lon(Cell)

%% List all cells that overlap a radius (km) around a point
Cells = z_ambit:cells_within_radius(52.3, 4.9, 50.0)
```

---

## Template model usage (`m.ambit`)

```django
{# Resources near a point #}
{% with m.ambit.nearby[lat=52.3][lon=4.9][radius=10] as results %}
    {% for id in results %}
        {{ id }}
    {% endfor %}
{% endwith %}

{# Resources within a cell #}
{% with m.ambit.within[cell=some_cell] as results %}
    …
{% endwith %}

{# Get the ambit cell for a coordinate #}
{% with m.ambit.cell[lat=52.3][lon=4.9] as cell %}
    {{ cell }}
{% endwith %}
```

---

## Map scomp usage (`ambit_map`)

Make sure the css and javascript code are loaded on the page. Either via a site wide js include, or
a location specific include of this template:

```django
{% include "_lib_leaflet.tpl" %}
```

```django
{# Map from a resource location #}
{% ambit_map id=id %}

{# Map from explicit coordinates #}
{% ambit_map latitude=52.3704 longitude=4.8952 zoom=13 width="100%" height="400px" %}
```

```django
{# Map from with multiple locations #}
{% ambit_map locations=[
        %{ lat: 52.370, lon: 4.8952, title: "Amsterdam", url: "/"},
        %{ lat: 52.3676, lon: 4.9041, title: "Stekkie", url: "/"}
   ] zoom=13 width="100%" height="400px" %}
```

---

## Licence

Copyright 2024 Maas-Maarten Zeeman

Licensed under the Apache License, Version 2.0.  See [LICENSE](LICENSE) for
the full text.
