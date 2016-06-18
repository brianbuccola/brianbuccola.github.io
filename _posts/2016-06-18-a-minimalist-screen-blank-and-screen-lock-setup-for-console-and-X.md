---
layout: post
title: A minimalist screen blank and screen lock setup for console and X
date: 2016-06-18
---

For many years, I used [XScreenSaver][xscreensaver] as my trusty screen saver
and screen locker for the X window system. Although I really enjoyed the many
different screen savers that it came with (I'll never forget my students'
reaction when one day in class my slides turned into a cow jumping on a
trampoline), I recently decided that I wanted something a bit more minimal (and
less embarrassment-prone). Here's what I wanted:

- When in console (i.e. not in X), the screen should go blank (i.e. turn off,
not just turn black) after **1 minute** of activity.

- When in X, the screen should go blank *and lock* after **10 minutes** of
inactivity.

The reason for switching from a screen saver to a blank screen in X is mainly
to conserve battery life.

The reason for not requiring a screen lock in console is simply because I
personally almost never spend time in console (I always start X right away), so
it's really not an issue. I simply want it to go blank in case, for example, I
boot up my computer, walk away to make a coffee, etc., and forget about it for
a while. In that case, I haven't logged in yet, so my console screen is already
password-protected.

For the impatient: just jump to the [recap](#recap) to see my setup.

## Console setup ##

To make the screen go blank in console after, say, 60 seconds, you just need to
pass the option `consoleblank=60` to the kernel, e.g. by adding this option as
a kernel parameter in your boot loader configuration file. I use
[Syslinux][syslinux] as my boot loader, so for me, I simply edit the file

    /boot/syslinux/syslinux.cfg

so that the line

    APPEND root=/dev/sda1 rw

becomes

    APPEND root=/dev/sda1 rw consoleblank=60

If you use GRUB, you would do the same thing but edit the GRUB configuration
file. See [here][kernel parameters] for more info about passing options to the
kernel.

## X setup ##

Recall that in X we want to do two things after 10 minutes of activity: blank
the screen *and* lock the screen. These are two separate things.

### Blanking the screen ###

To blank the screen, we use the `xset` command. First, let me mention that
running `xset q` lists all the current settings---try that now and look at the
output before reading further. The important sections are "Screen Saver" and
"DPMS".

Now then, the `s` option lets you set screen saver parameters. For example,

    xset s 600

activates the "screen saver" after 600 seconds (10 minutes). For me, activating
the "screen saver" is equivalent to blanking the screen---you can test this by
running `xset s 1` and waiting 1 second--- so this single command does the job
we want. (NB: 600 seconds is also the default, so `xset s` would also work; it
also resets any previous screen saver setting, such as `xset s 1` above.)

You can also use DPMS (Energy Star) features with the `dpms` option. There are
several DPMS states:

- standby
- suspend
- off
- on

For me, standby, suspend, and off are all equivalent to blanking the screen,
but I guess on some computers they will do different things. You can test them
yourself by running, for example,

    xset dpms force standby

To force standby, suspend, and off modes after 300s, 400s, and 500s,
respectively, run

    xset dpms 300 400 500

Once you figure out the command that you want, just add it to your X startup
file, `~/.xinitrc`, to run the command whenever you start X.

See [here][dpms] for more info, as well as, of course, `man xset`.

### Locking the screen ###

To lock the screen, first we need a screen locking program. I've tried several
[screen lockers][], and my favorite is [slock][], for one main reason: it's
super minimal. There is no login prompt or anything. The screen simply turns
black when it locks. When you start typing your password, the screen turns
blue. If you press `<Enter>` and the password was incorrect, it turns red.
Start typing again, and it turns blue again. In other words, you only see three
possible things: a black screen, a blue screen, or a red screen. I like that.
It would thoroughly confuse anyone trying to mess with your computer.

Use your package manager to download slock, and then try it out by running
`slock` in the terminal. Try out other [screen lockers][], too, if you like.
(Note that one advantage of some other lockers, such as sflock and physlock, is
that they block access to other TTYs, but I don't care too much about this
functionality since I never have other sessions open on other TTYs.)

Once you're satisfied that slock works and you like it (or once you pick a
different locker), you can use the `xautolock` command to run `slock` every 10
minutes by adding this command to your `~/.xnitrc`.

    xautolock -time 10 -locker slock &

(If you decided on a different locker, just replace `slock` with your locker's
name, e.g. `physlock`.)

Note the `&` at the end, which runs the command in the background. If you omit
this, then the other commands in your `~/.xinitrc` (such as the one that starts
your window manager) won't get executed, which is a problem.

That's it!

## Recap ##

To recap, we did three things:

- Added the kernel parameter `consoleblank=60` to blank the screen in console
after 1 minute.

- Added the command `xset s` (or similar) to `~/.xinitrc` to blank the screen
in X after 10 minutes.

- Added the command `xautolock -time 10 -locker slock &` (or similar) to
`~/.xinitrc` to lock the screen in X after 10 minutes.

Note that, without the `xautolock` command, the screen would simply go blank,
with no lock protection. Conversely, without the `xset s` command, the screen
would lock but not go blank (i.e, off); it would go black but still be on. By
blanking and locking, we save battery life and increase security.

[kernel parameters]: https://wiki.archlinux.org/index.php/Kernel_parameters
[xscreensaver]: https://www.jwz.org/xscreensaver/
[syslinux]: https://wiki.archlinux.org/index.php/syslinux
[screen lockers]: https://wiki.archlinux.org/index.php/List_of_applications#Screen_lockers
[slock]: http://tools.suckless.org/slock/
[dpms]: https://wiki.archlinux.org/index.php/Display_Power_Management_Signaling
