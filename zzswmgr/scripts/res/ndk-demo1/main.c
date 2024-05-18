#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <pthread.h>
#include <ctype.h>
#include <sys/stat.h>
#include <net/if.h>

#include <android/log.h>

#define  LOG_TAG    "phonepc"
#define  LOGI(...)  __android_log_print(ANDROID_LOG_INFO, LOG_TAG,__VA_ARGS__)

#define __FILENAME__ (strrchr(__FILE__, '/') ? strrchr(__FILE__, '/') + 1 : __FILE__)
#define LOG(fmt, ...) printf(fmt" %s:%d\n", ##__VA_ARGS__, __FILENAME__, __LINE__)
#define EXIT(error) do {perror(error); exit(EXIT_FAILURE);} while(0)

/** 注意：
	native apk 的入口函数是 ui_*.c 中的 android_main
	cli 程序的入口才是 main
**/
int main() {
	
	printf("msg from cli\n");
	printf("看到这条消息说明编译、运行都成功了\n");
	printf("这个程序即可运行于android console中，也可运行于droidvm中\n");

	return 0;
}



