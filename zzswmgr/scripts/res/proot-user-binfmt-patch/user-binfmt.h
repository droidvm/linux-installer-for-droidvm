
/**
 * @file main.c
 * @author 韦华锋
 * @brief 
 * @version 0.1
 * @date 2024-02-01
 * 
 * @copyright Copyright (c) 2024
 * 

ls -al \
/usr/lib/binfmt.d/    \
/usr/share/binfmts/   \
/etc/binfmt.d/        \
/var/lib/binfmts/

编译
# gcc main.c  -static
x86_64-linux-gnu-gcc-11  main.c  -static -o zzexec.amd64
aarch64-linux-gnu-gcc-11 main.c  -static -o zzexec.arm64

sudo mkdir -p /test 2>/dev/null
sudo chmod 777 /test
dir=`pwd`
cp -f ./a.out /test/
cp -f ./a     /test/
cd /
# ls -al /test
export PROOT_LOG_LEVEL=10
sudo proot -r / -w / -q ./test/a.out -v ${PROOT_LOG_LEVEL} ./test/a
export PROOT_LOG_LEVEL=0
sudo proot -r / -w / -q ./test/zzexec.amd64 -v ${PROOT_LOG_LEVEL} /bin/env ZZEXE_VERBOSE_ON=1 ZZDIR_BINFMT=/usr/lib/binfmt.d  ./test/a -u p=ww -x --help
cd $dir


cat /etc/ld.so.conf

 * 
 */

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <dirent.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/prctl.h>
#include <linux/elf.h>
#include <sys/stat.h>

#include "tracee/mem.h"
#include "syscall/chain.h"
#include "path/path.h"
#include "execve/aoxp.h"
#include "execve/execve.h"


#define VERSION_STRING		                " version 2024.02.02 by 韦华锋 保留所有权利\n"
#define DEFAULT_BINFMT_ELEMENT_MAX_LENGTH	256
#define DEFAULT_FILE_BUFFER_LENGTH			4096
#define BINFMT_DIR							"/etc/binfmt.d"   //   "/mnt/c/Users/lenovo/Desktop/test" // "/usr/lib/binfmt.d" // /etc/binfmt.d
#define PC_CMD_SPLITER		        		":"

typedef struct {
    char name[DEFAULT_BINFMT_ELEMENT_MAX_LENGTH]; // ignored
    char type; // ignored
    int offset; // ignored!!!
    char magic[DEFAULT_BINFMT_ELEMENT_MAX_LENGTH];
    char mask[DEFAULT_BINFMT_ELEMENT_MAX_LENGTH];
    char interpreter[PATH_MAX]; // empty if not set
    char flags[DEFAULT_BINFMT_ELEMENT_MAX_LENGTH]; // ignored
} BinfmtItem;

char*    log_dir                                            = NULL; // "/tmp";
int      b_verbose                                          = 0;



int zzlogf(const char* format, ...) {
    int nRet = 0;

    if(log_dir) {
        char logpath[PATH_MAX];
        snprintf(logpath, PATH_MAX, "%s/zzexec_pid_%d.log", log_dir, getpid());

        FILE *fplog;
        fplog = fopen(logpath, "ab+");
        if(fplog == NULL) {
            return -1;
        }

        va_list pArgs;
        va_start(pArgs, format);				//字符指针pArgs指向参数列表第一个未名参数(即format格式化所对应的...实际参数)
        nRet = vfprintf (fplog, format, pArgs);	//格式化到buf中
        va_end(pArgs);							//清理工作

        fclose(fplog);
    }else{
        va_list pArgs;
        va_start(pArgs, format);				//字符指针pArgs指向参数列表第一个未名参数(即format格式化所对应的...实际参数)
        nRet = vprintf(format, pArgs);          //格式化到buf中
        va_end(pArgs);							//清理工作

    }
	return nRet;
}

