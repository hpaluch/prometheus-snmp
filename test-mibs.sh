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
	echo >&2
	"$@"
}

# test scalar MIBs
echo "* Testing scalar MIB(s)..."
# NOTE: HOST-RESROUCES-MIB is well supported on both Linux and plain Windows SNMP service:
for mib in HOST-RESOURCES-MIB::hrSystem
do
	verbose_cmd snmpwalk -Os $cmd_common $mib | tee $tmp
	# 'wc -l' prints: COUNTER FILENAME
	lines=$(wc -l $tmp | awk '{print $1}')
	min_lines=1
	[ $lines -ge $min_lines ] || {
		echo "ERROR: Got $lines lines for MIB $mib, but expected at least $min_lines" >&2
		exit 1
	}
	echo "OK (exp min lines $min_lines, got lines $lines)"
done

# test tables - Disks (dskTable), Load Averages (laTable), Network interfaces (ifTable):
echo
echo  "* Testing table MIB(s)..."
# these tables are supported by UCD SNMP only (Unix)
declare -a ucd_tables=(UCD-SNMP-MIB::ucdavis.dskTable UCD-SNMP-MIB::ucdavis.laTable IF-MIB::ifTable)
# hrTables are supported by both UCD SNMP and Windows
declare -a hr_tables=(HOST-RESOURCES-MIB::hrStorageTable HOST-RESOURCES-MIB::hrDeviceTable
	HOST-RESOURCES-MIB::hrProcessorTable HOST-RESOURCES-MIB::hrNetworkTable HOST-RESOURCES-MIB::hrFSTable)
for mib in "${ucd_tables[@]}" "${hr_tables[@]}"
do
	verbose_cmd snmptable -Cb $cmd_common $mib | tee $tmp
	# 'wc -l' prints: COUNTER FILENAME
	lines=$(wc -l $tmp | awk '{print $1}')
	min_lines=4
	[ "$lines" -ge $min_lines ] || {
		echo "ERROR: Got $lines lines for MIB $mib, but expected at least $min_lines" >&2
		exit 1
	}
	echo "OK (minimum lines $min_lines, got lines $lines)"
done
echo "OK: All tests passed"
exit 0
