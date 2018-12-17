---
title: "Use Biblatex/Biber to create a new subdatabase based on an auxiliary file"
date: 2016-10-05
tags: [latex, biblatex, howto]
---

*(NB: I discovered this feature of Biblatex/Biber by searching for a way to
replicate [the very same feature in JabRef][JabRef], which I no longer use.)*

Sorry for the title gore. Here is what I mean. Suppose you're writing a paper
called `paper.tex` that uses a BibTeX database (bib file) called `master.bib`
containing all of your references. Normally, of course, `paper.tex` doesn't cite
every single entry in `master.bib`, but only a subset of them. Suppose now that
your paper has been accepted in some journal, and you need to submit your bib
file to the typesetters. Obviously, you don't really want to submit your entire
`master.bib`, but you also don't want to manually extract the subset of entries
actually cited in your paper. Well, it turns out you don't have to: you can
automatically create a new bib file containing exactly that subset by using
`biber` (the backend processor to [Biblatex][]). Here's how. (NB: In
`paper.tex`, you have to use the `biblatex` package with `biber` as the backend
processor. This won't work with regular `bibtex`.)

**Step 1.** Run `pdflatex paper.tex`, which will generate the auxiliary file
`paper.bcf`.

**Step 2.** Run `biber --output-format=bibtex paper.bcf`.

(You can leave off the `.tex` and `.bcf` extension in both commands.)

This will generate a file `paper_biber.bib` containing all entries in
`master.bib` that are cited in `paper.tex`. At this point in our made-up
scenario, you would probably rename `paper_biber.bib` to something like
`refs.bib`, change the `\addbibresource` line in `paper.tex` to use `refs.bib`,
recompile everything to make sure it all works, and finally submit `paper.tex`
and `refs.bib` to the journal.

One quick follow-up note. By default, `biber` will put entry names like
`@article` and entry fields like `author` in all caps:

```bibtex
@ARTICLE{smith2016,
  AUTHOR = {Mary Smith},
  ...
}
```

I personally like having everything in all lower case, because I don't like my
bib entries to yell at me (of course, as far as `biber` is concerned, it doesn't
actually matter: it's all cosmetics). You can tell `biber` what to do by using
the `--output_fieldcase` flag. The possible options are `upper` (default),
`lower` (my preference), or `title` (e.g. `InProceedings`).

There are a bunch of other output options, too. For example, you can specify the
output filename (e.g. `--output-file=refs.bib`), whether to align entry fields
in neat columns (`--output-align`), how many spaces to indent entry fields (e.g.
`--output-indent=4`), and so on. See `biber --help`, in particular everything
starting with `--output-*`. Here's an example command.

```bash
$ biber --output-format=bibtex --output_fieldcase=lower --output-file=refs.bib paper.bcf
```

[Biblatex]: http://biblatex-biber.sourceforge.net/
[JabRef]: https://help.jabref.org/en/NewBasedOnAux
