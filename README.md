# Armbian-Setup
A setup script to run on top of Armbian Debian in order to set up the necessary drivers and packages to get RetroPie working.

# Setup

1. Download Armbian Stetch (Legacy Kernel 4.4y) from https://www.armbian.com/tinkerboard - https://dl.armbian.com/tinkerboard/Debian_stretch_default.7z
2. Burn the image to an SD card using Etcher (https://etcher.io/)
3. Boot from the SD card. At the login prompt type *root* with password *1234*.
4. You are required to change your password, first enter the root password again *1234*. Then a new password *tinkerboard*.
5. You are now required to create a new user, for ease of compatiblity with Retropie, we will use *pi*. When asked for a password type *tinkerboard*. This has created a new user *pi* with the password *tinkerboard*. When prompted for *Full Name*, *Room Number*, *Work Phone*, *Home Phone* and *Other* just press Enter.
6. To set up WiFi - Type *sudo armbian-config*. Go to *Network* and then *wlan0*. Go to *WiFi* then choose your SSID and enter your password. Don't set up bluetooth or anything yet. Go back to the command prompt once you have an Internet conection.
7. Type *wget https://github.com/Tinkerpie/Armbian-Setup/raw/master/setup.sh*, *sudo chmod +x setup.sh* and then *./setup.sh*.
8. Once everything has installed, run RetroPie-Setup/retropie_setup.sh as indicated in the output of the above script and install core packages and restart.
