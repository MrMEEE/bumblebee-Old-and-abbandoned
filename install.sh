#!/bin/bash -l

# ----------------------------------------------------------------------------
# "Red Bull License"
# <mj@casalogic.dk> wrote this file and is providing free support
# in any spare time. If you need extended support, you can fuel him up by
# donating a Red Bull here to get him through the nights..:
#
# https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=mj%40casalogic
# %2edk&lc=US&item_name=The%20Bumblebee%20Project%20by%20Martin%20Juhl&amount=
# 3%2e00&currency_code=EUR&currency_code=EUR&bn=PP%2dDonationsBF%3abtn_donateC
# C_LG%2egif%3aNonHosted
# 
# ----------------------------------------------------------------------------

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
BUMBLEBEEVERSION=1.4.28


ROOT_UID=0

#Determine Arch x86_64 or i686
ARCH=`uname -m`

#Get tools location 
LSPCI=`which lspci`
MODPROBE=`which modprobe`

if [ `cat /etc/issue |grep -nir fedora |wc -l` -gt 0 ]; then
  DISTRO=FEDORA
  BASHRC=/etc/bashrc
elif [ `cat /etc/issue |grep -nir ubuntu |wc -l` -gt 0 ]; then
  DISTRO=UBUNTU
  BASHRC=/etc/bash.bashrc
elif [ `cat /etc/issue |grep -nir openSUSE |wc -l` -gt 0 ]; then
  DISTRO=OPENSUSE
  BASHRC=/etc/bash.bashrc
  ROOT_UID=1000
elif [ `cat /etc/issue |grep -nir debian |wc -l` -gt 0 ]; then
  DISTRO=DEBIAN
  BASHRC=/etc/bash.bashrc
elif [ `cat /etc/issue |grep -nir "Arch Linux" |wc -l` -gt 0  ]; then
  DISTRO=ARCH
  echo "You are running Arch Linux, please see the buildscript here for support:"
  echo
  echo "http://aur.archlinux.org/packages.php?ID=48866"
  echo 
  read
  exit 0
elif [ `cat /etc/issue |grep -nir "gentoo" |wc -l` -gt 0  ]; then
  DISTRO=GENTOO
  echo "You are running Gento Linux, please see the ebuild here for support:"
  echo
  echo "https://github.com/iegor/bumblebee-Gentoo-support"
  echo
  read
  exit 0
fi

echo
echo $DISTRO" distribution found."
echo


if [ $UID != $ROOT_UID ] || [ $HOME = /root ]; then
  echo "You don't have sufficient privileges to run this script."
  echo
  echo "Do not run this script as the root user."
  echo
  case "$DISTRO" in
   FEDORA | DEBIAN)
    echo "Please run the script with: sudo -E install.sh"
   ;;
   *)
    echo "Please run the script with: sudo install.sh"
   ;;
  esac
  exit 1
fi

echo "Welcome to the bumblebee installation v."$BUMBLEBEEVERSION
echo "Licensed under Red Bull, BEER-WARE License and GPL"
echo
echo "This will enable you to utilize both your Intel and nVidia card"
echo
echo "Please note that this script will probably only work with Ubuntu, Debian, OpenSuSE and Fedora Based machines"
echo "and has (by me) only been tested on Ubuntu Natty 11.04 and Fedora 14 but should work on others as well"
echo
echo "Are you sure you want to proceed?? (Y/N)"

read answer

case "$answer" in

y | Y )
;;

*)
exit 0
;;
esac

clear

BUMBLEBEEPWD=$PWD

echo
echo "Installing needed packages."
echo 

