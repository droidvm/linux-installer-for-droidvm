#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <syscall.h>
#include <unistd.h>
#include <sys/mman.h>
#include <wayland-client.h>
#include <wlp-xdgshell-client.h>
// #include <os-compatibility.h>

/* Wayland code */
struct client_state {
    /* Globals */
    struct wl_display *wl_display;
    struct wl_registry *wl_registry;
    struct wl_shm *wl_shm;
    // struct wl_shell *shell;
    struct wl_compositor *wl_compositor;
    struct xdg_wm_base *xdg_wm_base;
    /* Objects */
    struct wl_surface *wl_surface;
    struct xdg_surface *xdg_surface;
    struct xdg_toplevel *xdg_toplevel;
};

static void
wl_buffer_release(void *data, struct wl_buffer *wl_buffer)
{
    /* Sent by the compositor when it's no longer using this buffer */
    wl_buffer_destroy(wl_buffer);
}

static const struct wl_buffer_listener wl_buffer_listener = {
    .release = wl_buffer_release,
};

static struct wl_buffer *
draw_frame(struct client_state *state)
{
    const int width = 640, height = 480;
    int stride = width * 4;
    int size = stride * height;

    // int fd = allocate_shm_file(size);
    // if (fd == -1) {
    //     return NULL;
    // }

    // open an anonymous file and write some zero bytes to it
    int fd = syscall(SYS_memfd_create, "buffer", 0);
    printf("fd: %d\n", fd);
    ftruncate(fd, size);


    uint32_t *data = mmap(NULL, size,
            PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    if (data == MAP_FAILED) {
        close(fd);
        return NULL;
    }

    // 创建一个共享内存池
    struct wl_shm_pool *pool = wl_shm_create_pool(state->wl_shm, fd, size);

    // 创建一个缓冲区 
    struct wl_buffer *buffer = wl_shm_pool_create_buffer(pool, 0,
            width, height, stride, WL_SHM_FORMAT_XRGB8888);
    wl_shm_pool_destroy(pool);
    close(fd);

    /* Draw checkerboxed background */
    for (int y = 0; y < height; ++y) {
        for (int x = 0; x < width; ++x) {
            if ((x + y / 8 * 8) % 16 < 8)
                data[y * width + x] = 0xFF666666;
            else
                data[y * width + x] = 0xFFEEEEEE;
        }
    }

    munmap(data, size);

    // 添加监听器用于检测释放缓冲区的事件
    wl_buffer_add_listener(buffer, &wl_buffer_listener, NULL);
    return buffer;
}

static void
xdg_surface_configure(void *data,
        struct xdg_surface *xdg_surface, uint32_t serial)
{
    struct client_state *state = data;

    // 返回一个 ack_configure 以示确认
    xdg_surface_ack_configure(xdg_surface, serial);

    // 向缓冲区中绘制内容
    struct wl_buffer *buffer = draw_frame(state);

    // 将缓冲区内容附加到表面
    wl_surface_attach(state->wl_surface, buffer, 0, 0);

    // 提交表面
    wl_surface_commit(state->wl_surface);
}

static const struct xdg_surface_listener xdg_surface_listener = {
    .configure = xdg_surface_configure,
};

static void
xdg_wm_base_ping(void *data, struct xdg_wm_base *xdg_wm_base, uint32_t serial)
{
    xdg_wm_base_pong(xdg_wm_base, serial);
}

static const struct xdg_wm_base_listener xdg_wm_base_listener = {
    .ping = xdg_wm_base_ping,
};

static void
registry_global(void *data, struct wl_registry *wl_registry,
        uint32_t name, const char *interface, uint32_t version)
{
    struct client_state *state = data;

    // 绑定到全局
    if (strcmp(interface, wl_shm_interface.name) == 0) {
        state->wl_shm = wl_registry_bind(
                wl_registry, name, &wl_shm_interface, 1);
    } else if (strcmp(interface, wl_compositor_interface.name) == 0) {
        state->wl_compositor = wl_registry_bind(
                wl_registry, name, &wl_compositor_interface, 4);
    } else if (strcmp(interface, xdg_wm_base_interface.name) == 0) {
        state->xdg_wm_base = wl_registry_bind(
                wl_registry, name, &xdg_wm_base_interface, 1);
        xdg_wm_base_add_listener(state->xdg_wm_base,
                &xdg_wm_base_listener, state);
    #if 0
    } else if (strcmp(interface, "wl_shell") == 0) {
        state->shell = wl_registry_bind(registry, name,
            &wl_shell_interface, 1);
    #endif
    }
}

static void
registry_global_remove(void *data,
        struct wl_registry *wl_registry, uint32_t name)
{
    /* This space deliberately left blank */
}

static const struct wl_registry_listener wl_registry_listener = {
    .global = registry_global,
    .global_remove = registry_global_remove,
};

int
main(int argc, char *argv[])
{
    // 初始化状态
    struct client_state state = { 0 };
    
    // 获取默认显示器
    state.wl_display = wl_display_connect(NULL);
    
    // 注册到默认显示器
    state.wl_registry = wl_display_get_registry(state.wl_display);
    
    // 添加事件监听
    wl_registry_add_listener(state.wl_registry, &wl_registry_listener, &state);

    // 以 wl_display 作为代理连接到混成器
    wl_display_roundtrip(state.wl_display);

    // 从混成器创建一个表面
    state.wl_surface = wl_compositor_create_surface(state.wl_compositor);

    #if 1
    // 从 wl_surface 创建一个 xdg_surface
    state.xdg_surface = xdg_wm_base_get_xdg_surface(
            state.xdg_wm_base, state.wl_surface);

    // 添加事件监听
    xdg_surface_add_listener(state.xdg_surface, &xdg_surface_listener, &state);

    // 获得顶层窗口
    state.xdg_toplevel = xdg_surface_get_toplevel(state.xdg_surface);

    // 设置标题
    xdg_toplevel_set_title(state.xdg_toplevel, "Example client");
    #else
    struct wl_shell_surface *shell_surface = wl_shell_get_shell_surface(state->shell, state.wl_surface);
    if (!shell_surface) {
        printf("fail to create shell_surface\n");
        return 1;
    }
    wl_shell_surface_set_toplevel(shell_surface);
    #endif

    // 提交表面
    wl_surface_commit(state.wl_surface);

    while (wl_display_dispatch(state.wl_display)) {
        /* This space deliberately left blank */
    }

    return 0;
}