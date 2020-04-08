#!/usr/bin/env bash
#
# ease.sh
# This script sets up the WiFi Explorer Pro's External Adapter 
# Support Environment (EASE), which enables support for certain 
# Linux-compatible external USB Wi-Fi adapters.
# Version 2.1
#
# Copyright (c) 2019 Adrian Granados. All rights reserved.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

# install packages
[ -e /etc/sources_updated ] || (\
  echo "deb http://deb.debian.org/debian/ buster contrib non-free" >> /etc/apt/sources.list && \
  apt-get update && \
  touch /etc/sources_updated
) && \
apt-get install -y bc git lshw wireless-tools iw firmware-atheros firmware-ralink firmware-realtek libelf-dev python3-pip python3-dev tcpdump linux-headers-`uname -r` build-essential

# install python libraries
pip3 install flask psutil scapy

# build drivers
WIRELESS_MODULE="88XXau.ko"
WIRELESS_MODULE_DIR="/lib/modules/`uname -r`/kernel/drivers/net/wireless"
[ -e $WIRELESS_MODULE_DIR/$WIRELESS_MODULE ] || (\
  git clone -b v5.2.20 https://github.com/aircrack-ng/rtl8812au.git && \
  make -C rtl8812au && \
  make -C rtl8812au install && \
  modprobe 88XXau
  rm -rf rtl8812au
)

# setup sensor
[ -e wifiexplorer-sensor/wifiexplorer-sensor.py ] || (\
  git clone https://github.com/adriangranados/wifiexplorer-sensor.git > /dev/null 2>&1
) && \
cd wifiexplorer-sensor
git pull && install -p -m 755 wifiexplorer-sensor.py /usr/local/bin/wifiexplorer-sensor
cd /home/vagrant

# setup ease
install -p -m 755 ease.py /usr/local/bin/ease
install -p -m 755 ease /etc/init.d/ease
update-rc.d ease defaults
systemctl daemon-reload
rm -f ease*
systemctl stop ease.service
killall wifiexplorer-sensor > /dev/null 2>&1
systemctl start ease.service

echo "Done."
