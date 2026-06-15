{# Renders an interactive Leaflet map for one or more locations.
   Variables: location_lat, location_lon, locations, zoom, width, height, element_id, class #}

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
    const locationLat = {% if has_location %}{{ location_lat|to_json }}{% else %}null{% endif %};
    const locationLng = {% if has_location %}{{ location_lon|to_json }}{% else %}null{% endif %};
    const MIN_LAT = -90;
    const MAX_LAT = 90;
    const MIN_LNG = -180;
    const MAX_LNG = 180;
    const bounds = [];

    L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
        maxZoom: 19,
        attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    }).addTo(map);

    if (hasSingleLocation) {
        map.setView([locationLat, locationLng], zoom);
        L.marker([locationLat, locationLng]).addTo(map);
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

    if (!hasSingleLocation) {
        if (bounds.length > 0) {
            map.fitBounds(bounds, { padding: [20, 20] });
        } else {
            map.setView([0, 0], zoom);
        }
    }
})();
{% endjavascript %}
{% endwith %}
