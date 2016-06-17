---
layout: post
title: "Right-aligned text in a linguex gloss example (LaTeX)"
date: 2016-01-23
---

[linguex][] is a LaTeX package, popular among linguists, which "facilitates the
formatting of linguistics examples, automatically taking care of example
numbering, indentations, indexed brackets, and the '\*' in grammaticality
judgments." The main command is `\ex.`, which is used to produce a simple
example like this:

{% highlight latex %}
\ex. Colorless green ideas sleep furiously.
{% endhighlight %}

It is common, of course, to add a bit of commentary text to an example, such as
a parenthetical citation.[^parencite] An easy way to do this is to right-align
the text using `\hfill`:

[^parencite]: You should of course use `\parencite` ([biblatex][]) or `\citep`
              ([natbib][]) instead of manually entering citations.

{% highlight latex %}
\ex. Colorless green ideas sleep furiously. \hfill (Chomsky 1957)
{% endhighlight %}

Importantly, linguex allows you to easily create glossed examples by using a
slight variant of `\ex.`, namely the `\exg.` command. Instead of a single line,
`\exg.` expects 2-3 lines: the example, the gloss, and (optionally) the
translation.

{% highlight latex %}
\exg. Il ne veut pas venir.\\
he \textsc{ne} want.3sg not come.inf\\
`He does not want to come.'

\exg. Er will nicht kommen.\\
he want.3sg not come.inf\\     % no translation necessary
{% endhighlight %}

Now, what if you want to add some commentary text, for example the language
being glossed? It turns out (due to the inner workings of linguex) that you can
only `\hfill` some text on the third line, not the first. In other words, this
works...

{% highlight latex %}
\exg. Il ne veut pas venir.\\
he \textsc{ne} want.3sg not come.inf\\
`He does not want to come.' \hfill (French)
{% endhighlight %}

...but this doesn't...

{% highlight latex %}
\exg. Il ne veut pas venir. \hfill (French)\\
he \textsc{ne} want.3sg not come.inf\\
`He does not want to come.'
{% endhighlight %}

If all your glosses have translations, and if you don't mind the look of
commentary text on the third line, then this is good enough. However, if some
of your examples don't need translations, or if you simply prefer the look of
commentary text on the first line, then here is a workaround.[^attrib]

[^attrib]: This solution is a modification of a solution I came across on
           Facebook (which inspired this blog post), posted by Laura Kalin in
           response to a LaTeX question by Keir Moulton. Laura's solution,
           which she attributed to Byron Ahn, involved using `\rput` instead of
           `\raisebox`. `\rput` comes from the PSTricks package. A problem with
           this solution is that PSTricks does not work with PDFLaTeX (at least
           not by default), which means you need to first compile to PS/DVI and
           then convert PS/DVI to PDF, or else use XeLaTeX instead. (Also,
           PSTricks does not play nicely with certain other packages, IIRC.)
           The advantage of using `\raisebox` is that it's a native LaTeX
           command; no extra package necessary.

{% highlight latex %}
\exg. Il ne veut pas venir.\\
he \textsc{ne} want.3sg not come.inf\\
`He does not want to come.' \hfill \raisebox{1.9\baselineskip}[0pt][0pt]{(French)}
{% endhighlight %}

What this does is put "(French)" inside of a `\raisebox`, which is a box that
gets raised (almost) 2 lines up, so that "(French)" ends up on the same line as
the French example. (Actually, what's going on under the LaTeX hood is more
complicated than that, but that's essentially the end result.)

We can abstract over this particular case and define a new command to use
throughout a document as follows:

{% highlight latex %}
% Right-aligned comment in glossed example
\newcommand{\rcommentg}[1]{\raisebox{1.9\baselineskip}[0pt][0pt]{#1}}
{% endhighlight %}

Now, you can just do this:

{% highlight latex %}
\exg. Il ne veut pas venir.\\
he \textsc{ne} want.3sg not come.inf\\
`He does not want to come.' \rcommentg{(French)}

\exg. Er will nicht kommen.\\
he want.3sg not come.inf\\
`He does not want to come.' \rcommentg{(German)}
{% endhighlight %}

A few caveats:

1. You may have to fiddle with the `1.9` value, depending on font, etc.
2. If your example is really long and spills over to a second line, then
   `\rcommentg` won't work. In that case, just manually add the comment using a
   `\raisebox` and a larger value than `1.9\baselineskip`.
3. If your example spills over to the next page, i.e. the example sentence is
   on one page while the translation is on the next page, then `\rcommentg`
   won't work. My suggestion in this case is to wait until your manuscript is
   otherwise completely finished, and then add a `\clearpage` before the
   offending example. (Glossed examples really should not split across more
   than one page anyway, IMO.)

Lastly, I should mention that [expex][], a much more sophisticated example
package, comes with its own `\rightcomment` command that can be used on *any*
line of a gloss example. In expex, the French example above would look like
this:

{% highlight latex %}
\ex
\begingl
\gla \rightcomment{(French)}Il ne veut pas venir.//
\glb he \textsc{ne} want.3sg not come.inf//
\glft `He does not want to come.'//
\endgl
\xe
{% endhighlight %}

(Note the lack of space between the comment and the word "Il", and note the use
of *forward* double slashes to end a line.)

expex automatically handles all the caveats above. The downside (which is very
subjective, of course) is that expex's syntax is more cumbersome than
linguex's. However, if you find yourself doing quite a bit of complex examples,
requiring sophisticated commenting, spacing, formatting, etc., then you should
definitely consider switching to expex.

[linguex]: https://www.ctan.org/pkg/linguex
[biblatex]: https://www.ctan.org/pkg/biblatex
[natbib]: https://www.ctan.org/pkg/natbib
[expex]: https://www.ctan.org/pkg/expex

