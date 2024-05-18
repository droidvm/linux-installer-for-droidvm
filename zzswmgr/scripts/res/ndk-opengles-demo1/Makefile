
MAKEFLAGS:=-s -j${nproc}

NDK_VER=r26b
HOSTCPU=`uname -m`
# NDK_DIR=/mnt/d/downloads/android-ndk-${NDK_VER}
NDK_DIR=/opt/apps/android-ndk-${NDK_VER}
NDK_BIN=$(NDK_DIR)/toolchains/llvm/prebuilt/linux-${HOSTCPU}/bin
API_VER=23
NTV_DIR=$(NDK_DIR)/sources/android/native_app_glue
SRC_DIR=.
BULDDIR :=build
TMP_DIR=$(SRC_DIR)/tmp
TMP_APK=tmp.apk
SGN_APK=sgn.apk
OUT_APK=out.apk
KEYPAIR=myKeyPair.keystore
$(shell mkdir $(BULDDIR)				2>/dev/null)
$(shell mkdir $(BULDDIR)/abi_$(TEMPABI)	2>/dev/null)

EXE      =1
BIN      =$(BULDDIR)/abi_${TEMPABI}/main
INCS     = -I"./" 
LIBS     =

# -g3 to 生成调试信息
CFLAGS   =
XFLAGS   =

# 要编译可执行文件只需要把下面的-shared 去掉
ifndef EXE
LDFLAGS  = -shared
endif
CSOURCES+= main.c

# 隐藏函数名
CFLAGS	+=  -ffunction-sections -fdata-sections -fvisibility=hidden
XFLAGS	+=  -ffunction-sections -fdata-sections -fvisibility=hidden


CCSELECT:=__GCC__

ifeq ($(CCSELECT),__GCC__)
	GCC_DIR  =/usr
	# CC       = "$(NDK_BIN)/clang"
	# XX       = "$(NDK_BIN)/clang++"
	# TR       = "$(NDK_BIN)/llvm-strip"
	CC       = "$(NDK_BIN)/clang"
	XX       = "$(NDK_BIN)/clang++"
	TR       = "$(NDK_BIN)/llvm-strip"
	LIBS    +=
	INCS    += -I$(NTV_DIR)/
	CFLAGS	+=  -D__DEBUG__ -D${CCSELECT} -DANDROID_BUILD
	CFLAGS	+=  -target ${CPLARCH}-none-linux-android$(API_VER)
	CFLAGS  +=  --sysroot $(NDK_DIR)/toolchains/llvm/prebuilt/linux-${HOSTCPU}/sysroot
	# CFLAGS  +=  -I$(NDK_DIR)/toolchains/llvm/prebuilt/linux-${HOSTCPU}/sysroot/usr/include/
	CFLAGS  +=  -fdata-sections -ffunction-sections -fstack-protector-strong -funwind-tables -no-canonical-prefixes -Wno-invalid-command-line-argument 
	CFLAGS  +=  -Wno-unused-command-line-argument  -D_FORTIFY_SOURCE=2 -fpic -O2 -Wformat -Werror=format-security -Wno-zero-length-array
	CFLAGS  +=  -pedantic -fPIC -Wall -Wno-format-pedantic -Wno-unused-variable -Wno-gnu-binary-literal -Wno-return-type -Wno-int-to-pointer-cast -Wno-parentheses
	CFLAGS  +=  -std=gnu11
	CFLAGS  +=  -DANDROID

	XFLAGS  +=  -D__DEBUG__ -D${CCSELECT} -DANDROID_BUILD
	XFLAGS  +=  -target ${CPLARCH}-none-linux-android$(API_VER) -fdata-sections -ffunction-sections -fstack-protector-strong 
	XFLAGS  +=  -funwind-tables -no-canonical-prefixes  
	XFLAGS  +=  --sysroot $(NDK_DIR)/toolchains/llvm/prebuilt/linux-${HOSTCPU}/sysroot 
	XFLAGS  +=  -Wno-invalid-command-line-argument -Wno-unused-command-line-argument  
	XFLAGS  +=  -D_FORTIFY_SOURCE=2 -fno-exceptions -fno-rtti -fpic -O2 -DNDEBUG  
	# XFLAGS  +=  -I$(NDK_DIR)/sources/android/native_app_glue -Ijni    
	XFLAGS  +=  -DANDROID  -Wformat -Werror=format-security   

	# LDFLAGS +=  -latomic -llog -landroid -lc -lm -lOpenSLES #-lEGL -lGLESv1_CM 
	# LDFLAGS +=  -Wl,-soname,$(BIN) 
	# LDFLAGS +=  -latomic -target ${CPLARCH}-none-linux-android$(API_VER) -no-canonical-prefixes   
	# LDFLAGS +=  -Wl,--build-id=sha1 -Wl,--no-rosegment  -u ANativeActivity_onCreate -stdlib=libstdc++ -Wl,--no-undefined -Wl,
	# LDFLAGS	+=  -fvisibility=hidden -Wl,-gc-sections
	# LDFLAGS +=  -latomic -llog -landroid -lc -lm -lOpenSLES -lvulkan #-lEGL -lGLESv1_CM 
	LDFLAGS +=  -Wl,-soname,$(BIN) 
	LDFLAGS +=  -lEGL -lGLESv3 -target ${CPLARCH}-none-linux-android$(API_VER) -no-canonical-prefixes   
	LDFLAGS +=  -Wl,--build-id=sha1 -Wl,--no-rosegment  -u ANativeActivity_onCreate -stdlib=libstdc++ -Wl,--no-undefined -Wl,
	LDFLAGS	+=  -fvisibility=hidden -Wl,-gc-sections
endif


OBJEXT ?= .o
AOBJS   = $(ASOURCES:.S=$(OBJEXT))
AOBJS   := $(addprefix $(BULDDIR)/abi_$(TEMPABI)/, ${AOBJS})

COBJS_  = $(filter %.c,$(CSOURCES))
COBJS   = $(COBJS_:.c=$(OBJEXT))
COBJS   := $(addprefix $(BULDDIR)/abi_$(TEMPABI)/, ${COBJS})

XOBJS_  = $(filter %.cpp,$(CSOURCES))
XOBJS   = $(XOBJS_:.cpp=$(OBJEXT))
XOBJS   := $(addprefix $(BULDDIR)/abi_$(TEMPABI)/, ${XOBJS})

OBJS    = $(AOBJS) $(COBJS) $(XOBJS)

all: default

$(COBJS):$(BULDDIR)/abi_$(TEMPABI)/%.o:$(SRC_DIR)/%.c
	@echo CC	$<
	"$(CC)" -c $< -o $@ $(CFLAGS) $(INCS)

# %.o: %.cpp
$(XOBJS):$(BULDDIR)/abi_$(TEMPABI)/%.o:$(SRC_DIR)/%.cpp
	@echo XX	$<
	"$(XX)" -c $< -o $@ $(XFLAGS) $(INCS)



$(BIN): $(OBJS)

	echo -e '\e[1;36m  linking...\e[0m'
	"$(XX)" -o $(BIN) $(OBJS) $(LDFLAGS) $(LIBS)

	echo -e '\e[1;36m  stripping...\e[0m'
	"$(TR)" --strip-unneeded --remove-section=.symtab $(BIN)
	"$(TR)" $(BIN)

	# patchelf --set-rpath "\$$ORIGIN/rtlibs" $(BIN)

	@echo 体积：
	@ls -al $(BIN)

c: $(BIN)
	#do nothing

default:$(BIN)
	#do nothing


clean: 
	rm -rf $(BULDDIR)

