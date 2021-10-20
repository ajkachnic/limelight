const std = @import("std");

const renderer = @import("./renderer.zig");
const common = @import("./common.zig");
// const rope = @import("./rope.zig");
const state = @import("./state.zig");

const editor = @import("./editor.zig");
const buffer = @import("./buffer.zig");

const c = common.c;

var window: *c.SDL_Window = undefined;

fn hello() !void {
    try renderer.color(255, 200, 100, 255);
    var font = renderer.Font{ .file = "fonts/fira-code.ttf", .size = 16 };
    var opened = font.open() catch {
        std.debug.panic("Failed to open font: {s}", .{c.SDL_GetError()});
    };
    defer c.TTF_CloseFont(opened);
    try renderer.text("hello world", 0, 0, opened);

    renderer.update();
}

pub fn main() anyerror!void {
    var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = general_purpose_allocator.deinit();

    const gpa = &general_purpose_allocator.allocator;

    var quit = false;
    var event: c.SDL_Event = undefined;
    if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
        std.debug.panic("failed to init SDL: {s}", .{c.SDL_GetError()});
        return;
    }
    defer c.SDL_Quit();
    if (c.TTF_Init() != 0) {
        std.debug.panic("failed to init TTF: {s}", .{c.SDL_GetError()});
        return;
    }
    var dm: c.SDL_DisplayMode = undefined;
    _ = c.SDL_GetCurrentDisplayMode(0, &dm);

    var w = @floatToInt(c_int, std.math.round(@intToFloat(f32, dm.w) * 0.8));
    var h = @floatToInt(c_int, std.math.round(@intToFloat(f32, dm.h) * 0.8));
    // const flags = c.SDL_WINDOW_RESIZABLE | c.SDL_WINDOW_ALLOW_HIGHDPI | c.SDL_WINDOW_HIDDEN;

    window = c.SDL_CreateWindow("limelight", 0, 0, w, h, c.SDL_WINDOW_RESIZABLE).?;

    renderer.init(window);
    defer renderer.destroy();

    renderer.update();

    try hello();

    var font = renderer.Font{ .file = "fonts/fira-code.ttf", .size = 16 };
    var opened = font.open() catch {
        std.debug.panic("Failed to open font: {s}", .{c.SDL_GetError()});
    };
    defer c.TTF_CloseFont(opened);

    var ed = editor.Editor.init(gpa);
    var buf = try buffer.Buffer.fromFile(&ed, "/home/andrew/code/github.com/ajkachnic/limelight/hello");

    ed.font = opened;

    ed.setActiveBuffer(&buf);
    _ = try ed.viewActiveBuffer();

    // defer ed.deinit();
    defer buf.deinit();

    _ = buf;

    while (!quit) {
        _ = c.SDL_WaitEvent(&event);

        switch (event.type) {
            c.SDL_QUIT => {
                quit = true;
                break;
            },
            c.SDL_WINDOWEVENT => {
                std.log.debug("window event: {}", .{event.window.event});
                switch (event.window.event) {
                    c.SDL_WINDOWEVENT_EXPOSED => {
                        try renderer.color(0, 0, 0, 0);
                        try renderer.clear();
                        try hello();
                    },
                    c.SDL_WINDOWEVENT_SIZE_CHANGED => {
                        std.log.debug("window resized to {d}x{d}", .{ event.window.data1, event.window.data2 });
                        // var width = event.window.data1;
                        // var height = event.window.data2;
                        // renderer.resize();
                    },
                    // c.SDL_WINDOWEVENT_RESIZED => {
                    // },
                    else => continue,
                }
            },
            else => continue,
        }
    }
}
