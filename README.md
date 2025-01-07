# Monitoring SNMP targets with Prometheus

> [!WARNING]
> Work in Progress...

Required OS: Debian 12 (I use it).

# Setup

> [!WARNING]
> Currently there are too wide rights specified under `/etc/snmp/snmpd.conf.d/local.conf`.
> It should be reduced to necessary tree only before going to production!

NOTE: 2 Scripts below will modify several important files under `/etc/` - please review
them before running.

1. Install SNMP Daemon (server) and enable access to MIBs:

   ```shell
   ./aa-setup-snmpd.sh
   ```

2. Install SNMP Client tools so we can test MIBs that we plan to monitor with:

   ```shell
   ./bb-setup-snmp-tools.sh
   ```

3. Now you should run script that will test that used MIBs really produce data with:

   ```shell
   ./test-mibs.sh
   ```
   
4. Install SNMP Exporter (gathers data via SNMP protocol and publish them as HTTP to Prometheus)
  
   ```shell
   ./cc-setup-snmp-exporter.sh
   ```

5. Verify that Exporter published SNMP data on HTTP backend with:

   ```shell
   ./test-snmp-exporter.sh
   ```
