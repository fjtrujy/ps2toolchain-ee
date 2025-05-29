#!/bin/bash

PS2TOOLCHAIN_EE_BINUTILS_REPO_URL="https://github.com/ps2dev/binutils-gdb.git"
PS2TOOLCHAIN_EE_BINUTILS_DEFAULT_REPO_REF="ee-v2.44.0"
PS2TOOLCHAIN_EE_GCC_REPO_URL="https://github.com/fjtrujy/gcc.git"
PS2TOOLCHAIN_EE_GCC_DEFAULT_REPO_REF="ee-v15.1.0-foo_standards"
PS2TOOLCHAIN_EE_NEWLIB_REPO_URL="https://github.com/ps2dev/newlib.git"
PS2TOOLCHAIN_EE_NEWLIB_DEFAULT_REPO_REF="ee-v4.5.0"
PS2TOOLCHAIN_EE_PTHREAD_EMBEDDED_REPO_URL="https://github.com/ps2dev/pthread-embedded.git"
PS2TOOLCHAIN_EE_PTHREAD_EMBEDDED_DEFAULT_REPO_REF="platform_agnostic"

if test -f "$PS2DEV_CONFIG_OVERRIDE"; then
  source "$PS2DEV_CONFIG_OVERRIDE"
fi
