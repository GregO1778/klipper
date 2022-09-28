# [Custom build for CR-10 Smart (CRC-2405V1.2)](https://github.com/Desuuuu/klipper/discussions/74)

This build has been compled form 3 sources.
1) Klipper 3D - https://www.klipper3d.org/ https://github.com/Klipper3d/klipper
2) Klipper with DWIN/DGUS support - https://github.com/Desuuuu/klipper https://github.com/Desuuuu/DGUS-reloaded-Klipper https://github.com/Desuuuu/DGUS-reloaded-Klipper-config https://github.com/Desuuuu/DGUSPrinterMenu https://github.com/Desuuuu/klipper-macros
3) KIAUH installer - https://github.com/th33xitus/kiauh

Additional Installs:
1) Moonraker - https://github.com/Arksine/moonraker
2) Mainsail - https://github.com/mainsail-crew/mainsail
3) Fluidd - https://github.com/fluidd-core/fluidd
4) KlipperScreen - https://github.com/jordanruthe/KlipperScreen
5) OctoPrint - https://github.com/OctoPrint/OctoPrint
7) PrettyGCode - https://github.com/Kragrathea/pgcode
8) TelegramBot - https://github.com/TelegramBots/telegram.bot
9) OctoPrint-Klipper - https://github.com/maxmr/OctoPrint-Klipper
10) mjpg-streamer - https://github.com/jacksonliam/mjpg-streamer

CR-10 Smart configuration files are generic however the printer.cfg has been tested and is currently in use on my own machine.
Do note that My mahine has been upgraded with the Bondtech LGXLit, Bondtech Arrow, MicroSwiss Hotend, z bar backlash spring, adjusted strain gage to use less pressure, and Bed modification to add leveling screws (esintially making this comparable to teh CR-10 Smart Pro)

Note that the touchscreen is still a work in progress

Welcome to the Klipper project!

