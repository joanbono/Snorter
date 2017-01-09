#Kali docker with SNORT + BARNYARD2 + PULLEDPORK
#Version 0.1.0
From kalilinux/kali-linux-docker:latest
MAINTAINER Joan Bono <@joan_bono> && Alvaro Diaz <@alvarodh5>

RUN apt-get update && apt-get upgrade -y && apt-get install -y git curl wget
RUN git clone https://github.com/joanbono/Snorter.git /opt/Snorter
RUN /opt/Snorter/src/Snorter.sh -o OINKCODE -i INTERFACE
USER root
WORKDIR /opt/Snorter
