---
layout: post
title: "References and footnotes in HTML/CSS"
date: 2012-12-01 15:08
redirect_from: /blog/2012-12-01-references-and-footnotes-in-htmlcss.html
---

*Update: Since I wrote this post, I discovered that markdown conversion
programs like Pandoc and kramdown can convert extensions of markdown that
include footnotes. For example, it suffices to do:*

```
Blah blah blah.[^fn] Lorem ipsum...

[^fn]: Here's a footnote!
```

*But I will leave this post here since it may be a useful reference for people
writing in pure html rather than markdown.*

I've been toying with how best to incorporate inline references and
end--of--post footnotes into my blog posts, and here's what I've come up with.
I'll start with my first, very simplistic attempt, then explain my slightly
more complicated but also more flexible (I think) solution.

This blog is (*Update: was*) powered by [Octopress][op], which allows me to
write blog posts in [markdown][md] syntax, which is then parsed and converted
into HTML by [kramdown][kd].<a class="ref" id="ref:kd" href="#fn:kd">[1]</a>
Markdown has a nice, easy, and highly legible way of creating simple links.
Just type one of these.

```html
Click [here](url) to see something awesome!

Click [here][blah] to see something awesome!
[blah]: url
```

Both are expanded into the following.

```html
Click <a href="url">here</a> to see something awesome!
```

Now, whether you write in markdown or in HTML, footnotes would seem really easy
to do, and in some sense, they are. Simply create a footnote at the bottom of
the page that has some sort of element with an `id`, preferably mnemonic, e.g.,
`<a id="fn">...`, and then refer to that `id` in your text in the normal way,
by adding a #: either as `<a href="#fn">1</a>` in HTML, or as `[1](#fn)` in
markdown.

```html
Blah blah blah blah.[1](#fn) More blah...

---
1.  <a id="fn"></a> Even more blah...
```

But there are some problems with this method. First, it's ugly.[2](#fn:ugly)
See how ugly that big underlined number looks? Second, and more importantly, as
I've written it, there's no link from the footnote back up to the reference, so
once you're done reading the footnote, you have to go find where you were
before. Uncool. There's nothing worse than a footnote with no link back to the
reference.

One potential solution to both problems is the following: wrap some
`<sup></sup>` around the reference text to superscript it, and also use this
element to declare an `id` for the reference. Then you can link from the
footnote to the reference using the reference `id`, together with a useful
symbol like &uarr; as the link text (`&uarr;` in HTML; stands for **u**p
**arr**ow, of course).

```html
Blah blah blah blah.<sup id="ref">[1](#fn)</sup> More blah...

---
1.  <a id="fn" href="#ref">&uarr;</a> Even more blah...
```

This actually ain't *that* bad.<sup id="ref:sup">[3](#fn:sup)</sup> However,
what if we want to customize how the reference number looks? What if we don't
like underline, or we want a special color or font or size? Unfortunately, any
style properties of a `sup` element get overridden if they are also style
properties of the `a` element embedded inside the `<sup></sup>` tags: recall
that

```html
<sup ...>[text](url)</sup>
```

gets expanded to

```html
<sup ...><a href="url">text</a></sup>
```

In Octopress, that means that `sup {text-decoration: none;}`, `sup {font-size:
small;}`, etc. have no effect on superscript reference links because `a`
already has its own `text-decoration` and `font-size` values.

The solution I've come up with to all these problems is to define two new
classes of anchors (`a` elements): one for references and one for footnotes. I
like my reference numbers to be small and superscript, with no underline, and I
like my up arrow to be normal size and superscript, with no underline.

```css
a.ref {
  vertical-align: super;
  font-size: small;
  text-decoration: none;
  @include link-colors($link-color,
                       $hover: $link-color-hover,
                       $focus: $link-color-hover,
                       $visited: $link-color-visited,
                       $active: $link-color-active);
}

a.fn {
  vertical-align: super;
  text-decoration: none;
  @include link-colors($link-color,
                       $hover: $link-color-hover,
                       $focus: $link-color-hover,
                       $visited: $link-color-visited,
                       $active: $link-color-active);
}
```

The `@include ...` stuff adds all the color variables from
`/sass/custom/_colors.scss`. Without that, the links would be black.

These two classes now mean I do references and footnotes as follows.

```html
Blah blah.<a class="ref" id="ref:blah" href="#fn:blah">[1]</a> More blah

Aoeu aoeu aoeu.<a class="ref" id="ref:aoeu" href="#fn:aoeu">[2]</a> More aoeu

---
1.  <a class="fn" id="fn:blah" href="#ref:blah">&uarr;</a> Even more blah...

2.  <a class="fn" id="fn:aoeu" href="#ref:aoeu">&uarr;</a> Even more aoeu...
```

In other words, each *reference* consists of a number, like 1, surrounded by
`a` tags of the `ref` class, with some mnemonic ref `id`, pointing to the
corresponding fn anchor/`id`. The corresponding *footnote* consists of a
&uarr;, surrounded by `a` tags of the `fn` class, with some mnemonic fn `id`,
pointing back to the corresponding ref anchor/`id`.

I think this works pretty well. Although it clutters my markdown with a bit of
HTML, I think the flexibility is worth it. This way, I can easily change how my
reference numbers look, or how my footnote arrow looks, or both, and it'll
trickle down to all my posts that use these classes.

There may be a better way of handling footnotes, but I haven't seen it or
thought of it yet.

[op]: http://octopress.org/
[md]: http://daringfireball.net/projects/markdown/
[kd]: http://kramdown.rubyforge.org/
[rd]: https://github.com/rtomayko/rdiscount
[lx]: /blog/2012/11/28/latex-math-in-octopress/

---
1.  <a class="fn" id="fn:kd" href="#ref:kd">&uarr;</a> Octopress actually uses
    [rdiscount][rd] by default. Read [here][lx] to find out why I switched to
    kramdown.

2.  <a class="fn" id="fn:ugly"></a> The actual footnote doesn't look too bad,
    but keep reading.

3.  <a class="fn" id="fn:sup" href="#ref:sup">&uarr;</a> At least it works.
    Note that in Octopress superscripts are not very superscript by default.
    You must add `sup {vertical-align: super;}` to your
    `/sass/custom/_styles.scss`.
