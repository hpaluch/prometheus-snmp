#!/bin/bash
# cc-setup-snmp-exporter.sh install Prometheus SNMP Exporter
set -xeuo pipefail

dir=$(dirname $0)

[ -x /usr/bin/prometheus-snmp-generator ] || sudo apt-get install prometheus-snmp-exporter
snmp-exporter/reload-snmp-exporter.sh

exit 0

