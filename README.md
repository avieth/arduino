# nix derivation for programming an Arduino DUE

This hacky derivation is reverse engineered from the Arduino IDE debug output.

Uses a particular version of BOSSA. Newer stock version do not seem to work
properly: very fickle when using the native port, not working at all for the
programming port. BOSSA 1.6.1 from [this repository](https://github.com/shumatech/BOSSA)
is chosen.
