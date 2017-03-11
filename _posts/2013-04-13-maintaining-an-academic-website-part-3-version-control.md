---
layout: post
title: "Maintaining an academic website, part 3: version control"
date: 2013-04-13 10:11
redirect_from: /blog/2013-04-13-maintaining-an-academic-website-part-3-version-control.html
---

This is the third and final post in a series detailing how I currently maintain
my academic website ([here][me]). In the [first post][pt1], I explained how I
write and edit my site using the simple and intuitive syntax of [markdown][md],
rather than pure HTML, and convert from markdown to HTML using [pandoc][pd]. In
the [second post][pt2], I explained how I automate the process of pushing my
website to the hosting server using a combination of [ssh][] and [rsync][]. In
this post, I'll explain how to version control everything using [git][] and
[GitHub][gh].[^other]

[^other]: Other version control programs include [Mercurial][hg] and
          [Subversion][svn]. Another repository-hosting website is
          [Bitbucket][bb], which in addition to Git also supports Mercurial and
          even offers free private repos.

[me]:    https://github.com/brianbuccola/mcgill-website
[pt1]:   /maintaining-an-academic-website-part-1-editing-the-site/
[pt2]:   /maintaining-an-academic-website-part-2-pushing-to-server/
[md]:    http://daringfireball.net/projects/markdown/
[pd]:    http://johnmacfarlane.net/pandoc/
[ssh]:   http://www.openssh.org/
[rsync]: http://rsync.samba.org/
[git]:   http://git-scm.com/
[gh]:    https://github.com/
[hg]:    http://mercurial.selenic.com/
[svn]:   http://subversion.apache.org/
[bb]:    https://bitbucket.org/

Version Control
---------------

Version control is usually thought of as something that software developers do:
each time they make a software change, they implement and record the change in
a way that lets them track the history of the software and, if necessary,
revert back to a previous version, i.e. undo changes.

But software is not the only thing that can be version controlled. Any sort of
text can be, including HTML source code (hence, websites), LaTeX source codes
(hence, research papers), markdown code, etc. Here are just a few benefits to
version controlling and keeping your revisions as a repository on a site like
GitHub:

- **Automatic backups.** If you add/remove/change something and later decide
  that was a bad idea, you can easily revert back. Or if your computer dies and
  you lose your website entirely, just grab the whole thing, including all the
  revision history, from GitHub.

- **Separate branches.** Test out new changes in a separate "branch", without
  dirtying up the master branch, and then, once satisfied, merge the changes
  into the master branch.

- **Revision history.** Visualize all changes over time using change logs. For
  example, see when you're most active about updating your site, how often you
  update, etc.

- **Open source.** Assuming your GitHub repository is public (not private), the
  source code to your website will be open for people to view, reuse, modify,
  etc.

Moreover, version controlling a simple, one-page website is really easy and
will give you experience dealing with `git` so that you can move on to version
controlling more important/complex things, like a PhD thesis, books, research
papers, etc. written in LaTeX.

### Setup

First things first, you'll actually need the `git` program. On Linux, just grab
`git` using your package manager. Next, you need to tell `git` your name and
email address, which it attaches to the messages you write that explain changes
you make.

#### Username

