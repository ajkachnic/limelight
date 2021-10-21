const std = @import("std");

const App = @import("./app.zig").App;
const render = @import("./render.zig");
const common = @import("./common.zig");
// const rope = @import("./rope.zig");
const state = @import("./state.zig");

const editor = @import("./editor.zig");
const buffer = @import("./buffer.zig");

const c = common.c;

var window: *c.SDL_Window = undefined;

// fn hello() !void {
//     try renderer.color(255, 200, 100, 255);
//     var font = renderer.Font{ .file = "fonts/fira-code.ttf", .size = 16 };
//     var opened = font.open() catch {
//         std.debug.panic("Failed to open font: {s}", .{c.SDL_GetError()});
//     };
//     defer c.TTF_CloseFont(opened);
//     try renderer.text("hello world", 0, 0, opened);

//     renderer.update();
// }

pub fn main() anyerror!void {
    var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = general_purpose_allocator.deinit();

    const gpa = &general_purpose_allocator.allocator;

    var app = try App.init(gpa);
    defer app.deinit();

    var event: c.SDL_Event = undefined;

    while (true) {
        _ = c.SDL_WaitEvent(&event);
        if (app.handle_event(&event)) {
            break;
        }
    }
}
