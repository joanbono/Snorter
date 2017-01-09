#Snorter

Tricky script which mades Snort installation simply as a script execution is.

Successfully tested in:

+ Raspberry Pi + Raspbian Jessie
+ Kali Linux Rolling Release
+ Debian 8.5

***

##Installation

Detailed Installation instructions in this [PDF](doc/Instructions_EN.pdf) or this [MarkDown](doc/doc_EN.md).

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
bash Snorter.sh -o <oinkcode> -i <interface>
~~~~

![Snorter in action!](img/1.png)

***

##Docker
###Edit the Dockerfile

Dockerfile content. Use your personal [OINKCODE](https://www.snort.org/oinkcodes).

~~~~
#Kali docker with SNORT + BARNYARD2 + PULLEDPORK
#Version 0.1.0
From kalilinux/kali-linux-docker:latest
MAINTAINER Joan Bono <@joan_bono> && Alvaro Diaz <@alvarodh5>

RUN apt-get update && apt-get upgrade -y && apt-get install -y git curl wget
RUN git clone https://github.com/joanbono/Snorter.git /opt/Snorter
RUN /opt/Snorter/src/Snorter.sh -o OINKCODE -i INTERFACE
USER root
WORKDIR /opt/Snorter
~~~~

###Run the dockerfile

Start the `docker` daemon and run:

~~~~
cd Snorter/src/
docker build SnorterDock -e OINKCODE=<oinkcode> -e INTERFACE=<interface>
~~~~

***

##Install Instruction

+ English: [PDF](doc/Instructions_EN.pdf)  -  [MarkDown](doc/doc_EN.md)
+ Spanish: [PDF](doc/Instructions_ES.pdf)  -  [MarkDown](doc/doc_ES.md)
