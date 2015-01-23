<!-- begin metadata
title: Leaving vim-latex for rubber and ultisnips
date: 2013-02-09 21:08
categories:
- latex
- vim
- linux
end metadata -->

Several years ago when I started using [vim][], I needed a way to integrate
$\LaTeX{}$ and stumbled on the hugely popular [vim-latex][vl] plugin.  It comes
with a ton of bells and whistles, like automatic text replacement, shortcuts
for inserting environments, and macros for compiling `tex` code and for opening
the resulting `pdf` in your favorite viewer. Also, for users of graphical vim,
vim-latex adds a ton of new menus that list various environments, commands,
packages and their options, etc.

[vim]: http://www.vim.org/
[vl]:  http://vim-latex.sourceforge.net/

Over the years, however, I've realized that I don't actually use any of the
features other than the two macros above, plus a few basic text replacements
and environment shortcuts. In fact, some of the features can be quite annoying
and (as far as I've been able to learn) are not easily disabled.  For example,
if I want to write an expression in single quotes that starts with 'a', such as
'arm', the moment I type `` `a ``, the replacement mechanim kicks in and
replaces it with `\alpha`. And similar for a bunch of other character
combinations.

So the other day, I finally decided to get rid of vim-latex all together and
write my own macros for compiling and viewing. Initially, I was just going to
use `pdflatex`, but then I remembered about the awesome [rubber][], a program
for handling "all tasks related to the compilation of LaTeX documents". That
especially means compiling multiple times to fix labels as well as doing the
whole

```
$ pdflatex
$ bibtex
$ pdflatex
$ pdflatex
```

runaround. As expected, `rubber` also comes with a slew of options and can
compile to any of the usual formats.

[rubber]: https://launchpad.net/rubber/

Here are the two macros I wrote:

```vim
" LaTeX (rubber) macro
nnoremap <leader>t :w<CR>:!rubber --pdf --warn all %<CR>

" View PDF macro; '%:r' is current file's root (base) name.
nnoremap <leader>v :!mupdf %:r.pdf &<CR><CR>
```

The first macro saves the current file and then runs `rubber --pdf --warn all`
on it, which compiles to `pdf` using `pdflatex` and shows all warnings and
errors.

The second macro opens the current `tex` file's `pdf` file in mupdf. The
sequence `%:r` returns the root of the current filename, i.e., with the last
extension removed (same as GNU/Linux `basename`).

And there are other ways of creating sweet vim/latex harmony without vim-latex.
For example, for text replacement, I've started experimenting with
[ultisnips][us] (influenced by, but by now better than, [snipmate][sm]). It
ships with a few handy LaTeX snippets, and it's super easy to write new ones
(or snippets for any filetype).

[us]: https://github.com/SirVer/ultisnips
[sm]: https://github.com/msanders/snipmate.vim

I've also started using [surround][], which vastly simplifies the inserting,
changing, and deleting of "surroundings", e.g., `)`, `}`, `"`, etc.

[surround]: https://github.com/tpope/vim-surround

Hopefully in the near future I'll write up a more detailed post about my new
vim + latex (sans vim-latex) workflow.
