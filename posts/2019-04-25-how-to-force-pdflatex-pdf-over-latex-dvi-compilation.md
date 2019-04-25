---
title: "How to force pdflatex (PDF) over latex (DVI) compilation"
date: 2019-04-25 14:54
tags: latex howto
---

**PSA:**
If you're submitting a latex source file to a journal,
and their compiler is giving you errors related to DVI output,
try adding `%&pdflatex` to the top of the file
(make it line 1, all by itself)
to force using `pdflatex` over plain `latex` + `dvipdf`.

```latex
%&pdflatex
\documentclass{article}
\begin{document}
Hello, world!
\end{document}
```

In my case,
I was getting errors along the lines of

```
! LaTeX Error: Cannot determine size of graphic in figure.pdf (no BoundingBox)
```

This is an indication that the backend compiler is plain `latex`
(trying to create a DVI),
which is unable to determine the size of PDF, PNG, or JPG images.
(If this is your only problem,
then another solution is to use EPS images instead,
which should be handled just fine by plain `latex`.)

More info in the following TeX StackExchange threads:

- [Cannot determine size of graphic](https://tex.stackexchange.com/questions/17734/cannot-determine-size-of-graphic)
- [Cannot determine the size of the image](https://tex.stackexchange.com/questions/347460/cannot-determine-the-size-of-the-image/347462)
- [pdflatex producing dvi output instead of pdf](https://tex.stackexchange.com/questions/53600/pdflatex-producing-dvi-output-instead-of-pdf)
