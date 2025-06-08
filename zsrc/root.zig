const sdl = @import("sdl");

pub const Font = opaque {};

/// Initialize SDL_ttf.
///
/// You must successfully call this function before it is safe to call any
/// other function in this library.
///
/// It is safe to call this more than once, and each successful sdl_ttf.init()
/// call should be paired with a matching sdl_ttf.quit() call.
///
/// *returns* true on success or false on failure; call sdl.err.get() for more
///          information.
pub fn init() bool {
    return TTF_Init();
}

/// Deinitialize SDL_ttf.
///
/// You must call this when done with the library, to free internal resources.
/// It is safe to call this when the library isn't initialized, as it will just
/// return immediately.
///
/// Once you have as many quit calls as you have had successful calls to
/// TTF_Init, the library will actually deinitialize.
///
/// Please note that this does not automatically close any fonts that are still
/// open at the time of deinitialization, and it is possibly not safe to close
/// them afterwards, as parts of the library will no longer be initialized to
/// deal with it. A well-written program should call TTF_CloseFont() on any
/// open fonts before calling this function!
///
/// *threadsafety* It is safe to call this function from any thread.
pub fn quit() void {
    TTF_Quit();
}

/// Dispose of a previously-created font.
///
/// Call this when done with a font. This function will free any resources
/// associated with it. It is safe to call this function on NULL, for example
/// on the result of a failed call to TTF_OpenFont().
///
/// The font is not valid after being passed to this function. String pointers
/// from functions that return information on this font, such as
/// TTF_GetFontFamilyName() and TTF_GetFontStyleName(), are no longer valid
/// after this call, as well.
///
/// *param* font the font to dispose of.
///
/// *threadsafety* This function should not be called while any other thread is
///               using the font.
pub fn close_font(font: *Font) void {
    return TTF_CloseFont(font);
}

pub const io = struct {
    /// Create a font from an sdl.io.Stream, using a specified point size.
    ///
    /// Some .fon fonts will have several sizes embedded in the file, so the point
    /// size becomes the index of choosing which size. If the value is too high,
    /// the last indexed size will be the default.
    ///
    /// If `closeio` is true, `src` will be automatically closed once the font is
    /// closed. Otherwise you should keep `src` open until the font is closed.
    ///
    /// When done with the returned sdl_ttf.Font, use sdl_ttf.io.close_font() to
    /// dispose of it.
    ///
    /// *param* src an sdl.io.Stream to provide a font file's data.
    /// *param* closeio true to close `src` when the font is closed, false to leave
    ///                it open.
    /// *param* ptsize point size to use for the newly-opened font.
    /// *returns* a valid sdl_ttf.Font, or NULL on failure; call sdl.err.get() for more
    ///          information.
    ///
    /// *threadsafety* It is safe to call this function from any thread.
    pub fn open_font(src: ?*sdl.io.Stream, closeio: bool, ptsize: f32) ?*Font {
        return TTF_OpenFontIO(src, closeio, ptsize);
    }
};

