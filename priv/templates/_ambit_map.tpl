{# Renders an interactive Leaflet map for a single location.
   Variables: location_lat, location_lng, zoom, width, height, element_id, class #}

{% with element_id|default:#map as map_id %}
<div id="{{ map_id }}"
     class="ambit-map{% if class %} {{ class }}{% endif %}"
     style="width: {{ width|default:"700px" }}; height: {{ height|default:"480px" }};"></div>

{% javascript %}
(function() {
    var el = document.getElementById('{{ map_id }}');
    if (!el || typeof L === 'undefined') { return; }
    var map = L.map('{{ map_id }}').setView([{{ location_lat }}, {{ location_lng }}], {{ zoom|default:15 }});
    L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
        maxZoom: 19,
        attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    }).addTo(map);
    L.marker([{{ location_lat }}, {{ location_lng }}]).addTo(map);
})();
{% endjavascript %}
{% endwith %}
