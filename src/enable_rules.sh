#!/bin/bash
read -r -p "Do you want enable Community and Emerging Rules ? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
echo "# Community and Emerging Rules enabled" >> /etc/snort/snort.conf
for x in $(ls -l /etc/snort/rules/emerging-*.rules | awk '{print $9}'); do echo "include $x" >> /etc/snort/snort.conf ; done
echo "include /etc/snort/rules/community.rules" >> /etc/snort/snort.conf
sudo systemctl restart snort barnyard2
echo "Community and Emerging Rules enabled"
        ;;
    *)
        exit
        ;;
esac
