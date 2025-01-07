#!/bin/bash
# dd-setup-local-email.sh - setup local e-mail delivery
set -euo pipefail

# debconf-utils - contains debconf-set-selections, - special handling
p=debconf-utils
dpkg -s "$p" > /dev/null 2>&1 || sudo apt-get install -y "$p"

# prepare postfix configuration, from: https://serverfault.com/a/1095251
echo "postfix postfix/mailname string `hostname -f`" | sudo debconf-set-selections
echo "postfix postfix/main_mailer_type string 'Local only'" | sudo debconf-set-selections


# postfix - SMTP server, alpine - full-screen mail client, bash-mailx - CLI mail client, crudini - editor ini
declare -a pkgs=( postfix alpine bsd-mailx crudini)
declare -a missing_pkgs=( )
for i in "${pkgs[@]}"
do
	dpkg -s "$i" > /dev/null 2>&1 || missing_pkgs+=("$i")
done
[ ${#missing_pkgs[@]}  -eq 0 ] || {
	echo "Installing ${#missing_pkgs[@]} packages: ${missing_pkgs[@]}"
	sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "${missing_pkgs[@]}"
}

# Now tricky stuff - reconfiguring Postfix for local-only delivery
declare -A cfg=( ["mydestination"]="static:all" ["default_transport"]="error:outside mail is not deliverable" )
cfg+=( ["luser_relay"]="$USER" ["local_recipient_maps"]="" ) 

f=/etc/postfix/main.cf

for k in "${!cfg[@]}"
do
	v="${cfg["$k"]}"
	sudo crudini --set $f "" "$k" "$v"
done
echo "All foreign mail will be delivered to local user '$USER'"

# Applying changesw
sudo postfix upgrade-configuration
sudo postfix check
sudo systemctl restart postfix

echo "Sending test e-mail $USER -> root"
echo "Test content" | mail -r "$USER" -s "From $USER to root" -- root
echo "Sending test e-mail root -> $USER"
echo "Test content" | sudo mail -r root -s "From root to $USER" -- $USER
echo "Use 'alpine' or 'mail' command as user '$USER' or 'root' to see delivered e-mails."
exit 0

