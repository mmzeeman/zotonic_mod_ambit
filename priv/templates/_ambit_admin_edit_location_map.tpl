<div id="{{ #ambitmap }}" style="height:480px"></div>

{% javascript %}
const map = L.map('{{ #ambitmap }}');

L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
        maxZoom: 19,
        attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    }).addTo(map);

map.setView([0, 0], 14);

{% endjavascript %}
