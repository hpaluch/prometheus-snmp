#!/bin/bash
set -xeuo pipefail
cd $(dirname $0)
prometheus-snmp-generator generate
sudo cp -v generator.yml snmp.yml /etc/prometheus/
sudo systemctl restart prometheus-snmp-exporter
exit 0
