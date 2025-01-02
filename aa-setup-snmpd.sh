#!/bin/bash
# aa-setup-snmpd.sh - setup SNMP Daemon
set -xeuo pipefail

dir=$(dirname $0)

[ -f /usr/sbin/snmpd ] || sudo apt-get install snmpd

src_conf=$dir/snmpd/local.conf
dest_conf=/etc/snmp/snmpd.conf.d/local.conf

if [ -f $dest_conf ]; then
	diff $src_conf $dest_conf || {
		echo "WARNING"'!'" Configuration file is different" >&2
		exit 1
	}
else
	echo "File '$dest_conf' does not exist, copying..."
	sudo cp -v $src_conf $dest_conf
	sudo systemctl restart snmpd
fi

exit 0