int str_start_with(const char*str, char* needle) {
	
    if(!str || !needle) return 0;

	int len1 = strlen(str);
	int len2 = strlen(needle);
	if( len1 < 1 || len2 < 1 || ( len1 < len2) ) return 0;
	
    if(len1 < len2) return 0;

	int i;
	for(i=0; i<len2; i++) {
		if(*needle++ != *str++) return 0;
	}
	return 1;
}

int str_ends_with(const char*str, char* needle) {
	
    if(!str || !needle) return 0;

	int len1 = strlen(str);
	int len2 = strlen(needle);
	if( len1 < 1 || len2 < 1 || ( len1 < len2) ) return 0;
	
    if(len1 < len2) return 0;

	int i;
    char* ptr = (char*)str + (len1 - len2);
	for(i=0; i<len2; i++) {
		if(*needle++ != *ptr++) return 0;
	}
	return 1;
}

int hex2num(char c)
{
    if (c>='0' && c<='9') return c - '0';
    if (c>='a' && c<='f') return c - 'a' + 10;//这里+10的原因是:比如16进制的a值为10
    if (c>='A' && c<='F') return c - 'A' + 10;
    
    return 16;
}

/**
 * @brief hex2buff 对字符串URL解码,编码的逆过程
 *
 * @param buff 原字符串
 * @param buffSize 原字符串大小（不包括最后的\0）
 * @param result 结果字符串缓存区
 * @param resultSize 结果地址的缓冲区大小(包括最后的\0)
 *
 * @return: >0 result 里实际有效的字符串长度
 *            0 解码失败
 */
int hex2buff(const unsigned char* buff, const int buffSize, char* result, const int resultSize)
{
    char ch,ch1,ch2;
    int i;
    int j = 0;//record result index

    if ((buff==NULL) || (result==NULL) || (buffSize<=0) || (resultSize<=0)) {
        return 0;
    }

    for ( i=0; (i<buffSize) && (j<resultSize); ++i) {
        ch = buff[i];
        switch (ch) {
            // case '+':
            //     result[j++] = ' ';
            //     break;
            case '\\':
				if(buff[i+1] != 'x' && buff[i+1] != 'X') {
					zzlogf("格式错误1\n");
					return 0;
				}
				i++;
                if (i+2<buffSize) {
                    ch1 = hex2num(buff[i+1]);//高4位
                    ch2 = hex2num(buff[i+2]);//低4位
					if(ch1 >= 16 || ch2 >= 16) {
						zzlogf("格式错误2\n");
						return 0;
					}
					result[j++] = (char)((ch1<<4) | ch2);
                    i += 2;
                    break;
                } else {
                    break;
                }
            default:
                result[j++] = ch;
                break;
        }
    }
    
    result[j] = 0;
    return j;
}


/**
 * @brief buff2hex 对字符串URL编码
 *
 * @param buff 原字符串
 * @param buffSize 原字符串长度(不包括最后的\0)
 * @param result 结果缓冲区的地址
 * @param resultSize 结果缓冲区的大小(包括最后的\0)
 *
 * @return: >0:resultstring 里实际有效的长度
 *            0: 解码失败.
 */
int buff2hex(const unsigned char* buff, const int buffSize, char* result, const int resultSize)
{
    int i;
    int j = 0;//for result index
    char ch;

    if ((buff==NULL) || (result==NULL) || (buffSize<=0) || (resultSize<=0)) {
        return 0;
    }

    for ( i=0; (i<buffSize)&&(j<resultSize); ++i) {
        ch = buff[i];
        if (((ch>='A') && (ch<'Z')) ||
            ((ch>='a') && (ch<'z')) ||
            ((ch>='0') && (ch<'9'))) {
            result[j++] = ch;
        // } else if (ch == ' ') {
        //     result[j++] = '+';
        // } else if (ch == '.' || ch == '-' || ch == '_' || ch == '*') {
        //     result[j++] = ch;
        } else {
            if (j+4 < resultSize) {
                sprintf(result+j, "\\x%02x", (unsigned char)ch);
                j += 4;
            } else {
                return 0;
            }
        }
    }

    result[j] = '\0';
    return j;
}

