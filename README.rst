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

Installation
############
First, you need to deploy a minimal CentOS Stream 9 image. I did not use the OpenStack images (GenericCloud) or anything of the
sorts. I used the latest boot iso:

    http://mirror.stream.centos.org/9-stream/BaseOS/x86_64/iso/CentOS-Stream-9-latest-x86_64-boot.iso

Make a minimal installation. A few requirements:

* The drive type should be raw.
* The drive size should be as small as possible. I used 5 GiB
* When partitioning, just create a regular set of partitions (/boot and /), no swap, no home and no LVM please.
* Do not create a regular user.

Setup
#####
After you finish the installation, login as root and run the setup script. You can just make it executable and execute it if you
prefer.

Otherwise, make sure you run every command.

The script will poweroff the machine. It should remove all keys and history.

Drive resize
############
Next, we need to resize the drive to Azure's specifications. For this, we use the resize script. The script requires the path to the
image. It will only calculate and print the commands that need to be ran.

Once you convert and resize the drive, you just need to upload it into a container and deploy it from there. You should be able to
follow the steps outlined here:

    https://www.ibm.com/docs/en/sva/9.0.6?topic=mas-uploading-azure-compliant-vhd-azure-creating-azure-image

I couldn't find these instructions in Azure's documentation. They insist on one using their CLI tool.

