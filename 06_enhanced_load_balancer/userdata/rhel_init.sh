#!/bin/bash
# @sacloud-once
# @sacloud-text maxlen=36 user_name "Default USER NAME"
# @sacloud-radios-begin default=yes sudo_nopass "Default USER SUDONOPASS"
#     yes "yes"
#     no "no"
# @sacloud-radios-end
# @sacloud-text maxlen=18 eth1_ip "ETH1 IPADDRESS(*.*.*.*/*)"
# @sacloud-radios-begin default=no update "OS UPDATE"
#     yes "yes"
#     no "no"
# @sacloud-radios-end
# @sacloud-radios-begin default=no firewall "FIREWALL ENABLE"
#     yes "yes"
#     no "no"
# @sacloud-radios-end
# @sacloud-text maxlen=15 loopback_ip "LOOPBACK IPADDRESS(*.*.*.*)"
# @sacloud-radios-begin default=no httpd "HTTPD INSTALL"
#     yes "yes"
#     no "no"
# @sacloud-radios-end
# @sacloud-radios-begin default=no masquerade "IP MASQUERADE"
#     yes "yes"
#     no "no"
# @sacloud-radios-end

USER=@@@user_name@@@            # username
SUDO_NOPASS=@@@sudo_nopass@@@	# yes (= create user)
ETH1_IP=@@@eth1_ip@@@ 	      	# *.*.*.*/**
UPDATE=@@@update@@@ 	      	# yes
FIREWALL=@@@firewall@@@       	# no
LOOPBACK_IP=@@@loopback_ip@@@ 	# *.*.*.*
HTTPD=@@@httpd@@@		# yes
MASQUERADE=@@@masquerade@@@     # yes

#-- 8/9系の OS は通信が可能になるまで少し時間がかかる
if [ $(grep -c "release 8" /etc/redhat-release) -eq 1 ] || [ $(grep -c "release 9" /etc/redhat-release) -eq 1 ] ;then
	sleep 30
else
	exit 0
fi

function create_user() {
  if [ "$USER" == "" ]; then return 0; fi
  if [ "$SUDO_NOPASS" != "yes" ]; then return 0; fi
  id $USER > /dev/null 2>&1 && return 0;
  useradd $USER
  TEST=`cat /etc/shadow | grep root | awk -F':' '{print $2}'`
  sed -i -e "s|^$USER:!!|$USER:$TEST|" /etc/shadow
  mkdir /home/$USER/.ssh
  cp /root/.ssh/authorized_keys /home/$USER/.ssh/
  chown -R $USER:$USER /home/$USER/.ssh/
  chmod 700 /home/$USER/.ssh/
  chmod 600 /home/$USER/.ssh/authorized_keys
  echo "$USER ALL=(ALL) NOPASSWD: ALL"> /etc/sudoers.d/$USER
}
create_user

function setup_eth1() {
  IP=$ETH1_IP
  if [ "$IP" == "" ]; then return 0; fi
  ip a s | grep -q $IP && return 0;
  nmcli con mod "System eth1" \
  ipv4.method manual \
  ipv4.address $IP \
  connection.autoconnect "yes" \
  ipv6.method "disabled"
  nmcli con down "System eth1"; nmcli con up "System eth1"
}
setup_eth1

function init_loopback() {
  IP=$LOOPBACK_IP
  if [ "$IP" == "" ]; then return 0; fi
  nmcli connection add type dummy ifname vip01 ipv4.method manual ipv4.addresses $IP/32 ipv6.method ignore
  grep -q "net.ipv4.conf.all.arp_ignore = 1" /etc/sysctl.conf && return 0;
  echo "net.ipv4.conf.all.arp_ignore = 1" >> /etc/sysctl.conf
  echo "net.ipv4.conf.all.arp_announce = 2" >> /etc/sysctl.conf
  sysctl -p
}
init_loopback

function disable_firewalld() {
  if [ "$FIREWALL" == "no" ]; then
    systemctl stop firewalld
    systemctl disable firewalld
  fi
}
disable_firewalld

function init_masquerade() {
  if [ "$MASQUERADE" != "yes" ]; then return 0; fi
  systemctl enable firewalld
  systemctl start firewalld
  nmcli connection modify "System eth1" connection.zone trusted
  nmcli connection modify "System eth0" connection.zone trusted
  firewall-cmd --zone=trusted --add-masquerade --permanent
  firewall-cmd --reload
}
init_masquerade

function start_update() {
  if [ "$UPDATE" == "yes" ]; then
    dnf -y update
  fi
}
start_update

function install_httpd() {
  systemctl list-unit-files | grep -q "httpd" && return 0;
  if [ "$HTTPD" == "yes" ]; then
    dnf install -y httpd mod_ssl
    systemctl enable httpd
    systemctl start httpd
    hostname > /var/www/html/index.html
  fi
}
install_httpd