Open a terminal and type the following. (Remember that `$` is the (end of the)
terminal prompt; don't type it.)

```bash
$ git config --global user.name "Your Name"
```

#### Email

Now add your email address.

```bash
$ git config --global user.email "your_email@example.com"
```

What the two commands above do is essentially tell `git` to associate the two
values "Your Name" and "your_email@example.com" with the two *global* variables
`user.name` and `user.email`, respectively. You can check that it worked by
typing

```bash
$ git config --global --list
```

which tells `git` to list all global config options. You can also check them by
opening the file `.gitconfig` in a text editor, but don't edit this file
directly. Use `git config` instead.

#### GitHub

Now go over to [GitHub][gh], create an account, and sign in. (You should at
some point read through all the "bootcamp" help pages.)

The ultimate goal here is to have a local "repo(sitory)" on your home computer,
e.g. the main directory containing your website files, and a remote repo on
GitHub, and, each time you change your website, to push all those changes from
the local repo to the remote one, that way GitHub has an exact copy of all
versions of your website at all times.

But before you can push anything to GitHub, you need GitHub to give you access
remote access to your account. Luckily, GitHub does this using `ssh`, which we
already learned about in the [previous post][pt2]. So the setup here is
essentially the same: create a new `ssh` key pair (public and private keys),
give GitHub your public key so it can recognize you, and add GitHub to your
`ssh` config file to make your life easy.

So then, first run

```bash
$ mkdir -p ~/.ssh # create this if it doesn't already exist
$ cd ~/.ssh       # cd into it
$ ssh-keygen -f github -t rsa -C 'GitHub'
```

to generate the pair of RSA keys, giving them the filenames `github` and
`github.pub`, respectively. Now go to your GitHub account settings, click "SSH
Keys", and click "Add SSH key". Give the key a title, and then paste the
contents of `github.pub` (**NOT** `github`: this is the private key, which you
should never disclose) into the text field. One way get the contents of that
file is

```bash
$ xsel -b < ~/.ssh/github
```

if you have `xsel` installed, which copies the contents of `github` onto your
clipboard so that you can paste the contents into your browser, e.g. with
`ctrl-V`. Or open `github.pub` in your text editor and highlight and copy
everything. In any case, once you've managed that, click "Add key".

You can check that GitHub recognizes you by `ssh`-ing into GitHub:

```bash
$ ssh -i ~/.ssh/github git@github.com
```

You should get a message like, "Hello yourusername! You've successfully
authenticated, but GitHub does not provide shell access."

Note that in the above command the username is `git` rather than your own, and
the hostname is `github.com`. If you have an `ssh` config file
(`~/.ssh/config`), you can add GitHub so that you don't have to specify this
info, or the key, each time.

```bash
Host github
    User git
    HostName github.com
    IdentityFile ~/.ssh/github
```

Now you can run the following command, which is identical to the above one.

```bash
$ ssh github
```

Moreover, having a config file will make using `git` much easier, too.

Creating a Repo
---------------

It's time to create a repo(sitory). There will be two instances: one local one,
which is the directory containing the contents of your website, and one remote
one, hosted by GitHub. Basically, you'll maintain your website locally, track
changes using `git`, then push those changes to GitHub, so that GitHub will
have an exact copy of each version of your website (hence the automatic backups
benefit).

#### Remote Repo

In GitHub, click the "Create a new repo" icon at the top-right corner next to
your username. Call the new repo `my-website`, give it a description like
"Source code to my website" (this is optional and only appears on GitHub), make
sure that "Public" is checked, and then click "Create repository".

At this point, you have an empty repo on GitHub. Once we create the local
instance, we can push changes to the remote GitHub one.

#### Local Repo

Go into your website directory and *initialize* it with `git`, which means turn
that directory into a `git` repo, so that `git` can start tracking everything.
Following last post's example, our friend Bob would do the following.

```bash
$ cd ~/website
~/website $ git init
Initialized empty Git repository in /home/bob/website
```

Now we need to link up this local repo with the remote GitHub one so that we
can start pushing stuff to GitHub. Assuming that Bob's GitHub username is
`bobbarker` and that he has an entry in his `ssh` config called `Host github`,
then Bob would run the following command.

```bash
~/website $ git remote add origin github:bobbarker/my-website.git
```

This command adds a remote called `origin` (the convention is to always call it
`origin`), located at `bobbarker/my-website.git`.

Git Basics
----------

As you read this section, it might be helpful to periodically run `git status`
to see how things change as we run `git` commands. It's good habit anyway to
run `git status` while you work, especially because `git` usually tells you
exactly what you need to do and what commands to run.

#### Tracking/Adding Files

At the moment, Bob's remote repo is empty, and although the local repo has
stuff like `index.html` and other files and directories, none of them are being
*tracked* by `git`.

```bash
~/website $ git status
# On branch master
#
# Initial commit
#
# Untracked files:
#   (use "git add <file>..." to include in what will be committed)
#
#   index.html
#   ...
nothing added to commit but untracked files present (use "git add" to track)
```

What this means is that `git` is not tracking these files to look for changes.
If changes are made, `git` won't know, because it has no baseline. The syntax
for adding files to be tracked is the following.

```bash
$ git add [FILENAME] # add a file, or list of files, to be tracked
$ git add .          # add entire directory
```

For simplicity, let's assume Bob has added his entire website directory.

```bash
~/website $ git add .
~/website $ git status
# On branch master
#
# Initial commit
#
# Changes to be committed:
#   (use "git rm --cached <file>..." to unstage)
#
#   new file:   index.html
#   ...
#
```

Now that `git` is tracking the files, it tells Bob that there is a "change" to
be committed, namely that there is a new file.

#### Committing Changes

Before doing anything else, Bob should do a *commit*, essentially creates the
first snapshot of his website, as far as `git` is concerned. Every commit must
have a commit message, describing what changes have been made.

```bash
~/website $ git commit -m "first commit"
[summary of what was committed]
~/website $ git status
# On branch master
nothing to commit, working directory clean
```

#### Pushing to Remote

This commit is now ready to be pushed to GitHub.

```bash
$ git push -u origin master
```

This command pushes (all the committed changes from) the `master` branch (more
about branches later) over to the `origin` remote that was created earlier,
i.e. the GitHub remote.

If all was successful, you (or Bob) should be able to see an exact copy of your
website directory in your GitHub `my-website` repo.

#### Basic Workflow

So here's a typical example of how you might use `git` after, or while,
updating your website. Let's say you want to add new research paper,
`paper.pdf`, to your site.

1. Add `paper.pdf` to a directory like `~/website/files/`.
2. Update `index.markdown` to include a reference to `paper.pdf`.
3. Run `md2html.sh` to convert `index.markdown` to `index.html`.
4. Push changes to the university server.

If you run `git status`, you'll see that `git` has noticed that some tracked
files have been modified. So you

1. Add all of modifications with `git add .` .
2. Commit the added modifications with `git commit -m "added new paper"`.
3. Push to GitHub with `git push origin master`.

#### Adding vs. Committing

It took me a while to understand the differences between adding and committing,
and I suggest you read a bit online somewhere about it. But basically, once
you've modified some file, you `add` the changes to a so-called staging area,
and when you're ready, you `commit` those changes. (Or you can unstage the
changes with `git reset`, do more work, and readd them, or you discard all
changes and go back to a clean slate with `git checkout`.) The purpose of
`add`, I believe, is to let you gather up a range of changes, possibly over
several files, and commit them with a single commit. This would make sense if
you're committing a big "change" that spans several files, or several different
parts of a file.

