{# Renders an interactive Leaflet map for one or more locations.
   Variables: location_lat, location_lng, locations, zoom, width, height, element_id, class,
              show_center_marker, select_on_map, lat_field_id, lng_field_id #}

{% with element_id|default:#map as map_id %}
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

    L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
        maxZoom: 19,
        attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
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

        const marker = L.marker([lat, lon]).addTo(map);
        if (loc.title) {
            marker.bindTooltip(loc.title, {permanent: true});
        }
        if (loc.url) {
            marker.on('click', () => { window.location.href = loc.url; });
        }
        bounds.push([lat, lon]);
    });

    if (selectOnMap) {
        let selectMarker = null;

        const writeSelectFields = function(lat, lng) {
            if (latFieldId) {
                const latEl = document.getElementById(latFieldId);
                if (latEl) {
                    latEl.value = lat;
                    latEl.dispatchEvent(new Event('input'));
                }
            }
            if (lngFieldId) {
                const lngEl = document.getElementById(lngFieldId);
                if (lngEl) {
                    lngEl.value = lng;
                    lngEl.dispatchEvent(new Event('input'));
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

    if (bounds.length > 1) {
        map.fitBounds(bounds, { padding: [20, 20] });
    } else if (bounds.length === 1) {
        map.setView(bounds[0], zoom);
    } else if (centrePoint) {
        map.setView(centrePoint, zoom);
    } else {
        map.setView([0, 0], zoom);
    }
})();
{% endjavascript %}
{% endwith %}
