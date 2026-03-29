#!/bin/bash

# print help
help() {
  cat << EOF
Usage: $0 [OPTION...] [FIND-ARGS...]
Helper script to read all known/matching messages from an ebusd instance.

 Options:
  -s, --server=HOST   Connect to ebusd on HOST (name or IP) [localhost]
  -p, --port=PORT     Connect to ebusd on PORT [8888]
  -t, --timeout=SECS  Timeout for connecting to/receiving from ebusd, 0 for
                      none [60]
  -R, --readargs=...  Additional arguments to pass to the 'read' command []

If given, FIND-ARGS can be used to pass arguments to the 'find' command to
limit/widen the message list, e.g. '-c hwc' for the 'hwc' circuit.
EOF
}

# parse cmdline options
OPTS=$(getopt -n ebusctl -o 's:p:t:R:h' -l 'server:,port:,timeout:,readargs:,help' -- "$@")
if [ $? -ne 0 ]; then
  help
  exit 1
fi
eval set -- "$OPTS"
server=localhost
port=8888
timeout=60
readargs=
while true; do
  case "$1" in
    '-s'|'--server')
      shift
      server="$1"
      shift
      if [ -z "$server" ]; then
        echo "invalid server" >&2
        exit 1
      fi
      continue
      ;;
    '-p'|'--port')
      shift
      port="$1"
      shift
      if [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
        echo "invalid port" >&2
        exit 1
      fi
      continue
      ;;
    '-t'|'--timeout')
      shift
      timeout="$1"
      shift
      if [ "$timeout" -lt 0 ] || [ "$timeout" -gt 3600 ]; then
        echo "invalid timeout" >&2
        exit 1
      fi
      continue
      ;;
    '-R'|'--readargs')
      shift
      readargs="$1"
      shift
      continue
      ;;
    '-h'|'--help')
      shift
      help
      exit
      ;;
    '--')
      shift
      break
      ;;
    *)
      echo "error" >&2
      exit 1
      ;;
  esac
done

# set arguments to netcat
args=(-q 0)
if [ "$timeout" -gt 0 ]; then
  args+=(-w "$timeout")
fi
args+=("$server" "$port")

# query the messages
for i in `echo "f -F circuit,name" "$@"|nc "${args[@]}"|sort -u|grep ','`; do
  circuit=${i%%,*}
  name=${i##*,}
  if [ -z "$circuit" ] || [ -z "$name" ] || [ "$circuit,$name" = "scan,id" ]; then
    continue
  fi
  ret=`echo "r ${readargs} -c $circuit $name" |nc "${args[@]}"|head -n 1`
  echo "$circuit $name = $ret"
done
