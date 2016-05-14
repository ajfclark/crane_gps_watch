#! /bin/bash -xeu

# Copyright (C) 2014 - 2015 mru@sisyphus.teil.cc


readonly topdir=$(readlink -f $(dirname $0))
readonly releasedir=release
readonly iscc="$HOME/.wine/drive_c/Program Files (x86)/Inno Setup 5/ISCC.exe"
readonly build_cpu=$(uname -m)


if [[ -e $iscc ]]; then
  echo "using innosetup compiler at $iscc"
else
  echo "inno setup compiler not found"
  exit 1
fi

which i686-w64-mingw32-g++
which x86_64-w64-mingw32-g++


release() {
  local title=$1
  local config="$2"
  local destdir=$releasedir/$title

  mkdir $destdir
  (
  cd $destdir
  $topdir/configure $config
  make -j 10
  # only run test suite if architecture matches current architecture
  if [[ $title =~ $build_cpu ]]; then
    make check
  fi
  if [[ $title =~ win ]]; then
    "$iscc" src/setup.ss
    cp src/Output/setup.exe $topdir/$releasedir/setup-gps_watch-${title}.exe
  fi
  )
}

autoreconf
rm -rf $releasedir
mkdir $releasedir
make distclean || true


release win-i686 "--host i686-w64-mingw32 --build ${build_cpu}-pc-linux-gnu CXX=i686-w64-mingw32-g++ CC=i686-w64-mingw32-gcc"
release win-x86_64 "--host x86_64-w64-mingw32 --build ${build_cpu}-pc-linux-gnu CXX=x86_64-w64-mingw32-g++ CC=x86_64-w64-mingw32-gcc"
#release linux-i686 "--host i686-pc-linux-gnu --build ${build_cpu}-pc-linux-gnu"
# yes, i finally installed a 64bit linux
release linux-${build_cpu} "--host ${build_cpu}-pc-linux-gnu --build ${build_cpu}-pc-linux-gnu"


echo done

