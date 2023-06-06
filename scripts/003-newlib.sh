#!/bin/bash
# 003-newlib.sh by Francisco Javier Trujillo Mata (fjtrujy@gmail.com)

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

## Determine the maximum number of processes that Make can work with.
PROC_NR=$(getconf _NPROCESSORS_ONLN)

## For each target...
for TARGET in "mips64r5900el-ps2-elf"; do
  ## Create and enter the toolchain/build directory
  rm -rf "build-$TARGET"
  mkdir "build-$TARGET"
  cd "build-$TARGET"

  ## Configure the build.
  CFLAGS_FOR_TARGET="-O2" ../configure \
    --prefix="$PS2DEV/$TARGET_ALIAS" \
    --target="$TARGET" \
    --enable-newlib-retargetable-locking \
    $TARG_XTRA_OPTS

  ## Compile and install.
  make --quiet -j "$PROC_NR" all
  make --quiet -j "$PROC_NR" install-strip
  make --quiet -j "$PROC_NR" clean

  ## Exit the build directory.
  cd ..

  ## End target.
done
