# nix derivation for programming an Arduino DUE

This hacky derivation is reverse engineered from the Arduino IDE debug output.

```sh
nix-build default.nix
# ./result appears
# compile runs the arm g++ compiler with appropriate include and defines
./result/compile main.cpp -o main.o
# Give all of your object files to link and it will create the binary to
# upload to the device
./result/link main.o
# binary.bin appears; this is the image to upload (its name is hard-coded in
# the scripts).
# Erase the image on the board (replace with correct device)
./result/erase -F /dev/ttyACM0
# Upload the image. Set -U true if using native USB port
./result/upload --port=ttyACM0 -U false
```

Uses a particular version of BOSSA. Newer stock version do not seem to work
properly: very fickle when using the native port, not working at all for the
programming port. BOSSA 1.6.1 from [this repository](https://github.com/shumatech/BOSSA)
is chosen.