case "$DISTRO" in

 UBUNTU)
  VERSION=`cat /etc/issue | cut -f2 -d" "`
  if [ $VERSION = 11.04 ]; then 
   echo
   echo "Ubuntu 11.04 Detected." 
   echo
  else 
   echo
   echo "Ubuntu "$VERSION" Detected."
   echo "Adding X-Swat Driver Repository."
   echo
   apt-add-repository ppa:ubuntu-x-swat/x-updates
  fi
  apt-get update
  apt-get -y install nvidia-current screen
  if [ $? -ne 0 ]; then
   echo
   echo "Package manager failed to install needed packages..."
   echo
   exit 21
  fi
  ${MODPROBE} -r nouveau
  ${MODPROBE} nvidia-current
 ;;
 
 FEDORA)
  yum -y install wget binutils gcc kernel-devel mesa-libGL mesa-libGLU
  if [ $? -ne 0 ]; then
   echo 
   echo "Package manager failed to install needed packages..."
   echo     
   exit 21       
  fi
  rm -rf /tmp/NVIDIA*
  echo "Getting latest NVidia drivers version"
  NV_DRIVERS_VERSION=`wget -q -O - http://www.nvidia.com/object/unix.html | grep "Linux x86_64/AMD64/EM64T" | cut -f5 -d">" | cut -f1 -d"<"`
  echo "Latest NVidia drivers version is $NV_DRIVERS_VERSION"
  if [ "$ARCH" = "x86_64" ]; then  
    wget http://us.download.nvidia.com/XFree86/Linux-x86_64/${NV_DRIVERS_VERSION}/NVIDIA-Linux-x86_64-${NV_DRIVERS_VERSION}.run -O /tmp/NVIDIA-Linux-driver.run    
  elif [ "$ARCH" = "i686" ]; then
    wget http://us.download.nvidia.com/XFree86/Linux-x86/${NV_DRIVERS_VERSION}/NVIDIA-Linux-x86-${NV_DRIVERS_VERSION}.run -O /tmp/NVIDIA-Linux-driver.run
  fi
  chmod +x /tmp/NVIDIA-Linux-driver.run
  cd /tmp/
  /tmp/NVIDIA-Linux-driver.run -x
  if [ "$ARCH" = "x86_64" ]; then
    cd /tmp/NVIDIA-Linux-x86_64-${NV_DRIVERS_VERSION}/kernel
  elif [ "$ARCH" = "i686" ]; then
    cd /tmp/NVIDIA-Linux-x86-${NV_DRIVERS_VERSION}/kernel
  fi
  make install
  cd $BUMBLEBEEPWD
  depmod -a
  ldconfig 
  ${MODPROBE} -r nouveau
  ${MODPROBE} nvidia
  
  if [ "$ARCH" = "x86_64" ]; then
   rm -rf /usr/lib64/nvidia-current/
   rm -rf /usr/lib/nvidia-current/
   rm -rf /usr/lib32/nvidia-current/
   mkdir -p /usr/lib64/nvidia-current/
   mv /tmp/NVIDIA-Linux-x86_64-${NV_DRIVERS_VERSION}/* /usr/lib64/nvidia-current/
   ln -s /usr/lib64/nvidia-current/32 /usr/lib/nvidia-current
   mkdir -p /usr/lib64/nvidia-current/xorg
   ln -s /usr/lib64/nvidia-current/libglx.so.${NV_DRIVERS_VERSION} /usr/lib64/nvidia-current/xorg/libglx.so
   ln -s /usr/lib64/nvidia-current/nvidia_drv.so /usr/lib64/nvidia-current/xorg/nvidia_drv.so
   rm -rf /usr/lib64/nvidia-current/xorg/xorg
   ln -s /usr/lib64/nvidia-current/xorg/ /usr/lib/nvidia-current/xorg
   rm -rf /usr/lib64/xorg/xorg
   ln -s /usr/lib64/xorg/ /usr/lib/xorg
  elif [ "$ARCH" = "i686" ]; then
   rm -rf /usr/lib/nvidia-current/
   mkdir -p /usr/lib/nvidia-current/
   mv /tmp/NVIDIA-Linux-x86-${NV_DRIVERS_VERSION}/* /usr/lib/nvidia-current/
   mkdir -p /usr/lib/nvidia-current/xorg
   ln -s /usr/lib/nvidia-current/libglx.so.${NV_DRIVERS_VERSION} /usr/lib/nvidia-current/xorg/libglx.so
   ln -s /usr/lib/nvidia-current/nvidia_drv.so /usr/lib/nvidia-current/xorg/nvidia_drv.so
  fi
  echo
  echo "Regenerating initramfs."
  echo
  mkinitrd -f /boot/initramfs-$(uname -r).img $(uname -r)
 ;;
 OPENSUSE)
  VERSION=`cat /etc/issue |grep openSUSE | cut -f4 -d" "`
  echo "Do you want me to install NVidia repository for openSUSE $VERSION (y/n) ?"
  read answer
  case "$answer" in
   y|Y)
    zypper ar -f ftp://download.nvidia.com/opensuse/${VERSION}/nvidia
    if [ $? -ne 0 ]; then
     echo
     echo "Package manager failed to install needed packages..."
     echo
     exit 21
    fi
    zypper update
   ;;
   n|N)
    echo "NVidia drivers repository will NOT be installed."
   ;;
   *)
   ;;
  esac
  echo "What is your NVidia card family ?"
  echo "1) GF6 or newer"
  echo "2) FX5XXX"
  echo "3) GF4 or older"
  echo "4) Skip NVidia drivers install (you need to do this by yourself in this case)"
  read card

  case $card in
   1)
    zypper install x11-video-nvidiaG02
   ;;
   2)
    zypper install x11-video-nvidiaG01
   ;;
   3)
    zypper install x11-video-nvidiaG01
   ;;
   4)
    echo "Skip drivers installation. Please remember that NVidia drivers *HAVE TO BE INSTALLED*"

   ;;
   *)
    echo
    echo "Please choose a valid option, Press any key to try again"
    read
   ;;
   DEBIAN)
    apt-get update
    apt-get -y install nvidia-kernel-dkms nvidia-glx
    apt-get -y --reinstall install xserver-xorg-core
    if [ $? -ne 0 ]; then
     echo
     echo "Package manager failed to install needed packages..."
     echo "Please check that you have non-free repository enabled."
     echo
     exit 21
    fi
   ;;
  esac
 ${MODPROBE} -r nouveau
 ${MODPROBE} nvidia
esac


echo
echo "Backing up Configuration"
echo

if [ `cat $BASHRC |grep VGL |wc -l` -ne 0 ]; then
   cp $BASHRC.optiorig $BASHRC
fi

cp -n /etc/modules /etc/modules.optiorig
cp -n /etc/X11/xorg.conf /etc/X11/xorg.conf.optiorig

echo
echo "Installing Optimus Configuration and files"
echo

cp install-files/xorg.conf.intel /etc/X11/xorg.conf
cp install-files/xorg.conf.nvidia /etc/X11/

if [ ! -f /usr/local/bin/bumblebee-enablecard ]; then
 # Not installed
 cp install-files/bumblebee-enablecard /usr/local/bin/
else
 # Already Exists
 echo
 echo "nVidia card enable-script: /usr/local/bin/bumblebee-enablecard, already exists not overwriting"
 echo
fi

if [ ! -f /usr/local/bin/bumblebee-disablecard ]; then
 # Not installed
 cp install-files/bumblebee-disablecard /usr/local/bin/
else
 # Already Exists
 echo
 echo "nVidia card disable-script: /usr/local/bin/bumblebee-disablecard, already exists not overwriting"    
 echo
fi

cp -n $BASHRC $BASHRC.optiorig

case "$DISTRO" in

 UBUNTU)
  if [ "$ARCH" = "x86_64" ]; then
   echo
   echo "64-bit system detected"
   echo
   dpkg -i install-files/VirtualGL_amd64.deb
  elif [ "$ARCH" = "i686" ]; then
   echo
   echo "32-bit system detected"
   echo
   dpkg -i install-files/VirtualGL_i386.deb
  fi
  if [ $? -ne 0 ]; then
   echo
   echo "Package manager failed to install VirtualGL..."
   echo
   exit 20
  fi
  cp install-files/bumblebee.script.ubuntu /etc/init.d/bumblebee
#  update-alternatives --remove gl_conf /usr/lib/nvidia-current/ld.so.conf
  rm /etc/alternatives/gl_conf
  ln -s /usr/lib/mesa/ld.so.conf /etc/alternatives/gl_conf
  rm /etc/alternatives/xorg_extra_modules
  rm /etc/alternatives/xorg_extra_modules-bumblebee
  rm /usr/lib/nvidia-current/xorg/xorg
  ln -s /usr/lib/nvidia-current/xorg /etc/alternatives/xorg_extra_modules-bumblebee
  ldconfig 
 ;;
 DEBIAN)
 rm /etc/alternatives/libglx.so
 rm /etc/alternatives/libGL.so
 rm /etc/alternatives/libGL.so.1
 rm /usr/lib/xorg/modules/drivers/nvidia_drv.so
# rm -rf /usr/lib/xorg/extra-modules
 if [ "$ARCH" = "x86_64" ]; then
  echo
  echo "64-bit system detected"
  echo
  dpkg -i install-files/VirtualGL_amd64.deb
  ln -s /usr/lib64/xorg/modules/extensions/libglx.so /etc/alternatives/libglx.so
  ln -s /usr/lib64/libGL.so /etc/alternatives/libGL.so
  ln -s /usr/lib64/libGL.so.1 /etc/alternatives/libGL.so.1
 elif [ "$ARCH" = "i686" ]; then
  echo
  echo "32-bit system detected"
  echo
  ln -s /usr/lib/xorg/modules/extensions/libglx.so /etc/alternatives/libglx.so
  ln -s /usr/lib/libGL.so /etc/alternatives/libGL.so
  ln -s /usr/lib/libGL.so.1 /etc/alternatives/libGL.so.1
  dpkg -i install-files/VirtualGL_i386.deb
 fi
 if [ $? -ne 0 ]; then
  echo
  echo "Package manager failed to install VirtualGL..."
  echo
  exit 20
 fi
 cp install-files/bumblebee.script.debian /etc/init.d/bumblebee
 mkdir /usr/local/lib/bumblebee
 ln -s /usr/lib/nvidia/libglx.so /usr/local/lib/bumblebee/libglx.so
 ldconfig
 ;;
 FEDORA)
  cp install-files/bumblebee.script.fedora /etc/init.d/bumblebee
  if [ "$ARCH" = "x86_64" ]; then
   echo
   echo "64-bit system detected"
   echo
   echo $PWD
   yum -y --nogpgcheck install install-files/VirtualGL.x86_64.rpm
   sed -i 's$/usr/lib/$/usr/lib64/$g' /etc/init.d/bumblebee
  elif [ "$ARCH" = "i686" ]; then
   echo
   echo "32-bit system detected"
   echo
   yum -y --nogpgcheck install install-files/VirtualGL.i386.rpm
  fi
  if [ $? -ne 0 ]; then
   echo
   echo "Package manager failed to install VirtualGL..."
   echo
   exit 20
  fi
 ;;
 OPENSUSE)
  cp install-files/bumblebee.script.openSUSE /etc/init.d/bumblebee
  if [ "$ARCH" = "x86_64" ]; then   
   echo
   echo "64-bit system detected"
   echo
   echo $PWD
   zypper --no-gpg-check install -l install-files/VirtualGL.x86_64.rpm
  elif [ "$ARCH" = "i686" ]; then
   echo
   echo "32-bit system detected"
   echo
   zypper --no-gpg-check install -l install-files/VirtualGL.i386.rpm
  fi
  if [ $? -ne 0 ]; then
   echo
   echo "Package manager failed to install VirtualGL..."
   echo
   exit 20
  fi
 ;; 
esac

cp install-files/virtualgl.conf /etc/modprobe.d/
cp install-files/bumblebee-bugreport /usr/local/bin/
cp install-files/bumblebee-uninstall /usr/local/bin/
cp install-files/bumblebee-config /usr/local/bin/
chmod +x /etc/init.d/bumblebee
chmod +x /usr/local/bin/bumblebee-bugreport
chmod +x /usr/local/bin/bumblebee-uninstall
chmod +x /usr/local/bin/bumblebee-config
chmod +x /usr/local/bin/bumblebee-enablecard
chmod +x /usr/local/bin/bumblebee-disablecard

case "$DISTRO" in

UBUNTU | OPENSUSE)
if [ "$ARCH" = "x86_64" ]; then
 cp install-files/optirun32.ubuntu /usr/local/bin/optirun32
 cp install-files/optirun64.ubuntu /usr/local/bin/optirun64
else
 cp install-files/optirun64.ubuntu /usr/local/bin/optirun
fi
;;

FEDORA)
if [ "$ARCH" = "x86_64" ]; then
 cp install-files/optirun32.fedora /usr/local/bin/optirun32
 cp install-files/optirun64.fedora /usr/local/bin/optirun64
else
 cp install-files/optirun32.fedora /usr/local/bin/optirun
fi
;;

DEBIAN)
if [ "$ARCH" = "x86_64" ]; then
 cp install-files/optirun32.debian /usr/local/bin/optirun32
 cp install-files/optirun64.debian /usr/local/bin/optirun64
else
 cp install-files/optirun64.debian /usr/local/bin/optirun
fi
;;

esac

chmod +x /usr/local/bin/optirun*

case "$DISTRO" in

UBUNTU)
if [ "`cat /etc/modules |grep "nvidia-current" |wc -l`" -eq "0" ]; then
  echo "nvidia-current" >> /etc/modules
fi
;;
OPENSUSE | DEBIAN | FEDORA)
if [ "`cat /etc/modules |grep "nvidia-current" |wc -l`" -eq "0" ]; then
  echo "nvidia" >> /etc/modules
fi
;;
esac

if [ "`cat /etc/modprobe.d/blacklist.conf |grep "blacklist nouveau" |wc -l`" -ne "0" ]; then
  grep -Ev 'nouveau' /etc/modprobe.d/blacklist.conf > /etc/modprobe.d/blacklist.conf.tmp
  mv /etc/modprobe.d/blacklist.conf.tmp /etc/modprobe.d/blacklist.conf
fi

echo "blacklist nouveau" >> /etc/modprobe.d/nouveau-blacklist.conf

INTELBUSID=`echo "PCI:"\`${LSPCI} |grep VGA |grep Intel |cut -f1 -d:\`":"\`${LSPCI} |grep VGA |grep Intel |cut -f2 -d: |cut -f1 -d.\`":"\`${LSPCI} |grep VGA |grep Intel |cut -f2 -d. |cut -f1 -d" "\``
if [ `${LSPCI} |grep VGA |wc -l` -eq 2 ]; then 
   NVIDIABUSID=`echo "PCI:"\`${LSPCI} |grep VGA |grep nVidia |cut -f1 -d:\`":"\`${LSPCI} |grep VGA |grep nVidia |cut -f2 -d: |cut -f1 -d.\`":"\`${LSPCI} |grep VGA |grep nVidia |cut -f2 -d. |cut -f1 -d" "\``
elif [ `${LSPCI} |grep 3D |wc -l` -eq 1 ]; then
   NVIDIABUSID=`echo "PCI:"\`${LSPCI} |grep 3D |grep nVidia |cut -f1 -d:\`":"\`${LSPCI} |grep 3D |grep nVidia |cut -f2 -d: |cut -f1 -d.\`":"\`${LSPCI} |grep 3D |grep nVidia |cut -f2 -d. |cut -f1 -d" "\``   
else
 echo 
 echo "The BusID of the nVidia card can't be determined."
 echo "You must correct this manually in /etc/X11/xorg.conf.nvidia"
 echo "Please report this problem.."
 echo
 echo "Press Any Key to continue."
 echo
 read 
fi

clear

echo
echo "Changing Configuration to match your Machine."
echo 

sed -i 's/REPLACEWITHBUSID/'$INTELBUSID'/g' /etc/X11/xorg.conf
sed -i 's/REPLACEWITHBUSID/'$NVIDIABUSID'/g' /etc/X11/xorg.conf.nvidia

CONNECTEDMONITOR="UNDEFINED"

echo
echo "Auto-detecting hardware"
echo

case "$DISTRO" in

 UBUNTU)
  if [ `LD_LIBRARY_PATH=/usr/lib/nvidia-current /usr/lib/nvidia-current/bin/nvidia-xconfig  --query-gpu-info |grep "Display Devices" |cut -f2 -d":"` -gt 0 ]; then
   CONNECTEDMONITOR=`LD_LIBRARY_PATH=/usr/lib/nvidia-current /usr/lib/nvidia-current/bin/nvidia-xconfig  --query-gpu-info |grep "Display Device 0" | cut -f2 -d\( | cut -f1 -d\)`
  fi
 ;;

esac

while [ "$CONNECTEDMONITOR" = "UNDEFINED" ]; do


echo
echo "Select your Laptop:"
echo "1) Alienware M11X"
echo "2) Dell XPS 15/17"
echo "3) CLEVO W150HNQ"
echo "4) Asus EeePC 1215N"
echo "5) Acer Aspire 5745PG/5742G"
echo "6) Dell Vostro 3300"
echo "7) Dell Vostro 3400/3500"
echo "8) Samsung RF511/RF711/QX410-J01"
echo "9) Toshiba Satellite M645-SP4132L"
echo "10) Asus U30J/U35J/U36JC/U43JC/U35JC/U43JC/U53JC/P52JC/K52JC/X52JC/N53SV/N61JV/X64JV"
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
CONNECTEDMONITOR="DFP-0"
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
echo

case "$DISTRO" in
 UBUNTU)
  update-rc.d -f bumblebee remove
 ;; 
 DEBIAN)
  update-rc.d bumblebee defaults
 ;;
 FEDORA | OPENSUSE)
  chkconfig bumblebee on
 ;;
esac


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
echo "Please choose a valid option, Press any key to try again."
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
export VGL_READBACK" >> $BASHRC

echo '#!/bin/sh' > /usr/bin/vglclient-service
echo 'vglclient -gl' >> /usr/bin/vglclient-service
chmod +x /usr/bin/vglclient-service
if [ -d $HOME/.kde4/Autostart ]; then
   if [ -f $HOME/.kde4/Autostart/vglclient-service ]; then
   	rm $HOME/.kde4/Autostart/vglclient-service
   fi
   ln -s /usr/bin/vglclient-service $HOME/.kde4/Autostart/vglclient-service
elif [ -d $HOME/.kde/Autostart ]; then
   if [ -f $HOME/.kde/Autostart/vglclient-service ]; then
   	rm $HOME/.kde/Autostart/vglclient-service
   fi
   ln -s /usr/bin/vglclient-service $HOME/.kde/Autostart/vglclient-service
fi
if [ -d $HOME/.config/autostart ]; then
   if [ -f $HOME/.config/autostart/vglclient-service ]; then
        rm $HOME/.config/autostart/vglclient-service
   fi
   ln -s /usr/bin/vglclient-service $HOME/.config/autostart/vglclient-service
fi

echo
echo "Starting Services:"
echo
# Should be removed when changes from v.1.4.19+20 has been implemented on Fedora, OpenSuSE and Debian.

if [ "$DISTRO" != UBUNTU ]; then 
/etc/init.d/bumblebee start
/usr/bin/vglclient-service &
fi

echo
echo "Setting up bumblebee user rights."
echo
#Support for starting/stopping the Bumblebee services ondemand.
case "$DISTRO" in 
UBUNTU)
groupadd bumblebee
gpasswd -a `env |grep SUDO_USER |cut -f2 -d=` bumblebee
grep -Ev 'bumblebee' /etc/sudoers > /etc/sudoers.optiorig
mv /etc/sudoers.optiorig /etc/sudoers
echo "%bumblebee      ALL=(ALL:ALL) NOPASSWD: /etc/init.d/bumblebee" >> /etc/sudoers
chmod 0440 /etc/sudoers
;;
esac

echo
echo
echo
echo "Ok... Installation complete..."
echo
# Should be removed when changes from v.1.4.19+20 has been implemented on Fedora, OpenSuSE and Debian.

if [ "$DISTRO" != UBUNTU ]; then
 echo "Now you need to make sure that the command \"vglclient -gl\" is run after your Desktop Enviroment is started"
 echo
 echo "In KDE this is done by this script.. Thanks to Peter Liedler."
 echo
 echo "In GNOME this is done by this script.. Thanks to Peter Liedler."
 echo
else
 echo "Please logout and back in to activate new groups."
 echo
 echo "If you want power saving by shutting the nVidia down when not in use. Please adjust the scripts:"
 echo "/usr/local/bin/bumblebee-enablecard and /usr/local/bin/bumblebee-disablecard for your machine."
 echo
fi
if [ "$ARCH" = "x86_64" ]; then
echo "After that you should be able to start applications with \"optirun32 <application>\" or \"optirun64 <application>\""
echo "optirun32 can be used for legacy 32-bit applications and Wine Games.. Everything else should work on optirun64"
echo "But... if one doesn't work... try the other."
elif [ "$ARCH" = "i686" ]; then
echo "After that you should be able to start applications with \"optirun <application>\"."
fi
echo
echo "If you have any problems in or after the installation, please try to run the bumblebee-uninstall script and then"
echo "rerun this script... if that doesn't work: please run the bumblebee-bugreport tool and send me a bugreport."
echo 
echo "Or even better.. create an issue on github... this really makes bugfixing much easier for me and faster for you."
echo
echo "If you need to reconfigure bumblebee the script bumblebee-config as available."
echo
echo "Good luck... MrMEEE / Martin Juhl"
echo
echo "http://www.martin-juhl.dk, http://twitter.com/martinjuhl, https://github.com/MrMEEE/bumblebee"

echo "Bumblebee Version: "$BUMBLEBEEVERSION > /etc/bumblebee

exit 0
