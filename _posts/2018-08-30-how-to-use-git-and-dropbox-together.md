---
layout: post
title: "How to use Git and Dropbox together"
date: 2018-08-30 15:47
tags: [git, dropbox, command line, howto, latex, linux]
---

**Problem**:
You and some colleagues are working on a new project together
(e.g. writing a new paper).
You use [Git][] to version-control your work
and sync it to the cloud (with GitHub or similar),
but your colleagues use Dropbox.

What to do?
Abandon Git when collaborating? (No!)
Force your collaborators to learn Git? (Ye... No!)

**Solution**:
Use both!
All you need to do
is tell Dropbox to ignore all Git-specific files,
and tell Git to ignore all Dropbox-specific files.
While that sounds pretty simple,
there are a few [important caveats](#important-warning) to watch out for.
Here's how to do it.

## Step 1: Get the Dropbox command-line program

The first thing you'll need is the Dropbox command-line program.
Depending on your Linux distribution,
this program may already come with your Dropbox package,
or it may be available as a separate package
(on Arch Linux, the package is separate
and is called [`dropbox-cli`][db-cli-aur]).
Or you can just download [the Python script][db-cli] directly.
For concreteness, I'm going to call this program `dropbox`, 
but on your machine
it may be called `dropbox.py`, `dropbox-cli` (Arch Linux), etc.

`dropbox` provides a number of commands.
Run `dropbox help` to see them all.

The one we care about is the `exclude` command,
which allows you to exclude specific files/directories
from sync'ing to Dropbox.

You can run `dropbox exclude list` to list all excluded files,
`dropbox exclude add [file] ...` to add a file to the exclude list,
or `dropbox exclude remove [file] ...` to remove a file from the exclude list.

By the way,
even though `dropbox help exclude` mentions only directories,
you can actually exclude both directories and plain files.
(That's probably because on Unix,
[everything is a file](https://en.wikipedia.org/wiki/Everything_is_a_file).)

See [this article][db-wiki] on the Dropbox wiki for more information.

## Step 2: Start Dropbox

At this point, you can already start Dropbox.
So, in a terminal, run:

```bash
$ dropbox start
```

**Protip**:
Use the command

```bash
$ dropbox start && watch -n1 dropbox status && dropbox stop
```

to continually (every second) watch the Dropbox status,
or better yet,
create an alias for it called `db`,
as I previously described in [this post][db-alias].

## Step 3: Start a new project

Now we start our new project, e.g. LaTeX manuscript.
(If you used the `db` alias/command above,
then fire up a new terminal.)
Let's call the project `project`,
because we're not creative:

```bash
$ mkdir ~/Dropbox/project
$ cd ~/Dropbox/project
```

From here on out,
I'm going to assume that every command
is run from inside `~/Dropbox/project`.

## Step 4: Exclude Git files from Dropbox sync

With Dropbox running,
we're going to preemptively exclude two Git-related things:
the directory `.git` and the file `.gitignore`,
both of which will be created in the next step.

```bash
# Run this from inside ~/Dropbox/project!
$ dropbox exclude add .git .gitignore
Excluded:
.git
.gitignore
```

Dropbox confirms that it excluded the files,
but you can double-check that it worked by running:

```bash
$ dropbox exclude list
Excluded:
.git
.gitignore
```

Note that `.git` and `.gitignore` don't even exist yet!
In other words, you can tell Dropbox to exclude stuff
before even creating it.
In fact, you *should* do this.
More about that [at the end](#important-warning).

## Step 5: Exclude Dropbox files from Git tracking

Now we turn `project` into a Git repository in the usual way:

```bash
$ git init
```

This creates the directory `.git`.
Since we previously excluded this directory from Dropbox sync,
Dropbox won't actually do anything here.

If you check Git's status:

```bash
$ git status
```

you may see an untracked file called `.dropbox`.
We want Git to ignore that,
so we create the file `.gitignore`
and add `.dropbox` to it:

```bash
$ echo ".dropbox" > .gitignore
```

Again, since we previously excluded `.gitignore`,
Dropbox still won't do anything.

Now, when you run `git status`, you won't see `.dropbox`.

**Note**:
This step may no longer be necessary.
When I tested this just now,
Dropbox did not create a `.dropbox` file,
and all the `.dropbox` files in my Dropbox
are many months old.
So it may be that the newest version of Dropbox
no longer creates a `.dropbox` file
(or that the `.dropbox` file is coming
from one of my collaborators' versions of Dropbox).
Still, it can't hurt to add it to your `.gitignore`.

## Step 6: Profit

Now you can work as usual,
sync'ing to Dropbox
and committing changes to Git
as you normally would.
The two will not step on each other's toes.

The really nice thing about this method
is that when you sync your collaborators' changes
to your machine over Dropbox,
you can run

```bash
$ git status
```

to see which files were added, deleted, or changed,
as well as

```bash
$ git diff
```

or (my preference)

```bash
$ git diff --word-diff=color
```

to see *exactly* what changes were made
by your collaborators
since your last Git commit.

**Protip**:
Before doing new work on your project,
and definitely before sync'ing over Dropbox,
I highly recommend checking <https://www.dropbox.com/events>
to see if anyone has made any changes.
If so, then pull in the changes first,
review and commit them with Git:

```bash
$ git commit -am "Merge Alice's changes"
```

and then start your work.
(Otherwise, Dropbox will create a conflicted copy,
and then you'll have to manually merge your conflicted copy
with your collaborator's copy.)

## Important warning!

For some reason that I don't understand at all,
if you run:

```bash
$ dropbox exclude add foo
```

and `foo` already exists,
then Dropbox will actually *delete* `foo`!
Therefore, if you decide you want to exclude a file
from sync'ing over Dropbox,
but it's a file that you want to keep locally,
be sure to *move* the file out of your project folder first
(or make a copy of it).

For example, let's say that I've created a file `notes`
that contains my own notes for a collaborative project.
My colleagues don't care to see that,
so I decide to exclude it:

```bash
# From inside ~/Dropbox/project!
$ mv notes /tmp                # move notes to /tmp
$ dropbox start                # start Dropbox, if not already running
$ dropbox exclude add notes    # exclude notes
$ mv /tmp/notes .              # move notes back to project
```

If you accidentally `exclude add` a file that already exists,
and Dropbox deletes it,
don't worry:
you can manually download the deleted file
by going to the Dropbox website,
navigating to your project,
and making sure to "Show deleted files".
Once you've downloaded the deleted file,
move it into your `project` directory,
and Dropbox won't do anything with it,
since it's been excluded.

## Step 7 (bonus): Multiple versions of a file or directory

Since your colleagues don't use Git,
they may be in the habit
of creating entirely new files or directories
when they implement (major) changes,
which on first glance may look disastrous.

For example, suppose your project starts with the following state:

```bash
$ ls -a project
./ ../ .git/ .gitignore paper.tex paper.pdf
```

You start Dropbox,
and then when you run `git status`,
you notice that all your files have been deleted,
and in their place
you now have two untracked directories!

```bash
$ git status
Changes not staged for commit:

    deleted: paper.tex

Untracked files:

    v1/
    v2/
```

What happened, of course, was that
your colleague moved the old `paper.tex` and `paper.pdf`
into a new directory called `v1`,
copied them into another new directory called `v2`,
and then made their changes in the `v2` version.

```bash
$ ls -a project
./ ../ .git/ .gitignore v1/ v2/
$ ls -a v1 v2
v1:
./  ../  paper.pdf  paper.tex

v2:
./  ../  paper.pdf  paper.tex
```

Assuming they haven't made any filename changes,
all you have to do is
move `.git` and `.gitignore`
from the top-level `project` directory
to the new `v2` directory,
and then run `git status` to see the new changes.

However, *before* you do that,
make sure to exclude `v2/.git` and `v2/.gitignore`!

```bash
$ dropbox exclude add v2/.git v2.gitignore
Excluded:
v2/.git
v2/.gitignore
$ mv .git .gitignore v2
$ cd v2
$ git status
```

You can also now un-exclude the old top-level Git files:

```bash
$ cd .. # move back to ~/Dropbox/project
$ dropbox exclude remove .git .gitignore
No longer excluded:
.git
.gitignore
```

[git]: https://git-scm.com/
[db-alias]: /a-simple-dropbox-command-line-alias/
[db-cli]: https://www.dropbox.com/download?dl=packages/dropbox.py
[db-cli-aur]: https://aur.archlinux.org/packages/dropbox-cli/
[db-wiki]: https://www.dropboxwiki.com/tips-and-tricks/using-the-official-dropbox-command-line-interface-cli
