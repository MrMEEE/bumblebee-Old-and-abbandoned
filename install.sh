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

#Determine Arch x86_64 or i686
ARCH=`uname -m`

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

echo "Welcome to the bumblebee installation v.1.2.2"
echo "Licensed under BEER-WARE License and GPL"
echo
echo "This will enable you to utilize both your Intel and nVidia card"
echo
echo "Please note that this script will only work with 64-bit Debian Based machines"
echo "and has only been tested on Ubuntu Natty 11.04 but should work on others as well"
echo "from version v1.1 support for 32-bit Ubuntu has been added"
echo "I will add support for RPM-based distributions later.. or somebody else might..."
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
echo
echo "Installing needed packages"
apt-get -y install nvidia-current

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
cp install-files/virtualgl.conf /etc/modprobe.d/
cp install-files/optimusXserver /usr/local/bin/
cp install-files/bumblebee-bugreport /usr/local/bin/
cp install-files/bumblebee-uninstall /usr/local/bin/

if [ "$ARCH" = "x86_64" ]; then
echo
echo "64-bit system detected"
echo
cp install-files/xdm-optimus-64.bin /usr/bin/xdm-optimus
dpkg -i install-files/VirtualGL_amd64.deb
elif [ "$ARCH" = "i686" ]; then
echo
echo "32-bit system detected"
echo
cp install-files/xdm-optimus-32.bin /usr/bin/xdm-optimus
dpkg -i install-files/VirtualGL_i386.deb
fi

chmod +x /etc/init.d/xdm-optimus
chmod +x /usr/bin/xdm-optimus
chmod +x /usr/local/bin/optimusXserver
chmod +x /usr/local/bin/bumblebee-bugreport

depmod -a

update-alternatives --remove gl_conf /usr/lib/nvidia-current/ld.so.conf
rm /etc/alternatives/xorg_extra_modules 
ln -s /usr/lib/nvidia-current/xorg /etc/alternatives/xorg_extra_modules-bumblebee

ldconfig

if [ "`cat /etc/modprobe.d/blacklist.conf |grep "blacklist nouveau" |wc -l`" -eq "0" ]; then
echo "blacklist nouveau" >> /etc/modprobe.d/blacklist.conf
fi

if [ "`cat /etc/modules |grep "nvidia-current" |wc -l`" -eq "0" ]; then
echo "nvidia-current" >> /etc/modules
fi

modprobe -r nouveau
modprobe nvidia-current

INTELBUSID=`echo "PCI:"\`lspci |grep VGA |grep Intel |cut -f1 -d:\`":"\`lspci |grep VGA |grep Intel |cut -f2 -d: |cut -f1 -d.\`":"\`lspci |grep VGA |grep Intel |cut -f2 -d. |cut -f1 -d" "\``

if [ `lspci |grep VGA |wc -l` -eq 2 ]; then 
   NVIDIABUSID=`echo "PCI:"\`lspci |grep VGA |grep nVidia |cut -f1 -d:\`":"\`lspci |grep VGA |grep nVidia |cut -f2 -d: |cut -f1 -d.\`":"\`lspci |grep VGA |grep nVidia |cut -f2 -d. |cut -f1 -d" "\``
elif [ `lspci |grep 3D |wc -l` -eq 1 ]; then
   NVIDIABUSID=`echo "PCI:"\`lspci |grep 3D |grep nVidia |cut -f1 -d:\`":"\`lspci |grep 3D |grep nVidia |cut -f2 -d: |cut -f1 -d.\`":"\`lspci |grep 3D |grep nVidia |cut -f2 -d. |cut -f1 -d" "\`   
fi


clear

echo
echo "Changing Configuration to match your Machine"
echo 

sed -i 's/REPLACEWITHBUSID/'$INTELBUSID'/g' /etc/X11/xorg.conf
sed -i 's/REPLACEWITHBUSID/'$NVIDIABUSID'/g' /etc/X11/xorg.conf.nvidia

CONNECTEDMONITOR="UNDEFINED"

while [ "$CONNECTEDMONITOR" = "UNDEFINED" ]; do


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
echo "10) Asus U43JC"
echo "11) Samsung RF511"
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

10)
CONNECTEDMONITOR="CRT-0"
;;

11) 
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
export VGL_READBACK" >> /etc/bash.bashrc

if [ "$ARCH" = "x86_64" ]; then
 echo
 echo "64-bit system detected - Configuring"
 echo 
 echo "alias optirun32='vglrun -ld /usr/lib32/nvidia-current'
 alias optirun64='vglrun -ld /usr/lib64/nvidia-current'" >> /etc/bash.bashrc
elif [ "$ARCH" = "i686" ]; then
 echo
 echo "32-bit system detected - Configuring"
 echo
 echo "alias optirun='vglrun -ld /usr/lib/nvidia-current'" >> /etc/bash.bashrc
fi

echo '#!/bin/sh' > /usr/bin/vglclient-service
echo 'vglclient -gl' >> /usr/bin/vglclient-service
chmod +x /usr/bin/vglclient-service
if [ -d $HOME/.kde/Autostart ]; then
   if [ -f $HOME/.kde/Autostart/vlgclient-service ]; then
   	rm $HOME/.kde/Autostart/vglclient-service
   fi
   ln -s /usr/bin/vglclient-service $HOME/.kde/Autostart/vglclient-service
elif [ -d $HOME/.config/autostart ]; then
   if [ -f $HOME/.config/autostart/vlgclient-service ]; then
        rm $HOME/.config/autostart/vglclient-service
   fi
   ln -s /usr/bin/vglclient-service $HOME/.config/autostart/vglclient-service
fi

/etc/init.d/xdm-optimus start
/usr/bin/vglclient-service &

echo
echo
echo
echo "Ok... Installation complete..."
echo
echo "Now you need to make sure that the command \"vglclient -gl\" is run after your Desktop Enviroment is started"
echo
echo "In KDE this is done by this script.. Thanks to Peter Liedler.."
echo
echo "In GNOME this is done by this script.. Thanks to Peter Liedler.."
echo
if [ "$ARCH" = "x86_64" ]; then
echo "After that you should be able to start applications with \"optirun32 <application>\" or \"optirun64 <application>\""
echo "optirun32 can be used for legacy 32-bit applications and Wine Games.. Everything else should work on optirun64"
echo "But... if one doesn't work... try the other"
elif [ "$ARCH" = "i686" ]; then
echo "After that you should be able to start applications with \"optirun <application>\"."
fi
echo
echo "If you have any problems in or after the installation, please try to run the bumblebee-uninstall script and then"
echo "rerun this script... if that doesn't work: please run the bumblebee-bugreport tool and send me a bugreport."
echo 
echo "Or even better.. create an issue on github... this really makes bugfixing much easier for me and faster for you"
echo
echo "Good luck... MrMEEE / Martin Juhl"
echo
echo "http://www.martin-juhl.dk, http://twitter.com/martinjuhl, https://github.com/MrMEEE/bumblebee"


exit 0
