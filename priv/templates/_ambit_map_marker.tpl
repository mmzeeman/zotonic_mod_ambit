{# Template used by scomp_ambit_map to create the map markers #}
{# Extend this template if a category needs special map markers #}

{# Used as map marker html on the page #}
{% block html %}{# leave empty, for default marker #}{% endblock %}

{# User as map marker popup html on the page. When left empty, the popup will be disabled #}
{% block popup_html %}<a href="{{ id.page_url }}">{{ id.title | default:id.page_url }}</a>{% endblock %}
