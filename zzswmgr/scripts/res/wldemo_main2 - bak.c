#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <syscall.h>
#include <unistd.h>
#include <sys/mman.h>
#include <wayland-client.h>
#include <wlp-xdgshell-client.h>
// #include <os-compatibility.h>


struct client_state  {
    struct wl_compositor *compositor;
    struct wl_shm *shm;
    struct wl_shell *shell;
    struct xdg_wm_base *xdg_wm_base;

    struct wl_surface *surface;
    struct xdg_surface *xdg_surface;
    struct xdg_toplevel *xdg_toplevel;
};


static void
xdg_surface_configure(void *data,
        struct xdg_surface *xdg_surface, uint32_t serial)
{
    // struct client_state *state = data;

    // // 返回一个 ack_configure 以示确认
    // xdg_surface_ack_configure(xdg_surface, serial);

    // // 向缓冲区中绘制内容
    // struct wl_buffer *buffer = draw_frame(state);

    // // 将缓冲区内容附加到表面
    // wl_surface_attach(state->surface, buffer, 0, 0);

    // // 提交表面
    // wl_surface_commit(state->surface);
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
registry_global_handler(void *data, struct wl_registry *registry,
		uint32_t name, const char *interface, uint32_t version)
{
    printf("data: 0x%p, interface handler: %s\n", data, interface);

    struct client_state  *state = data;

    if (strcmp(interface, "wl_compositor") == 0) {
        state->compositor = wl_registry_bind(registry, name,
            &wl_compositor_interface, 3);
    } else if (strcmp(interface, "wl_shm") == 0) {
        state->shm = wl_registry_bind(registry, name,
            &wl_shm_interface, 1);
	} else if (strcmp(interface, "xdg_wm_base") == 0) {
			state->xdg_wm_base = wl_registry_bind(registry, name,
					 &xdg_wm_base_interface, 1);
            xdg_wm_base_add_listener(state->xdg_wm_base, &xdg_wm_base_listener, state);
    } else if (strcmp(interface, "wl_shell") == 0) {
        state->shell = wl_registry_bind(registry, name,
            &wl_shell_interface, 1);
    }

    // if (strcmp(interface, wl_compositor_interface.name) == 0) {
    //     printf("==================> %s\n", wl_compositor_interface.name);

    //     state->compositor = wl_registry_bind(registry, name, &wl_compositor_interface, 4);

    //     // state->compositor = wl_registry_bind(
    //     //     wl_registry, name, &wl_compositor_interface, 4);
    // } else if (strcmp(interface, "wl_shm") == 0) {
    //     state->shm = wl_registry_bind(registry, name, &wl_shm_interface, 1);
    // } else if (strcmp(interface, "wl_shell") == 0) {
    //     state->shell = wl_registry_bind(registry, name, &wl_shell_interface, 1);
    // }
}

static void
registry_global_remove_handler(void *data, struct wl_registry *registry,
		uint32_t name)
{
	// This space deliberately left blank
}

const struct wl_registry_listener registry_listener = {
    .global = registry_global_handler,
    .global_remove = registry_global_remove_handler
};


struct wl_buffer* create_shared_rgba_buffer(struct client_state  *state, struct wl_surface *surface, int width, int height, int stride) {

    int size = stride * height;  // bytes

    #if 1
    // open an anonymous file and write some zero bytes to it
    int fd = syscall(SYS_memfd_create, "buffer", 0);
    printf("fd: %d\n", fd);
    ftruncate(fd, size);
    #elif 1
	int fd = os_create_anonymous_file(size);
	if (fd < 0) {
		fprintf(stderr, "creating a buffer file for %d B failed\n", size);
		return NULL;
	}
    #else
    int fd = allocate_shm_file(size);
    if (fd == -1) {
        return NULL;
    }
    #endif
    

    // map it to the memory
    unsigned char *data = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);

    // turn it into a shared memory pool
    struct wl_shm_pool *pool = wl_shm_create_pool(state->shm, fd, size);

    // allocate the buffer in that pool
    struct wl_buffer *buffer = wl_shm_pool_create_buffer(pool,
        0, width, height, stride, WL_SHM_FORMAT_XRGB8888);

    return buffer;
}


static void
log_handler(const char *format, va_list args)
{
	vfprintf(stderr, format, args);
}


int
main(int argc, char *argv[])
{
	wl_log_set_handler_client(log_handler);

    struct client_state  _state = { 0 }, *state = &_state;

    printf("wldemo2, state: %p\n", state);
    
    struct wl_display *display = wl_display_connect(NULL);
    if (!display) {
        printf("fail to connect to wayland-server\n");
        return 1;
    }

    struct wl_registry *registry = wl_display_get_registry(display);
    if (!registry) {
        printf("fail to registry\n");
        return 1;
    }

    // wait for the "initial" set of globals to appear
    wl_registry_add_listener(registry, &registry_listener, state);
    wl_display_roundtrip(display);

    state->surface = wl_compositor_create_surface(state->compositor);
    if (!state->surface) {
        printf("fail to create surface\n");
        return 1;
    }
    printf("state->surface: %p\n", state->surface);

    // printf("tag1\n");
    // struct wl_shell_surface *shell_surface = wl_shell_get_shell_surface(state->shell, surface);
    // if (!shell_surface) {
    //     printf("fail to create shell_surface\n");
    //     return 1;
    // }
    // wl_shell_surface_set_toplevel(shell_surface);
    // printf("tag2\n");

    // 参考：https://wayland.arktoria.org/7-xdg-shell-basics/example-code.html
    state->xdg_surface = xdg_wm_base_get_xdg_surface(state->xdg_wm_base, state->surface);

    // 添加事件监听
    xdg_surface_add_listener(state->xdg_surface, &xdg_surface_listener, &state);

    // 获得顶层窗口
    state->xdg_toplevel = xdg_surface_get_toplevel(state->xdg_surface);

    // 设置标题
    xdg_toplevel_set_title(state->xdg_toplevel, "Example client");


    int width = 200;
    int height = 200;
    int stride = width * 4;
    struct wl_buffer *buffer = create_shared_rgba_buffer(state, state->surface, width, height, stride);
    if (!buffer) {
        printf("fail to create buffer\n");
        return 1;
    }

    printf("buffer1: %p\n", buffer);

    wl_surface_attach(state->surface, buffer, 0, 0);

    printf("buffer2: %p\n", buffer);


    printf("buffer3: %p\n", buffer);

    wl_surface_damage(state->surface, 0, 0, 100, 100);
    wl_surface_commit(state->surface);

    printf("buffer4: %p\n", buffer);


    while (1) {
        // wl_display_flush_clients();
        wl_display_dispatch(display);
    }

    wl_display_disconnect(display);
    return 0;

}
