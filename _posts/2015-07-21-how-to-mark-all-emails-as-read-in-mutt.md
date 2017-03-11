---
layout: post
title: "How to mark all emails as read in Mutt"
date: 2015-07-21 17:52
redirect_from: /blog/2015-07-21-how-to-mark-all-emails-as-read-in-mutt.html
---

Here's a simple macro to mark all new emails (messages) as read in Mutt. If you
want to use it, just add it to your Mutt configuration file (e.g. `~/.muttrc`).

```bash
macro index A \
    "<tag-pattern>~N<enter><tag-prefix><clear-flag>N<untag-pattern>.<enter>" \
    "mark all new as read"
```

(You could remove the two backslashes and have the macro on a single line, but I
split it up for legibility's sake.)

Let's parse this bit by bit.

- `macro` tells Mutt we're defining a new macro.
- `index` tells Mutt that the macro is defined only on the index, i.e. the
  screen that lists all your messages.
- `A` is the key that the macro is bound to.
- The next part is the actual macro.
- `"mark all new as read"` is the description you'll see on the help page for
  the index.

Let's now parse the actual macro command. Essentially, we just tag all new
messages, then the clear the "new" flag from those tagged messages, then untag
everything.

- `<tag-pattern>` is starts a tag pattern; it's the same as the default
  keybinding `l` in a Mutt session.
- `~N<enter>` matches all messages marked as "new", so that we tag all new messages.
- `<tag-prefix>` means apply the next function to all tagged messages; it's the
  same as the default keybinding `;` in a Mutt session.
- `<clear-flag>` is the function we want to apply to all tagged messages; it's
  the same as the default keybinding `W` in a mutt session. (`w` sets a flag;
  `W` clears one.)
- `N` is the "new" flag that we want to clear from all tagged (i.e. new)
  messages.
- `<untag-pattern>` starts an untag pattern.
- `.` matches everything, so that we untag everything.

I got tired of pressing `NNNNN...` to mark successive new messages as read, and
I find this macro to be extremely useful. I hope others do too.
