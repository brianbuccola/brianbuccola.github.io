---
layout: page
title: Tags
permalink: /blog/tags/
---

{% assign tags_sorted = site.tags | sort %}
<ul class="tag-list">
{% for tag in tags_sorted %}
  {% assign t = tag[0] %}
  {% assign ps = tag[1] %}
  <li>{{ t }}
    <ul>
      {% for p in ps %}
        <li><a href="{{ p.url | prepend: site.baseurl }}">{{ p.title }}</a> <span class="post-meta">&mdash; {{ p.date | date: "%b %-d, %Y" }}</span></li>
      {% endfor %}
    </ul>
  </li>
{% endfor %}
</ul>
