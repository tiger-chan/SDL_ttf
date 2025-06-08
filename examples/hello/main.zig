const std = @import("std");
const sdl = @import("sdl");
const sdl_ttf = @import("sdl_ttf");

const sdl_log = std.log.scoped(.sdl);

// Data used by this example
const tiny = @import("tiny.zig").tiny;

var window: ?*sdl.Window = null;
var renderer: ?*sdl.Renderer = null;
var texture: ?*sdl.Texture = null;
var font: ?*sdl_ttf.Font = null;

const App = struct {
    pub const AppState = struct {};
    pub fn on_init(appstate: *?*AppState, args: []const [*:0]u8) sdl.AppResult {
        _ = appstate;
        _ = args;

        const color = sdl.Color.rgb(255, 255, 255);

        const win_rend = sdl.create_window_and_renderer("Hello World", 800, 800, .{});
        if (win_rend == null) {
            sdl_log.err("Couldn't create window and renderer: {s}", .{sdl.err.get()});
            return .Failure;
        }
        window = win_rend.?.window;
        renderer = win_rend.?.renderer;

        if (!sdl_ttf.init()) {
            sdl_log.err("Couldn't initialize SDL_ttf: {s}", .{sdl.err.get()});
            return .Failure;
        }

        // Open the font
        font = sdl_ttf.io.open_font(sdl.io.from_const_mem(tiny), true, 18.0);
        if (font == null) {
            sdl_log.err("Couldn't open font: {s}", .{sdl.err.get()});
            return .Failure;
        }

        // Create the text
        const text = sdl_ttf.render.text.blended(font.?, "Hello World!", color);
        if (text != null) {
            texture = sdl.render.create_texture_from_surface(renderer.?, text.?);
            sdl.surface.destroy(text);
        }

        if (texture == null) {
            sdl_log.err("Couldn't create text: {s}", .{sdl.err.get()});
            return .Failure;
        }

        return .Continue;
    }

    pub fn iter(appstate: ?*AppState) sdl.AppResult {
        _ = appstate;
        const scale = 4.0;
        const size = sdl.render.output_size(renderer.?).?;
        const w: f32 = @floatFromInt(size.w);
        const h: f32 = @floatFromInt(size.h);
        _ = sdl.render.set_scale(renderer.?, scale, scale);
        const texture_size = sdl.render.texture_size(texture.?).?;
        const tw = texture_size.w;
        const th = texture_size.h;

        // Center the text and scale it up
        const dst = sdl.rect.FRect{
            .x = ((w / scale) - tw) / 2,
            .y = ((h / scale) - th) / 2,
            .w = tw,
            .h = th,
        };


        // Draw the text
        _ = sdl.render.draw_color(renderer.?, 0, 0, 0, 255);
        _ = sdl.render.clear(renderer.?);
        _ = sdl.render.texture(renderer.?, texture.?, null, &dst);
        _ = sdl.render.present(renderer.?);

        return .Continue;
    }

    pub fn on_event(appstate: ?*AppState, event: *sdl.Event) sdl.AppResult {
        _ = appstate;
        switch (event.type) {
            .KeyDown, .Quit => {
                return .Success;
            },
            else => {},
        }
        return .Continue;
    }

    pub fn on_quit(appstate: ?*AppState, result: sdl.AppResult) void {
        _ = appstate;
        _ = result;
        if (font != null) {
            sdl_ttf.close_font(font.?);
        }
        sdl_ttf.quit();
    }
};

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const args = try std.process.argsAlloc(allocator);
    if (sdl.run_app(args, App) != 0) @panic("Failed to start the application");
}
