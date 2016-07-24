# node-forever

This is a script to launch node's 'forever' script at boot time on a FreeBSD system.

# Installation

1. Copy the script to /usr/local/etc/rc.d
2. Set values in /etc/rc.conf or /etc/rc.conf.local. There are a few minimum values that are required.
  * forever_enable="YES"
  * forever_script="/path/to/your/script"
  * forever_scriptargs="--args --for --your --script"
3. Try it out with something like `sudo service node-forever onestart`

## Warning

This script runs `forever` as the `www` user, which is customary. It can be configured to run as any user at all. Be aware that it will create a bunch of files and directories and `chown` those file to that user. By default, it creates
* /var/log/forever-err.log
* /var/log/forever-out.log
* /var/log/forever.log
* /var/run/forever.pid
* /var/run/forever (directory)

## Limitation

Although `forever` itself is perfectly capable of creating, managing, starting, and stopping,
lots of different commands, this script only does ONE. It assumes you're only starting a single
command with `forever`. In particular, it's invoking referring to the process by ID `0`
when you invoke `stop` or `restart` on this rc script.

# Optional Configurations

The `FOREVER_ROOT` is set to `/var/run` by default.

# Complete Documentation

forever_enable:="NO"
forever_user:="www"
forever_root:="/var/run"
forever_sourcedir:="/usr/local/lib/node_modules"
forever_workingdir:="/usr/local/lib/node_modules"
forever_forever:="/usr/local/bin/forever"
forever_flags:="-a"
forever_script:=""
forever_scriptargs:=""
forever_max:=""
forever_logfile:="/var/log/forever.log"
forever_outfile:="/var/log/forever-out.log"
forever_errfile:="/var/log/forever-err.log"
forever_path:=""
forever_command:=""
forever_pid:="/var/run/forever.pid"
forever_nodeenv:="PRODUCTION"
