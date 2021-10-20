const std = @import("std");

const Editor = @import("./editor.zig").Editor;
const Language = @import("./language.zig").Language;

const ArrayList = std.ArrayList;

pub const BufferSource = union(enum) {
    None,
    File: struct {
        filename: []const u8,
    },
};

// A Buffer is a document opened within the editor. Similar to vim and other
// editors, buffers can be put in different window splits and configurations,
// but closing a window doesn't close the actual buffer itself.
//
// Buffers contain the current editor state for a given document
pub const Buffer = struct {
    bytes: ArrayList(u8),
    lang: Language,
    source: BufferSource,
    editor: *Editor,

    pub fn fromFile(editor: *Editor, filename: []const u8) !Buffer {
        var file_descriptor = try std.fs.openFileAbsolute(filename, .{
            .read = true,
        });
        var file_size = (try file_descriptor.stat()).size;
        var file_buffer = try ArrayList(u8).initCapacity(editor.alloc, file_size);

        std.log.debug("file size: {d}", .{file_size});

        var reader = file_descriptor.reader();
        try reader.readAllArrayList(&file_buffer, 2048);

        var lang = Language.fromFilename(filename);
        var source = BufferSource{ .File = .{ .filename = filename } };

        return Buffer{
            .lang = lang,
            .source = source,
            .bytes = file_buffer,
            .editor = editor,
        };
    }

    pub fn deinit(self: *Buffer) void {
        self.bytes.deinit();
    }
};
