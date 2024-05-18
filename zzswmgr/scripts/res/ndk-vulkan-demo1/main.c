#include <stdio.h>
#include <stdlib.h>
#include <mntent.h>
#include <errno.h>
#include <string.h>

#include <vulkan/vulkan.h>
// #include <GLES2/gl2.h>
// #include <GLES2/gl2ext.h>







// 教程
// https://blog.csdn.net/qq_41061477/article/details/130817222


/* 相关动态库
cat <<- EOF > ./rtlibs.txt
/system/lib64/liblog.so
/system/lib64/libEGL.so
/system/lib64/libGLESv3.so
/system/lib64/libstdc++.so
/system/lib64/libm.so
/system/lib64/libdl.so
/system/lib64/libc.so
/system/lib64/libc++.so
/system/lib64/ld-android.so
/system/lib64/libcutils.so
/system/lib64/libui.so
/system/lib64/libnativewindow.so
/system/lib64/libbacktrace.so
/system/lib64/libvndksupport.so
/system/lib64/android.hardware.graphics.allocator@2.0.so
/system/lib64/android.hardware.graphics.mapper@2.0.so
/system/lib64/android.hardware.configstore@1.0.so
/system/lib64/android.hardware.configstore-utils.so
/system/lib64/libbase.so
/system/lib64/libnativeloader.so
/system/lib64/libhardware.so
/system/lib64/libhidlbase.so
/system/lib64/libhidltransport.so
/system/lib64/libhwbinder.so
/system/lib64/libsync.so
/system/lib64/libutils.so
/system/lib64/libbinder.so
/system/lib64/android.hardware.graphics.common@1.0.so
/system/lib64/android.hidl.base@1.0.so
/system/lib64/libunwind.so
/system/lib64/liblzma.so
/system/lib64/libnativehelper.so
/system/lib64/libnativebridge.so
/system/lib64/libvulkan.so
/system/lib64/libziparchive.so
EOF

[ -d ./rtlibs ] || mkdir ./rtlibs
cat ./rtlibs.txt | while read line
do
	cp -f ${line} ./rtlibs/
done

patchelf --set-rpath "\$ORIGIN"             ./rtlibs/*

**/



static void check_vk_result(VkResult err)
{
    if (err == 0)
    {
        return;
    }
    printf("VkResult %d\n", err);
    if (err < 0)
    {
        exit(-1);
    }
}


int main(void)
{
        printf("=================NDK vulkan 测试开始\n");
	printf("这个程序既可运行于android console中，也可运行于proot环境中，但条件比较苛刻\n");

        printf("目前的测试发现，要想在proot环境中调用ndk编译的vulkan程序，需要满足两个条件：\n");
        printf("# 1). 以宿主的根目录做为虚拟系统的根目录 (无权限列出根目录的文件列表)\n");
        printf("      步骤：开始菜单 -> 控制台 -> proot管理 -> 以宿主根目录为根目录\n");
        printf("# 2). ndk-vulkan程序所在的完整的安卓路径，必须原样不变的映射到虚拟系统中\n");
        printf("      步骤：把此程序复制到 /exbin/n 文件夹内运行\n");
        printf("\n");
        printf("注意：部分机型不需要这些条件，比如早期的鸿蒙手机\n");

        VkApplicationInfo appInfo = {};
        appInfo.sType = VK_STRUCTURE_TYPE_APPLICATION_INFO;
        appInfo.pApplicationName = "Hello Triangle";
        appInfo.applicationVersion = VK_MAKE_VERSION(1, 0, 0);
        appInfo.pEngineName = "No Engine";
        appInfo.engineVersion = VK_MAKE_VERSION(1, 0, 0);
        appInfo.apiVersion = VK_API_VERSION_1_0;

        VkInstanceCreateInfo createInfo = {};
        createInfo.sType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO;
        createInfo.pApplicationInfo = &appInfo;

        VkInstance instance;
        VkResult err;

        if (vkCreateInstance(&createInfo, NULL, &instance) != VK_SUCCESS)
        {
                printf("failed to create instance!\n");
                return -1;
        }

        uint32_t gpu_count = 100;
        err = vkEnumeratePhysicalDevices(instance, &gpu_count, NULL);
        check_vk_result(err);
        printf("gpu_count: %d\n", gpu_count);

        if(gpu_count > 0) {

                int i;
                VkPhysicalDevice tmp_PhysicalDevice = VK_NULL_HANDLE;

                VkPhysicalDevice* gpus = (VkPhysicalDevice*)malloc(sizeof(VkPhysicalDevice) * gpu_count);
                err = vkEnumeratePhysicalDevices(instance, &gpu_count, gpus);
                check_vk_result(err);

                for(i=0; i<gpu_count; i++) {
                        tmp_PhysicalDevice = gpus[i];
                        
                        VkPhysicalDeviceProperties deviceProperties; // https://registry.khronos.org/vulkan/specs/1.3-extensions/man/html/VkPhysicalDeviceProperties.html
                        vkGetPhysicalDeviceProperties(tmp_PhysicalDevice, &deviceProperties);
                        printf("deviceName: %s\n", deviceProperties.deviceName);
                }

                free(gpus);
        }else{
                printf("当前设备未发现支持vulkan的gpu\n");
        }



        vkDestroyInstance(instance, NULL);


        printf("=================NDK vulkan 测试结束\n");

	printf("回车键退出\n");
	getchar();

}
