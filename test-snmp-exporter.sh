#!/bin/bash
set -xueo pipefail
declare -a targets
if [ $# -gt 0 ]; then
	targets=( "${@}" )
else
	targets=( "127.0.0.1" )
fi
for t in $targets
do
	set -x
	curl -fsS 127.0.0.1:9116/snmp?target=$t | grep -v '^#'
	set +x
done

exit 0
