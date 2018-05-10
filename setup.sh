#!/bin/bash

home="$(eval echo ~$user)"

# check, if sudo is used
check_sudo ()
{
    if [[ "$(id -u)" -eq 0 ]]; then
        echo "Script must NOT be run under sudo."
        exit 1
    fi
}

unknown_os ()
{
  echo "Unfortunately, your operating system distribution, version, kernel or drivers are not supported by this script."
  exit 1
}

detect_os ()
{
  if [[ ( -z "${os}" ) && ( -z "${dist}" ) ]]; then
    if [ `which lsb_release 2>/dev/null` ]; then
      dist=`lsb_release -c | cut -f2`
      os=`lsb_release -i | cut -f2 | awk '{ print tolower($1) }'`
    else
      unknown_os
    fi
  fi

  if [ -z "$dist" ]; then
    unknown_os
  fi

  # remove whitespace from OS and dist name
  os="${os// /}"
  dist="${dist// /}"

  echo "Detected operating system as $os/$dist"
}

check_os () {
    detect_os
    
    if [[ "${os}" != "debian" || "${dist}" != "stretch" ]]; then
        unknown_os
    fi
}

check_kernel () {
    if [[ ( -z "${kernel}" ) ]]; then
        kernel=`uname -r`
        if [[ -z "$dist" ]]; then
            unknown_os
        fi
        
        
        
        if [[ "${kernel}" != "4.4.119-rockchip" ]]; then
            echo "Detected kernel version as $kernel"
            unknown_os
        fi
        
        echo "Detected kernel version as $kernel"
    fi
}

check_drivers () {
    if [[ ( -z "${drivers}" ) ]]; then
        drivers=`cat /sys/module/midgard_kbase/version`
        if [[ -z "$drivers" ]]; then
            unknown_os
        fi
        
        
        
        if [[ "${drivers}" != "r14p0-01rel0 (UK version 10.6)" ]]; then
            echo "Detected drivers version as $drivers"
            unknown_os
        fi
        
        echo "Detected drivers version as $drivers"
    fi
}

install () {
    read -p "Do you want to continue, this will update your system and install the required packages and drivers? (Y/N)" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        echo "Updating system"
        
        sudo apt update
        sudo apt upgrade -y
        
        echo "Installing various required packaged"
        sudo apt install -y libtool cmake autoconf automake libdrm2 libx11-6 libx11-data libx11-xcb1 libxau6 libxcb-dri2-0 libxcb1 libxdmcp6 xutils-dev libsdl2-dev libffi-dev libexpat1-dev libxml2-dev libusb-1.0-0-dev libavcodec-dev libavformat-dev libavdevice-dev mpv
        
        echo "Installing kernel headers"
        sudo apt install -y linux-headers-rockchip
        
        echo "Installing requirements for GPU driver"
        sudo apt install -y libdrm2 libx11-6 libx11-data libx11-xcb1 libxau6 libxcb-dri2-0 libxcb1 libxdmcp6
        
        echo "Installing GPU userspace driver"
        wget https://github.com/rockchip-linux/rk-rootfs-build/raw/master/packages/armhf/libmali/libmali-rk-midgard-t76x-r14p0-r0p0_1.6-1_armhf.deb
        sudo dpkg -i libmali-rk-midgard-t76x-r14p0-r0p0_1.6-1_armhf.deb
        wget https://github.com/rockchip-linux/rk-rootfs-build/raw/master/packages/armhf/libmali/libmali-rk-dev_1.6-1_armhf.deb
        sudo dpkg -i libmali-rk-dev_1.6-1_armhf.deb
        
        rm libmali-rk-midgard-t76x-r14p0-r0p0_1.6-1_armhf.deb
        rm libmali-rk-dev_1.6-1_armhf.deb
        
        echo "Installing libDRM with experimental rockchip API support"
        sudo apt install -y xutils-dev
        git clone --branch rockchip-2.4.74 https://github.com/rockchip-linux/libdrm-rockchip.git
        cd libdrm-rockchip
        ./autogen.sh --disable-intel --enable-rockchip-experimental-api --disable-freedreno --disable-tegra --disable-vmwgfx --disable-vc4 --disable-radeon --disable-amdgpu --disable-nouveau
        make -j4 && sudo make install
        cd ~
        rm -rf libdrm-rockchip
        
        echo "Installing libmali"
        git clone --branch rockchip https://github.com/rockchip-linux/libmali.git
        cd libmali
        cmake CMakeLists.txt
        make -j4 -C ~/libmali && sudo make install
        cd ~
        rm -rf libmali
        
        echo "Installing MPP"
        git clone https://github.com/rockchip-linux/mpp.git
        cd mpp
        cmake -src-dir ~/mpp -DRKPLATFORM=ON -DHAVE_DRM=ON
        make -j4 && sudo make install
        cd ~
        rm -rf mpp
        
        echo "Installing Wayland"
        sudo apt install libffi-dev libexpat1-dev
        git clone git://anongit.freedesktop.org/wayland/wayland
        cd wayland
        ./autogen.sh --disable-documentation
        make -j4 && sudo make install
        cd ~
        rm -rf wayland
        
        echo "Cloning Tinkerpie RetroPie fork"
        git clone --depth=1 https://github.com/Tinkerpie/RetroPie-Setup.git
        
        echo "Installation complete. Run 'sudo ~/RetroPie-Setup/retropie_setup.sh' and then reboot your system. Then you can install the packages from RetroPie-Setup."
    fi
    
}

main ()
{
    check_sudo
    check_os
    check_kernel
    check_drivers
    install
}

main
