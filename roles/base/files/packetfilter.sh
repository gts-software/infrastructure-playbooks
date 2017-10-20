#!/bin/bash
set -e

case "$1" in
  'start'|'restart')
    echo "Applying netfilter rules..."
    source /usr/local/bin/packetfilter-helper.sh
    for CONFIG_FILE in `ls /etc/packetfilter/*.sh | sort -V`;
    do
      (
        set -e
        source "$CONFIG_FILE"
      )
    done
    echo "Done!"
  	;;

  'stop')
    echo "Ignoring!"
		;;

  'flush-connections')
    echo "Flushing tracked connections..."
    conntrack --flush
    echo "Done!"
		;;

  *)
		echo "Usage: $0 { start | stop | restart | flush-connections }"
		;;
esac
