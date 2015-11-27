---
layout: post
title: "LaTeX math in Octopress"
date: 2012-11-28 13:51
---

*Update: I no longer maintain this blog using Octopress, but I will leave this
post here in case it may be of use to people. For the curious, I now convert my
markdown posts to html using [Pandoc][pd], which has a `--mathjax` option that
renders $$\LaTeX{}$$ on the fly.*

[pd]: http://johnmacfarlane.net/pandoc/

With the help of Google and some smart Octopress bloggers
([here](http://www.idryman.org/blog/2012/03/10/writing-math-equations-on-octopress/),
particularly), I've successfully managed to get $$\LaTeX{}$$ math to show up in
my Octopress blog. Octopress uses [rdiscount][rd] as the default [markdown][md]
implementation/parser/converter-to-HTML, but unfortunately rdiscount cannot
parse or convert $$\LaTeX{}$$ code (because $$\LaTeX{}$$ code is, of course, not
markdown).

That's where [kramdown][kd] comes in. It parses and converts a superset of
markdown, including $$\LaTeX$$, meaning that together with [MathJax][mj] you can
have beautiful $$\LaTeX$$ math code rendered directly into your browser.

[rd]: https://github.com/rtomayko/rdiscount
[md]: http://daringfireball.net/projects/markdown/
[kd]: http://kramdown.rubyforge.org/
[mj]: http://www.mathjax.org/

You can have both inline math, e.g., $$A^{\ast} = \bigcup_{i=0}^{\infty} A^{i}$$,
as well as blocks of math. For example, as Kaplan and Kay (1994) tell us, if
$$A$$ and $$B$$ are regular $$n$$-relations, then so are

$$
\begin{align}
\mbox{$n$-way concatenation: } & A \cdot B = \{xy\mid x \in A, y \in B\} \\
\mbox{Union: } & A\cup B = \{x\mid x \in A \text{ or } x \in B\} \\
\mbox{$n$-way Kleene closure: } & A^{\ast} = \bigcup_{i=0}^{\infty} A^i
\end{align}
$$

<!-- more -->

Right-click on any of the math to view the MathJax options, including the
option to open the source code in a new window/tab. To get this all up and
running, follow these steps.

## 1\. Install kramdown

    gem install kramdown

## 2\. Replace rdiscount with kramdown

Open `_config.yml`, and change `markdown: rdiscount` to `markdown: kramdown`.

## 3\. Optional

Open `Gemfile`, and change `gem rdiscount` to `gem kramdown`, and change the
version number to whatever version you installed. This way if you migrate your
blog to a new machine, it'll complain if you try to `rake generate` before
grabbing kramdown (at least I think).

## 4\. Add MathJax script

Add the following MathJax script to `source/_layouts/default.html`:

```html
<!-- mathjax config similar to math.stackexchange -->
<script type="text/x-mathjax-config">
MathJax.Hub.Config({
  tex2jax: {
    inlineMath: [ ['$', '$'] ],
    displayMath: [ ['$$', '$$']]
  }
});
</script>
<script type="text/javascript"
  src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML">
</script>
```

## 5\. Fix right-click bug

At this point, kramdown and MathJax should both work; however, there's a bug
where if you right-click on any math, the website turns blank for as long as
the MathJax contex menu is open. To fix this, open `sass/base/_theme.scss` and
change

```css
body {
  > div {
    background: $sidebar-bg $noise-bg;
    border-bottom: 1px solid $page-border-bottom;
    > div {
      background: $main-bg $noise-bg;
      border-right: 1px solid $sidebar-border;
    }
  }
}
```

to

```css
body {
  > div#main {
    background: $sidebar-bg $noise-bg;
    border-bottom: 1px solid $page-border-bottom;
    > div {
      background: $main-bg $noise-bg;
      border-right: 1px solid $sidebar-border;
    }
  }
}
```

In other words, change the first occurrence of `div` to `div#main`.

**Important:** If, like me, you customized your background and therefore
override this `body` block in `sass/custom/_colors.scss`, then you have to
change the first occurrence of `div` to `div#main` in **both** files.

Now you can create inline math by surrounding the code with `$`, and block math
by surrounding the code with `$$`.
