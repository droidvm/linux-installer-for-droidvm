
MAKEFLAGS:=-s -j${nproc}

# NDK_DIR=/mnt/d/downloads/android-ndk-r10e
NDK_DIR=/mnt/d/downloads/android-ndk-r23b
NDK_BIN=$(NDK_DIR)/toolchains/llvm/prebuilt/linux-x86_64/bin
API_VER=26
NTV_DIR=$(NDK_DIR)/sources/android/native_app_glue
SRC_DIR=.
TMP_DIR=$(SRC_DIR)/tmp
TMP_APK=tmp.apk
SGN_APK=sgn.apk
OUT_APK=out.apk
KEYPAIR=myKeyPair.keystore

# CROSS_COMPILE=$(NDK_BIN)
CC		= $(NDK_BIN)/${CPLARCH}-linux-android$(API_VER)-clang
STRIP	= $(NDK_BIN)/llvm-strip
OBJCOPY	= $(NDK_BIN)/llvm-objcopy
OBJDUMP	= $(NDK_BIN)/llvm-objdump
CFLAGS	= 
LDFLAGS = 

CFLAGS	+=  -I$(NTV_DIR)/  -I"$(SRC)../../talloc-2.3.3/release/arm64/include"
CFLAGS	+=  -target ${CPLARCH}-none-linux-android$(API_VER)
CFLAGS  +=  --sysroot $(NDK_DIR)/toolchains/llvm/prebuilt/linux-x86_64/sysroot

LDFLAGS +=  -latomic -target ${CPLARCH}-none-linux-android$(API_VER)
LDFLAGS +=  -latomic -llog -landroid -lc -lm #-lEGL -lGLESv1_CM 

LDFLAGS +=  -L$(SRC)../../talloc-2.3.3/release/arm64/lib/alib   -Wl,-rpath='$$ORIGIN'




