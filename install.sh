#!/bin/bash

#
# ----------------------------------------------------------------------------
# "THE BEER-WARE LICENSE" (Revision 42):
# <mj@casalogic.dk> wrote this file. As long as you retain this notice you
# can do whatever you want with this stuff. If we meet some day, and you think
# this stuff is worth it, you can buy me a beer in return Martin Juhl
# ----------------------------------------------------------------------------
#

#    This file is part of bumblebee.
#
#    bumblebee is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    bumblebee is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with bumblebee.  If not, see <http://www.gnu.org/licenses/>.
#

ROOT_UID=0

if [ $UID != $ROOT_UID ]; then
    echo "You don't have sufficient privileges to run this script."
    echo
    echo "Please run the script with: sudo install.sh"
    exit 1
fi

if [ $HOME = /root ]; then
    echo "Do not run this script as the root user"
    echo
    echo "Please run the script with: sudo install.sh"
    exit 2
fi

echo "Welcome to the bumblebee installation v.1.0.1"
echo "Licensed under BEER-WARE License and GPL"
echo
echo "This will enable you to utilize both your Intel and nVidia card"
echo
echo "Please note that this script will only work with 64-bit Debian Based machines"
echo "and has only been tested on Ubuntu Natty 11.04 but should work on others as well"
echo "I will add support for RPM-based and 32-bit later.. or somebody else might..."
echo "Remember... This is OpenSource :D"
echo
echo "THIS SCRIPT MUST BE RUN WITH SUDO"
echo
echo "Are you sure you want to proceed?? (Y/N)"
echo

read answer

case "$answer" in

y | Y )
;;

*)
exit 0
;;
esac

clear
echo "Installing needed packages"
apt-get -y install nvidia-current

echo
echo "Copying nVidia Libraries and drivers"
mkdir -p /opt/bumblebee/lib64
mkdir -p /opt/bumblebee/lib32
mkdir -p /opt/bumblebee/driver

