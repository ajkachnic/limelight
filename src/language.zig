const std = @import("std");

pub const Language = enum {
    Zig,
    Rust,
    JavaScript,
    Go,
    Unknown,

    pub fn fromFilename(filename: []const u8) Language {
        if (std.mem.endsWith(u8, filename, ".zig")) {
            return .Zig;
        } else if (std.mem.endsWith(u8, filename, ".js")) {
            return .JavaScript;
        } else if (std.mem.endsWith(u8, filename, ".rs")) {
            return .Rust;
        } else if (std.mem.endsWith(u8, filename, ".go")) {
            return .Go;
        }
        return .Unknown;
    }

    pub fn commentString(self: Language) ?[]const u8 {
        return switch (self) {
            .Zig, .JavaScript, .Rust, .Go => "//",
            .Unknown => null,
        };
    }
};
