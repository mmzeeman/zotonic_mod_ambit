{% with id.location_lat as latitude %}
{% with id.location_lng as longitude %}

<div id="{{ #ambitmap }}" style="height:480px"></div>

{% javascript %}
const map = L.map('{{ #ambitmap }}');

const map_location = [ parseFloat("{{ latitude }}"), parseFloat("{{ longitude }}") ];

console.log(map_location);

L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
        maxZoom: 19,
        attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    }).addTo(map);

map.setView(map_location, 13);

{% endjavascript %}

{% endwith %}
{% endwith %}
