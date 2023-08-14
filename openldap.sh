#!/bin/bash
sudo dnf install openldap-servers -y
sudo chown -R ldap:ldap /var/lib/ldap
