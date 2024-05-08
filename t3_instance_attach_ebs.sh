#!/bin/bash
#Create dir and mount EBS
sudo mkdir /data
sudo mkfs -t xfs /dev/nvme1n1
sudo mount /dev/nvme1n1 /data
#Add auto mount
ebs_uuid=$(sudo blkid -s UUID -o value /dev/nvme1n1)
echo "UUID=$ebs_uuid  /data  xfs  defaults,nofail  0  2" | sudo tee -a /etc/fstab