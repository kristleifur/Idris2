#!/bin/sh

if [ -z "$SCHEME" ]
then
    echo "SCHEME not set. Invoke with SCHEME=[name of chez executable]"
    exit 1
fi

# Compile the bootstrap scheme
cd bootstrap
${SCHEME} --script compile.ss

# Put the result in the usual place where the target goes
mkdir -p ../build/exec
mkdir -p ../build/exec/idris2_app
install idris2-boot ../build/exec/idris2
install idris2_app/* ../build/exec/idris2_app

cd ..

# Install with the bootstrap directory as the PREFIX
DIR="`realpath $0`"
PREFIX="`dirname $DIR`"/bootstrap

if [ ${OS} = "windows" ]; then
    IDRIS_PREFIX=$(cygpath -m $PREFIX)
    IDRIS2_BOOT_PATH="${IDRIS_PREFIX}/idris2-0.2.0/prelude;${IDRIS_PREFIX}/idris2-0.2.0/base;${IDRIS_PREFIX}/idris2-0.2.0/contrib;${IDRIS_PREFIX}/idris2-0.2.0/network"
    NEW_PREFIX=$(cygpath -m $(dirname "$DIR"))
    IDRIS2_NEW_PATH="${NEW_PREFIX}/libs/prelude/build/ttc;${NEW_PREFIX}/libs/base/build/ttc;${NEW_PREFIX}/libs/network/build/ttc"
    IDRIS2_TEST_LIBS="${IDRIS_PREFIX}/idris2-0.2.0/lib"
    IDRIS2_TEST_DATA=${IDRIS_PREFIX}/idris2-0.2.0/support
else
    IDRIS2_BOOT_PATH="${PREFIX}/idris2-0.2.0/prelude:${PREFIX}/idris2-0.2.0/base:${PREFIX}/idris2-0.2.0/contrib:${PREFIX}/idris2-0.2.0/network"
    NEWPREFIX="`dirname $DIR`"
    IDRIS2_NEW_PATH="${NEWPREFIX}/libs/prelude/build/ttc:${NEWPREFIX}/libs/base/build/ttc:${NEWPREFIX}/libs/network/build/ttc"
    IDRIS2_TEST_LIBS="${PREFIX}/idris2-0.2.0/lib" IDRIS2_TEST_DATA=${PREFIX}/idris2-0.2.0/support
fi

# Now rebuild everything properly
echo ${PREFIX}


make libs SCHEME=${SCHEME} PREFIX=${PREFIX}
make install SCHEME=${SCHEME} PREFIX=${PREFIX}
make clean IDRIS2_BOOT=${PREFIX}/bin/idris2
make all IDRIS2_BOOT=${PREFIX}/bin/idris2 SCHEME=${SCHEME} IDRIS2_PATH=${IDRIS2_BOOT_PATH}

echo "Testing using libraries in ${IDRIS2_NEW_PATH}"
make test INTERACTIVE='' IDRIS2_PATH=${IDRIS2_NEW_PATH} SCHEME=${SCHEME} IDRIS2_LIBS=${IDRIS2_TEST_LIBS} IDRIS2_DATA=${IDRIS2_TEST_DATA}
