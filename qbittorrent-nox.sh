#/bin/bash
sudo dnf install qbittorrent-nox -y
sudo tee -a /etc/systemd/system/qbittorrent.service <<EOF
[Unit]
Description=qBittorrent-nox service
Wants=network-online.target
After=network-online.target nss-lookup.target

[Service]
Type=exec
Restart=always
RestartSec=1
User=adner
UMask=0000
ExecStart=/usr/bin/qbittorrent-nox

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable --now qbittorrent
