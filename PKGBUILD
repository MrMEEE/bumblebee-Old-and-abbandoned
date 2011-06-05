# This script is incomplete and in development. To install bumblebee use the one in the AUR
# http://aur.archlinux.org/packages.php?ID=49469

# Maintainer: Samsagax <samsagax@gmail.com>

pkgname=bumblebee
pkgver=1.6.10
nvpkgver=270.41.19
pkgrel=3
pkgdesc="Optimus Support for Linux Through VirtualGL. Turning ON/OFF still not supported"
arch=('i686' 'x86_64')
depends=('virtualgl-bin' 'dkms-nvidia')
optdepends=('acpi_call: turn on/off discrete card (not supported yet)')
url="https://github.com/MrMEEE/bumblebee/"
license="GPL3"
install=('bumblebee.install')
conflicts=('nvidia-utils')

if [ "$CARCH" = "i686" ]; then
	_arch='x86'
	_pkg="NVIDIA-Linux-${_arch}-${nvpkgver}"
        md5sums=('c167e32702f56599bd600add97943312' '9ad6873a6d49924849d883f062d6c5f9')
elif [ "$CARCH" = "x86_64" ]; then
	_arch='x86_64'
	_pkg="NVIDIA-Linux-${_arch}-${nvpkgver}"
        md5sums=('b84143ecb5c0511c5ef9e53e732d9136' '9ad6873a6d49924849d883f062d6c5f9')
fi

source=("ftp://download.nvidia.com/XFree86/Linux-${_arch}/${nvpkgver}/${_pkg}.run" "https://github.com/downloads/Samsagax/bumblebee/${pkgname}-${pkgver}-${pkgrel}.tar.gz")

package() {

# Installing nvidia modules
  chmod a+x ${_pkg}.run
  ./${_pkg}.run --extract-only

  cd $srcdir/${_pkg}
  install -D -m755 nvidia_drv.so $pkgdir/usr/lib/nvidia-current/xorg/modules/drivers/nvidia_drv.so
  install -D -m755 libglx.so.${nvpkgver} $pkgdir/usr/lib/nvidia-current/xorg/modules/extensions/libglx.so.${nvpkgver}
  ln -s libglx.so.${nvpkgver} $pkgdir/usr/lib/nvidia-current/xorg/modules/extensions/libglx.so
  install -D -m755 libGL.so.${nvpkgver} $pkgdir/usr/lib/nvidia-current/libGL.so.${nvpkgver}
  install -D -m755 libnvidia-glcore.so.${nvpkgver} $pkgdir/usr/lib/nvidia-current/libnvidia-glcore.so.${nvpkgver}
  install -D -m644 libXvMCNVIDIA.a $pkgdir/usr/lib/nvidia-current/libXvMCNVIDIA.a
  install -D -m755 libXvMCNVIDIA.so.${nvpkgver} $pkgdir/usr/lib/nvidia-current/libXvMCNVIDIA.so.${nvpkgver}
  install -D -m755 libvdpau_nvidia.so.${nvpkgver} $pkgdir/usr/lib/nvidia-current/vdpau/libvdpau_nvidia.so.${nvpkgver}
  install -D -m755 libcuda.so.${nvpkgver} $pkgdir/usr/lib/nvidia-current/libcuda.so.${nvpkgver}
  install -D -m755 libnvcuvid.so.${nvpkgver} $pkgdir/usr/lib/nvidia-current/libnvcuvid.so.${nvpkgver}
  install -D -m755 tls/libnvidia-tls.so.${nvpkgver} $pkgdir/usr/lib/nvidia-current/libnvidia-tls.so.${nvpkgver}
  install -D -m755 libnvidia-compiler.so.${nvpkgver} $pkgdir/usr/lib/nvidia-current/libnvidia-compiler.so.${nvpkgver}
  install -D -m755 libOpenCL.so.1.0.0 $pkgdir/usr/lib/nvidia-current/libOpenCL.so.1.0.0
  install -D -m644 nvidia.icd $pkgdir/etc/OpenCL/vendors/nvidia.icd # not sure if needed
  install -D -m755 libnvidia-cfg.so.${nvpkgver} $pkgdir/usr/lib/nvidia-current/libnvidia-cfg.so.${nvpkgver}
  install -D -m755 libnvidia-ml.so.${nvpkgver} $pkgdir/usr/lib/nvidia-current/libnvidia-ml.so.${nvpkgver}

	for _lib in $(find $pkgdir -name '*.so*'); do
		_soname="$(dirname ${_lib})/$(readelf -d "$_lib" | sed -nr 's/.*Library soname: \[(.*)\].*/\1/p')"
		if [ ! -e "${_soname}" ]; then
			ln -s "$(basename ${_lib})" "${_soname}"
			ln -s "$(basename ${_soname})" "${_soname/.[0-9]*/}"
		fi
	done

  install -D -m644 LICENSE $pkgdir/usr/share/licenses/nvidia/LICENSE
  ln -sf nvidia $pkgdir/usr/share/licenses/nvidia-utils
  install -D -m644 README.txt $pkgdir/usr/share/doc/nvidia/README
  install -D -m644 NVIDIA_Changelog $pkgdir/usr/share/doc/nvidia/NVIDIA_Changelog
  ln -s nvidia $pkgdir/usr/share/doc/nvidia-utils

# Installing Bumblebee scripts

  cd $srcdir/
  install -D -m755 bumblebee/xorg.conf.nvidia $pkgdir/etc/X11/xorg.conf.nvidia
  install -D -m755 bumblebee/bumblebee.default $pkgdir/etc/bumblebee/bumblebee.conf
  install -D -m755 bumblebee/bumblebee.daemon $pkgdir/etc/rc.d/bumblebee
  install -D -m755 bumblebee/bumblebee-bugreport $pkgdir/usr/share/bumblebee/bumblebee-bugreport
  install -D -m755 bumblebee/optirun $pkgdir/usr/bin/optirun
  install -D -m755 bumblebee/bumblebee-enablecard.simple $pkgdir/usr/share/bumblebee/bumblebee-enablecard.default
  install -D -m755 bumblebee/bumblebee-disablecard.simple $pkgdir/usr/share/bumblebee/bumblebee-disablecard.default
  cp -r bumblebee/examples $pkgdir/usr/share/bumblebee/.
}





















