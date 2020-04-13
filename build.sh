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
 -I$sam/include/variants/arduino_due_x"

COMMON_FLAGS="-g -Os -w -ffunction-sections -fdata-sections -nostdlib \
 --param max-inline-insns-single=500 -mcpu=cortex-m3 -mthumb \
 -fno-threadsafe-statics"

CFLAGS="${COMMON_FLAGS} -std=gnu11"
CXXFLAGS="${COMMON_FLAGS} -fno-rtti -fno-exceptions -std=gnu++11 -Wall -Wextra"

cd $TMP

# Create a suitable main file from the template, and the setup/loop idiomatic
# arduino main
# TODO explain why this works.
#cat $sam/main.cpp $src/main.c > ./main.cpp
#echo 'extern "C" void __cxa_pure_vritual() {while (true);}' >> ./main.cpp
#arm-none-eabi-g++ -MD -c ${CXXFLAGS} ${DEFINES} ${INCLUDES} ./main.cpp -o ./main.o

arm-none-eabi-g++ -MD -c ${CXXFLAGS} ${DEFINES} ${INCLUDES} $src/main.cpp -o ./main.o
OBJFILES="main.o"

NAME="build"

# Link gc-sections, archives, objects
arm-none-eabi-gcc -mcpu=cortex-m3 -mthumb -Os -Wl,--gc-sections -T$sam/scripts/flash.ld \
  -Wl,-Map,${NAME}.map \
  -o ${NAME}.elf -L$sam/lib -Wl,--cref -Wl,--check-sections -Wl,--gc-sections -Wl,--entry=Reset_Handler \
  -Wl,--unresolved-symbols=report-all -Wl,--warn-common -Wl,--warn-section-align \
  -Wl,--start-group -u _sbrk -u link -u _close -u _fstat -u _isatty -u _lseek -u _read -u _write -u _exit \
  -u kill -u _getpid $OBJFILES $sam/lib/syscalls_sam3.c.o \
  $sam/lib/variant.cpp.o \
  $sam/lib/libsam_sam3x8e_gcc_rel.a \
  $sam/lib/core.a -Wl,--end-group -lm -lgcc

# Create the binary to upload to the device.
arm-none-eabi-objcopy -O binary ${NAME}.elf ${NAME}.bin

arm-none-eabi-size -A ${NAME}.elf

mkdir $out
cp ./${NAME}.elf $out/
cp ./${NAME}.bin $out/
cp ${coreutils}/bin/stty $out/
cp ${bossa}/bin/bossac $out/

echo "./stty 1200 cs8 -cstopb -parenb hupcl $@" > erase.sh
chmod 755 erase.sh
cp erase.sh $out/
echo "./bossac -e -w ./${NAME}.bin --boot=1 -v -R $@" >> upload.sh
chmod 755 upload.sh
cp upload.sh $out/
