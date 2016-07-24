# node-forever

This is a script to launch node's [forever](https://github.com/foreverjs/forever) script at boot
time on a [FreeBSD](https://freebsd.org/) system. When I Googled, all I found was
[this script](https://gist.github.com/jellea/6510897), which doesn't make me happy. It doesn't really
get FreeBSD's `rc(8)` subsystem and how things are expected to work. I've taken
[jellea](https://github.com/jellea)'s script and radically reworked it. I suppose
The Right Way™ to do it would be to fork it, but this was such a significant rewrite
that I didn't think that made sense.

# Installation

1. Copy the script to `/usr/local/etc/rc.d`. Name it `node-forever` instead of `node-forever.sh`.
2. Set values in `/etc/rc.conf` or `/etc/rc.conf.local`. There are a few minimum values that are required.
  * `forever_enable="YES"`
  * `forever_script="/path/to/your/script"`
  * `forever_scriptargs="--args --for --your --script"`
3. Try it out with something like `sudo service node-forever start`


## Example Configuration

This is similar to what I have in my own `/etc/rc.conf` file. It's not many lines because
I like most of the defaults.

```shell
forever_enable="YES"
forever_sourcedir="/home/paco/myApp"
forever_workingdir="/home/paco/myApp"
forever_script="node_modules/http-server/bin/http-server"
forever_scriptargs="/home/paco/myApp/app -r -p 8000 -c-1"
```

# Usage

| Action   | Command |
|----------|---------|
| **Start the service** |  `sudo service node-forever start` |
| **Stop the service** | `sudo service node-forever stop` |
| **Restart the service** | `sudo service node-forever restart` |
| **Check Status** | `sudo service node-forever status` |

## Warning

This script runs `forever` as the `www` user, which is customary. It can be configured
to run as any user at all. Be aware that it will create a bunch of files and directories
and `chown` those file to that user. By default, it creates:
* `/var/log/forever-err.log`
* `/var/log/forever-out.log`
* `/var/log/forever.log`
* `/var/run/forever.pid`
* `/var/run/forever` (directory)

## Limitation

Although `forever` itself is perfectly capable of creating, managing, starting, and stopping,
lots of different commands, this script only does ONE. It assumes you're only starting a single
command with `forever`. In particular, it's invoking referring to the process by ID `0`
when you invoke `stop` or `restart` on this rc script.

# Optional Configurations

You will probably want to create a file like `/usr/local/etc/newsyslog.conf.d/node-forever` and put
some lines in it like this:
```shell
/var/log/forever.log                        640  7     *    @T00  JC
/var/log/forever-out.log                    640  7     *    @T00  JC
/var/log/forever-err.log                    640  7     *    @T00  JC
```

You could put those directly into `/etc/newsyslog.conf` or in a file in `/etc/newsyslog.conf.d`,
but there are advantages to making it a file that you just install. And putting it parallel to
`/usr/local/etc/rc.d` is good.


# Complete Documentation
| Variable   | Default | Meaning |
|----------|-------------|------|
| forever_enable | "NO" | Set to "YES" to enable the daemon. Won't run otherwise. |
| forever_user | "www"  | User that `forever` will run as.  Will own log files, too.  |
| forever_root | "/var/run/forever"  | Where to put `forever`'s management files and sockets.  |
| forever_sourcedir | "/usr/local/lib/node_modules"  | For `--sourceDir` |
| forever_workingdir | "/usr/local/lib/node_modules"  | For `--workingDir` |
| forever_forever | "/usr/local/bin/forever"  | The `forever` binary to invoke.  |
| forever_flags | "-a"  | Any miscellaneous flags for `forever`  |
| forever_script | ""  | The name of your script. E.g. `node_modules/http-server/bin/http-server`  |
| forever_scriptargs | ""  | Arguments to your script. E.g., `/path/to/my/app -r -p 8000 -c-1`  |
| forever_max | ""  | For `-m MAX`  |
| forever_logfile | "/var/log/forever.log"  | Logs the forever output to LOGFILE. For `-l`  |
| forever_outfile | "/var/log/forever-out.log"  | Logs stdout from child script to OUTFILE. For `-o`  |
| forever_errfile | "/var/log/forever-err.log"  | Logs stderr from child script to ERRFILE. For `-e`  |
| forever_pid | "/var/run/forever.pid"  | The PID file for `forever` itself, so rc.subr(8) can kill it.  |
| forever_nodeenv | "PRODUCTION" | Sets `NODE_ENV` to this value before invoking `forever` |
