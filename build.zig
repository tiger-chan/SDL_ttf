const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const use_freetype = true;
    const use_harfbuzz = b.option(bool, "harfbuzz", "Use harfbuzz to improve text shaping") orelse true;
    const use_plutosvg = b.option(bool, "plutosvg", "Use plutosvg for color emoji support") orelse true;
    const preferred_linkage = b.option(
        std.builtin.LinkMode,
        "preferred_linkage",
        "Prefer building statically or dynamically linked libraries (default: static)",
    ) orelse .static;

    const options = b.addOptions();
    options.addOption(bool, "harfbuzz", use_harfbuzz);
    options.addOption(bool, "plutosvg", use_plutosvg);

    const lib_mod = b.addModule("sdl_ttf", .{
        .root_source_file = b.path("zsrc/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const lib = b.addLibrary(.{
        .linkage = preferred_linkage,
        .name = "SDL_ttf",
        .root_module = lib_mod,
    });

    b.installArtifact(lib);

    const sdl_ttf = b.addStaticLibrary(.{
        .name = "c_sdl_ttf",
        .target = target,
        .optimize = optimize,
    });

    sdl_ttf.linkLibC();
    sdl_ttf.addIncludePath(b.path("include/"));
    sdl_ttf.addIncludePath(b.path("src/"));

    const sdl_ttf_flags = .{
        "-fno-sanitize=undefined",
    };

    sdl_ttf.addCSourceFiles(.{
        .root = b.path("src/"),
        .files = srcs,
        .flags = &sdl_ttf_flags,
    });
    if (use_freetype) {
        const freetype_dep = b.dependency("freetype", .{
            .target = target,
            .optimize = optimize,
        });
        lib.linkLibrary(freetype_dep.artifact("freetype"));
    }

    if (use_harfbuzz) {
        const harfbuzz_dep = b.dependency("harfbuzz", .{
            .target = target,
            .optimize = optimize,
        });
        lib.linkLibrary(harfbuzz_dep.artifact("harfbuzz"));
        lib_mod.addCMacro("TTF_USE_HARFBUZZ", "1");
    }

    const sdl3_dep = b.dependency("sdl", .{
        .target = target,
        .optimize = optimize,
    });
    const sdl3_mod = sdl3_dep.module("sdl");
    lib_mod.addImport("sdl", sdl3_mod);

    lib.addIncludePath(sdl3_dep.path("include"));
    sdl_ttf.addIncludePath(sdl3_dep.path("include"));

    sdl_ttf.linkSystemLibrary2("freetype2", .{ .use_pkg_config = .force });

    b.installArtifact(sdl_ttf);

    demo_step(b, lib_mod, target, optimize);

    const lib_unit_tests = b.addTest(.{
        .root_module = lib_mod,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}

const srcs: []const []const u8 = &.{
    "SDL_gpu_textengine.c",
    "SDL_hashtable.c",
    "SDL_hashtable_ttf.c",
    "SDL_renderer_textengine.c",
    "SDL_surface_textengine.c",
    "SDL_ttf.c",
};


fn demo_step(b: *std.Build, mod: anytype, target: anytype, optimize: anytype) void {
    const exe = b.addExecutable(.{
        .name = "hello",
        .root_source_file = b.path("examples/hello/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const sdl3_dep = b.dependency("sdl", .{
        .target = target,
        .optimize = optimize,
    });
    const sdl3_mod = sdl3_dep.module("sdl");
    exe.root_module.addImport("sdl", sdl3_mod);

    exe.root_module.addImport("sdl_ttf", mod);
    b.installArtifact(exe);

    const run_exe = b.step("hello", "Build SDL_TTF Hello Sample");
    run_exe.dependOn(&exe.step);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // This creates a build step. It will be visible in the `zig build --help` menu,
    // and can be selected like this: `zig build run`
    // This will evaluate the `run` step rather than the default, which is "install".
    const run_step = b.step("run", "Run the SDL_TTF Hello Sample");
    run_step.dependOn(&run_cmd.step);
}