int compare_magic(const char *data, const char *magic, const char *mask, size_t length) {
    if(!mask) {
        for (size_t i = 0; i < length; ++i) {
            if (data[i] != magic[i]) {
                return 0;
            }
        }
    }else{
        for (size_t i = 0; i < length; ++i) {
            if ((data[i] & mask[i]) != (magic[i] & mask[i])) {
                return 0;
            }
        }
    }
    return 1;
}

int is_host_elf_______(char* filepath) {
    // D:\downloads\android-ndk-r23b\toolchains\llvm\prebuilt\linux-x86_64\sysroot\usr\include\linux\elf.h
    int fd;
    int nread;
    char buffer[1024];
    int hdr_len = sizeof(Elf64_Ehdr);

    fd = open(filepath, O_RDONLY);
    if (fd < 0) {
        zzlogf("fail to open filepath: %s\n", filepath);
        return 0;
    }
    nread = read(fd, buffer, hdr_len);
    if (nread < hdr_len) {
        zzlogf("fail on reading elf header\n");
        close(fd);
        return 0;
    }
    close(fd);

    if(buffer[EI_CLASS] == ELFCLASS64) {
        Elf64_Ehdr* hdr = (Elf64_Ehdr*)buffer;
        
        // https://blog.csdn.net/b1049112625/article/details/135666735
        if(hdr->e_machine == (Elf64_Half)0xB7) { // arm64
            zzlogf("arm64 elf: %s\n", filepath);
            return 1;
        }

        // if(hdr->e_machine == (Elf64_Half)0x3E) { // amd64
        //     zzlogf("amd64 elf: %s\n", filepath);
        //     return 1;
        // }

        return 0;
    }else{
        return 0;
    }
}

int is_match(char* exepath, BinfmtItem *bfitem) {
    int fd;
    int rlt=0;
    int nread;
    char buffer[1024];

	if(!bfitem) return 0;

    if(bfitem->type == 'E') {
        zzlogf("fail on type E\n");
        return 0;
    }

    fd = open(exepath, O_RDONLY);
    if (fd < 0) {
        zzlogf("fail to open exepath: %s\n", exepath);
        return 0;
    }

	char buff_magic[1024], buff_masks[1024];;
    int len_magic = hex2buff((const unsigned char*)(bfitem->magic), strlen(bfitem->magic), buff_magic, 1024);
    if (len_magic < 1) {
        zzlogf("invalid len_magic: %d, shoud be >= 1\n", len_magic);
        return 0;
    }
    int len_masks = hex2buff((const unsigned char*)(bfitem->mask), strlen(bfitem->mask), buff_masks, 1024);
    // if (len_masks < 1) {
    //     zzlogf("invalid len_masks: %d, shoud be >= 1\n", len_masks);
    //     return 0;
    // }
    if (len_masks > 0 && len_magic != len_masks) {
        zzlogf("fail on len_masks != len_magic( %d != %d)\n", len_magic, len_masks);
        return 0;
    }

    if(bfitem->offset > 0) {
        off_t currpos;
        currpos = lseek(fd, bfitem->offset, SEEK_SET);
    }

    nread = read(fd, buffer, len_magic);
    if (nread < len_magic) {
        zzlogf("fail on reading file magic\n");
        close(fd);
        return 0;
    }
    close(fd);

    char buff_hex[1024];
    buff2hex((const unsigned char*)buffer, nread, buff_hex, 1024);

    int cmprlt = 0;
    if(len_masks > 0) {
        cmprlt = compare_magic(buffer, buff_magic, buff_masks, len_magic);
    }else{
        cmprlt = compare_magic(buffer, buff_magic, NULL, len_magic);
    }

    if(b_verbose) {
        zzlogf(" file magic: %s\n", (char*)buff_hex);
        zzlogf("   匹配结果：%d\n\n", cmprlt);
    }
    return cmprlt;
}

