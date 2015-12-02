---
layout: post
title: "Maintaining an academic website, part 1: editing the site"
date: 2013-02-23 15:19
redirect_from: /blog/2013-02-23-maintaining-an-academic-website-part-1-editing-the-site.html
---

This is the first in a series of posts in which I'll explain how I currently
maintain my academic website ([here][my-site]). By "maintain", I mean
everything from editing the site locally on my PC, to pushing the changes to
the remote McGill server that hosts the site, to version--controlling it all
with git. The best thing about it: no browser (or any GUI at all) is
required---everything happens in the terminal---*and* I still don't have to
deal with HTML. The method should work for any simple website with static
content.

Also, I realize that my site is currently pretty small, and there's not much to
update very often, so my method may seem overly complex, but (i) it was a fun
learning experience setting it all up, and (ii) as my site grows, I think my
method will make site maintenance way easier than it otherwise would be, while
also keeping the actual site simple (see next).

[my-site]: https://github.com/brianbuccola/mcgill-website

**KISS disclaimer.** Before I begin, I should mention that when it comes to
professional websites, I believe that the [KISS][] principle should be
followed: **K**eep **i**t **s**imple, **s**tupid! For me, that means no flashy
banners or animations, no crazy amount of fonts or colors, etc. For this post,
I'll assume we're dealing with a website with a single page called `index.html`
(but extending the method to multiple pages should be trivial) consisting of
little more than basic text (headers, links, lists) and basic formatting (bold,
italics) and maybe an image or two. Of course, feel free to go crazy in your
CSS stylesheet... but please, no neon.

[KISS]: http://en.wikipedia.org/wiki/KISS_principle

Here is my general workflow for site maintenance.

1. Edit the site locally on my PC, using [markdown][] and [pandoc][].
2. Push changes to the remote server hosting the site, using `ssh` and
    [rsync][].
3. Track changes using [git][], and push changes to [GitHub][] (or similar) for
    version control.

[markdown]: http://daringfireball.net/projects/markdown/
[pandoc]:   http://johnmacfarlane.net/pandoc/
[rsync]:    http://rsync.samba.org/
[git]:      http://git-scm.com/
[GitHub]:   https://github.com/

Each post in this series will cover one step in detail, including the various
scripts I've hacked together to automate it all.

<!-- more -->

Editing the site
----------------

Editing your webpage could be as simple as opening `index.html` in your
favorite text editor and hammering away, and in fact, that's what I used to do.
But I really hate editing HTML. To me, the tags make everything ugly and
unreadable, and since I'm no web developer, I never know the proper way to do
things anyway. Is it `<br>` or `<br />`? Do I close with `</p>`, or is that
unnecessary? I dunno!

That's why now I write exclusively in [markdown][]. In fact, I write this blog
in markdown, I write my notes in markdown, I write emails (mostly) in markdown.
When I want HTML, I just use [pandoc][] to automagically convert the markdown
to HTML and add the necessary HTML header stuff.

The rest of this post will explain the merits of markdown and pandoc and how I
use them together to write my webpage. Here's the breakdown:

