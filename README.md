#Snorter

Tricky script which mades Snort installation simply as a script execution is.

Successfully tested in:

+ Raspberry Pi + Raspbian Jessie
+ Kali Linux Rolling Release
+ Debian 8.5

***

##Installation

###Download

Simply run on your terminal:

~~~~bash
git clone https://github.com/joanbono/SnortBot.git
cd SnortBot/Snorter
~~~~

###Execution

Printing the USAGE:

~~~~bash
bash Snorter.sh -h
~~~~

OR

~~~~bash
bash Snorter.sh --help
~~~~

RECOMMENDED: Executing the script using an [OINKCODE](https://www.snort.org/oinkcodes)

~~~~bash
bash Snorter.sh XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
~~~~

![Snorter in action!](https://github.com/joanbono/SnortBot/blob/master/img/snorter.jpg)

***

##TODO

+ [ ] Add a service to `/etc/init.d/snort`.
+ [ ] Initialize `Snort` with the system boot.
+ [ ] Detailed installation instructions (PDF?).
