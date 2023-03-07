#!/bin/bash -e


#test -d /mnt/tmp || mkdir -m 1777 /mnt/tmp
#mount --bind /mnt/tmp /tmp
#echo " /mnt/tmp /tmp                    ext4    defaults,nodev,nosuid,noexec      1 2" >> /etc/fstab
#echo "/tmp /var/tmp none rw,noexec,nosuid,nodev,bind 0 0" >> /etc/fstab
#echo "tmpfs                   /dev/shm                tmpfs   defaults,nodev,nosuid,noexec        0 0" >> /etc/fstab

#cat /etc/fstab
#mount -o remount,noexec,nosuid,nodev /tmp
#mount -o rw,noexec,nosuid,nodev,bind /tmp/ /var/tmp/
#mount -o remount,noexec,nosuid,nodev /dev/shm

sudo yum install libselinux-python -y

cd /etc/modprobe.d
touch cis.conf
echo "install hfsplus /bin/true" >> /etc/modprobe.d/cis.conf
echo "install cramfs /bin/true" >> /etc/modprobe.d/cis.conf
echo "install hfs /bin/true" >> /etc/modprobe.d/cis.conf
echo "install udf /bin/true" >> /etc/modprobe.d/cis.conf
echo "install rds /bin/true" >> /etc/modprobe.d/cis.conf
echo "install tipc /bin/true" >> /etc/modprobe.d/cis.conf



#echo "blacklist cramfs" >> /etc/modprobe.d/blacklist
#echo "blacklist squashfs" >> /etc/modprobe.d/blacklist
#echo "blacklist hfs" >> /etc/modprobe.d/blacklist
#echo "blacklist hfsplus" >> /etc/modprobe.d/blacklist
#echo "blacklist udf" >> /etc/modprobe.d/blacklist
#echo "blacklist rds" >> /etc/modprobe.d/blacklist
#echo "blacklist tipc" >> /etc/modprobe.d/blacklist




echo "ExecStart=-/bin/sh -c '/sbin/sulogin; /usr/bin/systemctl --fail --no-block default'" >> /usr/lib/systemd/system/rescue.service
echo "ExecStart=-/bin/sh -c '/sbin/sulogin; /usr/bin/systemctl --fail --no-block default'" >> /usr/lib/systemd/system/emergency.service

# Ensure IP forwarding is disabled
#echo "net.ipv4.ip_forward = 0" >> /etc/sysctl.conf
#echo "net.ipv6.conf.all.forwarding = 0" >> /etc/sysctl.conf
#sysctl -w net.ipv4.ip_forward=0 
sysctl -w net.ipv6.conf.all.forwarding=0
#sysctl -w net.ipv4.route.flush=1
sysctl -w net.ipv6.route.flush=1

# Ensure source routed packets are not accepted
#echo "net.ipv4.conf.all.accept_source_route = 0 " >> /etc/sysctl.conf
#echo "net.ipv4.conf.default.accept_source_route = 0 " >> /etc/sysctl.conf
#echo "net.ipv6.conf.all.accept_ra = 0 " >> /etc/sysctl.conf
#echo "net.ipv6.conf.default.accept_ra = 0" >> /etc/sysctl.conf
#sysctl -w net.ipv4.conf.all.accept_source_route=0
#sysctl -w net.ipv4.conf.default.accept_source_route=0
#sysctl -w net.ipv6.conf.all.accept_source_route=0
#sysctl -w net.ipv6.conf.default.accept_source_route=0
#sysctl -w net.ipv4.route.flush=1
#sysctl -w net.ipv6.route.flush=1

#Ensure ICMP redirects are not accepted
#echo "net.ipv4.conf.all.accept_redirects = 0" >> /etc/sysctl.conf
#echo "net.ipv4.conf.default.accept_redirects = 0" >> /etc/sysctl.conf
#echo "net.ipv6.conf.all.accept_redirects = 0" >> /etc/sysctl.conf
#echo "net.ipv6.conf.default.accept_redirects = 0" >> /etc/sysctl.conf

#sysctl -w net.ipv4.conf.all.accept_redirects=0
#sysctl -w net.ipv4.conf.default.accept_redirects=0
#sysctl -w net.ipv6.conf.all.accept_redirects=0
#sysctl -w net.ipv6.conf.default.accept_redirects=0
#sysctl -w net.ipv4.route.flush=1
#sysctl -w net.ipv6.route.flush=1


#echo "net.ipv4.conf.all.secure_redirects = 0 " >> /etc/sysctl.conf
#echo "net.ipv4.conf.default.secure_redirects = 0" >> /etc/sysctl.conf
#sysctl -w net.ipv4.conf.all.secure_redirects=0 
#sysctl -w net.ipv4.conf.default.secure_redirects=0 
#sysctl -w net.ipv4.route.flush=1

#Ensure /etc/hosts.deny is configured
echo "ALL: ALL" >> /etc/hosts.deny

#Ensure loopback traffic is configured
#iptables -A INPUT -i lo -j ACCEPT
#iptables -A OUTPUT -o lo -j ACCEPT
#iptables -A INPUT -s 127.0.0.0/8 -j DROP 

#ip6tables -P INPUT DROP
#ip6tables -P OUTPUT DROP
#ip6tables -P FORWARD DROP

#ip6tables -A INPUT - i lo -j ACCEPT
#ip6tables -A OUTPUT -o lo -j ACCEPT
#ip6tables -A INPUT -s ::1 -j DROP

#Ensure permissions on all logfiles are configured
find -L /var/log -type f -exec chmod g-wx,o-rwx {} +

echo "Protocol 2" >> /etc/ssh/sshd_config 

echo "auth required pam_faillock.so preauth audit silent deny=5 unlock_time=900 " >> /etc/pam.d/password-auth
echo "auth [success=1 default=bad] pam_unix.so  " >> /etc/pam.d/password-auth
echo "auth [default=die] pam_faillock.so authfail audit deny=5 unlock_time=900 " >> /etc/pam.d/password-auth
echo "auth sufficient pam_faillock.so authsucc audit deny=5 unlock_time=900" >> /etc/pam.d/password-auth


echo "auth required pam_faillock.so preauth audit silent deny=5 unlock_time=900 " >> /etc/pam.d/system-auth
echo "auth [success=1 default=bad] pam_unix.so  " >> /etc/pam.d/system-auth
echo "auth [default=die] pam_faillock.so authfail audit deny=5 unlock_time=900 " >> /etc/pam.d/system-auth
echo "auth sufficient pam_faillock.so authsucc audit deny=5 unlock_time=900" >> /etc/pam.d/system-auth



#Ensure events that modify the system's network environment are collected
#Ensure system administrator actions (sudolog) are collected
echo "-a always,exit -F arch=b64 -S sethostname -S setdomainname -k system-locale " >> /etc/audit/rules.d/audit.rules
echo "-a always,exit -F arch=b32 -S sethostname -S setdomainname -k system-locale " >> /etc/audit/rules.d/audit.rules
echo "-w /etc/issue -p wa -k system-locale " >> /etc/audit/rules.d/audit.rules
echo "-w /etc/issue.net -p wa -k system-locale " >> /etc/audit/rules.d/audit.rules
echo "-w /etc/hosts -p wa -k system-locale " >> /etc/audit/rules.d/audit.rules
echo "-w /etc/sysconfig/network -p wa -k system-locale" >> /etc/audit/rules.d/audit.rules
echo "-w /var/log/sudo.log -p wa -k actions" >> /etc/audit/rules.d/audit.rules


#Ensure ICMP redirects are not accepted
