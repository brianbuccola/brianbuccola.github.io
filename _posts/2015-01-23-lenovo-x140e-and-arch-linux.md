---
layout: post
title: "Lenovo X140e and (Arch) Linux"
date: 2015-01-23 15:43
redirect_from: /blog/2015-01-23-lenovo-x140e-and-arch-linux.html
---

My previous laptop was an Asus that ran Linux beautifully, until, after a few
years, several pieces of hardware stopped working (first battery, then wifi,
then monitor). I had heard great things about Lenovo, specifically how nicely
they play with Linux, so last summer I bought myself a Lenovo X140e. On the
whole, I'm quite happy with it, but to my surprise (and sadness), it didn't
work out of the box like my Asus did. In this post I'll detail some of the
issues I had and my workarounds for dealing with them.

The main issues that I've managed to solve are:

- [wifi](#wifi) (Arch-specific solution)
- [brightness keys](#brightness-keys)
- [no insert key](#no-insert-key)

There's one issue that I *haven't* manage to solve:

- jittery touchpad, but only while on AC power

Basically, there's no issue while on battery power; but on AC power, touching
the touchpad, even without moving your finger around, causes the cursor to jut
around back and forth really fast. This (annoying) problem has been confirmed
elsewhere, but I haven't found a solution to it.

If you have a solution, please email me!

## WiFi

By far the most serious (but luckily, easiest to solve) issue is the Broadcom
wifi card BCM43228:

```bash
$ lspci -vnn | grep Broadcom
01:00.0 Network controller [0280]: Broadcom Corporation BCM43228 802.11a/b/g/n [14e4:4359]
```

This card was [not supported][b43] under the Linux kernel until kernel version
3.17. (We're now on 3.18, as of this writing; when I bought the laptop, we were
at 3.16.) The workaround for kernels below 3.17 is to use the AUR package
[broadcom-wl][bc]. However, even once we arrived at 3.17, I found the native
support (with the b43 driver and firmware) to be lacking: weak wifi connections,
constant dropping, etc. So I still use broadcom-wl. Here's how it works.

First, download broadcom-wl with your favorite AUR helper, and install it. For
example:

```bash
$ cower -d broadcom-wl
$ cd ~/aur/broadcom-wl
$ makepkg -csi
```

Second, restart computer.

That's all! Well, almost. Now, every time you update your kernel, you need to
rebuild and reinstall broadcom-wl. For example:

```bash
$ cd ~/aur/broadcom-wl
$ makepkg -csif
```

The `-f` flag forces a rebuild and overwrites the current `.pkg.tar.xz` file.

(Another option is to use broadcom-wl-dkms, which automatically rebuilds itself
after a kernel update.)

(This solution is obviously specific to Arch Linux, but most major distros
should have some analog of the broadcom-wl package available, which should
likewise solve the issue.)

## Brightness keys

You're supposed to be able to change the brightness with `<Fn-F8>` and
`<Fn-F9>` (that is, the function key together with `F8` or `F9`). For me, this
works fine in console, but *not* in X11, where most people (including me) spend
most of their time. I've read that a BIOS upgrade fixes this, but I haven't
tried that.

My workaround was to write a simple bash script, [brt.sh][brt]. The idea:

- `brt.sh` (no argument): output current brightness level (0--255).
- `brt.sh [n]`: set brightness level to *n* (0--255).
- `brt.sh down`: decrease brightness level by 20 (bind this to `<Fn-F8>`).
- `brt.sh up`: increase brightness level by 20 (bind this to `<Fn-F9>`).

I'll illustrate how the main part of it works, the `brt_change()` function (the
rest of the script should be pretty self-explanatory):

```bash
#!/bin/bash

brightness_file="/sys/class/backlight/radeon_bl0/brightness"
max_brightness=255
min_brightness=5
current_brightness=$(cat "$brightness_file")
up_amt=20
down_amt=20

brt_change() {
  echo "$1" | sudo tee "$brightness_file"
}

brt_up() {
  local new_brightness=$(($current_brightness + $up_amt))
  if [[ $new_brightness -le $max_brightness ]]; then
    brt_change "$new_brightness"
  else
    brt_change "$max_brightness"
  fi
}

brt_down() {
  local new_brightness=$(($current_brightness - $up_amt))
  if [[ $new_brightness -ge $min_brightness ]]; then
    brt_change "$new_brightness"
  else
    brt_change "$min_brightness"
  fi
}

if [[ $# -eq 1 ]]; then
  case "$1" in
    [0-9]*) brt_change "$1" && exit 0;;
        up) brt_up && exit 0;;
      down) brt_down && exit 0;;
         *) echo "Error: invalid argument. Pick a brightness level ($min_brightness-$max_brightness), or say 'up' or 'down'." && exit 1;;
  esac
elif [[ $# -eq 0 ]]; then
  echo "$current_brightness"
  exit 0
else
  echo "Error: too many arguments."
  exit 1
fi
```

The file `/sys/class/backlight/radeon_bl0/brightness` contains the current
brightness level, which for my Lenovo X140e is between 0 and 255. To change the
brightness, you just change this file. The problem is that since it's located in
`/sys/...`, you need root permission to change it. That means that

```bash
echo "100" > /sys/...
```

won't work, but neither will

```bash
sudo echo "100" > /sys/...
```

The reason is because in the latter, `sudo` is only operating on the `echo`
command. It's like saying, run `echo` as root, and now (not as root) append the
output to `/sys/...`. To solve this, we use `tee`, which allows piping from
stdin to a file, as root:

```bash
echo "100" | sudo tee /sys/...
```

This command will successfully set the brightness level to 100, and that's the
crux of the script.

There's one remaining issue, though: we don't want to run this script in a
terminal; we want to bind it to a key. But the script uses `sudo`, which
requires a password to be typed, which you can't really do outside of a
terminal. The solution is to allow `tee` to be run as root without a password.
To do this, you need to change the sudoers file by running `visudo` (as root)
and adding this line:

```bash
# Add `tee' to list of commands that user `brian' can run without password
brian ALL = NOPASSWD: /usr/bin/tee
```

What this does is allow the user "brian" (that's me) to run `tee` as root (`sudo
tee`) without a password.[^sudo-tee] `/usr/bin/tee` is of course the full path
to `tee`. To find that out on your system, run `which tee` in a terminal.

[^sudo-tee]: NB: This is a (potential) security risk, as it allows "brian", or
    anyone logged in as "brian", to overwrite *any* file! (Example: `echo "all
    gone" | sudo tee /path/to/important/file`.) Only do this if you're the only
    one with access to this user profile.

Now the script can be run effectively. Just bind `brt.sh down` and `brt.sh up`
to `<Fn-F8>` and `<Fn-F9>` (or whatever you want) in whatever way is required by
your desktop environment or window manager. (For me, I bind keys in `xmonad.hs`
since I use xmonad.)

## No insert key

The laptop keyboard does not come with any physical `Insert` key. I guess
that's because most people nowadays don't use it very often. But I do. One of
the best features of Linux (well, X11) is the X clipboard: whenever you
highlight something, it gets added to the X clipboard (no need to `<Ctrl-C>`),
and you can paste it with `<Shift-Insert>`. (I also use `Insert` to go into
ignore-mode in [Vimperator][vp] for Firefox.)

What I did was bind the Windows key (which was serving no purpose) to `Insert`.
Here's how:

```bash
xmodmap -e "keycode 133 = Insert"    # map windows button to insert
```

You can find the keycode of a key by running `xev` (X event program) from a
terminal, typing the key, and looking for "keycode" in the output. (Hit
`<Ctrl-C>` to exit `xev`.)

Now you can run this `xmodmap` command in a terminal, and it should work. But
the best solution is to include it in your `.xinitrc` file so that it's run
every time X starts. (I have a whole `keyboard-adjust` script that adds the
Dvorak layout, switches caps and control lock, etc., maps the Windows button to
insert, etc.; I then call the whole script from my `.xinitrc` file.)

[b43]:     http://wireless.kernel.org/en/users/Drivers/b43
[bc]:      https://aur.archlinux.org/packages/broadcom-wl/
[brt]:     https://github.com/brianbuccola/scripts/blob/master/brt.sh
[vp]:      http://www.vimperator.org/vimperator/
