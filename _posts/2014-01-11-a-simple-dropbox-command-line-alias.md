---
layout: post
title: "A simple Dropbox command-line alias"
date: 2014-01-11 09:57
redirect_from: /blog/2014-01-11-a-simple-dropbox-command-line-alias.html
---

Dropbox has a useful but rather simplistic command-line interface, which I use
almost exclusively. The reason I call it simplistic is that when you start
Dropbox with `dropbox start`, all you see is

```bash
$ dropbox start
Starting...Done!
$ 
```

It starts Dropbox then brings you right back to the command-line prompt, at
which point you have no idea what Dropbox is doing in the background. For me
it's important to know when Dropbox is finished syncing because I prefer to
leave Dropbox off otherwise; that is, once the sync is done, I want to know
that and then stop Dropbox.

There is a command `dropbox status`, but all that does is check the status
(whether Dropbox is idle, uploading, downloading, indexing, etc.) at the
*particular* moment you call `dropbox status`, and that's it. I could of
course keep calling `dropbox status` until it starts to return `Idle` every
time

```bash
$ dropbox status
Connecting...
$ dropbox status
Initializing...
$ dropbox status
Starting...
$ dropbox status
Downloading file list...
$ dropbox status
Updating (4 files)
Indexing (4 files)
$ dropbox status
Idle
$ dropbox status
Idle
```

but there is an easier way to do this: the Linux command `watch`, which
"execute[s] a program periodically, showing output fullscreen." Suppose I want
to check Dropbox's status every one second. Then I just run

```bash
watch -n1 dropbox status
```

(The option `-n1` is short for `--interval 1` and always refers to seconds.)

To stop watching the program (to exit `watch`), just hit `Ctrl-C`.

When I run Dropbox, I basically just want to start it, watch what it does until
it returns `Idle` every time, and then stop Dropbox. Here is simple alias (to
put in `.bashrc` or `.zshrc` or whatever) that lets me do that:

```bash
alias db='dropbox start && watch -n1 dropbox status && dropbox stop'
```

With this alias, I just type `db` at the command line, watch what Dropbox does
until I keep seeing `Idle`, hit `Ctrl-C`, and then Dropbox stops automatically.
