{# Template used by scomp_ambit_map to create the map markers #}
{# Extend this template if a category needs special map markers #}

{# Used as title on the page after clicking on a marker #}
{% block title %}{{ id.title }}{% endblock %}

{# Used as url. The title above will become a link #}
{% block url %}{{ id.page_url }}{% endblock %}

{# Used as map marker html on the page #}
{% block html %}{# leave empty, for default marker #}{% endblock %}
