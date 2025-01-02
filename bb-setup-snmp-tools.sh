#!/bin/bash
# bb-setup-snmp-tools.sh - setup SNMP Client Tools
set -xeuo pipefail

dir=$(dirname $0)

[ -x /usr/bin/snmpget ] || sudo apt-get install snmp

## Installing MIBs - requires non-free repos - must be careful to handle non-free-firmware correctly
# WARNING! This is NOT idempotent
conf=/etc/apt/sources.list
# It is not possible to use '-w' (word) switch because dash (-) is not considered word
grep -qE '\snon-free\s*$' $conf || {
	sudo sed -i -e '/^deb/s/$/ non-free/' $conf
	sudo apt-get update
}

[ -x /usr/bin/download-mibs ] || sudo apt-get install snmp-mibs-downloader

# Enable mibs in configuration
conf=/etc/snmp/snmp.conf
# 1st comment out 'mibs :'
if grep -E '^mibs\s+:' $conf; then
	sudo sed -i -e 's/^\(mibs .*\)/#\1/' $conf
fi
# 2nd uncomment mibdirs
grep -E '^mibdirs\s' $conf || {
	sudo sed -i -e 's/# *\(mibdirs *\)/\1/' $conf
}

exit 0

