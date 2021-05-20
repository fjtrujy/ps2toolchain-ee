#!/bin/bash
# 004-newlib-nano.sh by Francisco Javier Trujillo Mata (fjtrujy@gmail.com)

## This script is needed to generate a separate and nano libc. This is usefull for such programs that requires to have tiny binaries.
## I have tried to use --program-suffix during configure, but it looks that newlib is not using the flag properly.
## For this reason it requires to use a custom instalation script

## Download the source code.
REPO_URL="https://github.com/fjtrujy/newlib.git"
REPO_FOLDER="newlib"
BRANCH_NAME="posix-functions"
if test ! -d "$REPO_FOLDER"; then
	git clone --depth 1 -b $BRANCH_NAME $REPO_URL && cd $REPO_FOLDER || exit 1
else
	cd $REPO_FOLDER && git fetch origin && git reset --hard origin/${BRANCH_NAME} || exit 1
fi

TARGET_ALIAS="ee" 
TARGET="mips64r5900el-ps2-elf"
TARG_XTRA_OPTS=""
OSVER=$(uname)

## Apple needs to pretend to be linux
if [ ${OSVER:0:10} == MINGW64_NT ]; then
	export lt_cv_sys_max_cmd_len=8000
	export CC=x86_64-w64-mingw32-gcc
	TARG_XTRA_OPTS="--host=x86_64-w64-mingw32"
elif [ ${OSVER:0:10} == MINGW32_NT ]; then
	export lt_cv_sys_max_cmd_len=8000
	export CC=i686-w64-mingw32-gcc
	TARG_XTRA_OPTS="--host=i686-w64-mingw32"
fi

PS2DEV_TMP=$PWD/ps2dev-tmp

## Create ps2dev-tmp folder
rm -rf $PS2DEV_TMP && mkdir $PS2DEV_TMP || { exit 1; }

## Determine the maximum number of processes that Make can work with.
PROC_NR=$(getconf _NPROCESSORS_ONLN)

## Create and enter the toolchain/build directory
rm -rf build-$TARGET && mkdir build-$TARGET && cd build-$TARGET || { exit 1; }

## Configure the build.
CFLAGS_FOR_TARGET="-DPREFER_SIZE_OVER_SPEED=1 -G0 -Os" ../configure \
	--target="$TARGET" \
	--prefix="$PS2DEV_TMP/$TARGET_ALIAS" \
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
	--disable-nls \
	$TARG_XTRA_OPTS || { exit 1; }


## Compile and install.
make --quiet -j $PROC_NR clean          || { exit 1; }
make --quiet -j $PROC_NR all            || { exit 1; }
make --quiet -j $PROC_NR install-strip  || { exit 1; }
make --quiet -j $PROC_NR clean          || { exit 1; }

## Copy & rename manually libc, libg and libm to libc-nano, libg-nano and libm-nano
mv $PS2DEV_TMP/$TARGET_ALIAS/$TARGET/lib/libc.a $PS2DEV/$TARGET_ALIAS/$TARGET/lib/libc_nano.a
mv $PS2DEV_TMP/$TARGET_ALIAS/$TARGET/lib/libg.a $PS2DEV/$TARGET_ALIAS/$TARGET/lib/libg_nano.a
mv $PS2DEV_TMP/$TARGET_ALIAS/$TARGET/lib/libm.a $PS2DEV/$TARGET_ALIAS/$TARGET/lib/libm_nano.a