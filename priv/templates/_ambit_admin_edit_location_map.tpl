{% with id.location_lat as latitude %}
{% with id.location_lng as longitude %}

<div id="{{ #ambitmap }}" style="height:480px"></div>

{% javascript %}
(function() {
    const mapEl = document.getElementById('{{ #ambitmap }}');
    if (!mapEl || typeof L === 'undefined') return;

    const map = L.map('{{ #ambitmap }}');

    L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
        maxZoom: 19,
        attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    }).addTo(map);

    const initialLat = parseFloat("{{ latitude }}");
    const initialLng = parseFloat("{{ longitude }}");
    const hasLocation = !isNaN(initialLat) && !isNaN(initialLng);

    let marker = null;

    function setMarker(lat, lng) {
        if (marker) {
            marker.setLatLng([lat, lng]);
        } else {
            marker = L.marker([lat, lng]).addTo(map);
        }
        // Update the hidden location inputs so the new value is saved with the resource
        const latInput = document.querySelector('input[name="location_lat"]');
        const lngInput = document.querySelector('input[name="location_lng"]');
        if (latInput) latInput.value = lat;
        if (lngInput) lngInput.value = lng;
    }

    if (hasLocation) {
        map.setView([initialLat, initialLng], 13);
        setMarker(initialLat, initialLng);
    } else {
        map.setView([0, 0], 2);
    }

    map.on('click', function(e) {
        setMarker(e.latlng.lat, e.latlng.lng);
        if (!hasLocation) {
            // Zoom in on the first click when no location was set yet
            map.setView(e.latlng, 13);
        }
    });
})();
{% endjavascript %}

{% endwith %}
{% endwith %}
