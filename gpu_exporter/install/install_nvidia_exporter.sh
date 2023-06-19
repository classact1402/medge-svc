#!/bin/bash
set -e

# check nvidia driver and utilities
driver_version=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader | cut -d. -f1)

if [[ -n $driver_version ]]; then
	if [[ $driver_version != "515" ]]; then
		echo "Remove nvidia drivier and utils"
		echo "apt purge nvidia-driver-$driver_version nvidia-utils-$driver_version"
		apt purge -y nvidia-driver-$driver_version nvidia-utils-$driver_version
		echo "Install nvidia-driver-515 and nvidia-utils-515"
		sudo apt install -y nvidia-driver-515 nvidia-utils-515
	fi
fi


# nvidia gpu exporter should be installed on a virtual machine.
echo ""
echo "#### Install Nvidia GPU Exporter ####"
wget https://github.com/utkuozdemir/nvidia_gpu_exporter/releases/download/v1.1.0/nvidia_gpu_exporter_1.1.0_linux_x86_64.tar.gz
tar -xvzf nvidia_gpu_exporter_1.1.0_linux_x86_64.tar.gz
mv nvidia_gpu_exporter /usr/local/bin
rm nvidia_gpu_exporter_1.1.0_linux_x86_64.tar.gz

echo ""
echo "#### Register Nvidia Exporter as Service ####"
useradd nvidia_exporter
chown nvidia_exporter:nvidia_exporter /usr/local/bin/nvidia_gpu_exporter
tee /etc/systemd/system/nvidia_exporter.service << EOF
[Unit]
Description=Nvidia Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=nvidia_exporter
Group=nvidia_exporter
Type=simple
ExecStart=/usr/local/bin/nvidia_gpu_exporter

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable nvidia_exporter.service
systemctl restart nvidia_exporter.service

