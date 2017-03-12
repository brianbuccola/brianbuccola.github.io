---
layout: post
title: "Dealing with acronyms in LaTeX"
date: 2013-10-21 12:01
redirect_from: /blog/2013-10-21-dealing-with-acronyms-in-latex.html
tags: latex howto
---

I recently stumbled on what looks to be a very useful $$\LaTeX{}$$ package
called `acronym`. Its purpose is to simplify the task of defining and using
acronyms (and initialisms) when writing papers in $$\LaTeX{}$$ --- a *very*
common task in most academic fields, including linguistics.

The gist of `acronym` is that, once you properly define an acronym, you can use
a single command, `\ac{<label>}`, to generate either the "full form" of the
acronym when it's the first time the term is used, or the "short form" when the
term and acronym have already been introduced.

For example, we might want to do the following:

> Chomsky introduced the notion of Poverty of the Stimulus (POTS) to argue that
> lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy
> eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam
> voluptua.
>
> Evidence for POTS comes from the fact that at vero eos et accusam et justo
> duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus
> est Lorem ipsum dolor sit amet.

where the first occurrence of the term Poverty of the Stimulus is in its "full
form", i.e. the long-form term Poverty of the Stimulus plus the short-form
acronym POTS, and any subsequent occurrence is simply the acronym.

With `acronym` it's as easy as:

```latex
\documentclass{article}

\usepackage{acronym}
\acrodef{pots}[POTS]{Poverty of the Stimulus}

\begin{document}

Chomsky introduced the notion of \ac{pots} to argue that lorem ipsum dolor sit
amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut
labore et dolore magna aliquyam erat, sed diam voluptua.

Evidence for the \ac{pots} comes from the fact that at vero eos et accusam et
justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata
sanctus est Lorem ipsum dolor sit amet.

\end{document}
```

The relevant line is: `\acrodef{pots}[POTS]{Poverty of the Stimulus}`. The
command `\acrodef` takes two required arguments and one optional argument:

1. The acronym *label*, in this case `pots` (similar to a bibkey in BibTeX).
2. The *acronym* (optional), also called *short form* in the documentation, in
   this case `POTS`.
3. The *long form*, in this case `Poverty of the Stimulus`.

It might seem weird that the acronym is optional, but that's because if no
acronym is given, then `acronym` will use the label as the acronym. So you
could do `\acrodef{POTS}{Poverty of the Stimulus`, and that would produce
"POTS"; however, I prefer my labels to be lowercase, because I'm lazy when
typing.

`acronym` also provides the commands `\acf`, `\acl`, and `\acs` for producing
full, long, and short forms manually.

What if you want the term Poverty of the Stimulus to be *italicized* in the
full form? Then use the command `\acfi` (mnemonic: acronym fullform italic).
**Caveat:** When using `\acfi`, for some reason the acronym does not get marked
as "used". Thus, if `\acfi{pots}` is the first occurrence of the term, then the
very next `\ac{pots}` will produce the full "Poverty of the Stimulus (POTS)"
rather than just "POTS". To rectify this, use the `\acused` command, which
marks its argument as "used".:

```latex
Chomsky introduced the notion of \acfi{pots} \acused{pots} to argue that ...
```

The last thing I'll mention is that instead of using `\acrodef` in the
document's preamble, you can instead use the `acronym` environment inside the
document, with acronym entries defined using the `\acro` command. The
difference is that now `acronym` will produce a nice listing of all acronyms
and their long forms. You can even add the `withpage` package option to list
the pages that each acronym first occurs on. I imagine this would be very
useful for a book or long manuscript to have.

For a list of all available commands and their descriptions, see the `acronym`
documentation: `$ texdoc acronym` in your nearest terminal emulator.
