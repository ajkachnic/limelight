const common = @import("./common.zig");
const std = @import("std");

const c = common.c;

const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const StringHashMap = std.StringHashMap;
const Buffer = common.buffer.Buffer;
const Renderer = common.render.Renderer;

// The biggest construct of the editor, manages everything
pub const App = struct {
    alloc: *Allocator,
    renderer: Renderer,
    window: *c.SDL_Window,
    buffer_list: ArrayList(*Buffer),

    /// List of buffers with their corresponding file, for quick lookups
    files: StringHashMap(*Buffer),

    pub fn init(alloc: *Allocator) !App {
        if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
            return error.FailedToInitSDL;
        }
        if (c.TTF_Init() != 0) {
            return error.FailedToInitTTF;
        }

        var dm: c.SDL_DisplayMode = undefined;
        if (c.SDL_GetCurrentDisplayMode(0, &dm) != 0) {
            return error.FailedToGetDisplayMode;
        }

        // Open to 80% of screen size by default
        var w = @floatToInt(c_int, std.math.round(@intToFloat(f32, dm.w) * 0.8));
        var h = @floatToInt(c_int, std.math.round(@intToFloat(f32, dm.h) * 0.8));

        var window = c.SDL_CreateWindow("limelight", 0, 0, w, h, c.SDL_WINDOW_RESIZABLE).?;
        var renderer = Renderer.init(window);

        return App{
            .alloc = alloc,
            .buffer_list = ArrayList(*Buffer).init(alloc),
            .files = StringHashMap(*Buffer).init(alloc),
            .renderer = renderer,
            .window = window,
        };
    }

    pub fn deinit(self: *App) void {
        self.buffer_list.deinit();
        self.files.deinit();
        self.renderer.deinit();
        c.SDL_Quit();
    }

    /// Handle an SDL event. Returns whether or not to quit.
    pub fn handle_event(self: *App, ev: *c.SDL_Event) bool {
        _ = self;
        switch (ev.type) {
            c.SDL_QUIT => return true,
            else => return false,
        }
    }
};