int readline(int fd, void *buffer, size_t n) {
    size_t numRead;
    size_t totRead;
    char *buf;
    char ch;

    if (n <= 1 || buffer == NULL) {
        errno = EINVAL;
        return -1;
    }

    buf = (char *)buffer;

    totRead = 0;
    for (;;) {
        numRead = read(fd, &ch, 1);
        if (-1 == numRead) {
            if (errno == EINTR) {
                continue;
            } else {
                return -1;
            }
        } else if (numRead == 0) {
            if (totRead == 0) {
                return 0;
            } else {
                break;
            }
        } else {
            if (totRead < n - 1) {
                totRead++;
                *buf++ = ch;
            }

            if (ch == '\n') {
                break;
            }
        }
    }

    *buf = '\0';

    return totRead;
}

int parse_conf_line(char* strline, BinfmtItem *bfitem) {

	if(!bfitem) return 0;

	char* comment = NULL;
	if(comment=strstr(strline, "#")) {
		comment[0] = '\0';
	}

	int leng = strlen(strline);
	if(leng < 1) return 0;

	int i=0, j=0;
	char* fields[10];
	char* ptr=strline;

	do{
		if(strline[j] == ':') {
			ptr = strline + j + 1;
			fields[i] = ptr;
			strline[j] = '\0';
			i++;

			// :name:type:offset:magic:mask:interpreter:flags
			if(i>=7) break;
		}
		j++;
	}while(strline[j]);

	int field_count = i;
	// zzlogf(" field_count: %d\n", field_count);
	if(field_count < 7 ) {
        return 0;
    }

	// for(j=0; j<field_count; j++) {
	// 	zzlogf("    strfield: %s\n", fields[j]);
	// }

	i=0;
    snprintf(bfitem->name, DEFAULT_BINFMT_ELEMENT_MAX_LENGTH, "%s", strlen(fields[i]) > 0 ?fields[i]:""); i++;
	bfitem->type = strlen(fields[i]) > 0?fields[i][0]:'M'; i++;
	bfitem->offset = strlen(fields[i]) > 0?atoi(fields[i]):0; i++;
    snprintf(bfitem->magic, DEFAULT_BINFMT_ELEMENT_MAX_LENGTH, "%s", strlen(fields[i]) > 0 ?fields[i]:""); i++;
    snprintf(bfitem->mask, DEFAULT_BINFMT_ELEMENT_MAX_LENGTH, "%s", strlen(fields[i]) > 0 ?fields[i]:""); i++;
    snprintf(bfitem->interpreter, PATH_MAX, "%s", strlen(fields[i]) > 0 ?fields[i]:""); i++;
    snprintf(bfitem->flags, DEFAULT_BINFMT_ELEMENT_MAX_LENGTH, "%s", strlen(fields[i]) > 0 ?fields[i]:""); i++;

    for(i=0; i<strlen(bfitem->flags); i++) {
        if( (bfitem->flags)[i] == '\r') { (bfitem->flags)[i] = '\0'; break; }
        if( (bfitem->flags)[i] == '\n') { (bfitem->flags)[i] = '\0'; break; }
    }

    if(b_verbose) {
        zzlogf(
            "       name: %s\n"
            "       type: %c\n"
            "     offset: %d\n"
            "      magic: %s\n"
            "       mask: %s\n"
            "interpreter: %s\n"
            "      flags: %s\n"
            ,
            bfitem->name,
            bfitem->type,
            bfitem->offset,
            bfitem->magic,
            bfitem->mask,
            bfitem->interpreter,
            bfitem->flags
        );
    }

    return 1;
}

