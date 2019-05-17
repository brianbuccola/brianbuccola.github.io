---
title: "Troubleshooting LaTeX compilation errors when submitting to journals"
date: 2019-05-16 19:33
tags: [latex, howto]
---

I just spent several hours
troubleshooting a number of problems I encountered
while trying to submit the LaTeX source files
of a forthcoming manuscript
to a journal hosted by Manuscript Central / ScholarOne
(*Journal of Semantics*).
Since I
(and/or others)
will likely encounter these
(or similar)
problems in the future,
I figured I'd document my solutions
to the two problems
that gave me the most trouble,
plus my failure to solve a third problem.
Given also my [previous post][pp],
this may turn into a series of posts...

[pp]: /how-to-force-pdflatex-pdf-over-latex-dvi-compilation/

**Pro-tip:**
The first step is always
to inspect the log file produced by the compilation.
In my case,
I saw that the journal's version of TeX Live
is from 2013 —
6 years old!
This turned out to be the source
of both problems below.

## 1. Fixing old versions of TeX Live with fixltx2e

The first problem was that I kept getting an error
regarding my use of `\textsubscript`.
It took me longer than I care to admit
to just google the issue.
The first result was [this Stack Exchange thread][se],
which reveals that before 2015,
you needed to use the `fixltx2e` package
to properly use `\textsubscript`.
So I added

```latex
% Fix LaTeX2e (needed for JoS's 2013 version of TeX Live)
\usepackage{fixltx2e}
```

to my preamble.

If you're using an up-to-date version of TeX Live,
this will produce a warning
letting you know that you don't need this package anymore.

[se]: https://tex.stackexchange.com/questions/1013/how-to-typeset-subscript-in-usual-text-mode

## 2. Using a package that the journal doesn't have

The second problem was that
the journal doesn't have the [*ExPex*][ep] package.
(This package was only written in 2014,
a year after the journal's version of TeX Live,
and only available as part of TeX Live since 2017.)

[ep]: https://ctan.org/tex-archive/macros/generic/expex

In theory,
this shouldn't pose a huge problem,
because the journal allows you to upload
"supplementary TeX/LaTeX files" —
meaning you can just upload the source files
to any package that's missing.

In the case of *ExPex*, those files would be:

```
expex.sty
expex.tex
epltxfn.sty
```

(`expex.sty` is just a wrapper for `expex.tex`.
There's also `epltxchapno.sty`,
but that's for works with chapters.)

The problem I encountered was that
the journal was trying to convert `expex.tex` to a PDF,
which was producing a bunch of errors —
because that file isn't intended
to be converted into a PDF —
and the system won't let you complete submission
if there are any unconverted TeX files.

On a hunch,
I renamed `expex.tex` to `expex`
(i.e. I removed the extension).
Thankfully...

1. The journal didn't complain much.
(It did give me a warning about no extension,
but it let me continue anyway.)
2. It no longer tried to convert `expex` to PDF.
3. The missing *ExPex* package worked seamlessly
even with the missing `.tex` extension on the main file.

## 3. Re-running Biber (or BibTeX) to fix citations

This is something I *couldn't* solve:
although the system produced a PDF,
it didn't produce proper citations,
or print a bibliography.
Usually, this means that Biber (or BibTeX)
needs to be re-run,
but I couldn't force the system to do that from my end.

The problem could be because I use Biblatex/Biber
instead of the traditional BibTeX.
I tried forcing the Biber backend
by [adding the directive][se2]

[se2]: https://tex.stackexchange.com/questions/78101/when-and-why-should-i-use-tex-ts-program-and-tex-encoding

```latex
% !BIB TS-program = biber
```

to the top of the TeX file,
but that didn't work.
(This is apparently only for TeX Shop,
which I guess the journal doesn't use.
I'm not sure if there's a more general directive,
or a directive for `latexmk`,
similar to the `%&pdflatex` directive
that I discussed in my [previous post][pp].)

The problem could also be because
the journal uses plain `pdflatex`
rather than something like `latexmk`,
which takes care of Biber/Biblatex
and multiple compilations.

In any case,
I was able to complete my submission
(along with my own PDF,
with all the citations and bibliography),
because of the solutions to the first two problems.