pub const render = struct {
    pub const text = struct {
        /// Render UTF-8 text at high quality to a new 8-bit surface.
        ///
        /// This function will allocate a new 8-bit, palettized surface. The surface's
        /// 0 pixel will be the specified background color, while other pixels have
        /// varying degrees of the foreground color. This function returns the new
        /// surface, or NULL if there was an error.
        ///
        /// This will not word-wrap the string; you'll get a surface with a single line
        /// of text, as long as the string requires. You can use
        /// sdl_ttf.render.text.shaded_wrapped() instead if you need to wrap the output to
        /// multiple lines.
        ///
        /// This will not wrap on newline characters.
        ///
        /// You can render at other quality levels with sdl_ttf.render.text.solid,
        /// sdl_ttf.render.text.blended, and sdl_ttf.render.text.lcd.
        ///
        /// *param* font the font to render with.
        /// *param* text text to render, in UTF-8 encoding.
        /// *param* length the length of the text, in bytes, or 0 for null terminated
        ///               text.
        /// *param* fg the foreground color for the text.
        /// *param* bg the background color for the text.
        /// *returns* a new 8-bit, palettized surface, or NULL if there was an error.
        ///
        /// *threadsafety* This function should be called on the thread that created the
        ///               font.
        pub fn shaded(font: *Font, txt: []const u8, fg: sdl.Color, bg: sdl.Color) ?*sdl.Surface {
            return TTF_RenderText_Shaded(font, txt, @ptrCast(txt.ptr), txt.len, fg, bg);
        }

        /// Render word-wrapped UTF-8 text at high quality to a new 8-bit surface.
        ///
        /// This function will allocate a new 8-bit, palettized surface. The surface's
        /// 0 pixel will be the specified background color, while other pixels have
        /// varying degrees of the foreground color. This function returns the new
        /// surface, or NULL if there was an error.
        ///
        /// Text is wrapped to multiple lines on line endings and on word boundaries if
        /// it extends beyond `wrap_width` in pixels.
        ///
        /// If wrap_width is 0, this function will only wrap on newline characters.
        ///
        /// You can render at other quality levels with TTF_RenderText_Solid_Wrapped,
        /// TTF_RenderText_Blended_Wrapped, and TTF_RenderText_LCD_Wrapped.
        ///
        /// *param* font the font to render with.
        /// *param* text text to render, in UTF-8 encoding.
        /// *param* length the length of the text, in bytes, or 0 for null terminated
        ///               text.
        /// *param* fg the foreground color for the text.
        /// *param* bg the background color for the text.
        /// *param* wrap_width the maximum width of the text surface or 0 to wrap on
        ///                   newline characters.
        /// *returns* a new 8-bit, palettized surface, or NULL if there was an error.
        ///
        /// *threadsafety* This function should be called on the thread that created the
        ///               font.
        pub fn shaded_wrapped(font: *Font, txt: []const u8, fg: sdl.Color, bg: sdl.Color, wrap_width: i32) ?*sdl.Surface {
            return TTF_RenderText_Shaded_Wrapped(font, @ptrCast(txt.ptr), txt.len, fg, bg, wrap_width);
        }

        /// Render UTF-8 text at high quality to a new ARGB surface.
        ///
        /// This function will allocate a new 32-bit, ARGB surface, using alpha
        /// blending to dither the font with the given color. This function
        /// returns the new surface, or NULL if there was an error.
        ///
        /// This will not word-wrap the string; you'll get a surface with a
        /// single line of text, as long as the string requires. You can use
        /// sdl_ttf.render.text.blended_wrapped() instead if you need to wrap
        /// the output to multiple lines.
        ///
        /// This will not wrap on newline characters.
        ///
        /// You can render at other quality levels with sdl_ttf.render.text.solid,
        /// sdl_ttf.render.text.shaded, and sdl_ttf.render.text.lcd.
        ///
        /// *param* font the font to render with.
        /// *param* text text to render, in UTF-8 encoding.
        /// *param* length the length of the text, in bytes, or 0 for null terminated
        ///               text.
        /// *param* fg the foreground color for the text.
        /// *returns* a new 32-bit, ARGB surface, or NULL if there was an error.
        ///
        /// *threadsafety* This function should be called on the thread that created the
        ///               font.
        pub fn blended(font: *Font, txt: []const u8, fg: sdl.Color) ?*sdl.Surface {
            return TTF_RenderText_Blended(font, @ptrCast(txt.ptr), txt.len, fg);
        }

        /// Render word-wrapped UTF-8 text at high quality to a new ARGB surface.
        ///
        /// This function will allocate a new 32-bit, ARGB surface, using alpha
        /// blending to dither the font with the given color. This function returns the
        /// new surface, or NULL if there was an error.
        ///
        /// Text is wrapped to multiple lines on line endings and on word boundaries if
        /// it extends beyond `wrap_width` in pixels.
        ///
        /// If wrap_width is 0, this function will only wrap on newline characters.
        ///
        /// You can render at other quality levels with TTF_RenderText_Solid_Wrapped,
        /// TTF_RenderText_Shaded_Wrapped, and TTF_RenderText_LCD_Wrapped.
        ///
        /// *param* font the font to render with.
        /// *param* text text to render, in UTF-8 encoding.
        /// *param* length the length of the text, in bytes, or 0 for null terminated
        ///               text.
        /// *param* fg the foreground color for the text.
        /// *param* wrap_width the maximum width of the text surface or 0 to wrap on
        ///                   newline characters.
        /// *returns* a new 32-bit, ARGB surface, or NULL if there was an error.
        ///
        /// *threadsafety* This function should be called on the thread that created the
        ///               font.
        pub fn blended_wrapped(font: *Font, txt: []const u8, fg: sdl.Color, wrap_width: i32) ?*sdl.Surface {
            return TTF_RenderText_Blended_Wrapped(font, @ptrCast(txt.ptr), txt.len, fg, wrap_width);
        }

        /// Render UTF-8 text at LCD subpixel quality to a new ARGB surface.
        ///
        /// This function will allocate a new 32-bit, ARGB surface, and render
        /// alpha-blended text using FreeType's LCD subpixel rendering. This function
        /// returns the new surface, or NULL if there was an error.
        ///
        /// This will not word-wrap the string; you'll get a surface with a single line
        /// of text, as long as the string requires. You can use
        /// TTF_RenderText_LCD_Wrapped() instead if you need to wrap the output to
        /// multiple lines.
        ///
        /// This will not wrap on newline characters.
        ///
        /// You can render at other quality levels with TTF_RenderText_Solid,
        /// TTF_RenderText_Shaded, and TTF_RenderText_Blended.
        ///
        /// *param* font the font to render with.
        /// *param* text text to render, in UTF-8 encoding.
        /// *param* length the length of the text, in bytes, or 0 for null terminated
        ///               text.
        /// *param* fg the foreground color for the text.
        /// *param* bg the background color for the text.
        /// *returns* a new 32-bit, ARGB surface, or NULL if there was an error.
        ///
        /// *threadsafety* This function should be called on the thread that created the
        ///               font.
        pub fn lcd(font: *Font, txt: []const u8, fg: sdl.Color, bg: sdl.Color) ?*sdl.Surface {
            return TTF_RenderText_LCD(font, @ptrCast(txt.ptr), txt.len, fg, bg);
        }

        /// Render word-wrapped UTF-8 text at LCD subpixel quality to a new ARGB
        /// surface.
        ///
        /// This function will allocate a new 32-bit, ARGB surface, and render
        /// alpha-blended text using FreeType's LCD subpixel rendering. This function
        /// returns the new surface, or NULL if there was an error.
        ///
        /// Text is wrapped to multiple lines on line endings and on word boundaries if
        /// it extends beyond `wrap_width` in pixels.
        ///
        /// If wrap_width is 0, this function will only wrap on newline characters.
        ///
        /// You can render at other quality levels with TTF_RenderText_Solid_Wrapped,
        /// TTF_RenderText_Shaded_Wrapped, and TTF_RenderText_Blended_Wrapped.
        ///
        /// *param* font the font to render with.
        /// *param* text text to render, in UTF-8 encoding.
        /// *param* length the length of the text, in bytes, or 0 for null terminated
        ///               text.
        /// *param* fg the foreground color for the text.
        /// *param* bg the background color for the text.
        /// *param* wrap_width the maximum width of the text surface or 0 to wrap on
        ///                   newline characters.
        /// *returns* a new 32-bit, ARGB surface, or NULL if there was an error.
        ///
        /// *threadsafety* This function should be called on the thread that created the
        ///               font.
        pub fn lcd_wrapped(font: *Font, txt: []const u8, fg: sdl.Color, bg: sdl.Color, wrap_width: i32) ?*sdl.Surface {
            return TTF_RenderText_LCD_Wrapped(font, @ptrCast(txt.ptr), txt.len, fg, bg, wrap_width);
        }
    };
};

