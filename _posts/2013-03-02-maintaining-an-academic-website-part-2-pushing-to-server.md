---
layout: post
title: "Maintaining an academic website, part 2: pushing to server"
date: 2013-03-02 11:08
redirect_from: /blog/2013-03-02-maintaining-an-academic-website-part-2-pushing-to-server.html
---

This is the second in a series of posts on how I currently maintain my academic
website ([here][my-site]). In the [first post][part-1], I explained how I write
and edit my site using the simple and intuitive syntax of [markdown][], rather
than pure HTML, and convert from markdown to HTML using [pandoc][]. I also
explained how I modularize my website into (i) main content, the stuff written
in markdown, which evolves over time, and (ii) metacontent, which is kept in
separate header, footer, etc. files, which is more static; and I showed how
pandoc can combine all such content into one standalone HTML page. I gave a
pretty basic script for automating all that each time any part of the site is
edited.

[my-site]:  https://github.com/brianbuccola/mcgill-website
[part-1]:   /maintaining-an-academic-website-part-1-editing-the-site/
[markdown]: http://daringfireball.net/projects/markdown/
[pandoc]:   http://johnmacfarlane.net/pandoc/

In this post I'll explain how to automate another important aspect of site
maintenance: pushing the website from your local PC to the remote server
hosting the website, e.g., a university server (McGill's, in my case). For this
task, we'll be using [ssh][] and [rsync][].

[ssh]:   http://www.openssh.org/
[rsync]: http://rsync.samba.org/

<!-- more -->

Pushing to server
-----------------

Alright, so you've got a website all set up, and the directory structure looks
something like this.

```
after-body.html
before-body.html
favicon.png
files
    \--- handout-stuff.pdf
    \--- handout-junk.pdf
header.html
images
    \--- pic-of-me.jpg
index.html
index.markdown
md2html.sh
mystyle.css
```

(Most of these files are optional; all you really need is `index.markdown`,
`index.html`, and `md2htmlsh`. But for completeness, I'll assume we're dealing
with a CSS stylesheet, some images, downloadable files, etc.)

Essentially, we want to transfer the all necessary website components from a
local PC location to a remote server. The way we do this is with ssh (actually,
the suite of utilities provided by OpenSSH, including `ssh` and `scp` (secure
copy).)

### SSH

You know, instead of talking about "you" or "me", it'll be easier to talk about
a hypothetical third person. Meet Bob. Bob's website is located on his PC in
the directory `/home/bob/website`. Bob attends ABC University, which has been
kind enough to give Bob some server space for his website. They also tell Bob
he can access his server space remotely using "secure shell access".

What this means is that, while Bob is sitting on his couch in his apartment on
his own PC, he can access/log onto his university server. How so? With [ssh][],
a secure access utility provided OpenSSH.

#### ssh--ing manually

Let's assume that Bob's university login name is `bob22`, because he's the 22nd
Bob, and so his login name is `bob22@abc.edu`. Then he can access the server
with the following simple command (recall that `$` is the command--line prompt;
don't type it):

```bash
$ ssh bob22@abc.edu
```

Pretty easy. After executing this command, Bob will be prompted for his
university password, which happens to be `iluvssh` (but don't tell anyone). He
enters the password and is greeted with something like:

```
Welcome to ABC University's server! Blah blah blah, GNU/Linux license
stuff, no warranty, yada yada.

bob22@abc:~$
```

Bob went from being inside his personal home directory to being on his home
directory on his uni server, hence why `$` is the prompt in both cases. Note,
however, that Bob's local home directory is `/home/bob`, whereis his remote uni
one is (probably) `/home/bob22`.

```bash
bob22@abc:~$ echo $HOME
/home/bob22
```

Bob looks around in his home directory, and he notices two folders:

```bash
bob22@abc:~$ ls
private public_html
```

Presumably, `private` is for stuff that no other students/users of that server
has access to; `public_html` is where Bob needs to put his website. But how
does he do that? Right now, he's "inside" his uni home, with no way look at his
PC home, except in another shell, but then in that shell he would have no way
to look at his uni home. That is, the two shells could not "communicate", as it
were.

#### scp

Enter `scp`, or secure copy. First Bob exits from his uni server with `exit`,
putting him back into his ordinary PC home. Now he can do this:

```bash
$ scp ~/website/index.html bob22@abc.edu:/home/bob22/public_html
```

This command (securely) copies the file `index.html` from the local home
directory, `/home/bob`, over to Bob's university home directory, `/home/bob22`,
and into the `public_html` directory.

But there's a snag: Bob has to enter his password again. How annoying. In fact,
each time Bob runs `ssh` or `scp`, he has to enter his password. If only there
were a way for Bob's uni server to recognize that it's *Bob* (or Bob's PC)
requesting access, so that Bob doesn't always have to type `iluvssh`.

#### ssh keys

Well, there is a way: ssh identity files (or keys). Basically, Bob generates a
pair of keys---one private, which he keeps on his PC, and one public, which he
sends over to the server. The server, since it has Bob's public key, can
recognize and grant access to anyone having Bob's private key. Obviously, Bob
should not share the private key (the public one doesn't matter).

The command for all this is:

```bash
$ ssh-keygen -f abc -t rsa -C 'ABC University'
```

Legend:

- `-f` specifies the outut **f**ilename.
- `-t` specifies the encryption **t**ype. I use RSA, but DSA is fine too.
- `-C` is an optional **c**omment; use it to describe what the key is for.

(You'll be asked to specify a passphrase, which is optional.)

After running this command, Bob has two files: `abc`, his personal identity
file, and `abc.pub`, the public one. He should first put `abc` into the
directory `~/.ssh`, where any other keys are located, too:

```bash
$ mkdir ~/.ssh # create this directory, if not already existing
$ mv abc ~/.ssh/
```

(Bob could also have simply run `ssh-keygen` from inside `~/.ssh` to begin
with.)

Now he needs to get `abc.pub` onto the remote server. That's easy:

```bash
$ scp ~/abc.pub bob22@abc.edu:/home/bob22
```

But that's not quite enough. The way OpenSSH works is that the public key has
to be concatenated to a file `authorized_keys`, located in the remote `~/.ssh`,
which contains all public keys needed by Bob's remote server. To do that, Bob
must ssh one more time onto the server, create `~/.ssh` if necessary, append
`abc.pub` to `authorized_keys`, change the permissions on `authorized_keys` so
that only Bob can read and write to it, and finally delete `abc.pub`.

```bash
$ ssh bob22@abc.edu
Welcome! ...
bob22@abc:~$ ls
abc.pub private public_html
bob22@abc:~$ mkdir ~/.ssh
bob22@abc:~$ cat ~/abc.pub >> ~/.ssh/authorized_keys
bob22@abc:~$ chmod 600 ~/.ssh/authorized_keys
bob22@abc:~$ rm abc.pub
bob22@abc:~$ exit
```

If all went well, Bob should now be able to ssh onto the server without
typing `iluvssh` every time. Cool!

#### ssh config file

But there's another snag: What if Bob's username were actually

```bash
reallylongfirstname.superlonglastname946537
```

and/or what if his university's domain name were actually

```bash
abcdefghijklmnopqrstuvwxyz@abc.de.fghi.jklm.no.pqrst.uvwx.yz.edu
```

It'd be pretty annoying to type all that out every time Bob wanted to `ssh`
onto the server or `scp` something over to it. Sure, Bob could create a shell
alias for it, but ssh offers an easy solution: an ssh config file. Bob can
simply create a file `~/.ssh/config` that looks like this:

```bash
Host abc
    User bob22
    HostName abc.edu
    IdentityFile ~/.ssh/abc
```

The keywords are pretty straightforward. The only one worth discussing is
`Host`: this is the name that this particular entry goes by, and it's that name
which, when used in a shell or script, is equivalent to `bob22@abc.edu`. In
other words, typing

```bash
$ ssh abc
```

is equivalent to typing

```bash
$ ssh bob22@abc.edu
```

Similarly, typing

```bash
$ scp blah.txt abc:/home/bob22
```

is equivalent to typing

```bash
$ scp blah.txt bob22@abc.edu:/home/bob22
```

You can see how a config file drastically simplifies things.

Now all Bob has to do is `scp` over all the necessary website files. He could
do this manually, or write a script. If he wrote a script, then any time he
edited or added a file locally, he could then run the script to update the
remote website directory. However, if I'm not mistaken, *all* files, even those
untouched, would be copied over every time. There may be a smart way to use
`scp` to handle this problem, but in any case, I prefer rsync for all major
copying/backing up of anything.

### Rsync

Rsync is a great tool for copying or backing up data. Here are some advantages
that it has over `scp`:

1. It's smart enough to skip transferring files that are "the same", in some
sense, on the local and remote machines: e.g., if they have the same name and
size, and/or same last edit timestamp, and/or same md5sum check, etc.
2. When it copies over files that have been changed, it only transfers the
changes, which speeds things up dramatically.
3. It allows you to specify an "exclude" file that lists files it should
exclude from transfer. (Conversely, you can specify an "include" file that
lists the *only* files that should be transferred.)
4. Importantly for our (or Bob's) purposes, it seamlessly integrates ssh.

...and so forth.

Since this post is already pretty long, I'll wrap up with a simple rsync script
called `push-website.sh`, stored in Bob's `~/website` directory, which
transfers Bob's website from his local PC to his remote server's `public_html`
directory. It integrates an include file as well as a log file, both of which
are stored in a (hidden) directory `~/website/.push-website`.

```bash
#!/bin/bash

SRC="$HOME/website"
DEST="abc:/home/bob22/public_html"
EXCL="$SRC/.push-website/exclude-list"
LOG="$SRC/.push-website/log"

rsync \
    -avhhh \
    --exclude-from=$EXCL \
    --log-file=$LOG \
    $SRC/ $DEST/
```

Legend:

- `-a` means **a**rchive.
- `-v` means **v**erbose (make rsync say what it's doing while it runs).
- `-hhh` means extra **h**uman readable, e.g., "2M" instead of "2000".

**Important.** The forward slash, `/`, in `$SRC/` is crucial.  It tells rsync
to transfer the *contents* of the source directory into the destination
directory, rather than transfering `$SRC` itself. See `man rsync` for more
info. It's useful to read about all the rsync options.

So now Bob can update his site very simply by editing `index.markdown`, running
`md2html.sh` to convert to HTML, and running `push-website.sh` to push the
changes to his university server.

```bash
~/website $ vim index.markdown      # edit, edit, edit, save, quit
~/website $ ./md2html.sh            # convert to HTML
~/website $ ./push-website.sh       # push changes to remote server
```

Nice! By the way, here are some things that are good to keep in the exclude
file:

- `index.markdown`
- `header.html`
- `before-body.html`
- `after-body.html`
- `footer.html`
- etc.

All of that is already integrated into `index.html` when `md2html.sh` is
executed.  In fact, you also don't need to transfer over `md2html.sh` or
`push-website.sh` either, or the directory `.push-website`.

Really, you just need to transfer the main HTML file `index.html`, the
stylesheet `mystyle.css`, and any downloadables, like stuff in `images/` and
`files/`.

**Important.** Make sure that the permissions of all files are properly set on
the remote server. In particular, things that you want to be viewed (pages,
images) or downloaded (files) must allow read and (maybe) execute privileges
set. If an image fails to show up, or if clicking a link lands you on a
"Forbidden" page, then the permissions are not set right.

In the last part of this series, I'll explain how to version control your
website, scripts, etc. using git and GitHub. The setup will be a lot like the
above, because sites like GitHub and BitBucket use ssh for remote access. We'll
simply generate a new ssh key pair, plop the public one onto GitHub, and add a
github entry in `~/.ssh/config`. Easy stuff.
