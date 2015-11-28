---
layout: post
title: "Pandoc, MathJax, Google fonts, and HTTPS"
date: 2015-01-06 13:25
redirect_from: /blog/2015-01-06-pandoc-mathjax-google-fonts-and-https.html
---

**tl;dr** For any secure (`https`) webpage with URLs in its source code to
Google fonts or MathJax, those URLs must *also* be secure (`https`); otherwise,
the fonts, $$\LaTeX{}$$, etc. won't render.

It's been nearly a year since I last posted. One of my resolutions this year
(my dissertation year!) is to write more, including on this blog. Ideally I'd
write about semantics, but for now, just to get back into the swing of things,
I'll be happy to write about anything. To that end, here's a post.

I just upgraded [pandoc][pd] yesterday and decided to rebuild my blog to see if
any changes would occur. (I write my blog in [markdown][md] and then convert to
html using pandoc, so basically I reconverted all my posts markdown -> html.)
Aside from the copyright changing from "2012--2014" to "2012--2015", there was
only one subtle, but substantial change, and that has to do with [MathJax][mj].

MathJax is "an open source JavaScript display engine for mathematics that works
in all browsers". For example, it renders the html code `\(f(x) = x^2 + 4x -
3\)` into $$f(x) = x^2 + 4x - 3$$. The stuff between `\(...\)` is $$\LaTeX{}$$
code, and `\(...\)` are the delimiters that MathJax looks out for. But
actually, since I write my blog in markdown, I delimit $$\LaTeX{}$$ code using
`$...$` (just like in $$\LaTeX{}$$ itself) since that's what *pandoc* looks out
for. In other words:

1. Write in markdown: `$f(x) = x^2 + 4x - 3$`
2. Markdown becomes html (via pandoc): `\(f(x) = x^2 + 4x -3\)`
3. Html becomes pretty (via mathjax): $$f(x) = x^2 + 4x -3$$

MathJax is run as a script within the html source code. All you need is
something like this, which links to some MathJax JavaScript:

```html
<script src="http://cdn.mathjax.org/mathjax/..." type="text/javascript"></script>
```

(The full MathJax source URL is [here][mj-full].)

The pandoc option `--mathjax` is supposed to automagically add the source URL,
and it did, until the recent pandoc update. After the update, I noticed that
the `http:` part was completely missing.
[Apparently](https://github.com/jgm/pandoc/issues/1847), this isn't really a
bug; it was removed for principled reasons. The solution, I thought, was simply
to change from using `--mathjax` to explicitly using

```bash
--mathjax="http://cdn.mathjax.org/mathjax/..."
```

I tried that, and it worked! At least, on my *local* copy of the blog
(`file:///home/brian/blog/...`). It did *not* work when I pushed the changes to
github (`http://brianbuccola.github.io/blog/...`). The MathJax wasn't rendering
there. Huh.

I also noticed something else: my Google fonts were rendering on my local copy
of my blog, but not on the GitHub blog. Were the issues related? Yes, they
were. Here's how.

I use the Firefox extension HTTPS-Everywhere, which tries to use the more
secure `https://blah.com/` instead of `http://blah.com/` whenever possible. It
turns out that when using the secure version of my blog,
`https://brianbuccola.github.io/`, any insecure (`http`) Google font URLs or
MathJax URLs *won't work*. They need to all be changed to `https`. So that's
what I did

```bash
--mathjax="https://cdn.mathjax.org/mathjax/..."
```

```html
<script src="https://cdn.mathjax.org/mathjax/..." type="text/javascript"></script>
```

and voilà, everything works again.

Moreover, using `https` URLs for Google fonts and MathJax *still* works when
using the normal `http` version of my blog. So as far as I can tell, there's no
downside to always using the secure `https` URLs in your html source code, as
far as text rendering goes.

[pd]: http://johnmacfarlane.net/pandoc/
[md]: http://daringfireball.net/projects/markdown/
[mj]: http://www.mathjax.org/
[mj-full]: http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML
