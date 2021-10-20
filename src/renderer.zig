const common = @import("./common.zig");
const std = @import("std");
// usingnamespace common;

const c = common.c;

var window: *c.SDL_Window = undefined;
var ren: *c.SDL_Renderer = undefined;

var default_color: Color = Color{ .r = 0, .g = 0, .b = 0, .a = 0 };

pub const Rect = c.SDL_Rect;
pub const Color = c.SDL_Color;

pub const Font = struct {
    file: []const u8,
    size: c_int,

    const FontOpenError = error{FailedToOpen};

    pub fn open(self: *Font) !*c.TTF_Font {
        var font = c.TTF_OpenFont(self.file.ptr, self.size);
        if (font == null) {
            return FontOpenError.FailedToOpen;
        }
        return font.?;
    }
};

var clip: struct {
    left: c_int,
    top: c_int,
    right: c_int,
    bottom: c_int,
} = undefined;

pub fn init(win: *c.SDL_Window) void {
    window = win;
    ren = c.SDL_CreateRenderer(window, -1, c.SDL_RENDERER_ACCELERATED | c.SDL_RENDERER_PRESENTVSYNC).?;
}

pub fn resize() void {
    _ = c.SDL_RenderSetViewport(ren, null);
}

pub fn clear() !void {
    if (c.SDL_RenderClear(ren) != 0) {
        return error.FailedToClear;
    }
}

pub fn rect(r: *Rect) !void {
    if (c.SDL_RenderDrawRect(ren, r) != 0) {
        return error.FailedToDrawRect;
    }
}

pub fn fillRect(r: *Rect) !void {
    if (c.SDL_RenderFillRect(ren, r) != 0) {
        return error.FailedToDrawRect;
    }
}
pub fn color(r: u8, g: u8, b: u8, a: u8) !void {
    default_color = Color{ .r = r, .g = g, .b = b, .a = a };
    if (c.SDL_SetRenderDrawColor(ren, r, g, b, a) != 0) {
        return error.FailedToSetColor;
    }
}

const RenderTextError = error{ FailedToRenderText, FailedToCreateSurface };

pub fn text(txt: []const u8, x: c_int, y: c_int, font: *c.TTF_Font) !void {
    var text_surface = c.TTF_RenderText_Blended(font, txt.ptr, default_color);
    if (text_surface == null) {
        return RenderTextError.FailedToRenderText;
    }
    defer c.SDL_FreeSurface(text_surface);

    var texture = c.SDL_CreateTextureFromSurface(ren, text_surface);
    if (texture == null) {
        return RenderTextError.FailedToCreateSurface;
    }

    var dst = Rect{
        .x = x,
        .y = y,
        .w = 0,
        .h = 0,
    };

    _ = c.SDL_QueryTexture(texture, null, null, &dst.w, &dst.h);
    _ = c.SDL_RenderCopy(ren, texture, null, &dst);
}

pub fn destroy() void {
    _ = c.SDL_DestroyRenderer(ren);
    _ = c.SDL_DestroyWindow(window);
}

pub fn update() void {
    // _ = c.SDL_UpdateWindowSurface(window);
    _ = c.SDL_RenderPresent(ren);
}
