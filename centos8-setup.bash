#!/usr/bin/env bash
# This script sets up CentOS Stream 8 to be usable in Azure.
# It, mostly, follows the reference provided but, also, improves the procedure a bit.
#
# Reference: https://blog.hildenco.com/2020/07/how-to-create-centos-vm-on-azure.html

# step 
cat << 'EOF' > /etc/default/networking
NETWORKING=yes
HOSTNAME=localhost.localdomain

EOF

# step 
cat << 'EOF' > /etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE=eth0
ONBOOT=yes
BOOTPROTO=dhcp
TYPE=Ethernet
USERCTL=no
PEERDNS=yes
IPV6INIT=no
NM_CONTROLLED=no

EOF

# step     Modify udev rules to avoid generating static rules for the Ethernet interface(s)
ln -s /dev/null /etc/udev/rules.d/75-persistent-net-generator.rules

# step 
dnf -y upgrade

# step Modifying GRUB
grubby \
	--update-kernel=ALL \
	--remove-args='rhgb quiet crashkernel=1G-4G:192M,4G-64G:256M,64G-:512M' \
	--args='rootdelay=300 console=ttyS0 earlyprintk=ttyS0 net.ifnames=0'

grub2-mkconfig -o /boot/grub2/grub.cfg

# step Installing the Azure Linux Client
dnf -y install python-pyasn1 WALinuxAgent --nobest
systemctl enable waagent

# step 12
dnf -y install cloud-init cloud-utils-growpart gdisk hyperv-daemons

## Configure waagent for cloud-init
sed -i 's/Provisioning.UseCloudInit=n/Provisioning.UseCloudInit=y/g' /etc/waagent.conf
sed -i 's/Provisioning.Enabled=y/Provisioning.Enabled=n/g' /etc/waagent.conf
sed -i 's/# AutoUpdate.Enabled=y/AutoUpdate.Enabled=y/g' /etc/waagent.conf
sed -i 's/ResourceDisk.Format=y/ResourceDisk.Format=n/g' /etc/waagent.conf
sed -i 's/ResourceDisk.EnableSwap=y/ResourceDisk.EnableSwap=n/g' /etc/waagent.conf

# ResourceDisk.Format=y
# ResourceDisk.Filesystem=ext4
# ResourceDisk.MountPoint=/mnt/resource
# ResourceDisk.EnableSwap=y
# ResourceDisk.SwapSizeMB=4096    ## setting swap to 4Gb

cat << 'EOF' >> /etc/cloud/cloud.cfg.d/05_logging.cfg
## This tells cloud-init to redirect its stdout and stderr to
## 'tee -a /var/log/cloud-init-output.log' so the user can see output
## there without needing to look on the console.
output: {all: '| tee -a /var/log/cloud-init-output.log'}

EOF


# step 
rm -rf /root/azure-centos9-image
rm -f /root/.ssh/known-hosts
yum erase git-core -y
rm -f /var/log/waagent.log
cloud-init clean
waagent -force -deprovision+user
rm -f /root/.bash_history
export HISTSIZE=0
systemctl  poweroff
