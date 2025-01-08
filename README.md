# Monitoring SNMP targets with Prometheus

Standalone example how to use Prometheus and Alert Manager to
monitor machines using SNMP protocol.

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

6. Optional (but needed for default setup): setup local SMTP delivery Postfix server and send test e-mails using
   (used to deliver alerts without need for real SMTP relay):

   ```shell
   ./dd-setup-local-email.sh
   ```

   Do NOT run above script on production SMTP server (!) - it forces local-delivery of all e-mails!

7. Install and configure Prometheus and Alert Manager with:
   ```shell
   ./ee-setup-prometheus-am.sh
   ```

   - You can find Prometheus UI on `http://IP:9090`
   - WARNING! Standalone Alert Manager UI is on `http://IP:9093`, but it requires compilation with script
     `/usr/share/prometheus/alertmanager/generate-ui.sh` - however that script is broken.
     You can find more information at https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1067469
     and pointer to fixed script at https://salsa.debian.org/go-team/packages/prometheus-alertmanager/-/blob/51802d88957fc08bf13daab426e59718fadcf66e/debian/generate-ui.sh
     Please note that even with fixed script the standalone Alert Manager UI is half-broken.
     I recommend rather use Prometheus Alert view on `http://IP:9090/classic/alerts`

   NOTE: It is strongly recommended to limit UI access (there is no password or any other form
   of authentication) - for example by limiting it to listen on `localhost` only and possibly
   using reverse-proxy server with authentication to protect access.
