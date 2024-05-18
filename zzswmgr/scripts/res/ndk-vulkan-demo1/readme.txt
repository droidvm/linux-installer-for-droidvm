
必须在 vm_config.sh 中使用proot-userland才能在droidvm中通过box64调用ndk-clang

https://github.com/googlesamples/vulkan-basic-samples/
https://github.com/googlesamples/android-vulkan-tutorials/

readelf -d /system/lib64/libvulkan.so


droidvm@localhost:/system/lib64$ readelf -d libvulkan.so

Dynamic section at offset 0x284a0 contains 50 entries:
  Tag        Type                         Name/Value
 0x0000000000000001 (NEEDED)             Shared library: [android.hardware.configstore@1.0.so]
 0x0000000000000001 (NEEDED)             Shared library: [android.hardware.configstore-utils.so]
 0x0000000000000001 (NEEDED)             Shared library: [libziparchive.so]
 0x0000000000000001 (NEEDED)             Shared library: [libhardware.so]
 0x0000000000000001 (NEEDED)             Shared library: [libsync.so]
 0x0000000000000001 (NEEDED)             Shared library: [libbase.so]
 0x0000000000000001 (NEEDED)             Shared library: [libhidlbase.so]
 0x0000000000000001 (NEEDED)             Shared library: [liblog.so]
 0x0000000000000001 (NEEDED)             Shared library: [libui.so]
 0x0000000000000001 (NEEDED)             Shared library: [libgraphicsenv.so]
 0x0000000000000001 (NEEDED)             Shared library: [libutils.so]
 0x0000000000000001 (NEEDED)             Shared library: [libcutils.so]
 0x0000000000000001 (NEEDED)             Shared library: [libz.so]
 0x0000000000000001 (NEEDED)             Shared library: [libnativebridge_lazy.so]
 0x0000000000000001 (NEEDED)             Shared library: [libnativeloader_lazy.so]
 0x0000000000000001 (NEEDED)             Shared library: [libnativewindow.so]
 0x0000000000000001 (NEEDED)             Shared library: [libvndksupport.so]
 0x0000000000000001 (NEEDED)             Shared library: [android.hardware.graphics.common@1.0.so]
 0x0000000000000001 (NEEDED)             Shared library: [libSurfaceFlingerProp.so]
 0x0000000000000001 (NEEDED)             Shared library: [libgpud_sys.so]
 0x0000000000000001 (NEEDED)             Shared library: [libc++.so]
 0x0000000000000001 (NEEDED)             Shared library: [libc.so]
 0x0000000000000001 (NEEDED)             Shared library: [libm.so]
 0x0000000000000001 (NEEDED)             Shared library: [libdl.so]
 0x000000000000000e (SONAME)             Library soname: [libvulkan.so]
 0x000000000000001e (FLAGS)              BIND_NOW
