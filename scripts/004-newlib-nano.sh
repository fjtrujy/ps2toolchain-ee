#!/bin/bash
# 004-newlib-nano.sh by Francisco Javier Trujillo Mata (fjtrujy@gmail.com)

## This script is needed to generate a separate and nano libc. This is usefull for such programs that requires to have tiny binaries.
## I have tried to use --program-suffix during configure, but it looks that newlib is not using the flag properly.
## For this reason it requires to use a custom instalation script

## Exit with code 1 when any command executed returns a non-zero exit code.
onerr()
{
  exit 1;
}
trap onerr ERR

## Download the source code.
REPO_URL="https://github.com/ps2dev/newlib.git"
REPO_FOLDER="newlib"
BRANCH_NAME="ee-v4.1.0"
if test ! -d "$REPO_FOLDER"; then
  git clone --depth 1 -b "$BRANCH_NAME" "$REPO_URL"
else
  git -C "$REPO_FOLDER" fetch origin
  git -C "$REPO_FOLDER" reset --hard "origin/${BRANCH_NAME}"
  git -C "$REPO_FOLDER" checkout "$BRANCH_NAME"
fi
cd "$REPO_FOLDER"

TARGET_ALIAS="ee"
TARG_XTRA_OPTS=""
OSVER=$(uname)

if [ "${OSVER:0:10}" == MINGW64_NT ]; then
  export lt_cv_sys_max_cmd_len=8000
  export CC=x86_64-w64-mingw32-gcc
  TARG_XTRA_OPTS="--host=x86_64-w64-mingw32"
elif [ "${OSVER:0:10}" == MINGW32_NT ]; then
  export lt_cv_sys_max_cmd_len=8000
  export CC=i686-w64-mingw32-gcc
  TARG_XTRA_OPTS="--host=i686-w64-mingw32"
fi

PS2DEV_TMP="$PWD/ps2dev-tmp"

## Create ps2dev-tmp folder
rm -rf "$PS2DEV_TMP"
mkdir "$PS2DEV_TMP"

## Determine the maximum number of processes that Make can work with.
PROC_NR=$(getconf _NPROCESSORS_ONLN)

## For each target...
for TARGET in "mips64r5900el-ps2-elf"; do
  ## Create and enter the toolchain/build directory
  rm -rf "build-$TARGET"
  mkdir "build-$TARGET"
  cd "build-$TARGET"

  ## Configure the build.
  CFLAGS_FOR_TARGET="-DPREFER_SIZE_OVER_SPEED=1 -Os" ../configure \
    --prefix="$PS2DEV_TMP/$TARGET_ALIAS" \
    --target="$TARGET" \
    --disable-newlib-supplied-syscalls \
    --enable-newlib-reent-small \
    --disable-newlib-fvwrite-in-streamio \
    --disable-newlib-fseek-optimization \
    --disable-newlib-wide-orient \
    --enable-newlib-nano-malloc \
    --disable-newlib-unbuf-stream-opt \
    --enable-lite-exit \
    --enable-newlib-global-atexit \
    --enable-newlib-nano-formatted-io \
    --enable-newlib-retargetable-locking \
    --disable-nls \
    $TARG_XTRA_OPTS


  ## Compile and install.
  make --quiet -j "$PROC_NR" all
  make --quiet -j "$PROC_NR" install-strip
  make --quiet -j "$PROC_NR" clean

  ## Copy & rename manually libc, libg and libm to libc-nano, libg-nano and libm-nano
  mv "$PS2DEV_TMP/$TARGET_ALIAS/$TARGET/lib/libc.a" "$PS2DEV/$TARGET_ALIAS/$TARGET/lib/libc_nano.a"
  mv "$PS2DEV_TMP/$TARGET_ALIAS/$TARGET/lib/libg.a" "$PS2DEV/$TARGET_ALIAS/$TARGET/lib/libg_nano.a"
  mv "$PS2DEV_TMP/$TARGET_ALIAS/$TARGET/lib/libm.a" "$PS2DEV/$TARGET_ALIAS/$TARGET/lib/libm_nano.a"

  ## Exit the build directory.
  cd ..

  ## End target.
done
