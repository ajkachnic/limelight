const std = @import("std");
const common = @import("./common.zig");
const c = common.c;

const renderer = @import("./render.zig");

const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const AutoHashMap = std.AutoHashMap;
const Buffer = common.buffer.Buffer;

pub const Vector2 = struct { x: u32 = 0, y: u32 = 0 };

/// The Editor, which stores an active buffer, and acts as the interface for 
/// interacting with it.
pub const Editor = struct {
    alloc: *Allocator,
    buffer: *Buffer,
    cursor: Vector2,

    pub fn init(alloc: *Allocator, buffer: *Buffer) Editor {
        return Editor{
            .alloc = alloc,
            .buffer = buffer,
        };
    }
};
