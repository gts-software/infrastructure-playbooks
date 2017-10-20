#!/bin/bash
set -e

set-policy 4,6 filter INPUT DROP
set-policy 4,6 filter FORWARD DROP
set-policy 4,6 filter OUTPUT ACCEPT

append-rule 4,6 filter INPUT -i lo -j ACCEPT

append-rule 4   filter INPUT -p icmp -m icmp --icmp-type 3/4 -j ACCEPT
append-rule 4   filter INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT
append-rule 4   filter INPUT -p icmp -m icmp --icmp-type 11 -j ACCEPT

append-rule 4,6 filter INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

append-rule 4,6 filter INPUT -p tcp -m tcp --dport 22 -j ACCEPT
