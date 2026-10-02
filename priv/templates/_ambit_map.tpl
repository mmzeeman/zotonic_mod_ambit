{#
    Map Component

    Displays an interactive map showing one or more locations.

    Expected variables:
    - location      : A single location object
    - locations     : A list of location objects
    - zoom          : Optional zoom level
    - marker_title  : Optional marker label/title

    Notes:
    - When `location` is provided, the map is centered on that location.
    - When `locations` is provided, markers are shown for all locations and
      the map automatically fits the visible bounds.
    - Either `location` or `locations` can be supplied.

    Output:
    - Interactive map with one or more markers
    - Automatic viewport adjustment for multiple locations
    - Responsive map container
#}

{% with element_id | default:#map as map_id %}

<div id="{{ map_id }}"
     class="ambit-map{% if class %} {{ class }}{% endif %}"
     style="width:{{ width|default:"700px" }}; height:{{ height|default:"480px" }};"></div>


{% javascript %}
(function() {
    var el = document.getElementById('{{ map_id }}');
    if (!el || typeof L === 'undefined') {
        return;
    }

    const map = L.map('{{ map_id }}');
    const zoom = {{ zoom | default:15 }};
    const locations = {% if locations %}{{ locations | to_json }}{% else %}[]{% endif %};
    const hasSingleLocation = {% if has_location %}true{% else %}false{% endif %};
    const showCenterMarker = {% if show_center_marker %}true{% else %}false{% endif %};
    const selectOnMap = {% if select_on_map %}true{% else %}false{% endif %};
    const latFieldId = {% if lat_field_id %}"{{ lat_field_id }}"{% else %}null{% endif %};
    const lngFieldId = {% if lng_field_id %}"{{ lng_field_id }}"{% else %}null{% endif %};
    const locationLat = {% if has_location %}{{ location_lat | to_json }}{% else %}null{% endif %};
    const locationLng = {% if has_location %}{{ location_lng | to_json }}{% else %}null{% endif %};
    const MIN_LAT = -90;
    const MAX_LAT = 90;
    const MIN_LNG = -180;
    const MAX_LNG = 180;
    const bounds = [];

    // When hasSingleLocation is true but showCenterMarker is false, keep the
    // centre point as a fallback for setView when no other markers are present.
    const centrePoint = hasSingleLocation ? [locationLat, locationLng] : null;

    L.tileLayer(
        `{{ m.ambit.xyz_tile_url }}`, {
        maxZoom: {{ m.ambit.max_zoom }},
        minZoom: {{ m.ambit.min_zoom }},
        attribution: "{{ m.ambit.attribution | escapejs }}"
    }).addTo(map);

    if (hasSingleLocation && showCenterMarker) {
        L.marker([locationLat, locationLng]).addTo(map);
        bounds.push([locationLat, locationLng]);
    }

    locations.forEach(function(loc) {
        if (!loc || loc.lat === undefined || loc.lon === undefined) {
            return;
        }

        const lat = Number(loc.lat);
        const lon = Number(loc.lon);
        if (!Number.isFinite(lat) || !Number.isFinite(lon) ||
            lat < MIN_LAT || lat > MAX_LAT || lon < MIN_LNG || lon > MAX_LNG) {
            return;
        }

        const marker = L.marker([lat, lon]);

        if (loc.popup_html) {
            marker.bindPopup(loc.popup_html);
        }

        if (loc.html) {
            marker.setIcon(L.divIcon({className: 'resource-marker',
                   html: loc.html,
                   iconSize: [40, 40],
                   iconAnchor: [20, 40],
                   popupAnchor: [0, -40]
                   }));
        }

        marker.addTo(map);

        bounds.push([lat, lon]);
    });

    if (selectOnMap) {
        let selectMarker = null;

        const writeSelectFields = function(lat, lng) {
            if (latFieldId) {
                const latEl = document.getElementById(latFieldId);
                if (latEl) {
                    latEl.value = lat;
                    latEl.dispatchEvent(new Event('input', {bubbles: true}));
                }
            }
            if (lngFieldId) {
                const lngEl = document.getElementById(lngFieldId);
                if (lngEl) {
                    lngEl.value = lng;
                    lngEl.dispatchEvent(new Event('input', {bubbles: true}));
                }
            }
        };

        const placeSelectMarker = function(lat, lng) {
            if (selectMarker) {
                selectMarker.setLatLng([lat, lng]);
            } else {
                selectMarker = L.marker([lat, lng], {draggable: true}).addTo(map);
                selectMarker.on('dragend', function() {
                    const pos = selectMarker.getLatLng();
                    writeSelectFields(pos.lat, pos.lng);
                });
            }
            writeSelectFields(lat, lng);
        };

        if (hasSingleLocation) {
            placeSelectMarker(locationLat, locationLng);
        }

        map.on('click', function(e) {
            placeSelectMarker(e.latlng.lat, e.latlng.lng);
        });
    }

    function publish_map_update(retain) {
        const bounds = map.getBounds();
        cotonic.broker.publish("model/map/{{ map_id }}/event/update",
                               {"zoom": map.getZoom(),
                                "bounds": [bounds.getNorth(), bounds.getWest(),
                                           bounds.getSouth(), bounds.getEast()]},
                               {retain: retain});
    }

    // Dynamic marker stuff
    let dynamicMarkers = {};
    cotonic.broker.subscribe("model/map/{{ map_id }}/post/markers", (msg, binding) => {
        // Haal oude markers weg en zet er nieuwe bij.
        const markers = msg.payload;

        // Remove the old
        Object.values(dynamicMarkers).forEach((p) => {
            p.removeFrom(map);
        });
        dynamicMarkers = {};

        // Add the new.
        markers.forEach((m) => {
            const cluster = L.marker([m.location_lat, m.location_lng]);
            if (m.html) {
                cluster.setIcon(L.divIcon({className: 'resource-marker',
                                           html: m.html,
                                           iconSize: [40, 40],
                                           iconAnchor: [20, 40],
                                           popupAnchor: [0, -40]
                                           }
                                          )
                               );
            }
            cluster.addTo(map);
            dynamicMarkers[m.code] = cluster;
        });
    })

    map.on('load', () => { publish_map_update(true) }); // use a retained message. The observer is bound later
    map.on('moveend', () => { publish_map_update(false) });

    // Center on the provided centrePoint and its zoom level. When this is not
    // provided, use the bounds of the provided locations, if there is only
    // a single location provided, use that as centre with the default zoom.
    if (centrePoint) {
        map.setView(centrePoint, zoom);
    } else if (bounds.length > 1) {
        map.fitBounds(bounds, { padding: [20, 20] });
    } else if (bounds.length === 1) {
        map.setView(bounds[0], zoom);
    } else {
        map.setView([0, 0], zoom);
    }


    })();
{% endjavascript %}

{# When we need to react to dynamic updates, post the updates to the scomp #}
{% if cat %}
    {% wire type={mqtt topic=["model", "map", map_id, "event", "update"]}
            postback={update map_id=map_id cat=cat marker_tpl=marker_tpl cluster_tpl=cluster_tpl} 
            delegate="scomp_ambit_ambit_map"
    %}
{% endif %}

{% endwith %}
