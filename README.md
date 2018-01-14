# External Adapter Support Environment

The External Adapter Support Environment (EASE) allows [WiFi Explorer Pro](https://www.adriangranados.com/apps/wifi-explorer) to use certain external USB adapters for Wi-Fi scanning in macOS. Adapters must be Linux-compatible and support monitor mode.

EASE is basically a lightweight Debian VM that's been customized to leverage the [remote sensor](https://github.com/adriangranados/wifiexplorer-sensor) functionality to automatically configure an external Wi-Fi adapter as a pseudo-local sensor. These pseudo-local sensors are listed in WiFi Explorer Pro separately from remote sensors, but they work in the same manner. 

EASE supports multiple adapters and the installation is fairly straightforward using Vagrant. Once installed, you only need to _attach_ the adapter to the EASE VM and it will automatically show up in WiFi Explorer Pro where you can choose it for scanning.

## Supported External Adapters

EASE can work with Linux-compatible external USB adapters that support monitor mode, however, only a few adapters have been tested:

* [ASUS USB-N53](https://www.amazon.com/Asus-Wireless-N-Graphical-Interface-USB-N53/dp/B005SAKW9G/ref=sr_1_1?ie=UTF8&qid=1515551234&sr=8-1&keywords=asus+usb+n53)
* [ALFA AWUS051NH 802.11a/b/g/n 500mW 1x1:1](https://www.amazon.com/Alfa-AWUS051NH-Wireless-Network-9dBi/dp/B003YH1X48/ref=sr_1_1?ie=UTF8&qid=1515526895&sr=8-1&keywords=AWUS051NH)
* [Edimax EW-7833UAC AC1750](https://www.amazon.com/gp/product/B01G51FBF6/ref=oh_aui_detailpage_o01_s00?ie=UTF8&psc=1) - Realtek RTL8814AU
* [Odroid Wi-Fi Module 4](https://ameridroid.com/products/wifi-module-4) - MediaTek (Ralink) RT5572N
* [Odroid Wi-Fi Module 5](https://ameridroid.com/products/wifi-module-5) - Realtek RTL8812AU
* [TP-Link 802.11b/g/n TL-WN272N](https://www.amazon.com/TP-Link-Wireless-Adapter-150Mbps-TL-WN727N/dp/B001WU2N1G/ref=sr_1_1?ie=UTF8&qid=1515706464&sr=8-1&keywords=tp-link+tl-wn727n)

Other adapters using the same driver/chipset should work fine. If your device works in Linux, supports monitor mode but cannot be used with EASE, [contact me](mailto:support@adriangranados.com).

## Installation

1. Install [Vagrant](https://www.vagrantup.com/downloads.html), [VirtualBox](https://www.virtualbox.org/wiki/Downloads) and the [VirtualBox Extension Pack](https://www.virtualbox.org/wiki/Downloads) (required to enable USB support in VirtualBox). If you have any of these components already installed, please make sure you're running the latest version.
1. Install the support environment:
```bash
git clone https://github.com/adriangranados/ease.git
cd ease
vagrant up
```

The installation of the environment will take a few minutes as we need to download a clean Debian image and provision it. Once done, EASE is ready to use and you can proceed to attach your external USB Wi-Fi adapter.

## Attaching External USB Adapters to EASE

External USB adapters need to be _attached_ to the EASE VM. Using _VirtualBox's USB Device Filters_ we can configure the environment so that every time you plug in the adapter to the USB port in your computer, the adapter is automatically connected to the EASE VM.

1. Plug in the adapter to any of the USB ports in your Mac.
1. Open VirtualBox and select the EASE VM.
1. Choose Settings > Ports > USB.
1. Add a new USB filter by clicking the icon with the _+_ sign and choosing the adapter you just plugged in.
1. Click OK, then **unplug and plug back in the adapter.**

![USB Device Filters](../master/images/usb-device-filters.png "USB Device Filters")

The adapter will be automatically connected to the EASE VM and made available for Wi-Fi scanning in WiFi Explorer Pro. Repeat the steps above for every adapter you want to use with EASE.

## Using External USB Adapters with WiFi Explorer Pro

Once you have installed EASE and configured the USB device filters to automatically connect the external adapters to the EASE VM, you can choose the adapter from the _Scan Mode_ menu in the WiFi Explorer Pro's toolbar.

![WiFi Explorer Pro's Toolbar](../master/images/wifiexplorerpro-toolbar.png "WiFi Explorer Pro's Toolbar")

## Troubleshooting

If the adapter doesn't appear in WiFi Explorer Pro:
* Make sure you have unplugged and plugged back in the adapter after adding the USB device filter in VirtualBox.
* Make sure the EASE VM is running. If the computer went to sleep, VirtualBox will pause the VM and save the VM state. You can check the status of the VM in VirtualBox or by using the Vagrant CLI.
    ```bash
    cd <directory containing the EASE Vagrantfile>
    vagrant status
    ```
    If the EASE VM is not running, simple type _vagrant up_ from the same directory where the EASE's Vagrantfile is located. 
    ```bash
    cd <directory containing the EASE Vagrantfile>
    vagrant up
    ```
* If nothing helps, you can reboot the EASE VM by typing _vagrant reload_.
    ```bash
    cd <directory containing the EASE Vagrantfile>
    vagrant reload
    ```

If the adapter still doesn't appear in WiFi Explorer Pro, [contact me](mailto:support@adriangranados.com).
