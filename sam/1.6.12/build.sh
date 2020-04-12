# Set up the path from the build inputs
set -e
unset PATH
for p in $buildInputs; do
  export PATH=$p/bin${PATH:+:}$PATH
done

DEFINES="-Dprintf=iprintf -DF_CPU=84000000 -DARDUINO=10611 -D__SAM3X8E__ -DUSB_PID=0x003e -DUSB_VID=0x2341 -DUSBCON \
  -DARDUINO_SAM_DUE -DARDUINO_ARCH_SAM" # '-DUSB_MANUFACTURER="Arduino LLC"' -DUSB_PRODUCT=\"Arduino Due\""

INCLUDES="-I$src/system/libsam \
 -I$src/system/CMSIS/CMSIS/Include \
 -I$src/system/CMSIS/Device/ATMEL \
 -I$src/cores/arduino \
 -I$src/cores/arduino/avr \
 -I$src/variants/arduino_due_x"

COMMON_FLAGS="-g -Os -w -ffunction-sections -fdata-sections -nostdlib \
 --param max-inline-insns-single=500 -mcpu=cortex-m3 -mthumb \
 -fno-threadsafe-statics"

CFLAGS="${COMMON_FLAGS} -std=gnu11"
CXXFLAGS="${COMMON_FLAGS} -fno-rtti -fno-exceptions -std=gnu++11 -Wall -Wextra"

CORESRCXX=`ls ${src}/cores/arduino/*.cpp`" "`ls ${src}/cores/arduino/USB/*.cpp`" ${src}/variants/arduino_due_x/variant.cpp"
CORESRC=`ls ${src}/cores/arduino/*.c`

cd $TMP
#set -o xtrace

for cxxfile in $CORESRCXX
do
  arm-none-eabi-g++ -MD -c ${CXXFLAGS} ${DEFINES} ${INCLUDES} $cxxfile
done

for cfile in $CORESRC
do
  arm-none-eabi-gcc -MD -c ${CFLAGS} ${DEFINES} ${INCLUDES} $cfile 
done

# Must throw all of the object files into one core.a binary
OBJFILES=`ls ./*.o`

for objfile in $OBJFILES
do
  arm-none-eabi-ar rcs ./core.a $objfile
done

mkdir $out

mkdir $out/objs

cp *.o $out/objs
cp core.a $out/objs

# Also need some other stuff that we did not build; just copy it.
cp $src/variants/arduino_due_x/libsam_sam3x8e_gcc_rel.a $out/objs
mkdir $out/scripts
cp $src/variants/arduino_due_x/linker_scripts/gcc/flash.ld $out/scripts
