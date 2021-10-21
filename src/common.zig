pub const c = @cImport({
    @cInclude("stdio.h");
    @cInclude("SDL2/SDL.h");
    @cInclude("SDL2/SDL_ttf.h");
});

pub const std = @import("std");
pub const Allocator = std.mem.Allocator;
pub const ArrayList = std.ArrayList;
pub const HashMap = std.HashMap;
pub const AutoHashMap = std.AutoHashMap;

pub const app = @import("./app.zig");
pub const buffer = @import("./buffer.zig");
pub const editor = @import("./editor.zig");
pub const language = @import("./language.zig");
pub const render = @import("./render.zig");