int parse_conf_file(char* filepath, char* exepath, BinfmtItem* bfitem) {
	char buff[1024];
	int fd;
	int rlt = 0;


	fd = open(filepath, O_RDONLY);
	if (fd < 0) {
        errno = EINVAL;
		return rlt;
	}

	int nread;
	while(nread=readline(fd, buff, 1024) > 0) {
		if(!parse_conf_line(buff, bfitem)) continue;

		// item 有效
        if(is_match(exepath, bfitem)) {
			rlt = 1;
            break;
        }
		// int len = hex2buff(bfitem.magic, strlen(bfitem.magic), buff, 1024);
		// char buf2[1024];
		// buff2hex(buff, len, buf2, 1024);
		// zzlogf("      magic: %s\n", (char*)buf2);
	}

	close(fd);

	return rlt;
}

int read_cfg_dir(char *cfg_dirpath, char* exepath, BinfmtItem* bfitem)
{
    DIR *dir;
    struct dirent *ptr;
    char base[1000];
	int rlt_interpreter_exist = 0;

    zzlogf("BINFMT_DIR: |%s|\n", cfg_dirpath);

    if ((dir=opendir(cfg_dirpath)) == NULL)
    {
        zzlogf("fail to open dir \n");
        exit(1);
    }

    while ((ptr=readdir(dir)) != NULL) {
        

        // not a real file
        if(ptr->d_type != 8) continue;

        if(!str_ends_with(ptr->d_name, ".conf")) continue;

        char cfg_filepath[PATH_MAX];
        snprintf(cfg_filepath, PATH_MAX, "%s/%s", cfg_dirpath, ptr->d_name);

        if(b_verbose) {
            zzlogf("正在分析 %s\n", cfg_filepath);
        }

        rlt_interpreter_exist = parse_conf_file(cfg_filepath, exepath, bfitem);
        if(rlt_interpreter_exist) {
            break;
        }

        // if(strcmp(ptr->d_name,".")==0 || strcmp(ptr->d_name,"..")==0)    ///current dir OR parrent dir
        //     continue;
        // else if(ptr->d_type == 8)    ///file
        //     // zzlogf("d_name:%s/%s\n", cfg_dirpath, ptr->d_name);
        //     ;
        // else if(ptr->d_type == 10)    ///link file
        //     ;
        //     // zzlogf("d_name:%s/%s\n",cfg_dirpath,ptr->d_name);
        // else if(ptr->d_type == 4)    ///dir
        // {
        //     // memset(base,'\0',sizeof(base));
        //     // strcpy(base,cfg_dirpath);
        //     // strcat(base,"/");
        //     // strcat(base,ptr->d_name);
        //     // readFileList(base);
        // }
    }
    closedir(dir);
    return rlt_interpreter_exist;
}

bool user_binfmt_is_host_elf(const Tracee *tracee, const char *host_path)
{
	// for android: run "adb shell getprop ro.product.cpu.abilist" to get the abi list
    char* host_abis = getenv("PROOT_HOST_ABIS");
    if(!host_abis) {
		host_abis = "";
	}

	#if defined(ARCH_X86_64)
		int host_elf_machine[] = HOST_ELF_MACHINE;
	#elif defined(ARCH_ARM64)
		int host_elf_machine[4] = {0, 0, 0, 0};
		host_elf_machine[0] = 183;		// arm64, 
		if(strstr(host_abis, "armeabi")) {
			host_elf_machine[1] = 40;	// arm32
		}
	#else
		// #error "Unsupported architecture"
		return 0;
	#endif


	static int force_foreign = -1;
	ElfHeader elf_header;
	uint16_t elf_machine;
	int fd;
	int i;

	// if (force_foreign < 0)
	// 	force_foreign = (getenv("PROOT_FORCE_FOREIGN_BINARY") != NULL);

	// if (force_foreign > 0 || !tracee->qemu)
	// 	return false;

	fd = open_elf(host_path, &elf_header);
	if (fd < 0)
		return false;
	close(fd);

	elf_machine = ELF_FIELD(elf_header, machine);
	// https://blog.csdn.net/b1049112625/article/details/135666735
	VERBOSE(tracee, 1, "'%s' elf_machine => 0x%04X", host_path, elf_machine);
	for (i = 0; host_elf_machine[i] != 0; i++) {
		if (host_elf_machine[i] == elf_machine) {
			VERBOSE(tracee, 1, "'%s' is a host ELF", host_path);
			return true;
		}
	}

	return false;
}

