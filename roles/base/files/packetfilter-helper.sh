#!/bin/bash
set -e

function set-policy
{
  IFS=',' read -ra IPVS <<< "$1"; TABLE="$2"; CHAIN="$3"; shift 3
  for IPV in "${IPVS[@]}";
  do
    case $IPV in
      4) iptables  -t "$TABLE" -P "$CHAIN" "$@" ;;
      6) ip6tables -t "$TABLE" -P "$CHAIN" "$@" ;;
    esac
  done
}

function append-rule
{
  IFS=',' read -ra IPVS <<< "$1"; TABLE="$2"; CHAIN="$3"; shift 3
  for IPV in "${IPVS[@]}";
  do
    case $IPV in
      4) if ! iptables  -t "$TABLE" -C "$CHAIN" "$@" 2> /dev/null; then iptables  -t "$TABLE" -A "$CHAIN" "$@"; fi ;;
      6) if ! ip6tables -t "$TABLE" -C "$CHAIN" "$@" 2> /dev/null; then ip6tables -t "$TABLE" -A "$CHAIN" "$@"; fi ;;
    esac
  done
}
