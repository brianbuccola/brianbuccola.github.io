---
title: "How to build and install st (suckless simple terminal) from source on Arch Linux"
date: 2017-03-19 17:24
tags: [arch linux, howto, command line, suckless, linux]
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

### Step 1: Follow the installation instructions

The first step (after untarring the tarball and `cd`-ing into the `st-x.x`
directory) is to install st exactly as the `README` says:

```markdown
Installation
------------
Edit config.mk to match your local setup (st is installed into
the /usr/local namespace by default).

Afterwards enter the following command to build and install st (if
necessary as root):

    make clean install
```

Literally all I did was run `sudo make clean install`, and it worked. I could
run `st` no problem.

### Step 2: Configure `config.h` and apply some patches

Next, try and customize st a bit by editing `config.h` to your liking and
applying some patches. Take note of exactly what you do. In my case, I applied
the patches [scrollback][], [hidecursor][], and [copyurl][], by running `patch
-Np1 -i <patch>` for each patch. Once you're satisfied, it's time to create a
PKGBUILD.

## Creating a PKGBUILD

First off, read the Arch Wiki entries on [PKGBUILD][] and [Creating packages][].
You can either create one from scratch (while following the Arch Wiki), modify
the skeleton PKGBUILD `/usr/share/pacman/PKGBUILD.proto`, or modify an actual
existing PKGBUILD. I decided to opt for the latter, and the existing PKGBUILD I
chose to modify was the obvious one: `st` itself from `community`.

There are a number of ways to acquire an official PKGBUILD. Traditionally, you'd
go the [ABS][] route: install `abs`, clone the entire ABS tree (or at least the
subtree of the repo containing `st`, i.e. `community`) onto `/var/abs`, then
copy `/var/abs/community/st` over to something like `~/abs`.

However, nowadays there are tools like [asp][] and [pbget][] that let you
acquire the contents (PKGBUILD, etc.) of a single package without cloning an
entire repo tree. So that's what I did:

```bash
$ mkdir -p ~/.cache/asp
$ mkdir -p ~/builds
$ cd ~/builds
$ asp export st
$ cd st
$ ls
config.h PKGBUILD
```

Here I've used `asp` to export the `st` package, which comes with `config.h`
(the configuration file) and `PKGBUILD`, the PKGBUILD. Now I just need to edit
`config.h` in the same way I did in step 2 (easy part), and modify the PKGBUILD
to apply the three patches I want (slightly harder part).

There are four main changes I made to the PKGBUILD. First, I added an array
`_patches` with links to the three patches I want to apply:

```bash
_patches=("http://st.suckless.org/patches/st-scrollback-20170104-c63a87c.diff"
          "http://st.suckless.org/patches/st-hidecursor-20160727-308bfbf.diff"
          "http://st.suckless.org/patches/st-copyurl-20161105-8c99915.diff")
```

Second, I added the patches to the `source` array by adding `"${_patches[@]}"`
to it...

```bash
source=("http://dl.suckless.org/st/$pkgname-$pkgver.tar.gz"
        "config.h"
        "${_patches[@]}")
```

...and of course added the patches' corresponding hashes to the `md5sums` array.
(**Protip**: Run `updpkgsums` to automatically do this.)

Third, it turned out that any patches which tried to patch `config.def.h` would
lead to an error. This is because those patches --- specifically, the scrollback
and copyurl patches --- define new functions (for scrolling back and for copying
a URL) by modifying `st.c` and then bind keys to those functions by modifying
`config.def.h`, but `config.def.h` is first overwritten by the custom `config.h`
during the build stage, which later leads to a patch error. Therefore, I decided
to (i) manually modify `config.h` to bind the relevant functions to some keys
(easy), and then (ii) remove from those two patches the lines responsible for
patching `config.def.h`, which happen to be the first 13 lines in the scrollback
patch, and the first 12 lines in the copyurl patch:

