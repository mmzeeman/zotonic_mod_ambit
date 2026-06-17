{% extends "admin_edit_widget_std.tpl" %}

{# A map admin_edit widget #}

{% block widget_title %}{_ Map _}{% endblock %}
{% block widget_show_minimized %}true{% endblock %}
{% block widget_id %}content-ambit{% endblock %}

{% block widget_content %}
<div class="row">
    <div class="form-group col-md-4 label-floating">
        <input id="location_lat" 
               type="text"
               name="location_lat"
               value="{{ id.location_lat }}"
               class="form-control"
               placeholder="{_ Latitude _}"
               pattern="^\s*[\\+\\-]?[0-9]+(\.[0-9]+)?\s*$">
        <label for="location_lat" class="control-label">{_ Latitude _}</label>
    </div>

    <div class="form-group col-md-4 label-floating">
        <input id="location_lng"
               type="text"
               name="location_lng"
               value="{{ id.location_lng }}"
               class="form-control"
               placeholder="{_ Longitude _}"
               pattern="^\s*[\\+\\-]?[0-9]+(\.[0-9]+)?\s*$">
        <label for="location_lng" class="control-label">{_ Longitude _}</label>
    </div>

    <div class="form-group col-md-4 label-floating">
        <input id="location_zoom_level" type="number" name="location_zoom_level" min="0" max="29"
               value="{{ m.rsc[id].location_zoom_level }}" class="form-control" placeholder="{_ Zoom Level _} (0 … 29)">
        <label for="location_zoom_level" class="control-label">{_ Zoom Level _} (0 … 29)</label>
    </div>
</div>

<div id="{{ #lazy }}">
    {% lazy action={update target=#lazy id=id template="_ambit_admin_edit_location_map.tpl"}%}
</div>
{% endblock %}

