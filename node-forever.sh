#!/bin/sh
# Copyright (c) 2016 Paco Hope. <github@filter.paco.to>
# Code licensed under GNU GENERAL PUBLIC LICENSE Version 3

# PROVIDE: forever

# For documentation see: https://github.com/pacohope/bsd-scripts/blob/master/node-forever.md

# Adapted from https://gist.github.com/jellea/6510897
#  which credits http://habrahabr.ru/post/137857/

. /etc/rc.subr

name="forever"
rcvar="forever_enable"
extra_commands="status"

start_cmd="start"
status_cmd="status"
stop_cmd="stop"
restart_cmd="restart"
start_precmd="${name}_precmd"

load_rc_config $name
# Default values
: ${forever_enable:="NO"}
: ${forever_user:="www"}
: ${forever_root:="/var/run/forever"}
: ${forever_sourcedir:="/usr/local/lib/node_modules"}
: ${forever_workingdir:="/usr/local/lib/node_modules"}
: ${forever_forever:="/usr/local/bin/forever"}
: ${forever_flags:="-a"}
: ${forever_script:=""}
: ${forever_scriptargs:=""}
: ${forever_max:=""}
: ${forever_logfile:="/var/log/forever.log"}
: ${forever_outfile:="/var/log/forever-out.log"}
: ${forever_errfile:="/var/log/forever-err.log"}
: ${forever_pid:="/var/run/forever.pid"}
: ${forever_nodeenv:="PRODUCTION"}

export NODE_ENV="${forever_nodeenv}"
export FOREVER_ROOT="${forever_root}"

start()
{
  ARGS="${forever_flags} -l ${forever_logfile} -o ${forever_outfile} -e ${forever_errfile} -p ${forever_pid}"
  if [ "${forever_max}" != "" ]
  then
    ARGS="${ARGS} -m ${forever_max}"
  fi

  if [ "${forever_sourcedir}" != "" ]
  then
    ARGS="${ARGS} --sourceDir ${forever_sourcedir}"
  fi

  if [ "${forever_workingdir}" != "" ]
  then
    ARGS="${ARGS} --workingDir ${forever_workingdir}"
  fi

  /usr/bin/su -m "${forever_user}" -c \
    "${forever_forever} start ${ARGS} ${forever_script} ${forever_scriptargs}"
}

status()
{
  /usr/bin/su -m "${forever_user}" -c "${forever_forever} list"
}

stop()
{
  /usr/bin/su -m "${forever_user}" -c "${forever_forever} stop 0"
}

restart()
{
  /usr/bin/su -m "${forever_user}" -c "${forever_forever} restart 0"
}


# Make sure the script file is defined and is readable.
# Bail otherwise
forever_precmd() {
  if [ "${forever_script}" = "" ]
  then
    err "forever_script is undefined"
  fi

  if [ ! -r "${forever_sourcedir}/${forever_script}" ]
  then
    err 5 "\"${forever_script}\" is not readable"
  fi

  # Only root can write log files and pid files to these locations. So we
  # pre-create the files and chown them to the right user. I have no idea
  # if that's the right convention or not.
  [ "${forever_logfile}" != "" ] && \
    /usr/bin/touch "${forever_logfile}" && \
    /usr/sbin/chown "${forever_user}" "${forever_logfile}"

  [ "${forever_outfile}" != "" ] && \
    /usr/bin/touch "${forever_outfile}" && \
    /usr/sbin/chown "${forever_user}" "${forever_outfile}"

  [ "${forever_errfile}" != "" ] && \
    /usr/bin/touch "${forever_errfile}" && \
    /usr/sbin/chown "${forever_user}" "${forever_errfile}"

  [ "${forever_pid}" != "" ] && \
    /usr/bin/touch "${forever_pid}" && \
    /usr/sbin/chown "${forever_user}" "${forever_pid}"

  # Make the forever_root if it doesn't exist.
  if [ ! -d "${forever_root}" ]
  then
    warn "Making \"${forever_root}\""
    mkdir -p mkdir -p "${forever_root}"
  fi

  /usr/sbin/chown -R "${forever_user}" "${forever_root}"

}

run_rc_command "$1"
