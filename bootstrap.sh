#!/usr/bin/env bash
#
# ease.sh
# This script sets up the WiFi Explorer Pro's External Adapter 
# Support Environment (EASE), which enables support for certain 
# Linux-compatible external USB Wi-Fi adapters.
# Version 3.0
#
# Copyright (c) 2021 Intuitibits LLC. All rights reserved.
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

# setup ease
install -p -m 755 ease.py /usr/local/bin/ease
install -p -m 755 ease /etc/init.d/ease
update-rc.d ease defaults
systemctl daemon-reload
systemctl restart ease.service

# create ease user
id ease &> /dev/null ||
adduser --gecos "" --disabled-password ease &&
chpasswd <<<"ease:ease" &&
usermod -aG sudo ease

# set up password-less sudo for the ease user
echo 'ease ALL=(ALL) NOPASSWD:ALL' >/etc/sudoers.d/ease;
chmod 440 /etc/sudoers.d/ease;

echo "Done."
