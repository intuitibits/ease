#!/usr/bin/python
#
# ease.py
# External Adapter Support Environment (EASE)
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

from flask import Flask, jsonify, make_response
import json
import time
import psutil
import subprocess
from os import geteuid, devnull
from sys import exit
from threading import Thread
from pprint import pprint

app = Flask(__name__)

adapters = []

FNULL = open(devnull, 'w')

def find_adapters(json_data):
    for item in json_data:
        if item == 'children':
            for child in json_data['children']:
                find_adapters(child)
        elif item == 'description' and json_data['description'] == 'Wireless interface':
            name = json_data['vendor'] + ' ' + json_data['product']
            interface = json_data['logicalname']
            tag = 2000 + int(interface.replace('wlan', ''))
            port = 26700 + int(interface.replace('wlan', ''))

            found = False
            for adapter in adapters:
                if adapter['interface'] == interface:
                    adapter['last_seen'] = time.time()
                    found = True

            if not found:
                try:
                    subprocess.Popen(["/usr/local/bin/wifiexplorer-sensor", interface, str(port)], stdout=FNULL)
                    adapter = {
                        'name': name,
                        'interface': interface,
                        'port': port,
                        'tag': tag,
                        'last_seen': time.time()
                    }
                    adapters.append(adapter)
                    print "Adding %s" % adapter
                except OSError, e:
                    print("Failed to start sensor for adapter %s: %s" % (name, e))


def purge_adapters():
    for adapter in adapters:
        now = time.time()
        if now - adapter['last_seen'] > 2.0:
            print "Removing %s" % adapter
            adapters.remove(adapter)
            # Kill wifiexplorer-sensor for this adapter
            for proc in psutil.process_iter():
                cmdline = proc.cmdline()
                if len(cmdline) == 4:
                    if cmdline[1] == '/usr/local/bin/wifiexplorer-sensor' and cmdline[2] == adapter['interface'] and cmdline[3] == str(adapter['port']):
                        proc.kill()

def run():
    while True:
        json_data = json.loads(subprocess.check_output(["/usr/bin/lshw", "-json"], stderr=FNULL))
        find_adapters(json_data)
        purge_adapters()
        time.sleep(3)

@app.route('/ease/api/v1.0/adapters', methods=['GET'])
def get_adapters():
    return jsonify({'adapters': adapters})

@app.errorhandler(404)
def not_found(error):
    return make_response(jsonify({'error': 'Not found'}), 404)

if __name__ == '__main__':

    if geteuid() != 0:
        print "You need to have root privileges to run this script."
        exit(-1)

    thread = Thread(target = run)
    thread.daemon = True
    thread.start()
    app.run(host='0.0.0.0')