[![Klipper](docs/img/klipper-logo-small.png)](https://www.klipper3d.org/)

https://www.klipper3d.org/

Klipper is a 3d-Printer firmware. It combines the power of a general
purpose computer with one or more micro-controllers. See the
[features document](https://www.klipper3d.org/Features.html) for more
information on why you should use Klipper.

To begin using Klipper start by
[installing](https://www.klipper3d.org/Installation.html) it.

Klipper is Free Software. See the [license](COPYING) or read the
[documentation](https://www.klipper3d.org/Overview.html). We depend on
the generous support from our
[sponsors](https://www.klipper3d.org/Sponsors.html).

## Modifications

The scope of modifications is limited to adding support for DWIN T5UID1
touchscreens (except for the addition of a `--warn` CLI option, which sets the
logging level to WARNING).

The touchscreen feature is only available for AVR/LPC176X/STM32/SAMD
micro-controllers and it needs to be configured before compilation.

The touchscreen firmware compatible with this fork is available in
[this repository](https://github.com/Desuuuu/DGUS-reloaded-Klipper).

Example configurations are available in
[this repository](https://github.com/Desuuuu/DGUS-reloaded-Klipper-config).

Available configuration options are documented in the
[sample-t5uid1.cfg](/config/sample-t5uid1.cfg) file.




<p align="center">
  <a>
    <img src="https://raw.githubusercontent.com/th33xitus/kiauh/master/resources/screenshots/kiauh.png" alt="KIAUH logo" height="181">
    <h1 align="center">Klipper Installation And Update Helper</h1>
  </a>
</p>

<p align="center">
  A handy installation script that makes installing Klipper (and more) a breeze!
</p>

<p align="center">
  <a><img src="https://img.shields.io/github/license/th33xitus/kiauh"></a>
  <a><img src="https://img.shields.io/github/stars/th33xitus/kiauh"></a>
  <a><img src="https://img.shields.io/github/forks/th33xitus/kiauh"></a>
  <a><img src="https://img.shields.io/github/languages/top/th33xitus/kiauh?logo=gnubash&logoColor=white"></a>
  <a><img src="https://img.shields.io/github/v/tag/th33xitus/kiauh"></a>
  <br />  
  <a><img src="https://img.shields.io/github/last-commit/th33xitus/kiauh"></a>
  <a><img src="https://img.shields.io/github/contributors/th33xitus/kiauh"></a>
</p>

## **🛠️ Instructions:**

For downloading this script it is necessary to have git installed.\
If you haven't, please run `sudo apt-get install git -y` to install git first.\
After git is installed, use the following commands in the given order to download and execute the script:

For the main branch maintained my the creator:
```shell
cd ~

git clone https://github.com/th33xitus/kiauh.git

./kiauh/kiauh.sh
```

For the version included in this repo:
```shell
cd ~

git clone https://github.com/GregO1778/klipper.git

cd ./klipper
./kiauh.sh
```
**📢 Disclaimer: Usage of this script happens at your own risk!**


## **❗ Notes:**

**📋 Please see the [Changelog](docs/changelog.md) for possible important changes!**

- Tested **only** on Raspberry Pi OS Lite (Debian 10 Buster)
    - Other Debian based distributions can work
    - Reported to work on Armbian too
- During the use of this script you might be asked for your sudo password. There are several functions involved which need sudo privileges.

## **🌐 Sources & Further Information**

<table>
<tr>
<th><h3><a href="https://github.com/Klipper3d/klipper">Klipper</a></h3></th>
<th><h3><a href="https://github.com/Arksine/moonraker">Moonraker</a></h3></th>
<th><h3><a href="https://github.com/mainsail-crew/mainsail">Mainsail</a></h3></th>
</tr>
<tr>
<th><img src="https://raw.githubusercontent.com/Klipper3d/klipper/master/docs/img/klipper-logo.png" alt="Klipper Logo" height="64"></th>
<th><img src="https://avatars.githubusercontent.com/u/9563098?v=4" alt="Arksine avatar" height="64"></th>
<th><img src="https://raw.githubusercontent.com/mainsail-crew/docs/master/assets/img/logo.png" alt="Mainsail Logo" height="64"></th>
</tr>
<tr>
<th>by <a href="https://github.com/KevinOConnor">KevinOConnor</a></th>
<th>by <a href="https://github.com/Arksine">Arksine</a></th>
<th>by <a href="https://github.com/mainsail-crew">mainsail-crew</a></th>
</tr>
<tr>
<th><h3><a href="https://github.com/fluidd-core/fluidd">Fluidd</a></h3></th>
<th><h3><a href="https://github.com/jordanruthe/KlipperScreen">KlipperScreen</a></h3></th>
<th><h3><a href="https://github.com/OctoPrint/OctoPrint">OctoPrint</a></h3></th>
</tr>
<tr>
<th><img src="https://raw.githubusercontent.com/fluidd-core/fluidd/master/docs/assets/images/logo.svg" alt="Fluidd Logo" height="64"></th>
<th><img src="https://avatars.githubusercontent.com/u/31575189?v=4" alt="jordanruthe avatar" height="64"></th>
<th><img src="https://camo.githubusercontent.com/627be7fc67195b626b298af9b9677d7c58e698c67305e54324cffbe06130d4a4/68747470733a2f2f6f63746f7072696e742e6f72672f6173736574732f696d672f6c6f676f2e706e67" alt="OctoPrint Logo" height="64"></th>
</tr>
<tr>
<th>by <a href="https://github.com/fluidd-core">fluidd-core</a></th>
<th>by <a href="https://github.com/jordanruthe">jordanruthe</a></th>
<th>by <a href="https://github.com/OctoPrint">OctoPrint</a></th>
</tr>
<th><h3><a href="https://github.com/nlef/moonraker-telegram-bot">Moonraker-Telegram-Bot</a></h3></th>
<th><h3><a href="https://github.com/Kragrathea/pgcode">PrettyGCode for Klipper</a></h3></th>
<th><h3><a href="https://github.com/TheSpaghettiDetective/moonraker-obico">Obico for Klipper</a></h3></th>
<tr>
</tr>
<tr>
<th><img src="https://avatars.githubusercontent.com/u/52351624?v=4" alt="nlef avatar" height="64"></th>
<th><img src="https://avatars.githubusercontent.com/u/5917231?v=4" alt="Kragrathea avatar" height="64"></th>
<th><img src="https://avatars.githubusercontent.com/u/46323662?s=200&v=4" alt="Obico logo" height="64"></th>

</tr>
<tr>
<th>by <a href="https://github.com/nlef">nlef</a></th>
<th>by <a href="https://github.com/Kragrathea">Kragrathea</a></th>
<th>by <a href="https://github.com/TheSpaghettiDetective">Obico</a></th>
</tr>
</table>

## **Credits**

* A big thank you to [lixxbox](https://github.com/lixxbox) for that awesome KIAUH-Logo!
* Also a big thank you to everyone who supported my work with a [Ko-fi](https://ko-fi.com/th33xitus) !
* Last but not least: Thank you to all contributors and members of the Klipper Community who like and share this project!

# klipper-macros

A collection of my Klipper G-code macros.

## Usage
Copy the `macros` folder alongside your printer configuration file and edit it to add:

```
[include macros/*.cfg]
```

## Configuration
You can configure some macros using [SAVE_VARIABLE](https://github.com/KevinOConnor/klipper/blob/master/docs/G-Codes.md#save-variables) in the following way:

```
[save_variables]
filename: ~/variables.cfg

[delayed_gcode macros_initialize]
initial_duration: 1
gcode:
  INITIALIZE_VARIABLE VARIABLE=park_x VALUE=30
  INITIALIZE_VARIABLE VARIABLE=park_y VALUE=30
  INITIALIZE_VARIABLE VARIABLE=bowden_len VALUE=300
```

Here's the list of parameters you can configure:
| Name       | Default      | Description             |
|:----------:|:------------:|:-----------------------:|
| park_x     | *x_min* + 20 | Default X park position |
| park_y     | *y_min* + 20 | Default Y park position |
| bowden_len | 100          | Bowden tube length      |

## Macros
* [G27](/macros/G27.cfg)
* [G29](/macros/G29.cfg)
* [M204](/macros/M204.cfg)
* [M205](/macros/M205.cfg)
* [M600](/macros/M600.cfg)
* [M701](/macros/M701.cfg)
* [M702](/macros/M702.cfg)
* [M900](/macros/M900.cfg)
* [POWEROFF](/macros/POWEROFF.cfg)
* [NOTIFY](/macros/NOTIFY.cfg)
* [LAZY_HOME](/macros/LAZY_HOME.cfg)
* [RETRACT](/macros/RETRACT.cfg)
* [PAUSE_PARK](/macros/PAUSE_PARK.cfg)
* [PRE_START](/macros/PRE_START.cfg)
* [POST_END](/macros/POST_END.cfg)
* [WIPE_LINE](/macros/WIPE_LINE.cfg)
* [INITIALIZE_VARIABLE](/macros/INITIALIZE_VARIABLE.cfg)
* [SAVE_AT_END](/macros/SAVE_AT_END.cfg) by [Makoto](https://klipper.info/macro-examples-1/makotos-conditional-config-saving)
* [SAVE_IF_SET](/macros/SAVE_IF_SET.cfg) by [Makoto](https://klipper.info/macro-examples-1/makotos-conditional-config-saving)
