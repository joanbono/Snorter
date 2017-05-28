#!/bin/bash
echo "# Community and Emerging Rules enabled" >> /etc/snort/snort.conf
for x in $(ls -l /etc/snort/rules/emerging-*.rules | awk '{print $9}'); do echo "include $x" >> /etc/snort/snort.conf ; done
echo "include /etc/snort/rules/community.rules" >> /etc/snort/snort.conf
sudo systemctl restart snort barnyard2
