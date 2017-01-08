#!/bin/bash
# Title: Snorter.sh
# Description: Install automatically Snort + Barnyard2 + PulledPork
# Author: Joan Bono (@joan_bono)
# Version: 0.7.2
# Last Modified: jbono @ 20170108
# Usage: bash Snorter.sh
# Usage: bash Snorter.sh OINKCODE

##################################
#         TODO LIST              #
##################################
#
#  sudo service snort status
#
#  Add start to .bashrc \o/

OINKCODE=$1 
MACHINE=$(echo $(uname -m))
SNORT=$(echo $(curl -s https://www.snort.org | grep "wget" | grep -oP "snort\-\d.\d\.\d(\.\d)?"))
DAQ=$(echo $(curl -s https://www.snort.org | grep "wget" | grep -oP "daq\-\d\.\d\.\d"))

RED='\033[0;31m'
ORANGE='\033[0;205m'
YELLOW='\033[0;93m'
GREEN='\033[0;32m'
CYAN='\033[0;96m'
BLUE='\033[0;34m'
VIOLET='\033[0;35m'
NOCOLOR='\033[0m'


function check_version() {

	echo -ne "\n\t${CYAN}[i] INFO:${NOCOLOR} Updating and Upgrading repositories...\n\n"
	sudo apt-get update && sudo apt-get upgrade -y --force-yes
	echo "SNORT: "$SNORT
	echo "DAQ: "$DAQ
	echo "MACHINE: "$MACHINE
	
	if [ "$(echo ${#OINKCODE})" == "40" ]; then
		echo "OINKCODE: "$OINKCODE
	else
		echo "OINKCODE: No OINKCODE selected"
	fi
}

function snort_install() {

	echo -ne "\n\t${CYAN}[i] INFO:${NOCOLOR} Installing dependencies.\n\n"
	sudo apt-get install -y --force-yes build-essential libpcap-dev libpcre3-dev libdumbnet-dev bison flex zlib1g-dev git locate vim
	
	#Downloading DAQ and SNORT
	cd $HOME && mkdir snort_src && cd snort_src
	echo -ne "\n\t${CYAN}[i] INFO:${NOCOLOR} Downloading $DAQ.\n\n"
	wget -P $HOME/snort_src https://snort.org/downloads/snort/$DAQ.tar.gz
	echo -ne "\n\t${CYAN}[i] INFO:${NOCOLOR} Downloading $SNORT.\n\n"
	wget -P $HOME/snort_src https://snort.org/downloads/snort/$SNORT.tar.gz
	
	#Installing DAQ
	cd $HOME/snort_src/
	echo -ne "\n\t${CYAN}[i] INFO:${NOCOLOR} Installing $DAQ.\n\n"
	tar xvfz $DAQ.tar.gz
	mv $HOME/snort_src/daq-*/ $HOME/snort_src/daq                     
	cd $HOME/snort_src/daq
	./configure && make && sudo make install 
	echo -ne "\n\t${GREEN}[+] INFO:${NOCOLOR} $DAQ installed successfully.\n\n"
	
	#Installing SNORT
	cd $HOME/snort_src
	echo -ne "\n\t${CYAN}[i] INFO:${NOCOLOR} Installing $DAQ.\n\n"
	tar xvfz $SNORT.tar.gz > /dev/null 2>&1
	rm -r *.tar.gz > /dev/null 2>&1
	mv snort-*/ snort           
	cd snort
	./configure --enable-sourcefire && make && sudo make install
	echo -ne "\n\t${GREEN}[+] INFO:${NOCOLOR} $SNORT installed successfully.\n\n"
	cd ..
	
	sudo ldconfig
	sudo ln -s /usr/local/bin/snort /usr/sbin/snort

	#Adding SNORT user and group for running SNORT
	echo -ne "\n\t${CYAN}[i] INFO:${NOCOLOR} Adding user and group SNORT.\n\n"
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
	
	sudo cp ~/snort_src/snort/etc/*.conf* /etc/snort
	sudo cp ~/snort_src/snort/etc/*.map /etc/snort
	
	sudo sed -i 's/include \$RULE\_PATH/#include \$RULE\_PATH/' /etc/snort/snort.conf
	
	echo -ne "\n\t${CYAN}[i] INFO:${NOCOLOR} /var/log/snort and /etc/snort created and configurated.\n\n"
	sudo /usr/local/bin/snort -V
	echo -ne "\n\t${GREEN}[+] INFO:${NOCOLOR} Snort is successfully installed and configured!"

}

function snort_edit() {

	echo -ne "\n\t${YELLOW}[!] INFO:${NOCOLOR} Now it's time to edit the Snort configuration file.\n\n"
	echo -ne "\n\t${CYAN}[i] INFO:${NOCOLOR} Add your HOME_NET address [Ex: 192.168.1.0/24]"
	echo -ne "\n\t${YELLOW}[!] WARNING:${NOCOLOR} Press ENTER to continue. "
	read -n 1 -s
	sudo vim /etc/snort/snort.conf -c "/ipvar HOME_NET"

	echo -ne "\n\t${CYAN}[i] INFO:${NOCOLOR} Add your EXTERNAL_NET address [Ex: !\$HOME_NET]"
	echo -ne "\n\t${YELLOW}[!] WARNING:${NOCOLOR} Press ENTER to continue. "
	read -n 1 -s
	sudo vim /etc/snort/snort.conf -c "/ipvar EXTERNAL_NET"

	echo -ne "\n\t${CYAN}[i] INFO:${NOCOLOR} Adding RULE_PATH to snort.conf file"
	sudo sed -i 's/RULE_PATH\ \.\.\//RULE_PATH\ \/etc\/snort\//g' /etc/snort/snort.conf
	sudo sed -i 's/_LIST_PATH\ \.\.\//_LIST_PATH\ \/etc\/snort\//g' /etc/snort/snort.conf

	echo -ne "\n\t${CYAN}[i] INFO:${NOCOLOR} Enabling local.rules and adding a PING detection rule..."
	sudo sed -i 's/#include \$RULE\_PATH\/local\.rules/include \$RULE\_PATH\/local\.rules/' /etc/snort/snort.conf
	sudo echo 'alert icmp any any -> $HOME_NET any (msg:"Atac per PINGs"; sid:10000001; rev:001;)' >> /etc/snort/rules/local.rules

	#SNORT OUTPUT: UNIFIED2 --> MANDATORY || CSV/TCPDUMP/BOTH
	sudo sed -i 's/# unified2/output unified2: filename snort.u2, limit 128/g' /etc/snort/snort.conf
	
	while true; do
		echo -ne "\n\t${YELLOW}[!] WARNING:${NOCOLOR} Unified2 output configured. Configure another output?\n\t\t1 - CSV output\n\t\t2 - TCPdump output\n\t\t3 - CSV and TCPdump output\n\t\t4 - None\n\n\tOption [1-4]: "
		read OPTION
		case $OPTION in
			1 )
				echo -ne "\n\t${YELLOW}[!] WARNING:${NOCOLOR} CSV output will be configured\n"
				sudo sed -i 's/# syslog/output alert_csv: \/var\/log\/alert.csv default/g' /etc/snort/snort.conf
				break
				;;
			2 )
				echo -ne "\n\t${YELLOW}[!] WARNING:${NOCOLOR} TCPdump output will be configured\n"
				sudo sed -i 's/# pcap/output log_tcpdump: snort.log/g' /etc/snort/snort.conf
				break
				;;
			3 )
				echo -ne "\n\t${YELLOW}[!] WARNING:${NOCOLOR} CSV and TCPdump output will be configured\n"
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

	echo -ne "\n\t${YELLOW}[!] WARNING:${NOCOLOR} Starting SNORT in test mode. Checking configuration file.... \n"
	sudo snort -T -c /etc/snort/snort.conf

	echo -ne "\n\t${YELLOW}[!] WARNING:${NOCOLOR} Attempting to test ICMP rule. Send a PING to your SNORT machine. Press Ctrl+C to stop...\n "
	echo -ne "\n\t${YELLOW}[!] WARNING:${NOCOLOR} Press ENTER to continue. "
	read -n 1 -s
	sudo snort -A console -q -u snort -g snort -c /etc/snort/snort.conf -i eth0
	killall -9 snort
	
}

function barnyard2_ask() {

	while true; do
		echo -ne "\n\t${YELLOW}[!] IMPORTANT:${NOCOLOR} Would you like to install Barnyard2? [Y/n] "
		read OPTION
		case $OPTION in
			Y|y )
				barnyard2_install
				break
				;;
			N|n )
				echo -ne "\n\t${CYAN}[i] INFO:${NOCOLOR} Barnyard2 won't be installed.\n\n"
				break
				;;
			* )
				echo -ne "\n\t${RED}[-] ERROR:${NOCOLOR} Invalid option.\n\n"
				;;
		esac
	done

}

function barnyard2_install() {
	echo -ne "\n\t${YELLOW}[!] WARNING:${NOCOLOR} Insert new SNORT Database Password: "
	read SNORTSQLPASSWORD
	echo -ne "\n\t${CYAN}[i] INFO:${NOCOLOR} Installing dependencies."
	echo -ne "\n\t${YELLOW}[!] WARNING:${NOCOLOR} You will be asked for a password for MySQL service if it isn't installed in the system."
	echo -ne "\n\t${YELLOW}[!] WARNING:${NOCOLOR} Press ENTER to continue. "
	read -n 1 -s

	sudo apt-get install -y --force-yes mysql-server libmysqlclient-dev mysql-client autoconf libtool libdnet checkinstall yagiuda libdnet-dev locate
	
	cd $HOME/snort_src
	echo -ne "\n\t${CYAN}[i] INFO:${NOCOLOR} Downloading Barnyard2.\n\n"
	git clone https://github.com/firnsy/barnyard2.git && cd $HOME/snort_src/barnyard2
	autoreconf -fvi -I ./m4
	
	ln -s /usr/include/dumbnet.h dnet.h
	
	echo -ne "\n\t${CYAN}[i] INFO:${NOCOLOR} Installing Barnyard2.\n\n"

	#Raspberry Pi
	#./configure --with-mysql --with-mysql-libraries=/usr/lib/arm-linux-gnueabihf
	if [ "$MACHINE" == "x86_64" ]; then
		./configure --with-mysql --with-mysql-libraries=/usr/lib/x86_64-linux-gnu
	elif [ "$MACHINE" == "i386" ]; then
		./configure --with-mysql --with-mysql-libraries=/usr/lib/i386-linux-gnu
	else
		./configure --with-mysql --with-mysql-libraries=/usr/lib/arm-linux-gnueabihf
	fi
		
	#./configure --with-mysql --with-mysql-libraries=/usr/lib/$MACHINE
	
	make
	sudo make install
	
	echo -ne "\n\t${GREEN}[+] INFO:${NOCOLOR} Barnyard2 installed successfully.\n\n"
	
	sudo cp etc/barnyard2.conf /etc/snort > /dev/null 2>&1
	sudo mkdir /var/log/barnyard2 > /dev/null 2>&1
	sudo chown snort.snort /var/log/barnyard2 > /dev/null 2>&1
	sudo touch /var/log/snort/barnyard2.waldo > /dev/null 2>&1
	sudo chown snort.snort /var/log/snort/barnyard2.waldo > /dev/null 2>&1
	sudo touch /etc/snort/sid-msg.map > /dev/null 2>&1

	echo -ne "\n\t${CYAN}[i] INFO:${NOCOLOR} The SNORT database is going to be created. You will be asked for ${RED}MySQL password 3 times${NOCOLOR}"
	echo -ne "\n\t${YELLOW}[!] WARNING:${NOCOLOR} Press ENTER to continue. "
	read -n 1 -s
	echo -ne "\n\n"

	sudo /etc/init.d/mysql start > /dev/null 2>&1
	echo "create database snort;" | mysql -u root -p
	mysql -u root -p -D snort < ~/snort_src/barnyard2/schemas/create_mysql
	echo "grant create, insert, select, delete, update on snort.* to 'snort'@'localhost' identified by '$SNORTSQLPASSWORD'" | mysql -u root -p
	
	sudo echo "output database: log, mysql, user=snort password=$SNORTSQLPASSWORD dbname=snort host=localhost" >> /etc/snort/barnyard2.conf 
	sudo chmod o-r /etc/snort/barnyard2.conf
	
	echo -ne "${RED}"
	barnyard2 -V
	echo -ne "${NOCOLOR}"
	echo -ne "\n\t${GREEN}[+] INFO:${NOCOLOR} Barnyard2 is successfully installed and configured!"

}

function pulledpork_ask() {

	echo -ne "\n\t${YELLOW}[!] IMPORTANT:${NOCOLOR} Would you like to install PulledPork? [Y/n] "
	while true; do
		read OPTION
		case $OPTION in
			Y|y )
				pulledpork_install
				pulledpork_edit
				break
				;;
			N|n )
				echo -ne "\n\t${CYAN}[i] INFO:${NOCOLOR} PulledPork won't be installed.\n\n"
				break
				;;
			* )
				echo -ne "\n\t${RED}[-] ERROR:${NOCOLOR} Invalid option.\n\n"
				;;
		esac
	done

}

function pulledpork_install(){
	
	echo -ne "\n\t${CYAN}[i] INFO:${NOCOLOR} Installing dependencies.\n\n"
	sudo apt-get install -y --force-yes libcrypt-ssleay-perl liblwp-useragent-determined-perl
	
	cd ~/snort_src
	
	echo -ne "\n\t${CYAN}[i] INFO:${NOCOLOR} Downloading PulledPork.\n\n"
	git clone https://github.com/shirkdog/pulledpork.git
	cd $HOME/snort_src/pulledpork
	sudo cp pulledpork.pl /usr/local/bin > /dev/null 2>&1
	sudo chmod +x /usr/local/bin/pulledpork.pl > /dev/null 2>&1
	sudo cp etc/*.conf /etc/snort/ > /dev/null 2>&1
	sudo mkdir /etc/snort/rules/iplists  > /dev/null 2>&1
	sudo touch /etc/snort/rules/iplists/default.blacklist > /dev/null 2>&1

	echo -ne "\n\t${CYAN}[i] INFO:${NOCOLOR} Adding PulledPork to crontab. [Everyday at 4:15 AM].\n\n"
	sudo echo "15 4 * * * root pulledpork.pl -c /etc/snort/pulledpork.conf -i disablesid.conf -T -H" >> /etc/crontab
	
	pulledpork.pl -V
	echo -ne "\n\t${GREEN}[+] INFO:${NOCOLOR} PulledPork is successfully installed and configured!"

}

function pulledpork_edit() {

	if [ "$(echo ${#OINKCODE})" == "40" ]; then
		sudo sed -i "s/<oinkcode>/$OINKCODE/g" /etc/snort/pulledpork.conf
	fi

	while true; do
		echo -ne "\n\t${YELLOW}[!] IMPORTANT:${NOCOLOR} Would you like to enable Emerging Threats rules? [Y/n] "
		read OPTION
		case $OPTION in
			Y|y )
				sudo sed -i "s/#rule_url=https:\/\/rules.emergingthreats.net\//rule_url=https:\/\/rules.emergingthreats.net\//g" /etc/snort/pulledpork.conf
				echo -ne "\n\t${GREEN}[+] INFO:${NOCOLOR} Emerging Threats rules enabled!"
				break
				;;
			N|n )
				echo -ne "\n\t${GREEN}[+] INFO:${NOCOLOR} Emerging Threats rules disabled!"
				break
				;;
			* )
				echo -ne "\n\t${RED}[-] ERROR:${NOCOLOR} Invalid option."
				;;
		esac
	done

	echo -ne "\n\t${CYAN}[i] INFO:${NOCOLOR} Editing pulledpork.conf settings...\n"
	sudo sed -i "s/\/usr\/local\/etc\/snort\//\/etc\/snort\//g" /etc/snort/pulledpork.conf
	sudo sed -i "s/# enablesid=/enablesid=/g" /etc/snort/pulledpork.conf
	sudo sed -i "s/# dropsid=/enablesid=/g" /etc/snort/pulledpork.conf
	sudo sed -i "s/# disablesid=/enablesid=/g" /etc/snort/pulledpork.conf
	sudo sed -i "s/# modifysid=/enablesid=/g" /etc/snort/pulledpork.conf
	sudo sed -i "s/distro=FreeBSD-8-1/distro=Debian-8-4/g" /etc/snort/pulledpork.conf

}

function service_create() {

	echo "TODO --> Add Service /etc/init.d/snort"
	echo "TODO --> Start snort & barnyard with the system"

}

function last_steps() {

	echo "Now edit your /etc/snort/snort.conf and enable the rules you need by uncommnet the lines"

}

function system_start(){

	echo "ASK start system"
	echo -ne "\n\t${GREEN}[+] INFO:${NOCOLOR} Starting PULLEDPORK to download latest ruleset...\n"
	pulledpork.pl -c /etc/snort/pulledpork.conf -i disablesid.conf -T -H
	echo -ne "\n\t${GREEN}[+] INFO:${NOCOLOR} Checking ruleset. Starting SNORT in test mode...\n"
	sudo snort -T -c /etc/snort/snort.conf
	echo -ne "\n\t${GREEN}[+] INFO:${NOCOLOR} Starting SNORT and BARNYARD2...\n"
	sudo barnyard2 -c /etc/snort/barnyard2.conf -d /var/log/snort -f snort.u2 -w /var/log/snort/barnyard2.waldo -g snort -u snort &
	sudo /usr/local/bin/snort -q -u snort -g snort -c /etc/snort/snort.conf -i eth0

	echo -ne "\n\t${GREEN}[+] SUCCESS:${NOCOLOR} SNORT and BARNYARD2 running in the system!\n\n"

}

function banner(){


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

function help_usage(){
	
	if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then 
		echo -ne "\n\t\t${YELLOW}USAGE:${NOCOLOR} $0"
		echo -ne "\n\t\t${YELLOW}USAGE:${NOCOLOR} $0 ${GREEN}OINKCODE${NOCOLOR}\n\n"
		exit 0
	fi
}
function main() {

	banner
	help_usage $1
	check_version
	snort_install
	snort_edit
	snort_test
	barnyard2_ask
	pulledpork_ask
	#service_create
	#system_start
	last_steps

}

main $1
