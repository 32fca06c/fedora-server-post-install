echo fastestmirror=True>>/etc/dnf/dnf.conf
echo max_parallel_downloads=20>>/etc/dnf/dnf.conf

echo [Unit]>/etc/systemd/system/qbittorrent.service
echo Description=qBittorrent-nox service>>/etc/systemd/system/qbittorrent.service
echo Wants=network-online.target>>/etc/systemd/system/qbittorrent.service
echo After=network-online.target nss-lookup.target>>/etc/systemd/system/qbittorrent.service
echo >>/etc/systemd/system/qbittorrent.service
echo [Service]>>/etc/systemd/system/qbittorrent.service
echo Type=exec>>/etc/systemd/system/qbittorrent.service
echo Restart=always>>/etc/systemd/system/qbittorrent.service
echo RestartSec=1>>/etc/systemd/system/qbittorrent.service
echo User=adner>>/etc/systemd/system/qbittorrent.service
echo UMask=0000>>/etc/systemd/system/qbittorrent.service
echo ExecStart=/usr/bin/qbittorrent-nox>>/etc/systemd/system/qbittorrent.service
echo >>/etc/systemd/system/qbittorrent.service
echo [Install]>>/etc/systemd/system/qbittorrent.service
echo WantedBy=multi-user.target>>/etc/systemd/system/qbittorrent.service
systemctl daemon-reload
systemctl start qbittorrent
systemctl enable qbittorrent
mkdir ~/.config/qBittorrent/ssl
cd ~/.config/qBittorrent/ssl
openssl req -new -x509 -nodes -out server.crt -keyout server.key

curl -sSL https://repo.45drives.com/setup | sudo bash
dnf install cockpit-file-sharing cockpit-navigator
