---
layout: post
title: "Line breaks in mutt and vim"
date: 2016-07-07
---

## The problem

I've been using [mutt](http://www.mutt.org/) as my primary email client, and
[vim](http://www.vim.org/) as my text editor for composing emails, for
literally *years*, and I only just recently discovered that my email text comes
out very funny looking on the recipient's end when they view the email on a
small screen, like a smartphone screen.

By "funny looking", what I mean is this. When I compose email text in vim, I
hard-break lines at 80 characters, because imho it's much easier to read 12
lines of 80 characters each than, say, 6 lines of 160 characters each. However
(and this should've been painfully obvious to me long ago), if someone is
viewing such text on a screen that can display fewer than 80 characters per
line, then the screen wraps (soft-breaks) the line *before* the 80th character,
while the email text itself *still* hard-breaks at the 80th character, so that
you end up with (what looks like) *two* line breaks. In other words, you get
the following, where "X" marks the spot where the smartphone display wraps the
line, and "Y" marks where the email text hard-breaks the line (e.g. the 80th
character):

    text text text text text text text text text text text text X
    text text Y
    text text text text text text text text text text text text X
    text text Y
    text text text text text text text text text text text text X
    text text Y
    text text text text text text text text text text text text X
    text text Y

which obviously looks much uglier than

    text text text text text text text text text text text text text text Y
    text text text text text text text text text text text text text text Y
    text text text text text text text text text text text text text text Y
    text text text text text text text text text text text text text text Y

A similar issue arises with quoted text in a reply email (which I also noticed
long ago, but never really bothered to try and fix): quoted text is typically
preceded by a ">", but doing that can cause an unwanted line break, so that you
end up with the following, where "X" marks the new line break that occurs at,
say, the 80th character, and "Y" marks the old line break that had occurred at
the 80th character before ">" was added:

    > text text text text text text text text text text text text X
    text text Y
    > text text text text text text text text text text text text X
    text text Y
    > text text text text text text text text text text text text X
    text text Y
    > text text text text text text text text text text text text X
    text text Y

Again, this is much worse than

    > text text text text text text text text text text text text text text Y
    > text text text text text text text text text text text text text text Y
    > text text text text text text text text text text text text text text Y
    > text text text text text text text text text text text text text text Y

## The solution

### Flowed text in mutt

The solution to both problems is to use an email option called *flowed text*,
or *flowed format*. In mutt, you just add the line

    set text_flowed

to your `muttrc`. (Apparently all (or most) email clients support/respect this
feature.)

Flowed text essentially means this: a hard line break in the email text will
*not* be interpreted and rendered (by the email client) as an actual line break
*if* the line ends in white space; a hard line break *will* be interpreted and
rendered as an actual line break *if* the line ends in a non-white-space
character. (You can read more about flowed text
[here](http://joeclark.org/ffaq.html).)

For example, the following text, where `-` stands for a single white space
character (not a hyphen)

    text text text text-
    text text-
    text text text text text text text-

will pretty much be treated as if it had been written all on a single line: the
email client will simply wrap the line wherever it sees fit (or maybe not at
all, if it fits all on the screen), but not elsewhere. By contrast,

    text text text text
    text text
    text text text text text text text

will be treated as three distinct lines (useful for haikus, maybe, or lists).

So basically, you can write your email text, breaking at 80 characters just
like before, *as long as* each line ends in a space. (And if you actually want
a real line break, as in a haiku or list, just don't add the trailing space.)

### Flowed text in vim

Now, you might be thinking, *That's annoying. I don't want to manually add a
space after every line break*. Thankfully, vim makes this extremely easy. Just
add the `w` option to your `formatoptions`:

```vim
set formatoptions+=w
```

Now, as you're typing, when you hit 80 characters (or whatever your `textwidth`
is set to), vim will hard-break the line *and* add the trailing white space for
you. Easy.

You probably only want this to happen when you write emails. To ensure this,
you can set the `w` option only for files with the `mail` filetype, using an
`autocmd`:


```vim
" Add format option 'w' to add trailing white space, indicating that paragraph
" continues on next line. This is to be used with mutt's 'text_flowed' option.
augroup mail_trailing_whitespace " {
    autocmd!
    autocmd FileType mail setlocal formatoptions+=w
augroup END " }
```

See `:help fo-table` for more info.
