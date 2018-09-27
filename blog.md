---
layout: page
title: Blog
permalink: /blog/
---

<p style="float:right;">
  <a href="/feed.xml"><span class="icon icon--feed">{% include icon-feed.svg %}</span></a>
</p>

<ul class="post-list">
  {% for post in site.posts %}
    <li>
      <span class="post-meta">{{ post.date | date: "%b %-d, %Y" }}</span>

      <h2>
        <a class="post-link" href="{{ post.url | prepend: site.baseurl }}">{{ post.title }}</a>
      </h2>
    </li>
  {% endfor %}
</ul>
