---
layout: post
title: "How to build and install st (suckless simple terminal) from source on Arch Linux"
date: 2017-03-19 17:24
tags: ["arch linux", "command line", suckless, linux]
---

## Background

[*st*][st] (*simple terminal*), from the folks at [suckless][], is an extremely
lightweight terminal emulator that also supports true color. It's configured by
editing a C header file, `config.h`, and then recompiling everything into a
binary. For this reason, it doesn't make sense to install st from the official
repos (you'd just end up with a very basic, uncustomizable binary), nor does it
really make sense to install it from the [AUR][], because you'll inevitably want
to modify the PKGBUILD to apply [patches][] and do other things. Instead, your
best bet is to create your own personal PKGBUILD (or modify an existing, similar
one), which will apply the patches you want, copy over your custom `config.h`,
and build st, which you can then make into a package with `makepkg` and install
with `pacman` as usual.

## Building and installing manually from source

The first step is to decide whether you want to use the stable release
(currently [st-0.7.tar.gz](http://dl.suckless.org/st/st-0.7.tar.gz)) or the
development version (<http://git.suckless.org/st>). I originally went with the
development version, but I was unable to apply patches (because the patches were
created for the stable release, and I couldn't find any more up-to-date versions
of the patches). Therefore, in the end, I decided to go with the stable release,
which also has the advantage that my terminal, which I rely heavily on, won't
break any time soon.

### Step 1: follow the installation instructions

The first step (after untarring the tarball and `cd`-ing into the `st-x.x`
directory) is to install st exactly as the `README` says:

    Installation
    ------------
    Edit config.mk to match your local setup (st is installed into
    the /usr/local namespace by default).

    Afterwards enter the following command to build and install st (if
    necessary as root):

        make clean install

Literally all I did was run `sudo make clean install`, and it worked. I could
run `st` no problem.

### Step 2: Configure `config.h` and apply some patches

Next, try and customize st a bit by editing `config.h` to your liking and
applying some patches.

## The ABS and PKGBUILDs

## Putting it all together

[AUR]: https://wiki.archlinux.org/index.php/Arch_User_Repository
[patches]: http://st.suckless.org/patches/
[st]: http://st.suckless.org/
[suckless]: http://suckless.org/
