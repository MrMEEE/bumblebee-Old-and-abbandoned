#!/bin/bash

# Run as root or won't work

INS_DIR=/usr/share/nouveau-bumblebee

echo "Installing files..."
mkdir -v -p $INS_DIR
mkdir -v -p /etc/bumblebee

# Executable files
install -m755 -v arch-scripts/nouveau/daemon.test $INS_DIR/bumblebee
install -m755 -v arch-scripts/nouveau/optirun.test /usr/bin/optirun
install -m755 -v arch-scripts/nouveau/bumblebee-enablecard.switcheroo $INS_DIR/bumblebee-enablecard
install -m755 -v arch-scripts/nouveau/bumblebee-disablecard.switcheroo $INS_DIR/bumblebee-disablecard
ln -s $INS_DIR/bumblebee-disablecard /etc/pm/power.d/10-bumblebee-disablecard

# Configuration files
install -m644 -v arch-scripts/nouveau/xorg.conf.nouveau /etc/bumblebee/xorg.conf.nouveau
install -m644 -v arch-scripts/bumblebee.conf /etc/bumblebee/bumblebee.conf

# Replace BusID in configuration file.
if [ `lspci |grep VGA |wc -l` -eq 2 ]; then 
   NVIDIABUSID=`echo "PCI:"\`lspci |grep VGA |grep nVidia |cut -f1 -d:\`":"\`lspci |grep VGA |grep nVidia |cut -f2 -d: |cut -f1 -d.\`":"\`lspci |grep VGA |grep nVidia |cut -f2 -d. |cut -f1 -d" "\``
elif [ `lspci |grep 3D |wc -l` -eq 1 ]; then
   NVIDIABUSID=`echo "PCI:"\`lspci |grep 3D |grep nVidia |cut -f1 -d:\`":"\`lspci |grep 3D |grep nVidia |cut -f2 -d: |cut -f1 -d.\`":"\`lspci |grep 3D |grep nVidia |cut -f2 -d. |cut -f1 -d" "\``   
else
echo "The BusID of the nVidia card can't be determined"
echo "You must correct this manually in /etc/bumblebee/xorg.conf.nouveau"
fi
echo "Changing Configuration to match your Machine"
echo 
sed -i 's/REPLACEWITHBUSID/'$NVIDIABUSID'/g' /etc/bumblebee/xorg.conf.nouveau

# echo "Install complete. Make sure Nvidia proprietary module is not loaded"
# echo "or Bumblebee(nouveau) will fail"

