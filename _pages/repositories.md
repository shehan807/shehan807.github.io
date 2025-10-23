---
layout: page
permalink: /software/
title: software
description: Open-source software and tools I've developed
nav: true
nav_order: 4
---

<div class="software-projects-main">

  {%- comment -%} Software Cards Grid {%- endcomment -%}
  {% if site.data.software.projects %}
  <div class="software-cards-grid">
    {% assign projects = site.data.software.projects %}
    {% if site.data.software.config.max_display %}
      {% assign projects = projects | slice: 0, site.data.software.config.max_display %}
    {% endif %}

    {% for project in projects %}
      {% include software_card.liquid project=project %}
    {% endfor %}
  </div>
  {% endif %}

  {%- comment -%} More Projects Button {%- endcomment -%}
  {% if site.data.software.config.show_more_button and site.data.software.config.button_link %}
  <a href="{{ site.data.software.config.button_link }}"
     class="software-more-button"
     target="_blank"
     rel="noopener noreferrer">
    {{ site.data.software.config.button_text | default: "More Projects" }}
  </a>
  {% endif %}

</div>

{%- comment -%}
Legacy GitHub users section - uncomment if you want to keep it
{% if site.data.repositories.github_users %}

<hr class="my-5">

## GitHub users

<div class="repositories d-flex flex-wrap flex-md-row flex-column justify-content-between align-items-center">
  {% for user in site.data.repositories.github_users %}
    {% include repository/repo_user.liquid username=user %}
  {% endfor %}
</div>

{% if site.repo_trophies.enabled %}
{% for user in site.data.repositories.github_users %}
{% if site.data.repositories.github_users.size > 1 %}
  <h4>{{ user }}</h4>
{% endif %}
  <div class="repositories d-flex flex-wrap flex-md-row flex-column justify-content-between align-items-center">
  {% include repository/repo_trophies.liquid username=user %}
  </div>
{% endfor %}
{% endif %}
{% endif %}
{%- endcomment -%}
