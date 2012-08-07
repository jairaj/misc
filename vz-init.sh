#!/bin/bash
clear
img_url=http://download.openvz.org/template/precreated/centos-6-x86_64.tar.gz

sysinfo()
{
clear
echo "***************************"
echo "* OpenVz CentOS Installer *"
echo "***************************"
OS_REL=`cat /etc/issue | grep -i "Release"`
MEM_TOT=`cat /proc/meminfo | grep -i memtotal | awk '{print $2}'`
PROC_TOT=`cat /proc/cpuinfo | grep processor | wc -l`

echo ""
echo "System Configuration"
echo "********************"
echo "OS Release     : ${OS_REL}"
echo "Total Memory   : ${MEM_TOT} kB"
echo "Processor      : ${PROC_TOT} Core"
echo "*********************"
echo ""
}

sysinfo
echo "The installer is now ready to setup this node as an OpenVz host."
echo "Following actions would be performed in the next steps :"
echo "1. Download and install OpenVz Kernel packages and addon utilities"
echo "2. SELinux will be disables"
echo "3. Sysctl.conf will be modified"
echo "4. Node will be rebooted with OpenVz Kernel"
echo ""

echo "Are you sure you want to continue with the setup?"
echo "Press ENTER to continue or CTRL+C to break:"
read response

sysinfo
echo "1. Disabling SELinux        : ..."
echo ""
setenforce 0
echo 0 > /selinux/enforce
sed -i 's/^SELINUX=/#SELINUX=/g' /etc/selinux/config
echo 'SELINUX=disabled' >> /etc/selinux/config
sestatus

sleep 2
sysinfo 
echo "1. Disabling SELinux         : Done"
echo "2. Update YUM configs        : ..."
echo ""
cd /etc/yum.repos.d
curl --silent -O http://download.openvz.org/openvz.repo
rpm --import http://download.openvz.org/RPM-GPG-Key-OpenVZ


sleep 2
sysinfo 
echo "1. Disabling SELinux         : Done"
echo "2. Update YUM configs        : Done"
echo "3. Installing VzKernel       : ..."
echo ""
yum -y install vzkernel.x86_64

sleep 2
sysinfo
echo "1. Disabling SELinux         : Done"
echo "2. Update YUM configs        : Done"
echo "3. Installing VzKernel       : Done"
echo "4. Installing VzTools        : ..."
echo ""
yum install -y vzctl vzquota 

sleep 2
sysinfo
echo "1. Disabling SELinux         : Done"
echo "2. Update YUM configs        : Done"
echo "3. Installing VzKernel       : Done"
echo "4. Installing VzTools        : Done"
echo "4. Updating sysctl & vz.conf : ..."
echo ""

cat << EOF > /etc/sysctl.conf 
net.ipv4.ip_forward=1
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.lo.accept_source_route = 0
net.ipv4.conf.eth0.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.lo.rp_filter = 1
net.ipv4.conf.eth0.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.lo.accept_redirects = 0
net.ipv4.conf.eth0.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.log_martians = 0
net.ipv4.conf.lo.log_martians = 0
net.ipv4.conf.eth0.log_martians = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.lo.accept_source_route = 0
net.ipv4.conf.eth0.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.lo.rp_filter = 1
net.ipv4.conf.eth0.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.lo.accept_redirects = 0
net.ipv4.conf.eth0.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
kernel.sysrq = 1
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_keepalive_time = 1800
net.ipv4.tcp_window_scaling = 0
net.ipv4.tcp_sack = 0
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_syncookies = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.conf.all.log_martians = 1
net.ipv4.tcp_max_syn_backlog = 1024
net.ipv4.tcp_max_tw_buckets = 1440000
net.ipv4.conf.default.proxy_arp = 0
net.ipv4.conf.default.send_redirects = 1
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.forwarding = 1
EOF

sysctl -p > /dev/null

sed -i 's/^NEIGHBOUR_DEVS=.* /NEIGHBOUR_DEVS=all/g' /etc/vz/vz.conf

sleep 2
sysinfo
echo "1. Disabling SELinux         : Done"
echo "2. Update YUM configs        : Done"
echo "3. Installing VzKernel       : Done"
echo "4. Installing VzTools        : Done"
echo "4. Updating sysctl & vz.conf : Done"
echo "5. Fetch CentOs VZ Templates : ..."
echo ""
cd /vz/template/cache
[ -f /vz/template/cache/centos-6-x86_64.tar.gz ] && echo "Template: Centos-6-x86_64.tar.gz Found. Skipping download" || curl -O ${img_url}

sleep 2
sysinfo
echo "1. Disabling SELinux         : Done"
echo "2. Update YUM configs        : Done"
echo "3. Installing VzKernel       : Done"
echo "4. Installing VzTools        : Done"
echo "4. Updating sysctl & vz.conf : Done"
echo "5. Fetch CentOs VZ Templates : Done"
echo "6. Reboot"
echo ""
echo "Press ENTER to REBOOT the node or CTRL+C to break"
read response
reboot
