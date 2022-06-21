sudo systemctl enable --now cockpit.socket

sudo firewall-cmd --permanent --add-port=8080/tcp

echo [Unit]>>/etc/systemd/system/qbittorrent.service
Description=qBittorrent-nox service>/etc/systemd/system/qbittorrent.service
Wants=network-online.target>/etc/systemd/system/qbittorrent.service
After=network-online.target nss-lookup.target>/etc/systemd/system/qbittorrent.service

[Service]>/etc/systemd/system/qbittorrent.service
Type=exec>/etc/systemd/system/qbittorrent.service
Restart=always>/etc/systemd/system/qbittorrent.service
RestartSec=1>/etc/systemd/system/qbittorrent.service
User=adner>/etc/systemd/system/qbittorrent.service
UMask=0000>/etc/systemd/system/qbittorrent.service
ExecStart=/usr/bin/qbittorrent-nox>/etc/systemd/system/qbittorrent.service

[Install]>/etc/systemd/system/qbittorrent.service
WantedBy=multi-user.target>/etc/systemd/system/qbittorrent.service
