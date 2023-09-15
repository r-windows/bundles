#!/bin/sh
set -e

prepare_pacman(){
  curl -sSL https://raw.githubusercontent.com/r-windows/rtools-next/master/pacman.conf > /etc/pacman.conf
  pacman -Scc
  pacman -Syy
}

arch_prefix(){
  echo "$1" | sed "s/[^ ]* */mingw-w64-${arch}-&/g"
}

download_libs(){
  # Download files (-dd skips dependencies)
  pkg=$(arch_prefix $package)
  if [ "$deps" ]; then
    pkgdeps=$(arch_prefix $deps)
  else
    pkgdeps=$(pacman -Si $pkg | grep 'Depends On' | grep -o 'mingw-w64-[_.a-z0-9-]*')
  fi

  OUTPUT=$(mktemp -d)
  URLS=$(pacman -Sp $pkg $pkgdeps --cache=$OUTPUT)
  VERSION=$(pacman -Si $pkg | awk '/^Version/{print $3}')
  for URL in $URLS; do
    curl -OLs $URL
    FILE=$(basename $URL)
    echo "Extracting: $FILE"
    echo " - $FILE" >> readme.md
    tar xf $FILE -C ${OUTPUT}
    unlink $FILE
  done

  bundle="$package-$arch"
  mkdir -p $bundle/lib
  cp -Rv ${OUTPUT}/*/include $bundle/
  cp -v ${OUTPUT}/*/lib/*.a $bundle/lib/
  tar cfJ "$bundle.tar.xz" $bundle
  rm -Rf $bundle
}

create_bundles() {
  prepare_pacman
  arch="ucrt-x86_64" download_libs
}
