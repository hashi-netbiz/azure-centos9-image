=======================
CentOS Stream 9 @ Azure
=======================

Description
-----------
This repo provides some scripts to be able to generate a customized CentOS Stream 9 image that is usable on the Azure cloud.

The scripts were developed on Fedora 36 so I will asume you're using that or something very similar. Also, that you understand the
use of libvirt/kvm/qemu in order to run these images.

Pre-requisites
--------------
Install the following:

* libvirt-daemon
* qemu-img
* virt-manager

Instructions
------------

1.0 Installation
############
Refer to the HyperV-centos-Install.doc document for the installation of
Hyper-V hypervisor on windows 10/11 and deployment of a minimal CentOS Stream 9 
virtual image. The follwing boot iso is used:

    http://mirror.stream.centos.org/9-stream/BaseOS/x86_64/iso/CentOS-Stream-9-latest-x86_64-boot.iso

Make a minimal installation. A few requirements:

* The drive type should be raw.
* The drive size should be as small as possible. I used 6 GiB
* When partitioning, just create a regular set of partitions (/boot and /), no swap, no home and no LVM please.
* Do not create a regular user.

2.0 Setup
#####
After you finish the installation, login as root and 
1. run the following command to install git:
    yum install git -y
2. clone the repository where installation scripts are kept e.g
   git clone https://github.com/$(your-repo)
3. make the setup script executable as follows:
    chmod +x azure-centos-setup.bash
4. Cd to the local repo folder and run the setup script as follows:
    ./azure-centos-setup.bash

The script will poweroff the machine. It should remove all keys and history.

3.0 Upload VM and create Image
############
The following document describes the process of uploading the newly created 
centos 9 stream virtual machine (x.vhd) to Azure Storage Container. A temporary
image is also created.

    https://www.ibm.com/docs/en/sva/9.0.6?topic=mas-uploading-azure-compliant-vhd-azure-creating-azure-image


4.0 Create a VM and from the temporary Image in section 3.0 above
############
SSH into the VM and install the Azure Linux Agent by running the commands below:
    dnf -y install python-pyasn1 WALinuxAgent --nobest
    systemctl enable waagent
    systemctl restart waagent

    waagent -force -deprovision+user    
    export HISTSIZE=0

5.0 Finally create a golden image from the modified VM in 4.0 above
############
for the creation of the golden centos 9 stream image, refer to the 
microsoft publication referenced below:

    https://learn.microsoft.com/en-us/azure/virtual-machines/capture-image-portal

The Golden image is to be based on the VM created in section 4.0 above.
