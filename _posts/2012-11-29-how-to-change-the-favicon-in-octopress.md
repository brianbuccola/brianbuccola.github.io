---
layout: post
title: "How to change the favicon in Octopress"
date: 2012-11-29 10:15
redirect_from: /blog/2012-11-29-how-to-change-the-favicon-in-octopress.html
---

*Update: I no longer maintain this blog using Octopress, but I will leave this
post here in case it may be of use to people.*

I found several suggestions for how to change the default Octopress favicon (a
black and grey "O"), such as adding your `favicon.ico` to `source/`, and then
editing `source/_includes/custom/head.html` with the line

{% raw %}
```jekyll
{% assign favicon = '/favicon.ico' %}
```
{% endraw %}

For some reason that didn't work for me. Maybe it's because my `favicon.ico`
file was unreadable/corrupt. I used [favicon-generator][fg] to create my
favicon, which I downloaded as `favicon.ico`, but I couldn't open it in `feh`
either.

The solution was to convert to `png` using [ImageMagick][im]'s `convert`
command:

```bash
$ convert favicon.ico favicon.png
```

After that, I was able both to view the favicon in `feh` and to replace the
default Octopress favicon, without even touching
`source/_includes/custom/head.html`. The reason is that the default favicon was
named `favicon.png`, which I simply overwrite. Very easy, and plus there's no
need to keep around the default favicon anyway.

[fg]: http://favicon-generator.org/editor/
[im]: http://www.imagemagick.org/script/index.php

P.S. When testing if Octopress finds your favicon, refreshing your browser may
not be enough. You may have to restart the browser first to clear the old
favicon.
