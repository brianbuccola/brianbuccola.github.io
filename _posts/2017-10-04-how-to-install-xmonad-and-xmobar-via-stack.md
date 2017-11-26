---
layout: post
title: "How to install xmonad and xmobar via stack"
date: 2017-10-04 08:43
tags: xmonad xmobar haskell howto linux
---

Arch Linux recently changed their Haskell packages (no more static linking),
which broke a bunch of stuff. Specifically, upgrading `xmonad-0.13-8` →
`xmonad-0.13-9` produces errors when recompiling xmonad, and only downgrading
seems to fix the issue; and using `cabal-install` (`cabal install xmonad`) with
Arch's `ghc` likewise produces errors, failing to install xmonad. For those of
you coming from Google, the errors are of the format `Could not find module
...`. See [here](https://bbs.archlinux.org/viewtopic.php?pid=1739920) and
[here](https://www.reddit.com/r/xmonad/comments/73z1ew/could_not_find_module/),
for example.

In addition, Arch's xmobar (with `xmonad-0.13-8`) has been crashing sporadically
(segmentation faults), for some reason. See
[here](https://www.reddit.com/r/archlinux/comments/72hf42/xmonadcontrib013_dependency/),
for instance.

In this post, I'll explain how I got xmonad (and xmonad-contrib) and xmobar
installed and working -- and no xmobar crashes, so far -- via
[stack](https://www.haskellstack.org/). I'll try to keep it as short and simple
as possible. No in-depth explanations; just a straightforward, step-by-step
rundown of what I did. The usual disclaimers (YMMV, etc.) apply.

I'll assume you already have an `~/.xmonad` directory with an `xmonad.hs` config
file. If you don't use xmobar, this post can still be useful; just ignore the
lines/steps that refer to xmobar.

## Step 1: Get stack

There are couple ways to get stack. I installed
[stack-static](https://aur.archlinux.org/packages/stack-static/) from the AUR,
because it doesn't come with any Haskell dependencies.

```bash
pacaur -S stack-static
```

If you don't care about tracking stack with your package manager, then, as the
[stack
how-to-install](https://docs.haskellstack.org/en/stable/README/#how-to-install)
explains, just run

```bash
curl -sSL https://get.haskellstack.org/ | sh
```

or

```bash
wget -qO- https://get.haskellstack.org/ | sh
```

## Step 2: Install GHC with stack

To build and install Haskell packages, we need GHC. Simply run

```bash
stack setup
```

to install GHC into `~/.stack`. Useful for the kind of sandboxing projects that
we're doing with xmonad.

**NB:** You can run `stack ghc` to do things with GHC, `stack ghci` to fire up
interactive GHC, and so on.

## Step 3: Get xmonad, xmonad-contrib, and xmobar

We'll be turning our `~/.xmonad` directory into a stack project, so first, head
over there.

```bash
cd ~/.xmonad
```

For the remainder of this post, I'll assume you're inside `~/.xmonad`.

Next, download the xmonad, xmonad-contrib, and xmobar Git repositories, which
contain the `.cabal` and `.yaml` files that stack will look for in the next
step. I like to add `-git` to their directory names, just as a reminder.

```bash
# From inside ~/.xmonad.
git clone "https://github.com/xmonad/xmonad" xmonad-git
git clone "https://github.com/xmonad/xmonad-contrib" xmonad-contrib-git
git clone "https://github.com/jaor/xmobar" xmobar-git
```

Your `~/.xmonad` directory should now contain `xmonad-git`,
`xmonad-contrib-git`, and `xmobar-git`, each of which contains a `.cabal` file
and a `.yaml` file.

## Step 4: Initialize stack

This step is easy: just run

```bash
# From inside ~/.xmonad.
stack init
```

Stack will find the `.cabal` and `.yaml` files and auto-create the file
`stack.yaml` for you. It'll look like this:

```yaml
# ~/.xmonad/stack.yaml
resolver: lts-9.6
packages:
- xmobar-git
- xmonad-git
- xmonad-contrib-git
extra-deps: []
flags: {}
extra-package-dbs: []
```

At this point, you can modify `stack.yaml` to add flags, etc. The only change I
made was to add the flag `all_extensions` to xmobar, by changing

```yaml
flags: {}
```

to

```yaml
flags:
  xmobar:
    all_extensions: true
```

This flag provides all the xmobar bells & whistles, like support for xft, mpd,
battery, wifi, etc.

**NB:** If you add the `with_iwlib` flag (or `all_extensions`), you'll need to
also install the
[iwlib](http://www.hpl.hp.com/personal/Jean_Tourrilhes/Linux/Tools.html) C
library and headers. In Arch Linux, just install `wireless_tools`; in
Debian-based systems, `libiw-dev`.

## Step 5: Build and install everything

Next, run

```bash
# From inside ~/.xmonad.
stack install
```

to build and install xmonad, xmonad-contrib, and xmobar (and all their
dependencies). You'll now have two new binaries, `xmonad` and `xmobar`,
installed into `~/.local/bin`.

**NB:** You'll want to add `~/.local/bin` to your `PATH`, if it isn't already.

## Step 6: Write a build file

Since we're doing everything via stack, rather than ghc directly, `xmonad
--recompile` won't quite work yet. As of xmonad 0.13, we can write a custom
build script, named `build` and located inside `~/.xmonad`, which will use stack
ghc to recompile xmonad. (Borrowed from
[pbrisbin](https://github.com/pbrisbin/dotfiles/blob/master/xmonad/build).)

```bash
# ~/.xmonad/build
#!/bin/sh
exec stack ghc -- \
  --make xmonad.hs \
  -i \
  -ilib \
  -fforce-recomp \
  -main-is main \
  -v0 \
  -o "$1"
```

Make sure it's executable:

```bash
chmod a+x build
```

## Step 7: Recompile and restart xmonad

You should now be able to recompile and restart xmonad (and xmobar) with

```bash
xmonad --recompile && xmonad --restart
```

**NB:** I had to restart my computer in order for xmobar to start up properly --
probably because xmonad couldn't find the xmobar binary.

## Step 8: Updating

Whenever you update your xmonad, xmonad-contrib, or xmobar repositories, just
`cd ~/.xmonad` and run

```bash
stack install
```

to rebuild and reinstall everything.

**NB:** If you add a new flag or extra dependencies (in `stack.yaml`), you may
need to run `stack clean` first.
