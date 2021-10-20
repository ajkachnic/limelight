const std = @import("std");
const common = @import("./common.zig");
const c = common.c;

const buffer = @import("./buffer.zig");
const renderer = @import("./renderer.zig");

const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const AutoHashMap = std.AutoHashMap;
const Buffer = buffer.Buffer;

/// The editor itself, containing many buffers, views, etc
pub const Editor = struct {
    alloc: *Allocator,
    font: ?*c.TTF_Font,

    active_buffer: ?*Buffer,

    pub fn init(alloc: *Allocator) Editor {
        return Editor{
            .alloc = alloc,
            .active_buffer = null,
            .font = null,
        };
    }

    pub fn setActiveBuffer(self: *Editor, buf: *Buffer) void {
        self.active_buffer = buf;
    }

    pub fn clearActiveBuffer(self: *Editor) void {
        self.active_buffer = null;
    }

    pub fn viewActiveBuffer(self: *Editor) !bool {
        var active = if (self.active_buffer != null) self.active_buffer.? else {
            return false;
        };

        try renderer.color(255, 255, 255, 255);
        try renderer.text(active.bytes.items, 10, 10, self.font.?);

        return true;
    }
};
