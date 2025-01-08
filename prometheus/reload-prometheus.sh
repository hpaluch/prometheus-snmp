#!/bin/bash
set -xeuo pipefail
sudo promtool check config /etc/prometheus/prometheus.yml
sudo amtool check-config   /etc/prometheus/alertmanager.yml
sudo systemctl restart prometheus prometheus-alertmanager
exit 0
