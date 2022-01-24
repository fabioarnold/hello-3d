const std = @import("std");
const Sdk = @import("deps/sdl2/Sdk.zig"); // Import the Sdk at build time

pub fn build(b: *std.build.Builder) !void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("hello-3d", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    if (exe.target.isWindows()) {
        exe.addVcpkgPaths(.dynamic) catch @panic("vcpkg not installed");
        if (exe.vcpkg_bin_path) |bin_path| {
            for (&[_][]const u8{"SDL2.dll", "epoxy-0.dll"}) |dll|
                b.installBinFile(try std.fs.path.join(b.allocator, &.{ bin_path, dll }), dll);
        }
        exe.subsystem = .Windows;
    }
    exe.addPackagePath("zgl", "deps/zgl/zgl.zig");
    exe.addPackagePath("zlm", "deps/zlm/zlm.zig");
    const sdk = Sdk.init(b);
    exe.addPackage(sdk.getWrapperPackage("sdl2")); 
    sdk.link(exe, .dynamic); // link SDL2 as a shared library
    exe.linkSystemLibrary("epoxy");
    if (exe.target.isDarwin()) {
        exe.linkFramework("OpenGL");
    } else if (exe.target.isWindows()) {
        exe.linkSystemLibrary("opengl32");
    } else {
        exe.linkSystemLibrary("gl");
    }
    exe.linkLibC();
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    const run_step = b.step("run", "Run hello-3d");
    run_step.dependOn(&run_cmd.step);
}