```bash
# patch patches (don't let them patch config.def.h)
sed -i '1,13d' "$srcdir/$(basename ${_patches[0]})"
sed -i '1,12d' "$srcdir/$(basename ${_patches[2]})"
```

Fourth, and finally, inside of the `prepare()` function, I looped over each
patch and applied them in the same way as I did in step 2 above:

```bash
for patch in "${_patches[@]}"; do
  echo "Applying patch $(basename $patch)..."
  patch -Np1 -i "$srcdir/$(basename $patch)"
done
```

See [Patching in ABS][] for further details.

## Putting it all together

That's basically it. Now just run `makepkg -si` and make sure everything applies
and installs correctly. Once it does, you should also run `namcap` on `PKGBUILD`
and on the resulting `*.pkg.tar.xz` file to make sure there's nothing wrong. In
my case, `namcap` told me that the package didn't actually depend on `libxext`
or `xorg-fonts-misc`, even though the official PKGBUILD included those in the
`depends` array, so I just removed them.

Before concluding, I want to mention two bonus tips.

**Tip #1**: To avoid `config.h` from being overwritten by some future `asp
export` (supposedly, this can't happen, but just to be safe), and to keep my
config located among all my other configuration files, I moved `config.h` into
`~/.config/st` and then created a symlink to it from inside the build directory:

```bash
$ mkdir -p ~/.config/st
$ mv ~/builds/st/config.h ~/.config/st
$ ln -s ~/.config/st/config.h ~/builds/st
```

The directory `~/.config/st` is not actually recognized by st in any way, but
`~/.config` is where most other apps put their configuration files, so it makes
things tidier, especially since I version-control most things inside `~/.config`
with git.

**Tip #2**: What if you want to modify the patches themselves, i.e. patch a
patch (apart from removing the error-prone lines mentioned above)? In my case, I
wanted to modify the copyurl patch. By default, this patch patches `st.c` so
that it allows you to copy any URL starting with `http://` or `https://`, but I
wanted to also be able to copy anything starting with `ftp://`, `mailto:`, or
simply `www.`. So, here's what I did.

First, I edited `st.c` by hand (*after* the copyurl patch had applied to it) in
the way that I wanted, then manually reinstalled st to make sure it worked as
expected. It did. I could've stopped here, but this isn't really the elegant way
to do things.

Next, I created a directory `~/builds/st/mypatches`, and within that, two
subdirectories, `a` and `b`. Inside `a`, I placed the post-copyurl-patched
`st.c` file, and inside `b`, I placed my revised post-copyurl-patched `st.c`
file, and then ran...

```bash
diff -u a/st.c b/st.c > ../st-copyurl-bb.diff
```

...to create a patch `st-copyurl-bb.diff` in the base package directory
(alongside the other three patches).

Then I added this patch to the end of the `_patches` array, updated the hashes
with `updpkgsums`, and re-ran `makepkg -si`, and everything worked out great.

So far, I'm extremely happy with st. It's especially great to have a full range
of colors in vim with minimal hassle, by adding these lines to my `vimrc`:

```vim
set termguicolors " Enable true color support.
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
```

[AUR]: https://wiki.archlinux.org/index.php/Arch_User_Repository
[patches]: http://st.suckless.org/patches/
[st]: http://st.suckless.org/
[suckless]: http://suckless.org/
[copyurl]: http://st.suckless.org/patches/copyurl
[hidecursor]: http://st.suckless.org/patches/hidecursor
[scrollback]: http://st.suckless.org/patches/scrollback
[PKGBUILD]: https://wiki.archlinux.org/index.php/PKGBUILD
[Creating packages]: https://wiki.archlinux.org/index.php/Creating_packages
[ABS]: https://wiki.archlinux.org/index.php/Arch_Build_System
[asp]: https://github.com/falconindy/asp
[pbget]: http://xyne.archlinux.ca/projects/pbget/
[Patching in ABS]: https://wiki.archlinux.org/index.php/Patching_in_ABS
