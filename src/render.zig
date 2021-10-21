const common = @import("./common.zig");
const std = @import("std");
// usingnamespace common;

const c = common.c;

var default_color: Color = Color{ .r = 0, .g = 0, .b = 0, .a = 0 };

pub const Rect = c.SDL_Rect;
pub const Color = c.SDL_Color;

pub const Renderer = struct {
    win: *c.SDL_Window,
    ren: *c.SDL_Renderer,

    pub fn init(win: *c.SDL_Window) Renderer {
        var ren = c.SDL_CreateRenderer(win, -1, c.SDL_RENDERER_ACCELERATED | c.SDL_RENDERER_PRESENTVSYNC).?;

        return .{
            .win = win,
            .ren = ren,
        };
    }

    pub fn resize(self: *Renderer) void {
        _ = c.SDL_RenderSetViewport(self.ren, null);
    }

    pub fn clear(self: *Renderer) !void {
        if (c.SDL_RenderClear(self.ren) != 0) {
            return error.FailedToClear;
        }
    }

    pub fn rect(self: *Renderer, r: *Rect) !void {
        if (c.SDL_RenderDrawRect(self.ren, r) != 0) {
            return error.FailedToDrawRect;
        }
    }

    pub fn fillRect(self: *Renderer, r: *Rect) !void {
        if (c.SDL_RenderFillRect(self.ren, r) != 0) {
            return error.FailedToDrawRect;
        }
    }
    pub fn color(self: *Renderer, r: u8, g: u8, b: u8, a: u8) !void {
        default_color = Color{ .r = r, .g = g, .b = b, .a = a };
        if (c.SDL_SetRenderDrawColor(self.ren, r, g, b, a) != 0) {
            return error.FailedToSetColor;
        }
    }

    pub fn text(self: *Renderer, txt: []const u8, x: c_int, y: c_int, font: *c.TTF_Font) !void {
        var text_surface = c.TTF_RenderText_Blended(font, txt.ptr, default_color);
        if (text_surface == null) {
            return error.FailedToRenderText;
        }
        defer c.SDL_FreeSurface(text_surface);

        var texture = c.SDL_CreateTextureFromSurface(self.ren, text_surface);
        if (texture == null) {
            return error.FailedToCreateSurface;
        }

        var dst = Rect{
            .x = x,
            .y = y,
            .w = 0,
            .h = 0,
        };

        _ = c.SDL_QueryTexture(texture, null, null, &dst.w, &dst.h);
        _ = c.SDL_RenderCopy(self.ren, texture, null, &dst);
    }

    pub fn deinit(self: *Renderer) void {
        _ = c.SDL_DestroyRenderer(self.ren);
        _ = c.SDL_DestroyWindow(self.win);
    }

    pub fn update(self: *Renderer) void {
        _ = c.SDL_RenderPresent(self.ren);
    }
};

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
