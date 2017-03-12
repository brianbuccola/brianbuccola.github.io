---
layout: post
title: "How to cite in LaTeX without the citation appearing in the bibliography"
date: 2015-01-29 17:19
redirect_from: /blog/2015-01-29-how-to-cite-in-latex-without-the-citation-appearing-in-the-bibliography.html
tags: latex bibtex biblatex howto
---

A friend and colleague of mine asked on Facebook if it's possible in
$$\LaTeX{}$$ to include a citation (or several) in the main text without the
reference(s) actually appearing in the bibliography section. For example, in
the following text, Smith (2015) and Johnson (2015) are both cited, but Johnson
(2015) does not appear in the references section.

> According to Smith (2015), bluejays are the best; but according to Johnson
> (2015), cardinals are better.
>
> **References**
>
> Smith, Mary. 2015. *All About Birds*. New York, NY: Bird Cage Press.

Note that the `bibentry` package allows you to include a *whole* citation in
the main text, e.g. "According to Johnson, Harry (2015) *More About Birds*
...". But here, we just want "Johnson (2015)".

## BibTeX solution

As far as I'm aware, this is not (natively) possible with BibTeX: the moment
you do `\cite{<key>}` and then run `pdflatex` + `bibtex`, the `\bibitem`
associated with *\<key\>* gets added to the `.bbl` auxiliary file, which is
ultimately responsible for the bibliography. Any `\bibitems` in there appear in
the bibliography.

The hacky suggestion I originally gave was to write, cite, and compile
everything just as one would normally do when writing a LaTeX document. For
example, if the file you're writing is `file.tex`, then run:

```bash
$ pdflatex file
$ bibtex file
$ pdflatex file
$ pdflatex file
```

or, if you're using a LaTeX front-end/wrapper, then use whatever button/command
is available for typesetting, such as "Typeset" in MacTeX (I think), or
`latexmk file` if (like me) you use `latexmk`.

Once you're finished writing and are absolutely 100% sure you won't be adding
or removing or otherwise changing any citations, then open `file.bbl` and
delete any of the bibitems that you wish not to appear in the bibliography.
After that, simply run `pdflatex file` one more time, and you're done.

NB: *Don't* rerun `bibtex file` (hence, *don't* "Typeset" or run `latexmk` or
do anything that would itself rerun `bibtex`), since that would overwrite
`file.bbl`, and you'd be back to where you started.

### Advantage

The advantage to this solution is that you can more or less maintain your
normal LaTeX + BibTeX workflow, up to the very end.

### Disadvantage

The obvious disadvantage is that, after you've gone through all the trouble of
removing bibitems from `file.bbl`, you can no longer typeset your document
without fear of overwriting `file.bbl`. You could, of course, save a copy of
the precious `.bbl` file in case you overwrite it, but then if you want to add
new citations to your document, you'll have to merge the new `file.bbl` with
the copy of the older `file.bbl`. Quite a mess, and certainly not elegant.

## Biblatex solution

A better option is to use [Biblatex][bl]. I won't expound here on the
advantages of Biblatex over BibTeX, or even on the basics of how to use
Biblatex. (Maybe some other time.) See
[here](https://tex.stackexchange.com/questions/25701/bibtex-vs-biber-and-biblatex-vs-natbib)
for a discussion of BibTeX vs. Biblatex, and see
[here](https://www.sharelatex.com/blog/2013/07/31/getting-started-with-biblatex.html)
for a crash course in Biblatex.

Among its many features, Biblatex allows you to define bibliographic categories
with `\DeclareBibliographyCategory{<category>}` and then assign categories to
your bibliographic entries with `\addtocategory{<category>}{<key>}`. The
categories can be anything at all. Once you've assigned categories to your
entries, you can use commands that are sensitive to those categories. One such
command is the `\printbibliography` command, which replaces LaTeX's normal
`\bibliography{...}` command at the end of the document.

Normally, `\printbibliography` does just that: it prints the bibliography. But
you can give it some options, such as `\printbibliography[category=<blah>]`,
which prints a bibliography containing all and only entries of the category
*blah*. Or you can do `\printbibliography[notcategory=<blah>]`, which prints a
bibliography containing all and only entries that are *not* of the category
*blah*.

So the solution is to create a new category for the entries that we want to
cite in the main text but suppress in the bibliography. We do that by issuing
`\DeclareBibliographyCategory{ignore}` (the category name can be anything) in
the preamble, and then tagging the entries we want to ignore by issuing
`\addtocategory{ignore}{<key>}`.

Here is a minimal working example:

```latex
\documentclass{article}
\usepackage[style=authoryear]{biblatex}
\addbibresource{/path/to/references.bib}
\DeclareBibliographyCategory{ignore}
\addtocategory{ignore}{johnson2015}
\addtocategory{ignore}{doe1986}

\begin{document}

\cite{johnson2015},
\cite{smith2015},
\cite{doe1986},
\cite{samson2012}

\printbibliography[notcategory=ignore]
\end{document}
```

With this code, all four references will get cited in the main text, but
Johnson (2015) and Doe (1986) will not appear in the bibliography section.

### Advantage

The overwhelming advantage here is that this is an elegant (non-hacky) solution
that capitalizes on a feature of the Biblatex package that was designed
precisely to solve sticky problems like this that BibTeX is unable to handle.
No need to manually edit auxiliary files or anything.

Moreover, the solution is exetnsible: if you decide later that you want to omit
Smith (2015) from the bibliography, simply add
`\addtocategory{ignore}{smith2015}` to your preamble. if you decide that you
*do* want Johnson (2015) in the bibliography, simply delete or comment out the
line `\addtocategory{johnson2015}`.

### Disadvantage

The only disadvantage that I can see is that you need to use Biblatex. Of
course, users of Biblatex would hardly see this as a disadvantage. But there
are certainly at least some minor disadvantages to using Biblatex, especially
if you've never used it before. One is that you have to learn what commands to
include before and after the document, as well as some new `\cite` commands.
But that's easy. A more serious potential problem is that you simply cannot use
Biblatex. For example, you're submitting to a journal that doesn't allow it, or
you're collaborating with someone who refuses to use/learn it. Hopefully,
though, in due time, Biblatex will come to supersede BibTeX + `natbib`, and
these will be non-issues.

*NB: The solution presented here is based on a comment by [Daniel
Gutzmann][dg], who suggested creating several bibliographies based on keywords,
and then printing only those bibliographies containing (or lacking) a specific
keyword. The advantage of my solution is that you can still use a single master
`.bib` file and then categorize the entries in the preamble. If you wanted to
reproduce the effect across several documents, you could hardcode the
categories onto the entries in the actual `.bib` file by adding
`\DeclareBibliographyCategory{<category>}` and `\addtocategory{<key>}` to the
`@preamble` of your `.bib` file.*

[bl]: http://www.ctan.org/pkg/biblatex
[dg]: http://www.danielgutzmann.com/
