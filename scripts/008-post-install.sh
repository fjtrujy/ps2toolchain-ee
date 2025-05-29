#!/bin/bash
# 008-post-install.sh by ps2dev developers

## Exit with code 1 when any command executed returns a non-zero exit code.
onerr()
{
  exit 1;
}
trap onerr ERR

## Read information from the configuration file.
source "$(dirname "$0")/../config/ps2toolchain-ee-config.sh"

TARGET_ALIAS="ee"
TARGET="mips64r5900el-ps2-elf"

## Remove the dummy libraries created in step 6
echo "Removing temporary files created in step 6..."
rm -f "$PS2DEV/$TARGET_ALIAS/$TARGET/lib/libpthreadglue.a"
rm -f "$PS2DEV/$TARGET_ALIAS/$TARGET/lib/libcglue.a"
rm -f "$PS2DEV/$TARGET_ALIAS/$TARGET/lib/libkernel.a"
rm -f "$PS2DEV/$TARGET_ALIAS/$TARGET/lib/libcdvd.a"

## Remove generated dummy crt0.o file created by newlib
echo "Removing generated dummy crt0.o file created by newlib..."
rm -f "$PS2DEV/$TARGET_ALIAS/$TARGET/lib/crt0.o"

echo "Cleanup completed."
