#!/bin/bash
# Title: Snorter.sh
# Description: Install automatically Snort + Barnyard2 + PulledPork
# Author: Joan Bono (@joan_bono)
# Version: 1.0.2
# Last Modified: jbono @ 20180104

RED='\033[0;31m'
ORANGE='\033[0;205m'
YELLOW='\033[0;93m'
GREEN='\033[0;32m'
CYAN='\033[0;96m'
BLUE='\033[0;34m'
VIOLET='\033[0;35m'
NOCOLOR='\033[0m'
BOLD='\033[1m'

function update_upgrade() {

	echo -ne "\n\t${CYAN}[i] INFO:${NOCOLOR} Updating and Upgrading repositories...\n\n"
	sudo apt-get update && sudo apt-get upgrade -y --force-yes

}

function snort_install() {

	echo -ne "\n\t${CYAN}[i] INFO:${NOCOLOR} Installing dependencies.\n\n"
	sudo apt-get install -y --force-yes build-essential libpcap-dev libpcre3-dev libdumbnet-dev bison flex zlib1g-dev git locate vim

	#Downloading DAQ and SNORT
	cd $HOME && mkdir snort_src && cd snort_src
	echo -ne "\n\t${CYAN}[i] INFO:${NOCOLOR} Downloading ${BOLD}$DAQ${NOCOLOR}.\n\n"
	wget --no-check-certificate -P $HOME/snort_src https://snort.org/downloads/snort/$DAQ.tar.gz
	echo -ne "\n\t${CYAN}[i] INFO:${NOCOLOR} Downloading ${BOLD}$SNORT${NOCOLOR}.\n\n"
	wget --no-check-certificate -P $HOME/snort_src https://snort.org/downloads/snort/$SNORT.tar.gz

	#Installing DAQ
	cd $HOME/snort_src/
	echo -ne "\n\t${CYAN}[i] INFO:${NOCOLOR} Installing ${BOLD}$DAQ${NOCOLOR}.\n\n"
	tar xvfz $DAQ.tar.gz
	mv $HOME/snort_src/daq-*/ $HOME/snort_src/daq
	cd $HOME/snort_src/daq
	./configure && make && sudo make install
	echo -ne "\n\t${GREEN}[+] INFO:${NOCOLOR} ${BOLD}$DAQ${NOCOLOR} installed successfully.\n\n"

	#Installing SNORT
	cd $HOME/snort_src
	echo -ne "\n\t${CYAN}[i] INFO:${NOCOLOR} Installing ${BOLD}$SNORT${NOCOLOR}.\n\n"
	tar xvfz $SNORT.tar.gz > /dev/null 2>&1
	rm -r *.tar.gz > /dev/null 2>&1
	mv snort-*/ snort
	cd snort
	./configure --enable-sourcefire && make && sudo make install
	echo -ne "\n\t${GREEN}[+] INFO:${NOCOLOR} ${BOLD}$SNORT${NOCOLOR} installed successfully.\n\n"
	cd ..

	sudo ldconfig
	sudo ln -s /usr/local/bin/snort /usr/sbin/snort

	#Adding SNORT user and group for running SNORT
	echo -ne "\n\t${CYAN}[i] INFO:${NOCOLOR} Adding user and group ${BOLD}SNORT${NOCOLOR}.\n\n"
	sudo groupadd snort
	sudo useradd snort -r -s /sbin/nologin -c SNORT_IDS -g snort
	sudo mkdir /etc/snort > /dev/null 2>&1
	sudo mkdir /etc/snort/rules > /dev/null 2>&1
	sudo mkdir /etc/snort/preproc_rules > /dev/null 2>&1
	sudo touch /etc/snort/rules/white_list.rules /etc/snort/rules/black_list.rules /etc/snort/rules/local.rules > /dev/null 2>&1
	sudo mkdir /var/log/snort > /dev/null 2>&1
	sudo mkdir /usr/local/lib/snort_dynamicrules > /dev/null 2>&1
	sudo chmod -R 5775 /etc/snort > /dev/null 2>&1
	sudo chmod -R 5775 /var/log/snort > /dev/null 2>&1
	sudo chmod -R 5775 /usr/local/lib/snort_dynamicrules > /dev/null 2>&1
	sudo chown -R snort:snort /etc/snort > /dev/null 2>&1
	sudo chown -R snort:snort /var/log/snort > /dev/null 2>&1
	sudo chown -R snort:snort /usr/local/lib/snort_dynamicrules > /dev/null 2>&1

	sudo cp ~/snort_src/snort/etc/*.conf* /etc/snort > /dev/null 2>&1
	sudo cp ~/snort_src/snort/etc/*.map /etc/snort > /dev/null 2>&1

	sudo sed -i 's/include \$RULE\_PATH/#include \$RULE\_PATH/' /etc/snort/snort.conf

	echo -ne "\n\t${CYAN}[i] INFO:${NOCOLOR} /var/log/snort and /etc/snort created and configurated.\n\n"
	sudo /usr/local/bin/snort -V
	echo -ne "\n\t${GREEN}[+] INFO:${NOCOLOR} ${BOLD}SNORT${NOCOLOR} is successfully installed and configurated!"

}

function snort_edit() {

	echo -ne "\n\t${YELLOW}[!] INFO:${NOCOLOR} Now it's time to edit the ${BOLD}SNORT${NOCOLOR} configuration file.\n\n"
	echo -ne "\n\t${CYAN}[i] INFO:${NOCOLOR} Add your ${BOLD}HOME_NET${NOCOLOR} address [Ex: 192.168.1.0/24]"
	echo -ne "\n\t${YELLOW}[!] WARNING:${NOCOLOR} Press ${BOLD}ENTER${NOCOLOR} to continue. "
	read -n 1 -s
	sudo vim /etc/snort/snort.conf -c "/ipvar HOME_NET"

	echo -ne "\n\t${CYAN}[i] INFO:${NOCOLOR} Add your ${BOLD}EXTERNAL_NET${NOCOLOR} address [Ex: !\$HOME_NET]"
	echo -ne "\n\t${YELLOW}[!] WARNING:${NOCOLOR} Press ${BOLD}ENTER${NOCOLOR} to continue. "
	read -n 1 -s
	sudo vim /etc/snort/snort.conf -c "/ipvar EXTERNAL_NET"

	echo -ne "\n\t${CYAN}[i] INFO:${NOCOLOR} Adding ${BOLD}RULE_PATH${NOCOLOR} to snort.conf file"
	sudo sed -i 's/RULE_PATH\ \.\.\//RULE_PATH\ \/etc\/snort\//g' /etc/snort/snort.conf
	sudo sed -i 's/_LIST_PATH\ \.\.\//_LIST_PATH\ \/etc\/snort\//g' /etc/snort/snort.conf

	echo -ne "\n\t${CYAN}[i] INFO:${NOCOLOR} Enabling ${BOLD}local.rules${NOCOLOR} and adding a PING detection rule..."
	sudo sed -i 's/#include \$RULE\_PATH\/local\.rules/include \$RULE\_PATH\/local\.rules/' /etc/snort/snort.conf
	sudo chmod 766 /etc/snort/rules/local.rules
	sudo echo 'alert icmp any any -> $HOME_NET any (msg:"PING ATTACK"; sid:10000001; rev:001;)' >> /etc/snort/rules/local.rules

	#SNORT OUTPUT: UNIFIED2 --> MANDATORY || CSV/TCPDUMP/BOTH
	sudo sed -i 's/# unified2/output unified2: filename snort.u2, limit 128/g' /etc/snort/snort.conf

	while true; do
		echo -ne "\n\t${YELLOW}[!] WARNING:${NOCOLOR} Unified2 output configured. Configure another output?\n\t\t${YELLOW}1${NOCOLOR} - ${BOLD}CSV${NOCOLOR} output\n\t\t${YELLOW}2${NOCOLOR} - ${BOLD}TCPdump${NOCOLOR} output\n\t\t${YELLOW}3${NOCOLOR} - ${BOLD}CSV${NOCOLOR} and ${BOLD}TCPdump${NOCOLOR} output\n\t\t${YELLOW}4${NOCOLOR} - ${BOLD}None${NOCOLOR}\n\n\tOption [1-4]: "
		read OPTION
		case $OPTION in
			1 )
				echo -ne "\n\t${YELLOW}[!] WARNING:${NOCOLOR} ${BOLD}CSV${NOCOLOR} output will be configured\n"
				sudo sed -i 's/# syslog/output alert_csv: \/var\/log\/alert.csv default/g' /etc/snort/snort.conf
				break
				;;
			2 )
				echo -ne "\n\t${YELLOW}[!] WARNING:${NOCOLOR} ${BOLD}TCPdump${NOCOLOR} output will be configured\n"
				sudo sed -i 's/# pcap/output log_tcpdump: \/var\/log\/snort\/snort.log/g' /etc/snort/snort.conf
				break
				;;
			3 )
				echo -ne "\n\t${YELLOW}[!] WARNING:${NOCOLOR} ${BOLD}CSV${NOCOLOR} and ${BOLD}TCPdump${NOCOLOR} output will be configured\n"
				sudo sed -i 's/# syslog/output alert_csv: \/var\/log\/snort\/alert.csv default/g' /etc/snort/snort.conf
				sudo sed -i 's/# pcap/output log_tcpdump: \/var\/log\/snort\/snort.log/g' /etc/snort/snort.conf
				break
				;;
			4 )
				echo -ne "\n\t${YELLOW}[!] WARNING:${NOCOLOR} No other output will be configured\n\n"
				break
				;;
			* )
				echo -ne "\n\t${RED}[-] ERROR:${NOCOLOR} Invalid option\n\n"
				;;
		esac
	done

}

function snort_test() {

	echo -ne "\n\t${YELLOW}[!] WARNING:${NOCOLOR} Starting ${BOLD}SNORT${NOCOLOR} in test mode. Checking configuration file.... \n"
	sudo snort -T -c /etc/snort/snort.conf

	echo -ne "\n\t${YELLOW}[!] WARNING:${NOCOLOR} Attempting to test ${BOLD}ICMP${NOCOLOR} rule in ${BOLD}$INTERFACE${NOCOLOR}. Send a PING to your ${BOLD}SNORT${NOCOLOR} machine. Press ${BOLD}Ctrl+C${NOCOLOR} once and wait few seconds to stop the process...\n "
	echo -ne "\n\t${YELLOW}[!] WARNING:${NOCOLOR} Press ${BOLD}ENTER${NOCOLOR} to continue. "
	read -n 1 -s
	sudo snort -A console -q -u snort -g snort -c /etc/snort/snort.conf -i $INTERFACE
	killall -9 snort

}

function barnyard2_ask() {

	while true; do
		echo -ne "\n\t${YELLOW}[!] IMPORTANT:${NOCOLOR} Would you like to install ${BOLD}BARNYARD2${NOCOLOR}? [Y/n] "
		read OPTION
		case $OPTION in
			Y|y )
				barnyard2_install
				break
				;;
			N|n )
				echo -ne "\n\t${CYAN}[i] INFO:${NOCOLOR} ${BOLD}BARNYARD2${NOCOLOR} won't be installed.\n\n"
				break
				;;
			* )
				echo -ne "\n\t${RED}[-] ERROR:${NOCOLOR} Invalid option.\n\n"
				;;
		esac
	done

}

function barnyard2_install() {

	echo -ne "\n\t${YELLOW}[!] WARNING:${NOCOLOR} Insert new ${BOLD}SNORT${NOCOLOR} Database Password: "
	read SNORTSQLPASSWORD
	echo -ne "\n\t${CYAN}[i] INFO:${NOCOLOR} Installing dependencies."
	echo -ne "\n\t${YELLOW}[!] WARNING:${NOCOLOR} You will be asked for a ${BOLD}password for MySQL${NOCOLOR} service if it isn't installed in the system."
	echo -ne "\n\t${YELLOW}[!] WARNING:${NOCOLOR} Press ${BOLD}ENTER${NOCOLOR} to continue. "
	read -n 1 -s

	sudo apt-get install -y --force-yes mysql-server libmysqlclient-dev mysql-client autoconf libtool libdnet checkinstall yagiuda libdnet-dev locate

	cd $HOME/snort_src
	echo -ne "\n\t${CYAN}[i] INFO:${NOCOLOR} Downloading ${BOLD}BARNYARD2${NOCOLOR}.\n\n"
	git clone https://github.com/firnsy/barnyard2.git && cd $HOME/snort_src/barnyard2
	autoreconf -fvi -I ./m4

	ln -s /usr/include/dumbnet.h dnet.h

	echo -ne "\n\t${CYAN}[i] INFO:${NOCOLOR} Installing ${BOLD}BARNYARD2${NOCOLOR}2.\n\n"

	if [ "$MACHINE" == "x86_64" ]; then
		./configure --with-mysql --with-mysql-libraries=/usr/lib/x86_64-linux-gnu
	elif [ "$MACHINE" == "i386" ]; then
		./configure --with-mysql --with-mysql-libraries=/usr/lib/i386-linux-gnu
	else
		./configure --with-mysql --with-mysql-libraries=/usr/lib/arm-linux-gnueabihf
	fi

	make
	sudo make install

	echo -ne "\n\t${GREEN}[+] INFO:${NOCOLOR} ${COLOR}BARNYARD2${NOCOLOR} installed successfully.\n\n"

	sudo cp etc/barnyard2.conf /etc/snort > /dev/null 2>&1
	sudo mkdir /var/log/barnyard2 > /dev/null 2>&1
	sudo chown snort.snort /var/log/barnyard2 > /dev/null 2>&1
	sudo touch /var/log/snort/barnyard2.waldo > /dev/null 2>&1
	sudo chown snort.snort /var/log/snort/barnyard2.waldo > /dev/null 2>&1
	sudo touch /etc/snort/sid-msg.map > /dev/null 2>&1

	echo -ne "\n\t${CYAN}[i] INFO:${NOCOLOR} The ${BOLD}SNORT${NOCOLOR} database is going to be created. You will be asked for ${RED}MySQL password 3 times${NOCOLOR}"
	echo -ne "\n\t${YELLOW}[!] WARNING:${NOCOLOR} Press ${BOLD}ENTER${NOCOLOR} to continue. "
	read -n 1 -s
	echo -ne "\n\n"

	sudo /etc/init.d/mysql start > /dev/null 2>&1
	echo "create database snort;" | mysql -u root -p
	mysql -u root -p -D snort < $HOME/snort_src/barnyard2/schemas/create_mysql
	echo "grant create, insert, select, delete, update on snort.* to 'snort'@'localhost' identified by '$SNORTSQLPASSWORD'" | mysql -u root -p

	sudo echo "output database: log, mysql, user=snort password=$SNORTSQLPASSWORD dbname=snort host=localhost" >> /etc/snort/barnyard2.conf
	sudo chmod 766 /etc/snort/barnyard2.conf
	sudo chmod o-r /etc/snort/barnyard2.conf

	barnyard2 -V
	echo -ne "\n\t${GREEN}[+] INFO:${NOCOLOR} ${BOLD}BARNYARD2${NOCOLOR} is successfully installed and configurated!"

}

function pulledpork_ask() {

	echo -ne "\n\t${YELLOW}[!] IMPORTANT:${NOCOLOR} Would you like to install ${BOLD}PULLEDPORK${NOCOLOR}? [Y/n] "
	while true; do
		read OPTION
		case $OPTION in
			Y|y )
				pulledpork_install
				pulledpork_edit
				break
				;;
			N|n )
				echo -ne "\n\t${CYAN}[i] INFO:${NOCOLOR} ${BOLD}PULLEDPORK${NOCOLOR} won't be installed.\n\n"
				break
				;;
			* )
				echo -ne "\n\t${RED}[-] ERROR:${NOCOLOR} Invalid option.\n\n"
				;;
		esac
	done

}

function pulledpork_install() {

	echo -ne "\n\t${CYAN}[i] INFO:${NOCOLOR} Installing dependencies.\n\n"
	sudo apt-get install -y --force-yes libcrypt-ssleay-perl liblwp-useragent-determined-perl

	cd $HOME/snort_src

	echo -ne "\n\t${CYAN}[i] INFO:${NOCOLOR} Downloading ${BOLD}PULLEDPORK${NOCOLOR}.\n\n"
	git clone https://github.com/shirkdog/pulledpork.git
	cd $HOME/snort_src/pulledpork
	sudo cp pulledpork.pl /usr/local/bin > /dev/null 2>&1
	sudo chmod +x /usr/local/bin/pulledpork.pl > /dev/null 2>&1
	sudo cp etc/*.conf /etc/snort/ > /dev/null 2>&1
	sudo mkdir /etc/snort/rules/iplists  > /dev/null 2>&1
	sudo touch /etc/snort/rules/iplists/default.blacklist > /dev/null 2>&1

	echo -ne "\n\t${CYAN}[i] INFO:${NOCOLOR} Adding ${BOLD}PULLEDPORK${NOCOLOR} to crontab. [Everyday at 4:15 AM].\n\n"
	sudo chmod 766 /etc/crontab
	sudo echo "15 4 * * * root /usr/local/bin/pulledpork.pl -c /etc/snort/pulledpork.conf -i disablesid.conf -T -H" >> /etc/crontab
	sudo echo "15 6	* * * root /usr/local/bin/ruleitor" >> /etc/crontab

	sudo pulledpork.pl -V
	echo -ne "\n\t${GREEN}[+] INFO:${NOCOLOR} ${BOLD}PULLEDPORK${NOCOLOR} is successfully installed and configured!"

}

function pulledpork_edit() {

	if [ "$(echo ${#OINKCODE})" == "40" ]; then
		sudo sed -i "s/<oinkcode>/$OINKCODE/g" /etc/snort/pulledpork.conf
	fi

	while true; do
		echo -ne "\n\t${YELLOW}[!] IMPORTANT:${NOCOLOR} Would you like to enable ${BOLD}Emerging Threats${NOCOLOR} rules? [Y/n] "
		read OPTION
		case $OPTION in
			Y|y )
				sudo sed -i "s/#rule_url=https:\/\/rules.emergingthreats.net\//rule_url=https:\/\/rules.emergingthreats.net\//g" /etc/snort/pulledpork.conf
				echo -ne "\n\t${GREEN}[+] INFO:${NOCOLOR} ${BOLD}Emerging Threats${NOCOLOR} rules enabled!"
				break
				;;
			N|n )
				echo -ne "\n\t${GREEN}[+] INFO:${NOCOLOR} ${BOLD}Emerging Threats${NOCOLOR} rules disabled!"
				break
				;;
			* )
				echo -ne "\n\t${RED}[-] ERROR:${NOCOLOR} Invalid option."
				;;
		esac
	done

	echo -ne "\n\t${CYAN}[i] INFO:${NOCOLOR} Editing ${BOLD}pulledpork.conf${NOCOLOR} settings...\n"
	sudo sed -i "s/\/usr\/local\/etc\/snort\//\/etc\/snort\//g" /etc/snort/pulledpork.conf
	sudo sed -i "s/# enablesid=/enablesid=/g" /etc/snort/pulledpork.conf
	sudo sed -i "s/# dropsid=/enablesid=/g" /etc/snort/pulledpork.conf
	sudo sed -i "s/# disablesid=/enablesid=/g" /etc/snort/pulledpork.conf
	sudo sed -i "s/# modifysid=/enablesid=/g" /etc/snort/pulledpork.conf
	sudo sed -i "s/distro=FreeBSD-8-1/distro=Debian-8-4/g" /etc/snort/pulledpork.conf
	sudo sed -i "s/# out_path=/out_path=/g" /etc/snort/pulledpork.conf

	sudo echo """
	#!/bin/bash

	#Snort Snapshot
	cd /tmp
	tar -zxvf /tmp/snortrules-snapshot-*.tar.gz --strip-components=1 rules/ > /dev/null 2>&1
	cp /tmp/rules/*.rules /etc/snort/rules/ > /dev/null 2>&1
	rm -r /tmp/snortrules-snapshot-*.tar.gz /tmp/rules /tmp/preproc_rules /tmp/so_rules /tmp/etc > /dev/null 2>&1

	#Community Rules
	tar -zxvf /tmp/community-rules.tar.gz > /dev/null 2>&1
	cp /tmp/community-rules/*.rules /etc/snort/rules/ > /dev/null 2>&1
	rm -r /tmp/community-rules* > /dev/null 2>&1

	#Emerging Threats Rules
	tar -zxvf /tmp/emerging.rules.tar.gz > /dev/null 2>&1
	cp /tmp/rules/*.rules /etc/snort/rules/ > /dev/null 2>&1
	rm -r /tmp/* > /dev/null 2>&1

	#Adding permissions
	chmod 777 /etc/snort/rules/*.rules
	""" > /usr/local/bin/ruleitor
	sudo chmod 777 /usr/local/bin/ruleitor

}

function service_create() {

	while true; do
		echo -ne "\n\t${YELLOW}[!] IMPORTANT:${NOCOLOR} Would you like to create a service ${BOLD}snort${NOCOLOR}? [Y/n] "
		read OPTION
		case $OPTION in
			Y|y )
				service_add
				sudo chmod +x /etc/init/barnyard2.conf && initctl list | grep barnyard2 && sudo chmod +x /etc/init/snort.conf && initctl list | grep snort
				echo -ne "\n\t${CYAN}[i] INFO:${NOCOLOR} Now you can run ${BOLD}sudo service snort ${NOCOLOR} {start|stop|status}.\n\n"
				break
				;;
			N|n )
				echo -ne "\n\t${CYAN}[i] INFO:${NOCOLOR} The service ${BOLD}snort${NOCOLOR} won't be created.\n\n"
				break
				;;
			* )
				echo -ne "\n\t${RED}[-] ERROR:${NOCOLOR} Invalid option.\n\n"
				;;
		esac
	done

	if [ -f /etc/snort/pulledpork.conf ]; then
		while true; do
			echo -ne "\n\t${YELLOW}[!] IMPORTANT:${NOCOLOR} Would you like to download new rules using ${BOLD}PULLEDPORK${NOCOLOR}? [Y/n] "
			read OPTION
			case $OPTION in
				Y|y )
					sudo /usr/local/bin/pulledpork.pl -c /etc/snort/pulledpork.conf -i disablesid.conf -T -H
					sudo /usr/local/bin/ruleitor
					break
					;;
				N|n )
					echo -ne "\n\t${CYAN}[i] INFO:${NOCOLOR} The service ${BOLD}snort${NOCOLOR} won't be created.\n\n"
					break
					;;
				* )
					echo -ne "\n\t${RED}[-] ERROR:${NOCOLOR} Invalid option.\n\n"
					;;
			esac
		done
	fi


}


function service_add() {

	if [ -f /etc/snort/barnyard2.conf ]; then
sudo echo """
description \"barnyard2 service\"
stop on runlevel [!2345]
start on runlevel [2345]
script
    exec /usr/local/bin/barnyard2 -c /etc/snort/barnyard2.conf -d /var/log/snort -f snort.u2 -w /var/log/snort/barnyard2.waldo -g snort -u snort -D -a /var/log/snort/archived_logs
end script
""" > /etc/init/barnyard2.conf
fi
sudo echo """
description \"Snort NIDS service\"
stop on runlevel [!2345]
start on runlevel [2345]
script
    exec /usr/sbin/snort -q -u snort -g snort -c /etc/snort/snort.conf -i $INTERFACE -D
end script
""" > /etc/init/snort.conf
}

function websnort_ask() {

	echo -ne "\n\t${YELLOW}[!] IMPORTANT:${NOCOLOR} Would you like to install ${BOLD}WEBSNORT${NOCOLOR} for PCAP Analysis? [Y/n] "
	while true; do
		read OPTION
		case $OPTION in
			Y|y )
				websnort_install
				break
				;;
			N|n )
				echo -ne "\n\t${CYAN}[i] INFO:${NOCOLOR} ${BOLD}WEBSNORT${NOCOLOR} won't be installed.\n\n"
				break
				;;
			* )
				echo -ne "\n\t${RED}[-] ERROR:${NOCOLOR} Invalid option.\n\n"
				;;
		esac
	done

}

function websnort_install() {

	echo -ne "\n\t${CYAN}[i] INFO:${NOCOLOR} Installing dependencies.\n\n"
	sudo apt-get install -y --force-yes python-pip
	sudo pip install websnort > /dev/null 2>&1

	echo -ne "\n\t${CYAN}[i] INFO:${NOCOLOR} running ${BOLD}WEBSNORT${NOCOLOR} on ${BOLD}http://localhost:80${NOCOLOR}.\n\n"
	sudo websnort -p 80 > /dev/null 2>&1 &

	echo -ne "\n\t${YELLOW}[!] IMPORTANT:${NOCOLOR} Would you like to start ${BOLD}WEBSNORT${NOCOLOR} with the system? [Y/n] "
	while true; do
		read OPTION
		case $OPTION in
			Y|y )
				echo "sudo websnort -p 80 > /dev/null 2>&1 &" >> $HOME/.bashrc
				echo -ne "\n\t${GREEN}[+] INFO:${NOCOLOR} ${BOLD}WEBSNORT${NOCOLOR} is successfully installed and configured!\n\n"
				break
				;;
			N|n )
				echo -ne "\n\t${CYAN}[i] INFO:${NOCOLOR} ${BOLD}WEBSNORT${NOCOLOR} won't start at system boot."
				echo -ne "\n\t${YELLOW}[!] INFO:${NOCOLOR} run ${BOLD}sudo websnort -p 80${NOCOLOR} everytime you need ${BOLD}WEBSNORT${NOCOLOR}."
				break
				;;
			* )
				echo -ne "\n\t${RED}[-] ERROR:${NOCOLOR} Invalid option.\n\n"
				;;
		esac
	done


}

function last_steps() {

	echo -ne "\n\t${YELLOW}[!] IMPORTANT:${NOCOLOR} Would you like to enable ${BOLD}Emerging Threats${NOCOLOR} and ${BOLD}Community${NOCOLOR} rules for detection? [Y/n] "

	read OPTION
	case "$OPTION" in
		[yY][eE][sS]|[yY])
			echo "# Community and Emerging Rules enabled" >> /etc/snort/snort.conf
			for RULE in $(ls -l /etc/snort/rules/emerging-*.rules | awk '{print $9}'); do
				echo "include $RULE" >> /etc/snort/snort.conf ;
			done
			echo "include /etc/snort/rules/community.rules" >> /etc/snort/snort.conf
			sudo service barnyard2 restart && sudo service snort restart
			echo -ne "\n\t${GREEN}[+] SUCCESS:${NOCOLOR} ${BOLD}Emerging Threats${NOCOLOR} and ${BOLD}Community${NOCOLOR} rules enabled\n\n"
        		;;
    		*)
      			echo -ne "\n\t${YELLOW}[!] IMPORTANT:${NOCOLOR} Edit your ${BOLD}/etc/snort/snort.conf${NOCOLOR} and enable the rules you need by uncomment the lines"
			echo -ne "\n\t${YELLOW}[!] EXAMPLE:${NOCOLOR} If you want to enable the ${BOLD}Exploit rules${NOCOLOR}, remove the ${RED}${BOLD}#${NOCOLOR}:"
			echo -ne "\n\t\t${RED}#${NOCOLOR}include \$RULE_PATH/exploit.rules ${GREEN}-->${NOCOLOR} include \$RULE_PATH/exploit.rules\n\n"
        		;;
	esac

}

function system_reboot() {

	while true; do
		echo -ne "\n\t${YELLOW}[!] IMPORTANT:${NOCOLOR} Would you like to ${BOLD}REBOOT${NOCOLOR} now? [Y/n] "
		read OPTION
		case $OPTION in
			Y|y )
				echo -ne "\n\t${CYAN}[i] INFO:${NOCOLOR} Rebooting...\n\n"
				sleep 1
				sudo reboot
				break
				;;
			N|n )
				echo -ne "\n\t${CYAN}[i] INFO:${NOCOLOR} Exiting from the installer. Enjoy ${BOLD}SNORT${NOCOLOR}!\n\n"
				break
				;;
			* )
				echo -ne "\n\t${RED}[-] ERROR:${NOCOLOR} Invalid option.\n\n"
				;;
		esac
	done
}

function banner() {

	echo -ne """
	                ,-,------,
	                \\\\(\\\\(_,--	${RED} ███████╗${ORANGE}███╗   ██╗${YELLOW} ██████╗ ${GREEN}██████╗ ${CYAN}████████╗${BLUE}███████╗${VIOLET}██████╗  ${NOCOLOR}
	         <\\--/\>/(/(__		${RED} ██╔════╝${ORANGE}████╗  ██║${YELLOW}██╔═══██╗${GREEN}██╔══██╗${CYAN}╚══██╔══╝${BLUE}██╔════╝${VIOLET}██╔══██╗ ${NOCOLOR}
		 /. .          \	${RED} ███████╗${ORANGE}██╔██╗ ██║${YELLOW}██║   ██║${GREEN}██████╔╝${CYAN}   ██║   ${BLUE}█████╗  ${VIOLET}██████╔╝ ${NOCOLOR}
	        ('')  ,        @	${RED} ╚════██║${ORANGE}██║╚██╗██║${YELLOW}██║   ██║${GREEN}██╔══██╗${CYAN}   ██║   ${BLUE}██╔══╝  ${VIOLET}██╔══██╗ ${NOCOLOR}
	         \_._,        /		${RED} ███████║${ORANGE}██║ ╚████║${YELLOW}╚██████╔╝${GREEN}██║  ██║${CYAN}   ██║   ${BLUE}███████╗${VIOLET}██║  ██║ ${NOCOLOR}
	            )-)_/--( >  	${RED} ╚══════╝${ORANGE}╚═╝  ╚═══╝${YELLOW} ╚═════╝ ${GREEN}╚═╝  ╚═╝${CYAN}   ╚═╝   ${BLUE}╚══════╝${VIOLET}╚═╝  ╚═╝ ${NOCOLOR}
	           ''''  ''''

	"""

}

function help_usage() {

	echo -ne "\n\t\t${YELLOW}USAGE:${NOCOLOR} $0 -i ${GREEN}INTERFACE${NOCOLOR}"
	echo -ne "\n\t\t${YELLOW}USAGE:${NOCOLOR} $0 -o ${GREEN}OINKCODE${NOCOLOR} -i ${GREEN}INTERFACE${NOCOLOR}"
	echo -ne "\n\t\t${YELLOW}Example:${NOCOLOR} $0 -o ${GREEN}123456abcdefgh${NOCOLOR} -i ${GREEN}eth0${NOCOLOR}\n\n"
	exit 0

}

function main() {

	update_upgrade
	snort_install
	snort_edit
	snort_test
	barnyard2_ask
	pulledpork_ask
	service_create
	websnort_ask
	last_steps
	system_reboot

}

#PARSE PARAMETERS/CHECK FOR INTERFACE/CHECK FOR OINKCODE

banner

while getopts ":o:i:" OPTION; do
    case "${OPTION}" in
        o)
            OINKCODE=${OPTARG}
            ;;
        i)
            INTERFACE=${OPTARG}
            ;;
        *)
            help_usage
            ;;
    esac
done

shift $((OPTIND-1))

if [ -z "${INTERFACE}" ] ; then

    echo -ne "\n\t\t${RED}[-] ERROR:${NOCOLOR} ${BOLD}Interface${NOCOLOR} is mandatory\n"
    help_usage

fi

if [ "$(echo ${#OINKCODE})" -eq 40 ]; then

	MACHINE=$(echo $(uname -m))
	SNORT=$(echo $(curl -s -k https://www.snort.org | grep "wget" | grep -oP "snort\-\d.\d\.\d+(\.\d)?"))
	DAQ=$(echo $(curl -s -k https://www.snort.org | grep "wget" | grep -oP "daq\-\d\.\d\.\d"))

	echo -ne "\n\t\t${GREEN}[+] OINKCODE:${NOCOLOR} ${OINKCODE}"
	echo -ne "\n\t\t${GREEN}[+] INTERFACE:${NOCOLOR} ${INTERFACE}"
	echo -ne "\n\t\t${GREEN}[+] DAQ:${NOCOLOR} $DAQ"
	echo -ne "\n\t\t${GREEN}[+] SNORT:${NOCOLOR} $SNORT"
	echo -ne "\n\t\t${GREEN}[+] ARCH:${NOCOLOR} $MACHINE\n\n"
	main

elif [ "$(echo ${#OINKCODE})" -lt 40 ] && [ "$(echo ${#OINKCODE})" -gt 0 ]; then

	echo -ne "\n\t\t${RED}[-] ERROR:${NOCOLOR} Invalid ${BOLD}OINKCODE${NOCOLOR}\n"
	help_usage

elif [ $(echo ${#OINKCODE}) -lt 40 ] || [ $(echo ${#OINKCODE}) -gt 1 ]; then

	MACHINE=$(echo $(uname -m))
	SNORT=$(echo $(curl -s -k https://www.snort.org | grep "wget" | grep -oP "snort\-\d.\d\.\d+(\.\d)?"))
	DAQ=$(echo $(curl -s -k https://www.snort.org | grep "wget" | grep -oP "daq\-\d\.\d\.\d"))

	echo -ne "\n\t\t${GREEN}[+] OINKCODE:${NOCOLOR} No OINKCODE provided."
	echo -ne "\n\t\t${GREEN}[+] INTERFACE:${NOCOLOR} ${INTERFACE}"
	echo -ne "\n\t\t${GREEN}[+] DAQ:${NOCOLOR} $DAQ"
	echo -ne "\n\t\t${GREEN}[+] SNORT:${NOCOLOR} $SNORT"
	echo -ne "\n\t\t${GREEN}[+] ARCH:${NOCOLOR} $MACHINE\n\n"
	main

fi
