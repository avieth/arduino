# Set up the path from the build inputs
set -e
unset PATH
for p in $buildInputs; do
  export PATH=$p/bin${PATH:+:}$PATH
done

cp -R $src/src $TMP/
cp -R $src/arduino $TMP/
cp -R $src/install $TMP/
cp -R $src/res $TMP/
cp $src/Makefile $TMP/

cd $TMP
make bin/bossac

mkdir $out
mkdir $out/bin
cp bin/bossac $out/bin/
