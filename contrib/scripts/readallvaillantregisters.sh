#!/bin/bash
# readallvaillantregisters.sh - helper script to read all Vaillant registers from an ebusd instance.

# print help
help() {
  cat << EOF
Usage: $0 [OPTION...]
Helper script to read all Vaillant registers from an ebusd instance.

 Options:
  -s, --server=HOST   Connect to ebusd on HOST (name or IP) [localhost]
  -p, --port=PORT     Connect to ebusd on PORT [8888]
  -t, --timeout=SECS  Timeout for connecting to/receiving from ebusd, 0 for
                      none [60]
  -a, --addr=ZZ       Address to read (hex) [08]
  -f, --from=NUM      First register to read [0]
  -c, --count=NUM     Number of registers to read [128]
EOF
}

# parse cmdline options
OPTS=$(getopt -n ebusctl -o 's:p:t:a:f:c:h' -l 'server:,port:,timeout:,addr:,from:,count:,help' -- "$@")
if [ $? -ne 0 ]; then
  help
  exit 1
fi
eval set -- "$OPTS"
server=localhost
port=8888
timeout=60
addr=08
from=0
count=128
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
    '-a'|'--addr')
      shift
      addr="$1"
      shift
      if [ "${#addr}" != 2 ]; then
        echo "invalid addr" >&2
        exit 1
      fi
      continue
      ;;
    '-f'|'--from')
      shift
      from="$1"
      shift
      if [ "$from" -lt 0 ] || [ "$from" -gt 65535 ]; then
        echo "invalid from" >&2
        exit 1
      fi
      from=$(( $from ))
      continue
      ;;
    '-c'|'--count')
      shift
      count="$1"
      shift
      if [ "$count" -lt 1 ] || [ "$count" -gt 65535 ]; then
        echo "invalid count" >&2
        exit 1
      fi
      count=$(( $count ))
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

# check from/to bounds
to=$(( $from + $count ))
if [ "$to" -gt 65535 ]; then
  echo "invalid from/count" >&2
  exit 1
fi

# set arguments to netcat
args=(-q 0)
if [ "$timeout" -gt 0 ]; then
  args+=(-w "$timeout")
fi
args+=("$server" "$port")

# query the registers
for (( i=$from; i<$to; i++ )) ; do
  h=`printf "%4.4X" $i`
  ret=`echo "hex ${addr}b509030d${h##??}${h%%??}"|nc "${args[@]}"|head -n 1`
  echo $i "=" $ret
done
