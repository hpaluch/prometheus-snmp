#!/bin/bash
# test-mibs.sh - test SNMP access to monitored MIBs
set -ueo pipefail

tmp=`mktemp`
trap "rm -f -- $tmp" EXIT
cmd_common="-c public -v 1 localhost"

function verbose_cmd
{
	echo >&2
	echo "\$ $@"  >&2
	"$@"
}

# test scalar MIBs
for mib in DISMAN-EVENT-MIB::sysUpTimeInstance
do
	verbose_cmd snmpwalk -Os $cmd_common $mib | tee $tmp
	# 'wc -l' prints: COUNTER FILENAME
	lines=$(wc -l $tmp | awk '{print $1}')
	exp_lines=1
	[ "$lines" -eq $exp_lines ] || {
		echo "ERROR: Got $lines lines for MIB $mib, but expected $exp_lines" >&2
		exit 1
	}
	echo "OK (exp lines $exp_lines, got lines $lines)"
done

# test tables - Disks (dskTable), Load Averages (laTable), Network interfaces (ifTable):
for mib in UCD-SNMP-MIB::ucdavis.dskTable UCD-SNMP-MIB::ucdavis.laTable IF-MIB::ifTable
do
	verbose_cmd snmptable -Cb $cmd_common $mib | tee $tmp
	# 'wc -l' prints: COUNTER FILENAME
	lines=$(wc -l $tmp | awk '{print $1}')
	min_lines=4
	[ "$lines" -ge $exp_lines ] || {
		echo "ERROR: Got $lines lines for MIB $mib, but expected at least $exp_lines" >&2
		exit 1
	}
	echo "OK (minimum lines $min_lines, got lines $lines)"
done
echo "OK: All tests passed"
exit 0
