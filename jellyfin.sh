#!/bin/bash
sudo dnf install jellyfin-server jellyfin-web -y
sudo systemctl enable --now jellyfin.service
