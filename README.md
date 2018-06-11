# Snorter

![Snorter in action!](img/1.png)

![Version](https://img.shields.io/badge/version-1.0.0-green.svg) [![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](http://www.gnu.org/licenses/gpl-3.0)

Tricky script which mades Snort installation simply as a script execution is. The script installs:

+ [Snort](https://snort.org/): Open Source IDS.
+ [Barnyard2](https://github.com/firnsy/barnyard2): Interpreter for Snort unified2 binary output files.
+ [PulledPork](https://github.com/shirkdog/pulledpork): Snort rule management.
+ [WebSnort](https://github.com/shendo/websnort): Web Interface for PCAP analysis.

Successfully tested in:

+ Raspberry Pi + Raspbian Jessie
+ Kali Linux Rolling Release
+ Debian 9.0+
+ Ubuntu 18.04
+ Ubuntu 14.04 using the [`Snorter_Ubuntu-14.04.sh`](src/Snorter_Ubuntu-14.04.sh) script.

***

## Installation

Detailed install [instructions](https://github.com/joanbono/Snorter#install-instructions).

### Download

Simply run on your terminal:

~~~~bash
git clone https://github.com/joanbono/Snorter.git
cd Snorter/src
~~~~

### Execution

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

***

## Docker
### Edit the Dockerfile

Dockerfile content. Use your personal [OINKCODE](https://www.snort.org/oinkcodes).

~~~~
#Kali docker with SNORT + BARNYARD2 + PULLEDPORK
#Version 0.1.0
From kalilinux/kali-linux-docker:latest
MAINTAINER Joan Bono <@joan_bono>

ENV OINKCODE
ENV INTERFACE

RUN apt-get update && apt-get upgrade -y && apt-get install -y git curl wget
RUN git clone https://github.com/joanbono/Snorter.git /opt/Snorter
RUN /opt/Snorter/src/Snorter.sh -o ${OINKCODE} -i ${INTERFACE}
USER root
WORKDIR /opt/Snorter
~~~~

### Run the dockerfile

Start the `docker` daemon.

+ With `websnort`:

~~~~
cd Snorter/src/
docker build SnorterDock -p 80:80 -e OINKCODE=<oinkcode> -e INTERFACE=<interface>
~~~~


+ Without `websnort`:

~~~~
cd Snorter/src/
docker build SnorterDock -e OINKCODE=<oinkcode> -e INTERFACE=<interface>
~~~~

***

## WebSnort Usage

+ Submit a `pcap` using the web browser:

![](img/20.png)

+ Watch the `alerts` on the web browser:

![](img/21.png)

+ Submit a `pcap` using the `API`:

~~~~
curl -i --form file=@test.pcap http://ADDRESS/api/submit
~~~~

![](img/22.png)

***

## Install Instructions

+ English: [PDF](doc/Instructions_EN.pdf)  -  [MarkDown](doc/doc_EN.md)
+ Spanish: [PDF](doc/Instructions_ES.pdf)  -  [MarkDown](doc/doc_ES.md)
+ Catalan: [PDF](doc/Instructions_CA.pdf)  -  [MarkDown](doc/doc_CA.md)

***

## Stargazers over time

[![Stargazers over time](https://starcharts.herokuapp.com/joanbono/Snorter.svg)](https://starcharts.herokuapp.com/joanbono/Snorter)
      
***

## Special thanks to

+ [@goffinet](https://github.com/goffinet) for the rule enabler and for solving solving the `systemctl` issue.
+ [@rbshadow](https://github.com/rbshadow) for the `Snorter` script adapted to `Ubuntu 14.04`.
