#!/bin/bash
set -e

# remove 'nvidia_gpu_exporter' service
echo "Stopping nvidia_gpu_exporter..."
systemctl stop nvidia_exporter.service
echo "nvida_exporter stopped."
echo "Removing nvidia_gpu_exporter..."
rm -rf /etc/systemd/system/nvidia_exporter.service
echo "nvida_exporter removed."
echo "Reloading daemon..."
systemctl daemon-reload

# remove user 'nvidia_exporter'
echo "Removing user 'nvidia_exporter'..."
userdel nvidia_exporter
echo "User nvidia_exporter removed."
