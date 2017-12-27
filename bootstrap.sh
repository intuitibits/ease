#!/usr/bin/env bash
#
# ease.sh
# This script sets up the WiFi Explorer Pro's External Adapter 
# Support Environment (EASE), which enables support for certain 
# Linux-compatible external USB Wi-Fi adapters.
# Version 1.0
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND 
# CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, 
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF 
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR 
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, 
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. YOU MAY 
# NOT COPY, MODIFY, SUBLICENSE, OR DISTRIBUTE THIS SOFTWARE.
#
# Copyright (c) 2018 Adrian Granados. All rights reserved.
#

# install packages
[ -e /etc/sources_updated ] || (\
  echo "deb http://httpredir.debian.org/debian/ jessie contrib non-free" >> /etc/apt/sources.list && \
  apt-get update && \
  touch /etc/sources_updated
) && \
apt-get install -y git lshw wireless-tools iw firmware-ralink python-pip python-dev scapy tcpdump linux-headers-`uname -r` build-essential

# install python libraries
pip install libnl flask psutil

# build drivers
WIRELESS_MODULE="8812au.ko"
WIRELESS_MODULE_DIR="/lib/modules/`uname -r`/kernel/drivers/net/wireless"
[ -e $WIRELESS_MODULE_DIR/$WIRELESS_MODULE ] || (\
  git clone https://github.com/astsam/rtl8812au.git && \
  make -C rtl8812au && \
  mkdir -p $WIRELESS_MODULE_DIR && \
  install -p -m 644 rtl8812au/$WIRELESS_MODULE $WIRELESS_MODULE_DIR && \
  depmod -a && modprobe 8812au && \
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
