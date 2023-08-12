#!/bin/bash
# Variables
EMAIL=
DOMAIN1=
DOMAIN2=
# Certbot
sudo dnf install certbot python-certbot-nginx -y
sudo certbot --nginx -d $DOMAIN1 -d $DOMAIN2 --non-interactive --agree-tos -m $EMAIL
sudo nginx -s stop
