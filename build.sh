# Set up the path from the build inputs
set -e
unset PATH
for p in $buildInputs; do
  export PATH=$p/bin${PATH:+:}$PATH
done

DEFINES="-Dprintf=iprintf -DF_CPU=84000000 -DARDUINO=10611 -D__SAM3X8E__ -DUSB_PID=0x003e -DUSB_VID=0x2341 -DUSBCON \
  -DARDUINO_SAM_DUE -DARDUINO_ARCH_SAM" # '-DUSB_MANUFACTURER="Arduino LLC"' -DUSB_PRODUCT=\"Arduino Due\""

INCLUDES="-I$sam/include/system/libsam \
 -I$sam/include/system/CMSIS/CMSIS/Include \
 -I$sam/include/system/CMSIS/Device/ATMEL \
 -I$sam/include/cores/arduino \
 -I$sam/include/cores/arduino/avr \
 -I$sam/include/cores/arduino/USB \
 -I$sam/include/variants/arduino_due_x"

COMMON_FLAGS="-g -Os -w -ffunction-sections -fdata-sections -nostdlib \
 --param max-inline-insns-single=500 -mcpu=cortex-m3 -mthumb \
 -fno-threadsafe-statics"

CFLAGS="${COMMON_FLAGS} -std=gnu11"
CXXFLAGS="${COMMON_FLAGS} -fno-rtti -fno-exceptions -std=gnu++11 -Wall -Wextra"

cd $TMP

#NAME="build"

#arm-none-eabi-size -A ${NAME}.elf

mkdir $out
GXX=${armgcc}/bin/arm-none-eabi-g++
GCC=${armgcc}/bin/arm-none-eabi-gcc
OBJCOPY=${armgcc}/bin/arm-none-eabi-objcopy
STTY=${coreutils}/bin/stty
BOSSAC=${bossa}/bin/bossac

echo "${GXX} -MD -c ${CXXFLAGS} ${DEFINES} ${INCLUDES} \$@" > compile
chmod 755 compile
cp compile $out/

echo "${GCC} -mcpu=cortex-m3 -mthumb -Os -Wl,--gc-sections -T$sam/scripts/flash.ld \
 -Wl,-Map,build.map \
 -o build.elf -L$sam/lib -Wl,--cref -Wl,--check-sections -Wl,--gc-sections -Wl,--entry=Reset_Handler \
 -Wl,--unresolved-symbols=report-all -Wl,--warn-common -Wl,--warn-section-align \
 -Wl,--start-group -u _sbrk -u link -u _close -u _fstat -u _isatty -u _lseek -u _read -u _write -u _exit \
 -u kill -u _getpid \$@ $sam/lib/syscalls_sam3.c.o \
 $sam/lib/variant.cpp.o \
 $sam/lib/libsam_sam3x8e_gcc_rel.a \
 $sam/lib/core.a -Wl,--end-group -lm -lgcc" > link
echo "${OBJCOPY} -O binary build.elf build.bin" >> link
chmod 755 link
cp link $out/

echo "${STTY} 1200 cs8 -cstopb -parenb hupcl \$@" > erase
chmod 755 erase
cp erase $out/

echo "${BOSSAC} -e -w ./build.bin --boot=1 -v -R \$@" >> upload
chmod 755 upload
cp upload $out/