Thus, with `add` and `commit`, you're not really adding or committing *files*,
but rather *changes*, which in turn means that you can add and commit different
changes to a single file or multiple files at different times and with
different commit messages. It's very versatile.

Git Branches
------------

One of best `git` features is branching. Currently, Bob has only a master
branch.  Suppose, however, that he wants to completely overhaul the layout of
his website. (I'll talk only about `index.html` here.) It might take him a
month or two of off-and-on working to get his site looking the way he wants it,
and he doesn't want the new and improved version to go live until it's
completely done. Moreover, he still wants to be able to add new papers, etc. to
his live website. Essentially, then, Bob needs to be able to work on two
versions of his website: the master version, which has the old layout but is
still updated with new content, and the in-progress version, which has the new
layout.

Enter branches. Bob creates a new branch of his website repo called
`new_layout`.

```bash
~/website $ git branch new_layout
~/website $ git branch
* master
  new_layout
```

The `branch` command with no arguments lists all branches, and the star
indicates which branch you're currently working on. Bob switches over to the
`new_layout` branch and does some hacking.

```bash
~/website $ git checkout new_layout
Switched to branch 'new_layout'
```

Bob does a bunch of edits and commits. He can view the results in his browser,
etc. Finally, he pushes the commits to GitHub, which creates a `new_layout`
branch there, too. And finally, he switches back to the master branch.

```bash
~/website $ git checkout master
Switched to branch 'master'
```

Bob now sees the old, untouched version of `index.html`. He can also add new
papers, commit and push them, etc. without affecting the other branch, and he
can switch to `new_layout` whenever he wants to work on the new layout.

A month passes and finally Bob is ready to use his new layout, so he must merge
his `new_layout` branch into his `master` branch.

```bash
~/website $ git merge new_layout
```

This command updates the `master` branch to include changes from `new_layout`.
(Merging may require some human intervention if `git` can't figure everything
out.) Once Bob is satisfied that everything is merged properly, he can delete
the `new_layout` branch.

```bash
~/website $ git branch -d new_layout
```

Note that all commits and commit messages made in `new_layout` become commits
in `master`.

Git Resources
-------------

In addition to the basic "bootcamp" help offered by GitHub, I found the
following website particularly helpful.

- [Git Reference](http://gitref.org/)

Moreover, the primary documentation is probably the most exhaustive and
authoritative.

- [Git Documentation](http://git-scm.com/documentation)

Lastly, the `git` program itself has a very exhaustive `help` command. Just
about everything has a help page.

- `git help push`
- `git help config`
- `git help commit`
- `git help add`
- and so forth.
