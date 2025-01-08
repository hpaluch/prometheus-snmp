#!/bin/bash
# ee-setup-prometheus-am.sh - setup Prometheus with Alert Manager
set -euo pipefail

d=$(dirname $0)

# packages for Prometheus and Alert Manager
declare -a pkgs=( prometheus prometheus-alertmanager )
declare -a missing_pkgs=( )
for i in "${pkgs[@]}"
do
	dpkg -s "$i" > /dev/null 2>&1 || missing_pkgs+=("$i")
done
[ ${#missing_pkgs[@]}  -eq 0 ] || {
	echo "Installing ${#missing_pkgs[@]} packages: ${missing_pkgs[@]}"
	sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "${missing_pkgs[@]}"
}

( cd $d/prometheus
  sudo cp -iv *.yml /etc/prometheus/
  sudo mkdir -p /etc/prometheus/rules
  sudo cp -iv rules/*.rules /etc/prometheus/rules/
)

set -x
$d/prometheus/reload-prometheus.sh
set +x
exit 0

