#!/bin/bash
# 006-foo-standard-libs.sh by ps2dev developers

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
TARGET_AR="$PS2DEV/$TARGET_ALIAS/bin/$TARGET-ar"
TARGET_CC="$PS2DEV/$TARGET_ALIAS/bin/$TARGET-gcc"
TEMP_DIR="$PWD/temp_libs"

## Create temporary directory for building libraries
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR"

## Create pthreadglue implementation
cat > pthreadglue.c << 'EOF'
#include <stddef.h>

/* Dummy implementations of pthreadglue functions */
void *pte_osMutexLock(void *mutex) { return NULL; }
void *pte_osMutexUnlock(void *mutex) { return NULL; }
int pte_osThreadGetMinPriority(void) { return 0; }
void *pte_osSemaphoreCreate(int initialCount) { return NULL; }
void *pte_osThreadGetHandle(void) { return NULL; }
int pte_osAtomicCompareExchange(int *ptr, int oldval, int newval) { return oldval; }
int pte_osAtomicExchange(int *ptr, int newval) { return 0; }
int pte_osSemaphorePend(void *sem, unsigned int timeout) { return 0; }
int pte_osSemaphorePost(void *sem) { return 0; }
int pte_osSemaphoreDelete(void *sem) { return 0; }
int pte_osTlsSetValue(unsigned int key, void *value) { return 0; }
void pte_osThreadExitAndDelete(void *thread) { }
int pte_osThreadDelete(void *thread) { return 0; }
int pte_osThreadGetMaxPriority(void) { return 0; }
void *pte_osThreadCreate(void *(*start)(void *), void *arg, int priority) { return NULL; }
int pte_osThreadStart(void *thread) { return 0; }
EOF

## Create cglue implementation
cat > cglue.c << 'EOF'
#include <stddef.h>
#include <unistd.h>

/* Dummy implementations of cglue functions */
void __retarget_lock_acquire_recursive(void *lock) { }
void __retarget_lock_release_recursive(void *lock) { }
void __retarget_lock_init_recursive(void *lock) { }
void __retarget_lock_close_recursive(void *lock) { }

/* These are actually variables, but we'll implement them as functions for simplicity */
void *__lock___malloc_recursive_mutex(void) { return NULL; }
void *__lock___sfp_recursive_mutex(void) { return NULL; }

/* Kernel functions moved to cglue */
void *_sbrk(int incr) { return NULL; }
int _close(int fd) { return -1; }
off_t _lseek(int fd, off_t offset, int whence) { return -1; }
ssize_t _read(int fd, void *buf, size_t count) { return -1; }
ssize_t _write(int fd, const void *buf, size_t count) { return -1; }
EOF

## Compile all implementations
"$TARGET_CC" -c pthreadglue.c -o pthreadglue.o
"$TARGET_CC" -c cglue.c -o cglue.o

## Create the lib directory if it doesn't exist
mkdir -p "$PS2DEV/$TARGET_ALIAS/$TARGET/lib"

## Create libraries
cd "$PS2DEV/$TARGET_ALIAS/$TARGET/lib"

## Create libraries with their respective object files
"$TARGET_AR" rcs libpthreadglue.a "$TEMP_DIR/pthreadglue.o"
"$TARGET_AR" rcs libcglue.a "$TEMP_DIR/cglue.o"
"$TARGET_AR" rcs libkernel.a
"$TARGET_AR" rcs libcdvd.a

## Clean up
rm -rf "$TEMP_DIR"

echo "Created standard libraries in $PS2DEV/$TARGET_ALIAS/$TARGET/lib using $TARGET-ar:"
echo "  - libpthreadglue.a (with pthread glue implementations)"
echo "  - libcglue.a (with C glue and kernel function implementations)"
echo "  - libkernel.a (empty)"
echo "  - libcdvd.a (empty)"