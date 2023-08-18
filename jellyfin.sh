#!/bin/bash
sudo dnf install jellyfin-server jellyfin-web intel-media-driver -y
sudo systemctl enable --now jellyfin.service
