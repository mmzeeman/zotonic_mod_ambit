{% with id.location_lat as latitude %}
{% with id.location_lng as longitude %}
{% with m.rsc[id].location_zoom_level|default:13 as zoom %}

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

    const initialLat  = parseFloat("{{ latitude }}");
    const initialLng  = parseFloat("{{ longitude }}");
    const initialZoom = parseInt("{{ zoom }}", 10) || 13;
    const hasLocation = !isNaN(initialLat) && !isNaN(initialLng);

    let marker = null;

    // Grab the sibling form inputs by their stable id attributes
    const latInput  = document.getElementById('location_lat');
    const lngInput  = document.getElementById('location_lng');
    const zoomInput = document.getElementById('location_zoom_level');

    function setMarker(lat, lng) {
        if (marker) {
            marker.setLatLng([lat, lng]);
        } else {
            marker = L.marker([lat, lng]).addTo(map);
        }
        // Keep the visible inputs in sync
        if (latInput) {
            latInput.value  = lat;
        }
        if (lngInput)  {
            lngInput.value  = lng;
        }
    }

    if (hasLocation) {
        map.setView([initialLat, initialLng], initialZoom);
        setMarker(initialLat, initialLng);
    } else {
        map.setView([0, 0], 2);
    }

    // Click on map → move marker
    map.on('click', function(e) {
        setMarker(e.latlng.lat, e.latlng.lng);
        if (!marker || !hasLocation) {
            map.setView(e.latlng, map.getZoom());
        }
    });

    // Map zoom changes (scroll, +/- buttons, setZoom …) → sync field
    map.on('zoomend', function() {
        if (zoomInput) {
            zoomInput.value = map.getZoom();
        }
    });

    // Zoom-level field → update map zoom
    if (zoomInput) {
        zoomInput.addEventListener('change', function() {
            const z = parseInt(this.value, 10);
            if (!isNaN(z)) {
                map.setZoom(z);
            }
        });
    }

    // Lat / Lng fields → move marker and pan map
    function onLatLngChange() {
        const lat = parseFloat(latInput  ? latInput.value  : NaN);
        const lng = parseFloat(lngInput  ? lngInput.value  : NaN);
        if (!isNaN(lat) && !isNaN(lng)) {
            setMarker(lat, lng);
            map.panTo([lat, lng]);
        }
    }

    if(latInput) {
        latInput.addEventListener('change', onLatLngChange);
    }
    if (lngInput) {
        lngInput.addEventListener('change', onLatLngChange);
    }
})();
{% endjavascript %}

{% endwith %}
{% endwith %}
{% endwith %}
