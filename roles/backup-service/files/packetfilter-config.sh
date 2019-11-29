#!/bin/bash
set -e

append-rule 4,6 filter INPUT -p tcp -m tcp --dport 80 -j ACCEPT