cp -a /usr/lib/nvidia-current/* /opt/bumblebee/lib64/
cp -a /usr/lib32/nvidia-current/* /opt/bumblebee/lib32/

cp /lib/modules/`uname -r`/updates/dkms/nvidia-current.ko /opt/bumblebee/driver

echo
echo "Removing conflicting nVidia files"
echo

apt-get -y purge nvidia-current

echo
echo "Backing up Configuration"
if [ `cat /etc/bash.bashrc |grep VGL |wc -l` -ne 0 ]; then
   cp /etc/bash.bashrc.optiorig /etc/bash.bashrc
fi 
cp -n /etc/bash.bashrc /etc/bash.bashrc.optiorig
cp -n /etc/modprobe.d/blacklist.conf /etc/modprobe.d/blacklist.conf.optiorig
cp -n /etc/modules /etc/modules.optiorig
cp -n /etc/X11/xorg.conf /etc/X11/xorg.conf.optiorig

echo
echo "Installing Optimus Configuration and files"
cp install-files/xorg.conf.intel /etc/X11/xorg.conf
cp install-files/xorg.conf.nvidia /etc/X11/
rm -rf /etc/X11/xdm-optimus
cp -a install-files/xdm-optimus /etc/X11/
cp install-files/xdm-optimus.script /etc/init.d/xdm-optimus
cp install-files/xdm-optimus.bin /usr/bin/xdm-optimus
cp install-files/virtualgl.conf /etc/modprobe.d/
cp install-files/optimusXserver /usr/local/bin/
dpkg -i install-files/VirtualGL_amd64.deb
chmod +x /etc/init.d/xdm-optimus
chmod +x /usr/bin/xdm-optimus

cp /opt/bumblebee/driver/nvidia-current.ko /lib/modules/`uname -r`/updates/dkms/
depmod -a
if [ "`cat /etc/modprobe.d/blacklist.conf |grep "blacklist nouveau" |wc -l`" -eq "0" ]; then
echo "blacklist nouveau" >> /etc/modprobe.d/blacklist.conf
fi

if [ "`cat /etc/modules |grep "nvidia" |wc -l`" -eq "0" ]; then
echo "nvidia" >> /etc/modules
fi

modprobe -r nouveau
modprobe nvidia-current

INTELBUSID=`echo "PCI:"\`lspci |grep VGA |grep Intel |cut -f1 -d:\`":"\`lspci |grep VGA |grep Intel |cut -f2 -d: |cut -f1 -d.\`":"\`lspci |grep VGA |grep Intel |cut -f2 -d. |cut -f1 -d" "\``
NVIDIABUSID=`echo "PCI:"\`lspci |grep VGA |grep nVidia |cut -f1 -d:\`":"\`lspci |grep VGA |grep nVidia |cut -f2 -d: |cut -f1 -d.\`":"\`lspci |grep VGA |grep nVidia |cut -f2 -d. |cut -f1 -d" "\``
echo
echo "Changing Configuration to match your Machine"
echo 

sed -i 's/REPLACEWITHBUSID/'$INTELBUSID'/g' /etc/X11/xorg.conf
sed -i 's/REPLACEWITHBUSID/'$NVIDIABUSID'/g' /etc/X11/xorg.conf.nvidia

CONNECTEDMONITOR="UNDEFINED"

while [ "$CONNECTEDMONITOR" = "UNDEFINED" ]; do

clear

echo
echo "Select your Laptop:"
echo "1) Alienware M11X"
echo "2) Dell XPS 15"
echo "3) Asus N61Jv (X64Jv)"
echo "4) Asus EeePC 1215N"
echo "5) Acer Aspire 5745PG"
echo "6) Dell Vostro 3300"
echo "7) Dell XPS 15 (L502x)"
echo "8) Dell Vostro 3400"
echo "9) Toshiba Satellite M645-SP4132L"
echo
echo "97) Manually Set Output to CRT-0"
echo "98) Manually Set Output to DFP-0"
echo "99) Manually Enter Output"

echo
read machine
echo

case "$machine" in

1)
CONNECTEDMONITOR="CRT-0"
;;

2)
CONNECTEDMONITOR="CRT-0"
;;

3)  
CONNECTEDMONITOR="CRT-0"
;;

4)  
CONNECTEDMONITOR="DFP-0"
;;
  
5)  
CONNECTEDMONITOR="DFP-0"
;;
  
6)  
CONNECTEDMONITOR="DFP-0"
;;

7)
CONNECTEDMONITOR="CRT-0"
;;

8)
CONNECTEDMONITOR="CRT-0"
;;

9)
CONNECTEDMONITOR="CRT-0"
;;
    
97)
CONNECTEDMONITOR="CRT-0"
;;

98)
CONNECTEDMONITOR="DFP-0"
;;

99)
echo
echo "Enter output device for nVidia Card"
echo
read manualinput
CONNECTEDMONITOR=`echo $manualinput`
;;


*)
echo
echo "Please choose a valid option, Press any key to try again"
read
clear

;;

esac

done

echo
echo "Setting output device to: $CONNECTEDMONITOR"
echo

sed -i 's/REPLACEWITHCONNECTEDMONITOR/'$CONNECTEDMONITOR'/g' /etc/X11/xorg.conf.nvidia

echo
echo "Enabling Optimus Service"
update-rc.d xdm-optimus defaults

echo
echo "Setting up Enviroment variables"
echo

IMAGETRANSPORT="UNDEFINED"

while [ "$IMAGETRANSPORT" = "UNDEFINED" ]; do

clear

echo
echo "The Image Transport is how the images are transferred from the"
echo "nVidia card to the Intel card, people has different experiences of"
echo "performance, but just select the default if you are in doubt."
echo 
echo "I recently found out that yuv and jpeg both has some lagging"
echo "this is only noticable in fast moving games, such as 1st person"
echo "shooters and for me, its only good enough with xv, even though"
echo "xv sets down performance a little bit."
echo
echo "1) YUV"  
echo "2) JPEG"     
echo "3) PROXY"
echo "4) XV (default)"
echo "5) RGB"  

echo
read machine
echo

case "$machine" in

1)
IMAGETRANSPORT="yuv"
;;

2)
IMAGETRANSPORT="jpeg"    
;;

3)
IMAGETRANSPORT="proxy"    
;;

4)
IMAGETRANSPORT="xv"    
;;

5)
IMAGETRANSPORT="rgb"
;;
*)
echo
echo "Please choose a valid option, Press any key to try again"
read
clear
  
;;
     
esac
done


echo "VGL_DISPLAY=:1
export VGL_DISPLAY
VGL_COMPRESS=$IMAGETRANSPORT
export VGL_COMPRESS
VGL_READBACK=fbo
export VGL_READBACK

alias optirun32='vglrun -ld /opt/bumblebee/lib32'
alias optirun64='vglrun -ld /opt/bumblebee/lib64'" >> /etc/bash.bashrc

echo '#!/bin/sh' > /usr/bin/vglclient-service
echo 'vglclient -gl' >> /usr/bin/vglclient-service
chmod +x /usr/bin/vglclient-service
if [ -d $HOME/.kde/Autostart ]; then
 ln -s /usr/bin/vglclient-service $HOME/.kde/Autostart/vglclient-service
fi
echo
echo
echo
echo "Ok... Installation complete..."
echo
echo "Now you need to make sure that the command \"vglclient -gl\" is run after your Desktop Enviroment is started"
echo
echo "In KDE this is done by this script.. Thanks to Peter Liedler.."
echo
echo "In GNOME this is done by placing a shortcut in ~/.config/autostart/ or using the Adminstration->Sessions GUI"
echo
echo "After that you should be able to start applications with \"optirun32 <application>\" or \"optirun64 <application>\""
echo "optirun32 can be used for legacy 32-bit applications and Wine Games.. Everything else should work on optirun64"
echo "But... if one doesn't work... try the other"
echo
echo "Good luck... MrMEEE / Martin Juhl"
echo
echo "http://www.martin-juhl.dk, http://twitter.com/martinjuhl, https://github.com/MrMEEE/bumblebee"


exit 0
