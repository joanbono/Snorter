#Kali docker with SNORT + BARNYARD2 + PULLEDPORK
From kalilinux/kali-linux-docker:latest
MAINTAINER Joan Bono <@joan_bono>

RUN apt-get update && apt-get upgrade -y && apt-get install -y git curl wget
RUN git clone https://github.com/joanbono/Snorter.git /opt/Snorter
RUN /opt/Snorter/src/Snorter.sh <oinkcode>
USER root
WORKDIR /opt/Snorter
