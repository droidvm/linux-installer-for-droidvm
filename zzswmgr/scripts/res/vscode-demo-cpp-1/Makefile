# -s 表示指令不回显，-j表示多进程并行编译
MAKEFLAGS:=-s -j${nproc}

CC		= gcc
XX		= g++
INCS	=
LIBS	= -lpthread

CFLAGS	=
XFLAGS	=
OBJEXT ?= .o

# 源文件清单
# SOURCE_FILES=main.c test.c
# SOURCE_FILES=$(wildcard ./*.c)
SOURCE_FILES=main.cpp

# 汇编源文件
AOBJS_  = $(filter %.S,$(SOURCE_FILES))
AOBJS   = $(ASOURCES:.S=$(OBJEXT))

# C源文件
COBJS_  = $(filter %.c,$(SOURCE_FILES))
COBJS   = $(COBJS_:.c=$(OBJEXT))

# C++源文件
XOBJS_  = $(filter %.cpp,$(SOURCE_FILES))
XOBJS   = $(XOBJS_:.cpp=$(OBJEXT))

# 所有的.o文件
OBJS    = $(AOBJS) $(COBJS) $(XOBJS)

# 当前时间
BUILD_DATETIME :=$(shell date  '+%Y-%m-%d %H:%M:%S')
OUT_BIN_DBG=./build/Debug/outDebug
OUT_BIN_RLS=./build/Release/outRelease











# 调试版编译目标，也是此文件中的第一个编译目标
debug: OUT_MSG:=调试版
debug: OUT_BIN:=$(OUT_BIN_DBG)
debug: OUT_DIR:=$(shell dirname $(OUT_BIN))
debug: CFLAGS+= -g3
debug: XFLAGS+= -g3
debug: dumpInfo $(OUT_BIN_DBG)
	$(showbinary)
	cp -rf ./.vscode/launch.json.bak ./.vscode/launch.json
	echo -e '若要调试，请在vscode中打开此项目，切换到任意一个c文件的编辑界面\n然后按F5即可开始调试'


# 发行版编译目标
release: OUT_MSG:=发行版
release: OUT_BIN:=$(OUT_BIN_RLS)
release: OUT_DIR:=$(shell dirname $(OUT_BIN))
release: dumpInfo $(OUT_BIN_RLS)
	$(showbinary)
	echo -e '如需调试代码，请编译调试版'

$(OUT_BIN_DBG): $(OBJS)
	$(dolink)

$(OUT_BIN_RLS): $(OBJS)
	$(dolink)

# C源码的编译规则
$(COBJS):%.o:%.c
	@echo CC	$<  $(CFLAGS)
	"$(CC)" -c $< -o $@ $(CFLAGS) $(INCS)

# C++源码的编译规则
$(XOBJS):%.o:%.cpp
	@echo XX	$<  $(XFLAGS)
	"$(XX)" -c $< -o $@ $(XFLAGS) $(INCS)

# 编译之前显示一些信息
dumpInfo:
	echo -e '' \
	'\e[1;36m编译日期: $(BUILD_DATETIME)\e[0m\n' \
	'\e[1;36m编译版本: $(OUT_MSG)\e[0m\n' \
	'\e[1;36m创建目录: $(OUT_DIR)\e[0m\n' \
	'\e[1;36m输出文件: $(OUT_BIN)\e[0m\n' \
	'【建议】：调试版和发行版的.o文件不要共用，若需要编译不同的版本，请先执行make clean把上一次的产生的.o文件清除掉\n'

clean:
	echo "正在清理项目"
	rm -rf ./build
	rm -rf ./.vscode/*.json
	rm -rf $(OBJS)
	clear

define dolink
	echo ''
	echo "正在链接成可执行文件"
	mkdir -p $(OUT_DIR) 2>/dev/null
	$(XX) $(OBJS) $(LIBS) -o $(OUT_BIN)

endef

define showbinary
	echo -e '\e[1;36m 编译完成\n\n\e[0m可执行文件路径为: $(OUT_BIN)'
	ls -al $(OUT_BIN)
	echo ''
endef