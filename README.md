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
git clone https://github.com/joanbono/Snorter.git
cd Snorter/src
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
bash Snorter.sh <oinkcode>
~~~~

![Snorter in action!](https://github.com/joanbono/SnortBot/blob/master/img/snorter.jpg)

***

##Docker
###Edit the Dockerfile

Dockerfile content. __Replace__ \<oinkcode\> with your personal [OINKCODE](https://www.snort.org/oinkcodes).

~~~~
#Kali docker with SNORT + BARNYARD2 + PULLEDPORK
From kalilinux/kali-linux-docker:latest
MAINTAINER Joan Bono <@joan_bono>

RUN apt-get update && apt-get upgrade -y && apt-get install -y git curl wget
RUN git clone https://github.com/joanbono/Snorter.git /opt/Snorter
RUN /opt/Snorter/src/Snorter.sh <oinkcode>
USER root
WORKDIR /opt/Snorter
~~~~

###Run the dockerfile

Start the `docker` daemon and run:

~~~~
cd Snorter/src/
docker build SnorterDock
~~~~

***

##TODO

+ [ ] Add a service to `/etc/init.d/snort`.
+ [ ] Initialize `Snort` with the system boot.
+ [ ] Detailed installation instructions (PDF?).
+ [x] [Dockerfile](https://github.com/joanbono/Snorter/blob/master/src/SnorterDock/Dockerfile).
