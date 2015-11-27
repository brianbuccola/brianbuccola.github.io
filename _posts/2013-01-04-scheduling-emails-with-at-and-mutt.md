---
layout: post
title: "Scheduling emails with at and mutt"
date: 2013-01-04 11:08
---

I had assumed that most modern email services, like Gmail, allow users to
schedule emails to be sent at some later specified time, but a quick Google
search reveals that that's not quite the case. It looks like you need to use a
browser extension like [Boomerang][bg] or [Right Inbox][ri].

[bg]: http://www.boomeranggmail.com/
[ri]: http://www.rightinbox.com/

But what if you don't trust browser extensions/third parties to handle private
emails?  Or what if you don't use Firefox, Chrome, etc.? (I use [dwb][].) In
this post I'll explain how Linux users who are already set up with [mutt][] (or
any mail client with similar command-line capability) can harness the powers of
`at` and `mutt` to schedule emails.

[dwb]:  http://portix.bitbucket.org/dwb/
[mutt]: http://www.mutt.org/

The `at` command lets you schedule tasks (shell commands) that are to be
executed at a specified time. The basic syntax is `at TIMESPEC`, where timespec
is something like `now + 10 minutes`, `noon tomorrow`, `11:59pm Dec 31`, etc.
The `at` command is run from a terminal, and once you specify the timespec and
hit enter, you're put into an interactive prompt where you list the commands
that you want `at` to execute at the specified time. Hit `<Ctrl-D>` to finish,
or `<Ctrl-C>` to cancel. For example:

```bash
$ at now + 1 minute
warning: commands will be executed using /bin/sh
at> echo "testing out at" >>~/my-at-test
at> <EOT>
job 13 at Fri Jan  4 11:46:00 2013
```

In the above code, we tell `at` that 1 minute from now, it should append the
text "testing out at" to the file `my-at-test` (and create it if it doesn't
already exist).[^atd]

[^atd]: `at` comes with a daemon, `atd`, which must be running in order to
        schedule and execute commands.  If you get the error

        Can't open /var/run/atd.pid to signal atd. No atd running?

    then it means `atd` is not running. Either run `sudo atd` to run `atd` just
    this once, or do whatever is necessary to have `atd` load on boot. (In Arch
    Linux: `sudo systemctl enable atd.service`.)

You can run `atq` to view the queue of current jobs, `atrm JOBID` to remove a
job, and `at -c JOBID` to view (**c**at) a queued job.

Since `at` accepts any shell command, we can schedule emails using mutt's
command-line interface. The basic syntax for sending emails with mutt from the
command line is

```bash
$ echo "MSG" | mutt -s SUBJ -- RECIPIENT # for simple messages
$ mutt -s SUBJ -- RECIPIENT <MSG         # for longer messages (files)
```

Suppose I want to email myself a reminder tomorrow at 10am to call John. Here's
what I do.[^alias]

[^alias]: I have `me` aliased to my email address in `~/.mutt/alias`, which is
          sourced in `.muttrc`.

```bash
$ at 10am tomorrow
warning: commands will be executed using /bin/sh
at> echo "Remember to call John." | mutt -s "Call John" -- me
at> <EOT>
job 14 at Sat Jan  5 10:00:00 2013
```

There's a problem though. If my computer is off tomorrow at 10am, nothing will
happen. And if my computer is on but not connected to the internet, then the
job will technically be executed (and thus be subsequently removed from the
queue), but no mail will be sent.

Moreover, if my computer is off tomorrow at 10am, then `at` will execute the
command the next time I boot, but unfortunately it'll do so immediately, before
enough time has passed to allow my wifi connection to be established.

There's really no complete remedy to these problems except to ensure that the
computer is on and connected to the internet at the specified time (which is no
problem for people who rarely turn off their computers, or for dedicated
servers).

But if the computer is off and/or not online, there is still a way to ensure
that the email is not sent until a wifi connection is established.  We just
need to write a simple shell script, `check-wifi.sh`, which only exits once a
wifi connection is established.

```bash
#!/bin/bash

until [[ -n "$(iwgetid)" ]]; do
    sleep 1
done

exit 0
```

`iwgetid` is a command that returns the ESSID of the current wifi connection if
there is one, and nothing otherwise. So this script does the following: keep
waiting (sleeping) until `iwgetid` returns a string of nonzero length, then
exit with status 0. (Remember to make it executable: `chmod a+x
check-wifi.sh`.)

Now we can modify our `at` commands as follows:

```bash
$ at 10am tomorrow
at> /path/to/check-wifi.sh
at> echo "Remember to call John." | mutt -s "Call John" -- me
at> <EOT>
```

Now the email won't try to be delivered until `check-wifi.sh` finishes running,
i.e., until a wifi connection is established.

We can also modify `check-wifi.sh` to time out after, say, 3 minutes of no
wifi, and to write something to a log file.

```bash
#!/bin/bash

COUNT=0
TIMEOUT=180
E_TIMEOUT=70

until [[ -n "$(iwgetid)" ]]; do
    sleep 1
    let "COUNT+=1"
    # wait $TIMEOUT seconds, then exit
    if [[ $COUNT -ge $TIMEOUT ]]; then
        echo "$(date '+%F %T') \
            Wifi connection not established. No mail sent." >>~/.at.log
        exit $E_TIMEOUT
    fi
done

exit 0
```

The result of all this is that I can schedule an email for, say, 6am tomorrow,
when my computer is probably off, and it'll get delivered the moment I boot up
and connect to the internet. Or I can schedule a birthday email for 6am on
John's birthday, and it'll get sent the moment I boot up and get online,
assuming I do so on John's birthday.

As you can see, the possibilities with `at`, mutt, and shell scripting are
endless.
