# This script is incomplete and in development. To install bumblebee use the one in the AUR
# http://aur.archlinux.org/packages.php?ID=49469

# Maintainer: Samsagax <samsagax@gmail.com>

pkgname=bumblebee-nouveau-git
pkgver=20110729
pkgrel=1
pkgdesc="Optimus Support for Linux Through VirtualGL using Nouveau driver. Power Management supported throug Vga-switcheroo"
arch=('i686' 'x86_64')
depends=('virtualgl-bin' 'xf86-video-nouveau' 'pm-utils')
builddepends=("git")
url="https://github.com/Samsagax/bumblebee/tree/nouveau"
license=("GPL3")
install=('bumblebee.install')
provides=("bumblebee")
conflicts=("bumblebee")

_giturl="git://github.com/Samsagax/bumblebee.git"
_gitbranch="nouveau"

build() {
     cd $srcdir/
     git clone -b ${_gitbranch} ${_giturl} --depth 1
}

package() {
  cd $srcdir/bumblebee
  
# Installing Bumblebee scripts
  # Executable files
  install -D -m755 -v arch-scripts/nouveau/bumblebee.daemon ${pkgdir}/usr/bin/bumblebeed
  install -D -m755 -v arch-scripts/nouveau/bumblebee.handler ${pkgdir}/etc/rc.d/bumblebee
  install -D -m755 -v arch-scripts/nouveau/bumblebee.pm ${pkgdir}/usr/lib/pm-utils/power.d/bumblebee
  install -D -m755 -v arch-scripts/nouveau/optirun ${pkgdir}/usr/bin/optirun
  install -D -m755 -v arch-scripts/nouveau/bumblebee-enablecard.switcheroo ${pkgdir}/usr/bin/bumblebee-enablecard
  install -D -m755 -v arch-scripts/nouveau/bumblebee-disablecard.switcheroo ${pkgdir}/usr/bin/bumblebee-disablecard
  
  # Configuration files
  install -D -m644 -v arch-scripts/nouveau/xorg.conf.nouveau ${pkgdir}/etc/bumblebee/xorg.conf.nouveau
  install -D -m644 -v arch-scripts/bumblebee.conf ${pkgdir}/etc/bumblebee/bumblebee.conf
  # Bash completion
  install -D -m644 -v arch-scripts/optirun.bash_completion ${pkgdir}/etc/bash_completion.d/optirun
}

