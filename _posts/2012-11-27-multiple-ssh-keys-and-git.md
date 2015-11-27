---
layout: post
title: "Multiple SSH keys and Git"
date: 2012-11-27 09:26
---

I have three different ssh keys set up: `id_rsa.mcgill` for my McGill site,
`id_rsa.github` for GitHub, and `id_rsa.bitbucket` for BitBucket. I also have
the following in my `~/.ssh/config`:

```bash
Host mcgill
  User brian.buccola
  HostName people.linguistics.mcgill.ca
  IdentityFile ~/.ssh/id_rsa.mcgill

Host github
  User git
  HostName github.com
  IdentityFile ~/.ssh/id_rsa.github

Host bitbucket
  User git
  HostName bitbucket.org
  IdentityFile ~/.ssh/id_rsa.bitbucket
```

Now, it had been a while since I manually `ssh`-ed into GitHub or even McGill.
I update my McGill site with a simple rsync command that includes the `-i`
option specifying the `ssh` identity file to use.

```bash
rsync -e "ssh -i $HOME/.ssh/id_rsa.mcgill" src-path dest-path
```

So I was confused recently when, each time I tried to `ssh` into GitHub or
McGill, I would get this error:

```bash
$ ssh git@github.com
Permission denied (publickey)
```

The solution, it turns out, is that if the identity file is named something
*other than* `id_rsa` or `id_dsa`, then running `ssh user@hostname` (without
the `-i` option) will not find it. That should've been immediately obvious to
me: the whole point of an `ssh` config file like the one I set up months ago is
to not have to type out `user@hostname`!

So all I had to do was stop typing `git@github` and instead use simply `github`
(or whatever comes after `Host` in the config; that's up to you). So all of
these should work, and they do:

```bash
$ ssh mcgill
$ ssh github
$ ssh bitbucket
```
