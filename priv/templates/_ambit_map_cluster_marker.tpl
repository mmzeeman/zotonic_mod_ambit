{% extends "_ambit_map_marker.tpl" %}

{% block html %}

<div class="position-relative">
    <div class="d-flex">
        {% if id.depiction %}
            {% image id.depiction mediaclass="post-img-xs"
                     class="chat-marker-icon rounded-4 border border-4 border-white shadow-sm" %}
        {% else %}
            {% image "lib/images/og_image.png"
                      mediaclass="post-img-xs" class="chat-marker-icon rounded-4 border border-4 border-white shadow-sm" %}
        {% endif %}
        <div class="position-absolute top-100 start-0 translate-middle-y fs-6">
            <span class="badge bg-primary rounded-pill">{{ count }}</span>
        </div>
    </div>
    </div>
{% endblock %}

{% block popup_html %}{# No popup for posts on the map #}{% endblock %}
