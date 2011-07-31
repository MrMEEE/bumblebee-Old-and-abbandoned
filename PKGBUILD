# This script is incomplete and in development. To install bumblebee use the one in the AUR
# http://aur.archlinux.org/packages.php?ID=49469

# Maintainer: Samsagax <samsagax@gmail.com>

pkgname=bumblebee
pkgver=1.7.9
pkgrel=1
pkgdesc="Optimus Support for Linux Through VirtualGL. Power management supported with vga-switcheroo"
arch=('i686' 'x86_64')
depends=('pm-utils' 'virtualgl-bin' 'dkms-nvidia' 'nvidia-utils-bumblebee')
optdepends=('acpi_call: turn on/off discrete card (replaces switcheroo)')
if [ "$CARCH" = "x86_64" ]; then
     optdepends[1]=('lib32-nvidia-utils-bumblebee: run 32bit applications with optirun32')
fi
url="https://github.com/Samsagax/bumblebee"
license=("GPL3")
install=('bumblebee.install')
conflicts=("bumblebee-nouveau")
source=("https://github.com/downloads/Samsagax/bumblebee/${pkgname}-${pkgver}-${pkgrel}.tar.gz")
#md5sums=('f3287306837a9ae05dad3959f9401ea3') 

package() {
# Installing Bumblebee scripts
  cd $srcdir/
  # Config files
  install -D -m644 bumblebee/xorg.conf.nvidia $pkgdir/etc/X11/xorg.conf.nvidia
  install -D -m644 bumblebee/bumblebee.conf $pkgdir/etc/bumblebee/bumblebee.conf
  # Executables
  install -D -m755 bumblebee/bumblebee.handler $pkgdir/etc/rc.d/bumblebee
  install -D -m755 bumblebee/bumblebee.daemon $pkgdir/usr/bin/bumblebeed
  install -D -m755 bumblebee/optirun $pkgdir/usr/bin/optirun
  install -D -m755 bumblebee/bumblerun $pkgdir/usr/bin/bumblerun
  
  install -D -m755 bumblebee/bumblebee-bugreport $pkgdir/usr/share/bumblebee/bumblebee-bugreport
  install -D -m755 bumblebee/bumblebee-submitsystem $pkgdir/usr/share/bumblebee/bumblebee-submitsystem
  #Power management
  install -D -m755 bumblebee/bumblebee.pm $pkgdir/usr/lib/pm-utils/power.d/bumblebee
  install -D -m755 bumblebee/bumblebee.sleep.pm $pkgdir/usr/lib/pm-utils/sleep.d/10-bumblebee
  install -D -m755 bumblebee/bumblebee-disablecard.template $pkgdir/usr/bin/bumblebee-disablecard
  install -D -m755 bumblebee/bumblebee-enablecard.template $pkgdir/usr/bin/bumblebee-enablecard

# This won't be needed anymore
  #if [ "$CARCH" = "x86_64" ]; then
  # install -D -m755 bumblebee/optirun32 $pkgdir/usr/bin/optirun32
  #fi
  
  # Example scripts
  cp -v -r bumblebee/power-management $pkgdir/usr/share/bumblebee/.
}





















