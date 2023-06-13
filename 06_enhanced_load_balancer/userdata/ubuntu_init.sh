#!/bin/bash
# @sacloud-once
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
# @sacloud-text maxlen=18 masquerade_nw "ETH1 NETWORK(*.*.*.*/*)"

SUDO_NOPASS=@@@sudo_nopass@@@	  # yes
ETH1_IP=@@@eth1_ip@@@ 	      	  # *.*.*.*/**
UPDATE=@@@update@@@ 	      	  # yes
FIREWALL=@@@firewall@@@       	  # no
LOOPBACK_IP=@@@loopback_ip@@@ 	  # *.*.*.*
HTTPD=@@@httpd@@@		  # yes
MASQUERADE=@@@masquerade@@@       # yes
MASQUERADE_NW=@@@masquerade_nw@@@ # *.*.*.*/**

function nonpass_sudo() {
  if [ "$SUDO_NOPASS" == "yes" ]; then 
    USER=ubuntu
    echo "$USER ALL=(ALL) NOPASSWD: ALL"> /etc/sudoers.d/$USER
  fi
}
nonpass_sudo

function setup_eth1() {
  IP=$ETH1_IP
  FILE=/etc/netplan/02-netcfg.yaml
  if [ "$IP" == "" ]; then return 0; fi
  if [ -f $FILE ]; then
    return 0;
  fi
cat <<__EOF__ >> $FILE
network:
  ethernets:
    eth1:
      addresses:
        - $IP
      dhcp4: 'no'
      dhcp6: 'no'
  renderer: networkd
  version: 2
__EOF__
  netplan apply
}
setup_eth1

function init_loopback() {
  IP=$LOOPBACK_IP
  FILE=/etc/netplan/lo-netcfg.yaml
  if [ "$IP" == "" ]; then return 0; fi
  if [ -f $FILE ]; then
    return 0;
  fi
cat <<__EOF__ >> $FILE
network:
  version: 2
  renderer: networkd
  ethernets:
    lo:
      match:
        name: lo
      addresses: [ $IP/32 ]
__EOF__
  netplan apply

  FILE=/etc/sysctl.d/99-loopback.conf
  if [ -f $FILE ]; then
    return 0;
  fi
  echo "net.ipv4.conf.all.arp_ignore = 1" > $FILE 
  echo "net.ipv4.conf.all.arp_announce = 2" >> $FILE
  sysctl -p
}
init_loopback

function disable_firewalld() {
  if [ "$FIREWALL" == "no" ]; then
    ufw disable
  fi
}
disable_firewalld

function init_masquerade() {
  if [ "$MASQUERADE" != "yes" ]; then return 0; fi
  if [ "$MASQUERADE_NW" == "" ]; then return 0; fi
  grep -q '^net/ipv4/ip_forward=1' /etc/ufw/sysctl.conf && echo "y" | ufw enable && return 0;
  ufw default allow incoming
  ufw default allow outgoing
  ufw default allow forward
  sed -i -e 's/^#net\/ipv4\/ip_forward=1$/net\/ipv4\/ip_forward=1/' /etc/ufw/sysctl.conf

cat <<__EOF__ >> /etc/ufw/before.rules
*nat
:POSTROUTING ACCEPT [0:0]
:PREROUTING ACCEPT [0:0]
-F
-A POSTROUTING -s $MASQUERADE_NW -o eth0 -j MASQUERADE
COMMIT
__EOF__
  
  ufw disable && echo "y" | ufw enable
}
init_masquerade

function start_update() {
  if [ "$UPDATE" == "yes" ]; then
    apt update
    apt -y upgrade
  fi
}
start_update

function install_httpd() {
  systemctl list-unit-files | grep -q "apache2" && return 0;
  if [ "$HTTPD" == "yes" ]; then
    apt update
    apt install apache2 -y
    systemctl enable apache2
    systemctl start apache2
    hostname > /var/www/html/index.html
  fi
}
install_httpd