int expand_user_binfmt(Tracee *tracee, char host_path[PATH_MAX], char user_path[PATH_MAX]) {
	b_verbose = tracee->verbose;
	int status;
	int fd = -1;
	ArrayOfXPointers *argv;
	ElfHeader ehdr; ElfHeader* pHdr = &ehdr;
	BinfmtItem binary_binfmt;
	char cfgdir[PATH_MAX];

// #ifdef __ANDROID__
//     // run at host side !!!!
//     /* example:
//        cp -f /system/bin/sh  ~/sh.hst
//        ~/sh.hst
//     */
//     if(str_ends_with(host_path, ".hst")) {
//         tracee->skip_proot_loader = true;
//     }
// #endif    

	memset(&binary_binfmt, 0, sizeof(BinfmtItem));

	if (user_binfmt_is_host_elf(tracee, host_path)) {
		// VERBOSE(tracee, 0, "%s is host elf", host_path);
		return 0;
	// }else{
	// 	VERBOSE(tracee, 0, "%s is not host elf", host_path);
	}

    char* USER_BINFMT_DIR = getenv("PROOT_USER_BINFMT_DIR");
    if(!USER_BINFMT_DIR || strlen(USER_BINFMT_DIR) < 2) {
		USER_BINFMT_DIR = BINFMT_DIR;
	}
	char* path2guest = get_root(tracee);
	snprintf(cfgdir, PATH_MAX, "%s%s", path2guest, USER_BINFMT_DIR);

	char* user_interpreter = NULL;
	int rlt_interpreter_exist = read_cfg_dir(cfgdir, host_path, &binary_binfmt);
    if(rlt_interpreter_exist) {
        user_interpreter = binary_binfmt.interpreter;
	}else{
		return 0;
	}

    // char* user_interpreter = getenv("PROOT_USER_BINFMT_INTERPRETER");
    // if(!user_interpreter || strlen(user_interpreter) < 2) {
	// 	return 0;
	// }

	VERBOSE(tracee, 1, "user-binfmt-support hit: |%s| |%s|", user_interpreter, host_path);

	// 	fd = open_elf(host_path, pHdr);
	// 	if (fd < 0) {
	// 		return 0;
	// 	}
	// 	close(fd);

	// 	uint16_t archid = ELF_FIELD(ehdr, machine);

	// #if defined(ARCH_X86_64)
	// 	if(IS_CLASS64(ehdr) && archid == 0x003E) {
	// 		return 0;
	// 	}

	// #elif defined(ARCH_ARM64)
	// 	if(!IS_CLASS64(ehdr)) {
	// 		return 0;
	// 	}

	// #else
	// 	// #error "Unsupported architecture"
	// 	return 0;
	// #endif


	status = fetch_array_of_xpointers(tracee, &argv, SYSARG_2, 0);
	if (status < 0)
		return status;
	
	status = resize_array_of_xpointers(argv, 0, 1);
	if (status < 0)
		return status;

	status = write_xpointees(argv, 0, 2, user_interpreter, user_path);
	if (status < 0)
		return status;
	
	status = push_array_of_xpointers(argv, SYSARG_2);
	if (status < 0)
		return status;

	strcpy(user_path, user_interpreter);

	status = translate_path(tracee, host_path, AT_FDCWD, user_path, true);
	if (status < 0)
		return status;

    return 0;
}

