const std = @import("std");
const sdl = @import("sdl2");
const gl = @import("zgl");
const zlm = @import("zlm");
const m = zlm.SpecializeOn(f32);

pub fn main() !void {
    try sdl.init(.{ .video = true, .events = true });
    defer sdl.quit();

    try sdl.gl.setAttribute(.{ .depth_size = 24 });
    try sdl.gl.setAttribute(.{ .multisamplebuffers = true });
    try sdl.gl.setAttribute(.{ .multisamplesamples = 4 });
    const window = try sdl.createWindow("hello-3d", .{ .centered = {} }, .{ .centered = {} }, 640, 400, .{ .opengl = true, .allow_high_dpi = true });
    defer window.destroy();

    const ctx = try sdl.gl.createContext(window);
    defer sdl.gl.deleteContext(ctx);

    try sdl.gl.setSwapInterval(.vsync);
    gl.enable(.depth_test);

    var mvp_loc: u32 = undefined;
    var color_loc: u32 = undefined;
    const program = gl.Program.create();
    {
        const vs = gl.Shader.create(.vertex);
        defer vs.delete();
        vs.source(1, &.{@embedFile("../data/transform.vert")});
        vs.compile();
        const fs = gl.Shader.create(.fragment);
        defer fs.delete();
        fs.source(1, &.{@embedFile("../data/color.frag")});
        fs.compile();
        program.attach(vs);
        defer program.detach(vs);
        program.attach(fs);
        defer program.detach(fs);
        program.link();
        mvp_loc = program.uniformLocation("mvp").?;
        color_loc = program.uniformLocation("color").?;
    }
    program.use();

    const buf = gl.Buffer.gen();
    buf.bind(.array_buffer);
    gl.bufferData(.array_buffer, f32, &@import("zig-mark.zig").positions, .static_draw); // buf.data requires gl 4.5
    defer buf.delete();

    const proj = m.Mat4.createPerspective(zlm.toRadians(45.0), 1.6, 0.1, 10.0);
    const trans = m.Mat4.createTranslationXYZ(0, 0, 4);

    var frame: u64 = 0;
    mainLoop: while (true) {
        while (sdl.pollEvent()) |ev| {
            switch (ev) {
                .quit => break :mainLoop,
                else => {},
            }
        }

        gl.clearColor(0.5, 0.5, 0.5, 1);
        gl.clear(.{ .color = true, .depth = true });

        const rot = m.Mat4.createAngleAxis(m.Vec3.unitY, 0.04 * @intToFloat(f32, frame));
        const mvp = rot.mul(trans.mul(proj));

        gl.enableVertexAttribArray(0);
        gl.vertexAttribPointer(0, 3, .float, false, 0, 0);
        program.uniformMatrix4(mvp_loc, false, &.{mvp.fields});
        program.uniform4f(color_loc, 0.97, 0.64, 0.11, 1);
        gl.drawArrays(.triangles, 0, 120);
        program.uniform4f(color_loc, 0.98, 0.82, 0.6, 1);
        gl.drawArrays(.triangles, 120, 66);
        program.uniform4f(color_loc, 0.6, 0.35, 0.02, 1);
        gl.drawArrays(.triangles, 186, 90);
        gl.disableVertexAttribArray(0);

        sdl.gl.swapWindow(window);
        frame += 1;
    }
}
