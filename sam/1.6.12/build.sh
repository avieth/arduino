#set -o xtrace

# Set up the path from the build inputs
set -e
unset PATH
for p in $buildInputs; do
  export PATH=$p/bin${PATH:+:}$PATH
done

DEFINES="-Dprintf=iprintf -DF_CPU=84000000L -DARDUINO=10809 -D__SAM3X8E__ \
 -DUSB_PID=0x003e -DUSB_VID=0x2341 \
 -DARDUINO_SAM_DUE -DARDUINO_ARCH_SAM \
 -DUSBCON"# \
 # -DUSB_MANUFACTURER=\""$usb_manufacturer"\" \
 # -DUSB_PRODUCT=\""$usb_product"\""

INCLUDES="-I$src/system/libsam \
 -I$src/system/CMSIS/CMSIS/Include \
 -I$src/system/CMSIS/Device/ATMEL \
 -I$src/cores/arduino \
 -I$src/cores/arduino/avr \
 -I$src/variants/arduino_due_x"

COMMON_FLAGS="-g -Os -w -ffunction-sections -fdata-sections -nostdlib \
 --param max-inline-insns-single=500 -mcpu=cortex-m3 -mthumb \
 -fno-threadsafe-statics -MMD"

CFLAGS="${COMMON_FLAGS} -std=gnu11"
CXXFLAGS="${COMMON_FLAGS} -fno-rtti -fno-exceptions -std=gnu++11 -Wall -Wextra"

CORESRCXX=`ls ${src}/cores/arduino/*.cpp`" "`ls ${src}/cores/arduino/USB/*.cpp`" ${src}/variants/arduino_due_x/variant.cpp"
CORESRC=`ls ${src}/cores/arduino/*.c`" "`ls ${src}/cores/arduino/avr/*.c`

cd $TMP
mkdir core

for cxxfile in $CORESRCXX
do
  arm-none-eabi-g++ -c ${CXXFLAGS} ${DEFINES} -DUSB_MANUFACTURER="\"$usb_manufacturer\"" -DUSB_PRODUCT="\"$usb_product\"" ${INCLUDES} $cxxfile -o ./core/`basename ${cxxfile}`.o
done

# TODO list the files explicitly

for cfile in $CORESRC
do
  arm-none-eabi-gcc -c ${CFLAGS} ${DEFINES} -DUSB_MANUFACTURER="\"$usb_manufacturer\"" -DUSB_PRODUCT="\"$usb_product\"" ${INCLUDES} $cfile -o ./core/`basename ${cfile}`.o
done

arm-none-eabi-gcc -c -x assembler-with-cpp \
  ${CLAGS} ${DEFINES} ${INCLUDES} ${src}/cores/arduino/wiring_pulse_asm.S \
  -o ./core/wiring_pulse_asm.S.o

arm-none-eabi-ar rcs ./core/core.a ./core/IPAddress.cpp.o
arm-none-eabi-ar rcs ./core/core.a ./core/Print.cpp.o
arm-none-eabi-ar rcs ./core/core.a ./core/Reset.cpp.o
arm-none-eabi-ar rcs ./core/core.a ./core/RingBuffer.cpp.o
arm-none-eabi-ar rcs ./core/core.a ./core/Stream.cpp.o
arm-none-eabi-ar rcs ./core/core.a ./core/UARTClass.cpp.o
arm-none-eabi-ar rcs ./core/core.a ./core/USARTClass.cpp.o
arm-none-eabi-ar rcs ./core/core.a ./core/CDC.cpp.o
arm-none-eabi-ar rcs ./core/core.a ./core/PluggableUSB.cpp.o
arm-none-eabi-ar rcs ./core/core.a ./core/USBCore.cpp.o
arm-none-eabi-ar rcs ./core/core.a ./core/WInterrupts.c.o
arm-none-eabi-ar rcs ./core/core.a ./core/WMath.cpp.o
arm-none-eabi-ar rcs ./core/core.a ./core/WString.cpp.o
arm-none-eabi-ar rcs ./core/core.a ./core/abi.cpp.o
arm-none-eabi-ar rcs ./core/core.a ./core/dtostrf.c.o
arm-none-eabi-ar rcs ./core/core.a ./core/cortex_handlers.c.o
arm-none-eabi-ar rcs ./core/core.a ./core/hooks.c.o
arm-none-eabi-ar rcs ./core/core.a ./core/iar_calls_sam3.c.o
arm-none-eabi-ar rcs ./core/core.a ./core/itoa.c.o
arm-none-eabi-ar rcs ./core/core.a ./core/main.cpp.o
arm-none-eabi-ar rcs ./core/core.a ./core/new.cpp.o
arm-none-eabi-ar rcs ./core/core.a ./core/syscalls_sam3.c.o
arm-none-eabi-ar rcs ./core/core.a ./core/watchdog.cpp.o
arm-none-eabi-ar rcs ./core/core.a ./core/wiring.c.o
arm-none-eabi-ar rcs ./core/core.a ./core/wiring_analog.c.o
arm-none-eabi-ar rcs ./core/core.a ./core/wiring_digital.c.o
arm-none-eabi-ar rcs ./core/core.a ./core/wiring_pulse.cpp.o
arm-none-eabi-ar rcs ./core/core.a ./core/wiring_pulse_asm.S.o
arm-none-eabi-ar rcs ./core/core.a ./core/wiring_shift.c.o

mkdir $out
mkdir $out/lib
cp ./core/*.o $out/lib/
cp ./core/core.a $out/lib/
# Did not generate this but we still need it.
cp $src/variants/arduino_due_x/libsam_sam3x8e_gcc_rel.a $out/lib/
# Downstream programs will need this script.
mkdir $out/scripts
cp $src/variants/arduino_due_x/linker_scripts/gcc/flash.ld $out/scripts

# Throw in all of the headers
cd $src
HEADERFILES=`find ./ -regex ".*\.h" -printf "%P\n"`
for hfile in $HEADERFILES
do
  mkdir -p $out/include/`dirname $hfile`
  cp $hfile $out/include/$hfile
done
cd -
