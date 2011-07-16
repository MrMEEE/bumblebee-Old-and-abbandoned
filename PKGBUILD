# This script is incomplete and in development. To install bumblebee use the one in the AUR
# http://aur.archlinux.org/packages.php?ID=49469

# Maintainer: Samsagax <samsagax@gmail.com>

pkgname=bumblebee
pkgver=1.6.14
pkgrel=1
pkgdesc="Optimus Support for Linux Through VirtualGL. Power Management still not supported"
arch=('i686' 'x86_64')
depends=('virtualgl-bin' "dkms-nvidia" "nvidia-utils-bumblebee")
optdepends=('acpi_call: turn on/off discrete card (not supported yet)')
if [ "$CARCH" = "x86_64" ]; then
     optdepends[1]='lib32-nvidia-utils-bumblebee: run 32bit applications with optirun32'
fi
url="https://github.com/Samsagax/bumblebee"
license=("GPL3")
install=('bumblebee.install')
conflicts=("bumblebee<${pkgver}")
source=("https://github.com/downloads/Samsagax/bumblebee/${pkgname}-${pkgver}-${pkgrel}.tar.gz")
md5sums=('f3287306837a9ae05dad3959f9401ea3') 

package() {
# Installing Bumblebee scripts
  cd $srcdir/
  install -D -m644 bumblebee/xorg.conf.nvidia $pkgdir/etc/X11/xorg.conf.nvidia
  install -D -m644 bumblebee/bumblebee.conf $pkgdir/etc/bumblebee/bumblebee.conf
  install -D -m755 bumblebee/bumblebee.daemon $pkgdir/etc/rc.d/bumblebee
  install -D -m755 bumblebee/bumblebee-bugreport $pkgdir/usr/share/bumblebee/bumblebee-bugreport
  install -D -m755 bumblebee/bumblebee-submitsystem $pkgdir/usr/share/bumblebee/bumblebee-submitsystem
  install -D -m755 bumblebee/optirun $pkgdir/usr/bin/optirun
  if [ "$CARCH" = "x86_64" ]; then
	install -D -m755 bumblebee/optirun32 $pkgdir/usr/bin/optirun32
  fi
  cp -v -r bumblebee/power-management $pkgdir/usr/share/bumblebee/.
}





