extern fn TTF_Init() callconv(.c) bool;
extern fn TTF_Quit() callconv(.c) void;
extern fn TTF_OpenFontIO(src: ?*sdl.io.Stream, closeio: bool, ptsize: f32) callconv(.c) ?*Font;
extern fn TTF_CloseFont(font: *Font) callconv(.c) void;

extern fn TTF_RenderText_Shaded(font: *Font, txt: [*]const u8, len: usize, fg: sdl.Color, bg: sdl.Color) callconv(.c) ?*sdl.Surface;
extern fn TTF_RenderText_Shaded_Wrapped(font: *Font, txt: [*]const u8, len: usize, fg: sdl.Color, bg: sdl.Color, wrap_width: i32) callconv(.c) *sdl.Surface;
extern fn TTF_RenderText_Blended(font: *Font, text: [*]const u8, len: usize, fg: sdl.Color) callconv(.c) ?*sdl.Surface;
extern fn TTF_RenderText_Blended_Wrapped(font: *Font, txt: [*]const u8, len: usize, fg: sdl.Color, wrap_width: i32) callconv(.c) *sdl.Surface;
extern fn TTF_RenderText_LCD(font: *Font, txt: [*]const u8, len: usize, fg: sdl.Color, bg: sdl.Color) callconv(.c) *sdl.Surface;
extern fn TTF_RenderText_LCD_Wrapped(font: *Font, txt: [*]const u8, len: usize, fg: sdl.Color, bg: sdl.Color, wrap_width: i32) callconv(.c) *sdl.Surface;