- [Markdown](#markdown)
- [Pandoc](#pandoc)
- [Metadata](#metadata)
- [Putting it all together](#putting-it-all-together)

### Markdown

Markdown was designed as a way to write highly readable plain text that can be
converted into HTML while also faithfully reproducing lists, textual emphasis,
links, etc. Take, for example, the following simple HTML code:

{% highlight html %}
<h1>My supercool site</h1>

Welcome to the <em>best</em> academic site in the world! Here are my research
interests:

<ul>
    <li>Stuff</li>
    <li>Junk</li>
    <li>More stuff</li>
</ul>

You can download my CV <a href="cv.pdf">here</a>!
{% endhighlight %}

Okay, okay, it's not as ugly and illegible as I made it out to be (that is, as
long you don't start adding javascript and `div` and `span` tags everywhere),
but compare it with the totally equivalent markdown version:

{% highlight html %}
My supercool site
=================

Welcome to the *best* site in the world! Here are my research interests:

- Stuff
- Junk
- More stuff

You can download my CV [here](cv.pdf).
{% endhighlight %}

If you've never seen markdown before, you might not even realize that there's
anything "special" about the text above. By "special", I mean syntactically:
the fact that `=`, `*`, `-`, and `[..](..)` have special meanings when they
occur in markdown. The text reads very naturally, as if it were written just to
look good but without any well--defined syntactic meaning. But it's much more
than just good--looking text.

In markdown, underlining text with `=` makes it a main header, surrounding text
with `*` makes it emphatic (usually rendered as italics), listing things with
`-` (or `*`) turns them into, well, lists, and so forth. Only the link syntax
is slightly unintuitive (maybe), but it's easy to learn, and if you use
[reddit][] or [stackoverflow][], you probably already know it.

[reddit]:        http://www.reddit.com/
[stackoverflow]: http://stackoverflow.com/

The basic markdown syntax is pretty simple, and yet also quite comprehensive.
As long as you're maintaining a simple, KISS--type website, markdown should
serve you well. That's all I'll say about markdown syntax; for more info, head
to the markdown website, and definitely read the entire
[syntax](http://daringfireball.net/projects/markdown/syntax) page. (It's not
long, which is a testament to markdown's simplicity.)

### Pandoc

OK, so you've got a markdown file, like `index.markdown`, with some headers,
paragraphs, lists, links. Now what? Enter pandoc, the Swiss army knife of
document conversion tools. You can convert your file to HTML5, $$\LaTeX$$, and
plenty other formats, but we'll stick with HTML5.

Moreover, pandoc understands a *superset* of markdown, i.e., a sort of extended
markdown. For example, you can add metadata to the top of your markdown file
that pandoc can use when creating HTML header info (see below), and you can do
other cool things like add footnotes. Following the KISS principle, though,
we'll stick with normal, non--extended markdown.

(Note that pandoc is not the only conversion tool you can use. Markdown comes
with its own perl script, `Markdown.pl`, and there's also [kramdown][],
[maruku][], etc., written in Ruby. But pandoc has some really useful options
that'll make life easier, as we'll see below. If you prefer Ruby over Haskell,
try one of the above.)

[kramdown]: http://kramdown.rubyforge.org/
[maruku]:   http://maruku.rubyforge.org/

The basic command is:

{% highlight bash %}
$ pandoc -f markdown -t html5 -o index.html index.markdown
{% endhighlight %}

Legend:

- `$` is the terminal prompt; don't type this.
- `-f markdown` means convert **f**rom markdown.
- `-t html5` means convert **t**o HTML5.
- `-o index.html` means make `index.html` the **o**utput filename.
- `index.markdown` is the main argument of `pandoc`; it's the file we're
  converting.

### Metadata

Assuming you have a basic `index.markdown` with no extra HTML in it (oh, I
forgot to mention that markdown can include arbitrary HTML, but remember,
KISS), then pandoc will produce an HTML file that has all the basic HTML tags
corresponding to your markdown syntax, but it'll lack any metadata
(the stuff inside `<head>`) , like what the title of the website is---which is
very important, since, for example, that's what people will see in Google
search results---and who the author is, also very important, if you want people
to find your site when they Google you.

Luckily, pandoc provides a commandline option for automatically generating
header info, the `DOCTYPE`, etc.: it's `-s`, meaning **s**tandalone, as in the
output can stand on its own as an HTML file.

However, using `-s` still won't add a title or an author. There are two ways to
do that. First, as mentioned above, you can add pandoc--specific metadata to
your markdown file, like this:

{% highlight html %}
% My title
% My name

My supercool site
=================

...
{% endhighlight %}

When pandoc parses the file, it'll see the top two lines starting with `%` and
from them generate title and author info for the header. However, I don't like
this method because it dirties up the markdown file, in the sense that
`index.markdown` is now written in pandoc--specific, extended markdown. (If you
later decided to convert your file with, say, kramdown, or if you viewed it in
your browser on GitHub, then you'd see those two `%` lines in your HTML
output.) But if that doesn't bother you, by all means use this method.

A second way to supply title and author info is by explicitly telling pandoc
what values to use for its internal author and title **v**ariables:

{% highlight bash %}
$ pandoc -V pagetitle="My title" -V author-meta="My name" ...
{% endhighlight %}

Since I use a personalized script (see below) to run pandoc, I prefer this
method because I can keep this metainfo inside my script and not inside the
markdown file itself. Separation of main content and meta--content is
important!

Now what if you want to add more header info for which pandoc doesn't have
internal variables or command--line options? That's easy: create `header.html`
(or whatever you want to call it), throw in whatever HTML you want in your
header (except title and author), and run

{% highlight bash %}
$ pandoc -H header.html ...
{% endhighlight %}

Your `header.html` is a great place to add optional stuff like `description`
and `keyword` metadata, the URL to your favicon (if you have one), and any
Google Analytics code.

You can also have a `before-body.html` file which, if `-B before-body.html` is
used, will be inserted as the very first thing after `<body>`. I use this to
hold the code that puts my picture in the top--right corner of my webpage. The
reason I do this is that markdown doesn't deal with images very well, so I need
to use `div` and other ugly--looking HTML. Plus, I don't feel that an image is
part of the main content anyway; if I wanted to give someone a text--only
version of my page, I'd like to be able to give them the markdown source, with
no image code.

Also, as you probably guessed, you can have an `after-body.html` file which, if
`-A after-body.html` is used, will be inserted as the last thing before
`</body>`. This is useful if you want, say, a footer that's not semantically
part of the main page, e.g., a "last updated: ..." line.

(Note: the mnemonic is that `-B` specifies what goes **b**efore the body, and
`-A` what goes **a**fter, but keep in mind that both contents do ultimately end
up *inside* of `<body></body>`.)

### Putting it all together

All right, so you've got `index.markdown`, and maybe also `header.html`,
`before-body.html` and `after-body.html`. You probably also have a CSS
stylesheet like `mystyle.css`, which you can tell pandoc about with `-c
mystyle.css` (or you can refer to it yourself in `header.html`).

Here's what your command will look like:

{% highlight bash %}
pandoc \
    -c mystyle.css \
    -H header.html -B before-body.html -A after-body.html \
    -V pagetitle="My title" -V author-meta="My name" \
    -f markdown -t html5 -o index.html index.markdown
{% endhighlight %}

Wow, that's a lot to type each time you want to convert a newly modified
markdown file into HTML. Better put that inside a script. Let's also put each
of those things into a variable, so that we can easily modify the script
command by changing variables rather than the command itself.

{% highlight bash %}
#!/bin/bash

TITLE="My title"
AUTHOR="My name"

IN_FILE="./index.markdown"
OUT_FILE="./index.html"

CSS="./mystyle.css"
HEADER="./header.html"
BEFORE="./before-body.html"
AFTER="./after-body.html"

# Convert markdown to html5.
pandoc
    -c "$CSS" \
    -H "$HEADER" -B "$BEFORE" -A "$AFTER" \
    -V pagetitle="$TITLE" -V author-meta="$AUTHOR" \
    -f markdown -t html5 -o "$OUT_FILE" "$IN_FILE"
{% endhighlight %}

Save this as, say, `md2html.sh`, make it executable with `chmod +x md2html.sh`,
plop it inside the website directory containing `index.markdown`, and simply
run:

{% highlight bash %}
$ ./md2html.sh
{% endhighlight %}

You should now see `index.html` in the same directory, which you can open in
your browser to inspect and make sure it looks good.

And there you have it. Now, whenever you need to edit your webpage, you can
deal entirely with `index.markdown` using your favorite text editor, save the
changes, and run `md2html.sh` to (re--)generate `index.html`. Easy.

In the next post, I'll explain how to push your website onto a remote server,
e.g., a university server, using ssh and rsync inside a script. The end result
is that, in the same way that `md2html.sh` does the whole conversion in one
fell swoop, so too will `push-website.sh` push your site in one fell swoop: no
passwords or GUI clicking required.
