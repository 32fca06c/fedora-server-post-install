#!/bin/bash
sudo dnf install certbot python-certbot-nginx -y
sudo certbot --nginx -d adner.ddns.net -d adner.ru
sudo nginx -s stop
