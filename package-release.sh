#!/usr/bin/env bash 

set -e

shopt -s extglob

if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 version destdir [--no-package] [--dev-build]"
  exit 1
fi

DXVK_VERSION="$1"
DXVK_SRC_DIR=$(readlink -f "$0")
DXVK_SRC_DIR=$(dirname "$DXVK_SRC_DIR")
DXVK_BUILD_DIR=$(realpath "$2")"/dxvk-$DXVK_VERSION"
DXVK_ARCHIVE_PATH=$(realpath "$2")"/dxvk-$DXVK_VERSION.tar.gz"

if [ -e "$DXVK_BUILD_DIR" ]; then
  echo "Build directory $DXVK_BUILD_DIR already exists"
  exit 1
fi

shift 2

opt_nopackage=0
opt_devbuild=0
opt_buildid=false
opt_64_only=0
opt_32_only=0

crossfile="build-win"

while [ $# -gt 0 ]; do
  case "$1" in
  "--no-package")
    opt_nopackage=1
    ;;
  "--dev-build")
    opt_nopackage=1
    opt_devbuild=1
    ;;
  "--build-id")
    opt_buildid=true
    ;;
  "--64-only")
    opt_64_only=1
    ;;
  "--32-only")
    opt_32_only=1
    ;;
  *)
    echo "Unrecognized option: $1" >&2
    exit 1
  esac
  shift
done

function build_arch {
  export WINEARCH="win$1"
  export WINEPREFIX="$DXVK_BUILD_DIR/wine.$1"
  
  cd "$DXVK_SRC_DIR"

  opt_strip=
  if [ $opt_devbuild -eq 0 ]; then
    opt_strip=--strip
  fi
  #-Dc_args="-fno-pic -fno-pie -finline-functions -fomit-frame-pointer -fno-stack-protector -fno-math-errno -fno-trapping-math -fno-common -fgraphite-identity -floop-nest-optimize -ftree-loop-distribution -fno-semantic-interposition -fipa-pta -fno-plt -ffast-math -ffp-contract=fast -freciprocal-math -ffinite-math-only" \
   #     -Dc_link_args="-flto=full -s -fdata-sections -ffunction-sections -Wl,--gc-sections" \
    #    -Dcpp_args="-std=c++17 -fno-pic -fno-pie -finline-functions -fomit-frame-pointer -fno-stack-protector -fno-math-errno -fno-trapping-math -fno-common -fgraphite-identity -floop-nest-optimize -ftree-loop-distribution -fno-semantic-interposition -fipa-pta -fno-plt -ffast-math -ffp-contract=fast -freciprocal-math -ffinite-math-only" \
     #   -Dcpp_link_args="-flto=full -s -fdata-sections -ffunction-sections -Wl,--gc-sections" \
        
 # -Dc_args="-include /usr/include/wine/wine/windows/d3d11on12.h -fno-pic -fno-pie -finline-functions -fomit-frame-pointer -fno-stack-protector -fno-math-errno -fno-trapping-math -fno-common -fgraphite-identity -floop-nest-optimize -ftree-loop-distribution -fno-semantic-interposition -fipa-pta -fno-plt -ffast-math -ffp-contract=fast -freciprocal-math -ffinite-math-only" \
  # -Dcpp_args="-include /usr/include/wine/wine/windows/d3d11on12.h -fno-pic -fno-pie -finline-functions -fomit-frame-pointer -fno-stack-protector -fno-math-errno -fno-trapping-math -fno-common -fgraphite-identity -floop-nest-optimize -ftree-loop-distribution -fno-semantic-interposition -fipa-pta -fno-plt -ffast-math -ffp-contract=fast -freciprocal-math -ffinite-math-only" \
#-Dc_args="-fprofile-generate=E:\\ --coverage -fprofile-arcs -ftest-coverage -fno-pic -fno-pie -finline-functions -fomit-frame-pointer -fno-stack-protector -fno-math-errno -fno-trapping-math -fno-common -fgraphite-identity -floop-nest-optimize -ftree-loop-distribution -fno-semantic-interposition -fipa-pta -fno-plt -ffast-math -ffp-contract=fast -freciprocal-math -ffinite-math-only" \
       # -Dc_link_args="/usr/lib/gcc/x86_64-w64-mingw32/13-win32/libgcov.a -flto=full -s -fdata-sections -ffunction-sections -Wl,--gc-sections" \
      #  -Dcpp_args="-fprofile-generate=E:\\ --coverage -fprofile-arcs -ftest-coverage -fno-pic -fno-pie -finline-functions -fomit-frame-pointer -fno-stack-protector -fno-math-errno -fno-trapping-math -fno-common -fgraphite-identity -floop-nest-optimize -ftree-loop-distribution -fno-semantic-interposition -fipa-pta -fno-plt -ffast-math -ffp-contract=fast -freciprocal-math -ffinite-math-only" \
       # -Dcpp_link_args="/usr/lib/gcc/x86_64-w64-mingw32/13-win32/libgcov.a -flto=full -s -fdata-sections -ffunction-sections -Wl,--gc-sections" \
        #-Db_sanitize=none \


             
  #CC=llvm-mingw-20241203-msvcrt-ubuntu-20.04-x86_64/bin/x86_64-w64-mingw32-clang CXX=llvm-mingw-20241203-msvcrt-ubuntu-20.04-x86_64/bin/x86_64-w64-mingw32-clang++ 
  meson setup --cross-file "$DXVK_SRC_DIR/$crossfile$1.txt" \
        --buildtype "release"                               \
        --prefix "$DXVK_BUILD_DIR"                          \
        $opt_strip                                          \
        --bindir "x$1"                                      \
        --libdir "x$1" \
        -Dc_args="-fprofile-generate=./ --coverage -fprofile-arcs -ftest-coverage" \
        -Dc_link_args="/usr/lib/gcc/x86_64-w64-mingw32/13-win32/libgcov.a" \
        -Dcpp_args="-fprofile-generate=./ --coverage -fprofile-arcs -ftest-coverage" \
        -Dcpp_link_args="/usr/lib/gcc/x86_64-w64-mingw32/13-win32/libgcov.a" \
        -Db_ndebug=if-release                               \
        -Dbuild_id=$opt_buildid                             \
        "$DXVK_BUILD_DIR/build.$1"

  cd "$DXVK_BUILD_DIR/build.$1"
  ninja install

  if [ $opt_devbuild -eq 0 ]; then
    # get rid of some useless .a files
    rm "$DXVK_BUILD_DIR/x$1/"*.!(dll)
    rm -R "$DXVK_BUILD_DIR/build.$1"
  fi
}

function package {
  cd "$DXVK_BUILD_DIR/.."
  tar -czf "$DXVK_ARCHIVE_PATH" "dxvk-$DXVK_VERSION"
  rm -R "dxvk-$DXVK_VERSION"
}

if [ $opt_32_only -eq 0 ]; then
  build_arch 64
fi
if [ $opt_64_only -eq 0 ]; then
  build_arch 32
fi

if [ $opt_nopackage -eq 0 ]; then
  package
fi
