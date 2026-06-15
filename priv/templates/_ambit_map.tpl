{# Renders an interactive Leaflet map for one or more locations.
   Variables: location_lat, location_lng, locations, zoom, width, height, element_id, class #}

{% with element_id|default:#map as map_id %}
<div class="ambit-map-container"
     style="display:flex; width:{{ width|default:"700px" }}; max-width:100%;">
    <div id="{{ map_id }}"
         class="ambit-map{% if class %} {{ class }}{% endif %}"
         style="flex:1 1 auto; min-width:0; height:{{ height|default:"480px" }};"></div>
    {% if locations %}
    <div class="ambit-map-list"
         style="width:30%; height:{{ height|default:"480px" }}; overflow-y:auto; border-left:1px solid #ccc;">
        <ul style="list-style:none; margin:0; padding:0;">
            {% for loc in locations %}
            <li style="border-bottom:1px solid #eee;">
                <a href="{{ loc.url }}"
                   style="display:block; padding:8px 12px; text-decoration:none; color:inherit;">{{ loc.title }}</a>
            </li>
            {% endfor %}
        </ul>
    </div>
    {% endif %}
</div>

{% javascript %}
(function() {
    var el = document.getElementById('{{ map_id }}');
    if (!el || typeof L === 'undefined') {
        return;
    }

    var map = L.map('{{ map_id }}');
    var zoom = {{ zoom | default:15 }};
    var locations = {% if locations %}{{ locations|to_json }}{% else %}[]{% endif %};
    var hasSingleLocation = {% if has_location %}true{% else %}false{% endif %};
    var locationLat = {% if has_location %}{{ location_lat|to_json }}{% else %}null{% endif %};
    var locationLng = {% if has_location %}{{ location_lng|to_json }}{% else %}null{% endif %};
    var bounds = [];

    L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
        maxZoom: 19,
        attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    }).addTo(map);

    if (hasSingleLocation) {
        map.setView([locationLat, locationLng], zoom);
        L.marker([locationLat, locationLng]).addTo(map);
    }

    locations.forEach(function(loc) {
        if (!loc || loc.lat === undefined || loc.lng === undefined) {
            return;
        }

        var marker = L.marker([loc.lat, loc.lng]).addTo(map);
        if (loc.title) {
            marker.bindPopup(loc.title);
        }
        bounds.push([loc.lat, loc.lng]);
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
