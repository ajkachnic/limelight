const builtin = @import("builtin");
const std = @import("std");
const Builder = std.build.Builder;
const allocator = std.testing.allocator;

pub fn build(b: *Builder) !void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("limelight", "src/main.zig");
    exe.setTarget(target);

    exe.setMainPkgPath("./");
    exe.linkSystemLibrary("c");
    exe.linkSystemLibrary("SDL2");
    exe.linkSystemLibrary("SDL2_ttf");
    try includeNix(exe, "NIX_XORGPROTO_DEV");
    try includeNix(exe, "NIX_LIBX11_DEV");
    try includeNix(exe, "NIX_SDL2_DEV");
    try includeNix(exe, "NIX_SDL2_TTF_DEV");
    exe.setOutputDir("./zig-cache");

    exe.setBuildMode(mode);
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}

fn includeNix(exe: *std.build.LibExeObjStep, env_var: []const u8) !void {
    var buf = std.ArrayList(u8).init(allocator);
    defer buf.deinit();
    try buf.appendSlice(std.os.getenv(env_var).?);
    try buf.appendSlice("/include");
    exe.addIncludeDir(buf.items);
}
