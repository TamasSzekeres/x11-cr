require "./c/Xlib"

module X11
  include C

  enum DisplayInitialization
    Name
    PDisplay
  end

  class Display
    # Pointer to the underlieing XDisplay object.
    getter dpy : X::PDisplay

    getter? closed : Bool = false

    # Opens a connection to the X server that controls a display.
    #
    # ###Arguments
    # - **name** Specifies the hardware display name, which determines the display and communications domain to be used.
    # On a `POSIX`-conformant system, if the `name` is *nil*, it defaults to the value of the `DISPLAY` environment variable.
    #
    # ###Description
    # The encoding and interpretation of the display name is implementation dependent.
    # Strings in the `Host Portable Character Encoding` are supported;
    # support for other characters is implementation dependent. On `POSIX`-conformant systems,
    # the display name or `DISPLAY` environment variable can be a string in the format:
    # ```text
    # hostname:number.screen_number
    # ```
    # - **hostname** Specifies the name of the host machine on which the display is physically attached.
    # You follow the hostname with either a single colon (:) or a double colon (::).
    # - **number** Specifies the number of the display server on that host machine.
    # You may optionally follow this display number with a period (.).
    # A single CPU can have more than one display. Multiple displays are usually numbered starting with zero.
    # - **screen_number** Specifies the screen to be used on that server.
    # Multiple screens can be controlled by a single X server. The screen_number sets an internal
    # variable that can be accessed by using the `default_screen` function.
    # For example, the following would specify screen 1 of display 0 on the machine named *dual-headed*:
    # ```text
    # dual-headed:0.1
    # ```
    def initialize(name : String? = nil)
      if name.is_a?(String)
        @dpy = X.open_display name.to_unsafe
      else
        @dpy = X.open_display nil
      end
      @initialization = DisplayInitialization::Name
    end

    def initialize(@dpy : X11::C::X::PDisplay)
      raise BadAllocException.new if @dpy.null?
      @initialization = DisplayInitialization::PDisplay
    end

    def finalize
      close
    end

    # Closes the connection to the X server.
    #
    # ###Description
    # `close` function closes the connection to the X server for the display
    # specified in the Display structure and destroys all windows, resource IDs
    # (`X11::C::Window`, `X11::C::Font`, `X11::C::Pixmap`, `X11::C::Colormap`,
    # `X11::C::Cursor`, and `GContext`), or other resources that the client has
    # created on this display, unless the close-down mode of the resource has
    # been changed (see `set_close_down_mode`). Therefore, these windows, resource IDs,
    # and other resources should never be referenced again or an error will be generated.
    # Before exiting, you should call `close` explicitly so that any pending
    # errors are reported as `close` performs a final `sync` operation.
    #
    # ###Diagnostics
    # `close` can generate a **BadGC** error.
    #
    # ###See also
    # `flush`, `set_close_down_mode`.
    def close : Int32
      return 0 if @closed

      res = 0
      if @initialization == DisplayInitialization::Name
        res = X.close_display @dpy
      end
      @dpy = X11::C::X::PDisplay.null
      @closed = true
      res
    end

    # Provides the most common way for accessing a font.
    #
    # ###Arguments
    # - **name** Specifies the name of the font.
    #
    # ###Description
    # `load_query_font` function provides the most common way for accessing a font.
    # `load_query_font` both opens (loads) the specified font and returns a pointer
    # to the appropriate `FontStruct` structure. If the font name is not in the
    # Host Portable Character Encoding, the result is implementation dependent.
    # If the font does not exist, `load_query_font` returns **nil**.
    #
    # `load_query_font` can generate a **BadAlloc** error.
    #
    # ###Diagnostics
    # - **BadAlloc** The server failed to allocate the requested source or server memory.
    #
    # ###See also
    # `create_gc`, `free_font`, `FontStruct::property`, `list_fonts`, `load_font`,
    # `query_font`, `set_font_path`, `unload_font`.
    def load_query_font(name : String) : FontStruct
      FontStruct.new(self, X.load_query_font(@dpy, name.to_unsafe))
    end

    # Returns a `FontStruct` structure, which contains information associated with the font.
    #
    # ###Arguments
    # - **font_id** Specifies the font ID or the `GContext` ID.
    #
    # ###Description
    # The `query_font` function returns a `FontStruct` structure, which contains
    # information associated with the font. You can query a font or the font stored in a GC.
    # The font ID stored in the `FontStruct` structure will be the `GContext` ID,
    # and you need to be careful when using this ID in other functions (see `g_context_from_gc`).
    # If the font does not exist, `query_font` returns **nil**. To free this data, use `X11::X.free_font_info`.
    #
    # ###See also
    # `create_gc`, `free_font`, `FontStruct::property`, `list_fonts`, `load_font`,
    # `load_query_font`, `set_font_path`, `unload_font`.
    def query_font(font_id : X11::C::XID) : FontStruct
      FontStruct.new(self, X.query_font(@dpy, font_id))
    end

    # Returns all events in an array from the motion history buffer that fall between the specified start and stop times,
    # inclusive, and that have coordinates that lie within the specified window (including its borders) at its present placement.
    # If the server does not support motion history, if the start time is later than the stop time,
    # or if the start time is in the future, no events are returned; *motion_events* returns empty array.
    # If the stop time is in the future, it is equivalent to specifying *CurrentTime* .
    #
    # ###Arguments
    # - **w** Specifies the window.
    # - **start**, **stop** Specify the time interval in which the events are
    # returned from the motion history buffer. You can pass a timestamp or **CurrentTime**.
    # ###Description
    # The `motion_events` function returns all events in the motion history buffer
    # that fall between the specified start and stop times, inclusive,
    # and that have coordinates that lie within the specified window (including its borders)
    # at its present placement. If the server does not support motion history,
    # if the start time is later than the stop time, or if the start time is in
    # the future, no events are returned; `motion_events` returns **nil**.
    # If the stop time is in the future, it is equivalent to specifying **CurrentTime**.
    #
    # `motion_events` can generate a **BadWindow** error.
    #
    # ###Diagnostics
    # - **BadWindow** A value for a Window argument does not name a defined Window.
    #
    # ###See also
    # `display_motion_buffer_size`, `if_event`, `next_event`, `put_back_event`, `send_event`.
    def motion_events(w : X11::C::Window, start : X11::C::Time, stop : X11::C::Time) : Array(TimeCoord)
      p_time_coords = X.get_motion_events @dpy, w, start, stop, out num_time_coords
      return [] of TimeCoord if num_time_coords == 0
      time_coords = Array(TimeCoord).new num_time_coords
      (0...num_time_coords).each do |i|
        time_coords[i] = TimeCoord.new(p_time_coords[i])
      end
    end

    # Returns a newly created `ModifierKeymap` object that contains the keys being used as modifiers.
    #
    # ###See also
    # `change_keyboard_mapping`, `ModifierKeymap::delete_entry`, `display_keycodes`,
    # `ModifierKeymap::finalize`, `keyboard_mapping`, `ModifierKeymap::insert_entry`,
    # `ModifierKeymap::new`, `set_modifier_mapping`, `set_pointer_mapping`.
    def modifier_mapping : ModifierKeymap
      ModifierKeymap.new(X.get_modifier_mapping(@dpy))
    end

    # Creates an `Image`.
    #
    # ###Arguments
    # - **visual** Specifies the `Visual` structure.
    # - **depth** Specifies the depth of the image.
    # - **format** Specifies the format for the image. You can pass **XYBitmap**, **XYPixmap**, or **ZPixmap**.
    # - **offset** Specifies the number of pixels to ignore at the beginning of the scanline.
    # - **data** Specifies the image data.
    # - **width** Specifies the width of the image, in pixels.
    # - **height** Specifies the height of the image, in pixels.
    # - **bitmap_pad** Specifies the quantum of a scanline (8, 16, or 32).
    # In other words, the start of one scanline is separated in client memory
    # from the start of the next scanline by an integer multiple of this many bits.
    # - **bytes_per_line** Specifies the number of bytes in the client image between
    # the start of one scanline and the start of the next.
    #
    # ###Description
    # The `create_image` function allocates the memory needed for an `Image` structure
    # for the specified display but does not allocate space for the image itself.
    # Rather, it initializes the structure byte-order, bit-order, and bitmap-unit
    # values from the display and returns a pointer to the `Image` structure.
    # The red, green, and blue mask values are defined for Z format images only
    # and are derived from the `Visual` structure passed in. Other values also
    # are passed in. The offset permits the rapid displaying of the image without
    # requiring each scanline to be shifted into position. If you pass a zero
    # value in bytes_per_line, Xlib assumes that the scanlines are contiguous
    # in memory and calculates the value of *bytes_per_line* itself.
    #
    # Note that when the image is created using `create_image`, `get_image`, or
    # `Image::sub_image`, the destroy procedure that the `Image::finalize`
    # function calls frees both the image structure and the data pointed to by the image structure.
    #
    # ###See also
    # `Image::add_pixel`, `Image::finalize`, `Image::pixel`, `Image::put_pixel`, `Image::sub_image`.
    def create_image(visual : Visual, depth : UInt32, format : Int32, offset : Int32, data : Bytes, width : UInt32, height : UInt32, bitmap_pad : Int32, bytes_per_line : Int32) : Image
      Image.new(X.create_image(@dpy, visual.to_unsafe, depth, format, offset, data.to_unsafe, width, height, bitmap_pad, bytes_per_line))
    end

    # This function specifically supports rudimentary screen dumps.
    #
    # ###Arguments
    # - **d** Specifies the drawable.
    # - **x**, **y** Specify the *x* and *y* coordinates, which are relative to the origin of the drawable and define the upper-left corner of the rectangle.
    # - **width**, **height** Specify the *width* and *height* of the subimage, which define the dimensions of the rectangle.
    # - **plane_mask** Specifies the plane mask.
    # - **format** Specifies the format for the image. You can pass **XYPixmap** or **ZPixmap** .
    #
    # ###Description
    # The `get_image` function returns an Image object.
    # This object provides you with the contents of the specified rectangle of the drawable in the format you specify.
    # If the `format` argument is **XYPixmap** , the image contains only the bit planes you passed to the plane_mask argument.
    # If the plane_mask argument only requests a subset of the planes of the display,
    # the depth of the returned image will be the number of planes requested.
    # If the format argument is **ZPixmap** , `get_image` returns as zero the bits in all planes not specified in the `plane_mask` argument.
    # The function performs no range checking on the values in `plane_mask` and ignores extraneous bits.
    #
    # `get_image` returns the depth of the image to the depth member of the Image object.
    # The depth of the image is as specified when the drawable was created,
    # except when getting a subset of the planes in **XYPixmap** format,
    # when the depth is given by the number of bits set to 1 in `plane_mask`.
    #
    # If the drawable is a *pixmap*, the given rectangle must be wholly contained within the pixmap,
    # or a **BadMatch** error results. If the drawable is a *window*,
    # the window must be viewable, and it must be the case that if there were no inferiors or overlapping windows,
    # the specified rectangle of the window would be fully visible on the screen and wholly contained within the outside edges of the window,
    # or a **BadMatch** error results. Note that the borders of the window can be included and read with this request.
    # If the window has backing-store, the backing-store contents are returned for regions of the window that are obscured by noninferior windows.
    # If the window does not have backing-store, the returned contents of such obscured regions are undefined.
    # The returned contents of visible regions of inferiors of a different depth than the specified window's depth are also undefined.
    # The pointer cursor image is not included in the returned contents. If a problem occurs, `get_image` raises exception.
    #
    # `get_image` can generate **BadDrawable** , **BadMatch** , and **BadValue** errors.
    #
    # ###Diagnostic
    # - **BadDrawable** A value for a `Drawable` argument does not name a defined `Window` or `Pixmap`.
    # - **BadMatch** An `InputOnly` window is used as a `Drawable`.
    # - **BadMatch** Some argument or pair of arguments has the correct type and range but fails to match in some other way required by the request.
    # - **BadValue** Some numeric value falls outside the range of values accepted by the request.
    # Unless a specific range is specified for an argument, the full range defined by the argument's type is accepted.
    # Any argument defined as a set of alternatives can generate this error.
    #
    # ###See also
    # `Image::add_pixel`, `create_image`, `Image::finalize`, `Image::pixel`, `Image::init`, `put_image`, `Image::put_pixel`, `sub_image`.
    def image(d : X11::C::Drawable, x : Int32, y : Int32, width : UInt32, height : UInt32, plane_mask : UInt64, format : Int32) : Image
      Image.new(X.get_image(@dpy, d, x, y, width, height, plane_mask, format))
    end

    # Updates *dest_image* with the specified subimage in the same manner as #get_image.
    #
    # ###Arguments
    # - **d** Specifies the drawable.
    # - **x**, **y** Specify the *x* and *y* coordinates, which are relative to the origin of the drawable and define the upper-left corner of the rectangle.
    # - **width**, **height** Specify the *width* and *height* of the subimage, which define the dimensions of the rectangle.
    # - **plane_mask** Specifies the plane mask.
    # - **format** Specifies the format for the image. You can pass **XYPixmap** or **ZPixmap**.
    # - **dest_image** Specifies the destination image.
    # - **dest_x**, **dest_y** Specify the *x* and *y* coordinates, which are relative to the origin of the destination rectangle, specify its upper-left corner, and determine where the subimage is placed in the destination image.
    #
    # ###Description
    # The `sub_image` function updates *dest_image* with the specified subimage in the same manner as `image`.
    # If the *format* argument is **XYPixmap**, the image contains only the bit planes you passed to the *plane_mask* argument.
    # If the *format* argument is **ZPixmap** , #get_sub_image returns as zero the bits in all planes not specified in the *plane_mask* argument.
    # The function performs no range checking on the values in *plane_mask* and ignores extraneous bits.
    # As a convenience, `sub_image` returns an image object specified by *dest_image*.
    # The depth of the destination `Image` object must be the same as that of the drawable.
    # If the specified subimage does not fit at the specified location on the destination image,
    # the right and bottom edges are clipped. If the drawable is a *pixmap*,
    # the given rectangle must be wholly contained within the *pixmap*,
    # or a **BadMatch** error results. If the drawable is a *window*,
    # the window must be viewable, and it must be the case that if there were no inferiors or overlapping windows,
    # the specified rectangle of the window would be fully visible on the screen and wholly contained within the outside edges of the window,
    # or a **BadMatch** error results. If the window has backing-store,
    # then the backing-store contents are returned for regions of the window that are obscured by noninferior windows.
    # If the window does not have backing-store, the returned contents of such obscured regions are undefined.
    # The returned contents of visible regions of inferiors of a different depth than the specified window's depth are also undefined.
    # If a problem occurs, `sub_image` raises exception.
    #
    # `sub_image` can generate **BadDrawable**, **BadGC**, **BadMatch**, and **BadValue** errors.
    #
    # ###Diagnostics
    # - **BadDrawable** A value for a *Drawable* argument does not name a defined *Window* or *Pixmap*.
    # - **BadGC** A value for a *GContext* argument does not name a defined *GContext*.
    # - **BadMatch** An **InputOnly** window is used as a *Drawable*.
    # - **BadMatch** Some argument or pair of arguments has the correct type and range but fails to match in some other way required by the request.
    # - **BadValue** Some numeric value falls outside the range of values accepted by the request. Unless a specific range is specified for an argument, the full range defined by the argument's type is accepted. Any argument defined as a set of alternatives can generate this error.
    #
    # ##See also
    # `Image::add_pixel`, `create_image`, `Image::finalize`, `Image::pixel`, `Image::init`, `put_image`, `put_pixel`.
    def sub_image(d : X11::C::Drawable, x : Int32, y : Int32, width : UInt32, height : UInt32, plane_mask : UInt64, format : Int32, dest_image : Image, dest_x : Int32, dest_y : Int32) : Image
      Image.new(X.get_sub_image(@dpy, d, x, y, width, height, plane_mask, format, dest_image.imagem dest_x, dest_y))
    end

    # Returns data from cut buffer 0
    #
    # ###Description
    # Returns a non empty `String` if the buffer contains data, otherwise returns an empty `String`.
    #
    # ###See also
    # `fetch_buffer`, `rotate_buffers`, `store_buffer`, `store_bytes`.
    def fetch_bytes : String
      pstr = X.fetch_bytes @dpy, out num_bytes
      return "" if num_bytes == 0
      str = String.new pstr
      X.free pstr
      str
    end

    # Returns data from a specified cut buffer.
    #
    # ###Arguments
    # - **buffer** Specifies the buffer from which you want the stored data returned.
    #
    # ###Description
    # Returns a non empty `String` if the buffer contains data.
    # Returns an empty `String` if no dta in the buffer or the `buffer` is invalid.
    #
    # ###See also
    # `fetch_bytes`, `rotate_buffers`, `store_buffer`, `store_bytes`.
    def fetch_buffer(buffer : Int32) : String
      pstr = X.fetch_buffer @dpy, out num_bytes, buffer
      return "" if num_bytes == 0
      str = String.new pstr
      X.free pstr
      str
    end

    # Returns the name associated with the specified atom.
    #
    # ###Arguments
    # - **atom** Specifies the atom for the property name you want returned.
    #
    # ###Description
    # If the data returned by the server is in the Latin Portable Character Encoding,
    # then the returned string is in the Host Portable Character Encoding.
    # Otherwise, the result is implementation dependent.
    #
    # ###Diagnostics
    # - **BadAtom** A value for an `Atom` argument does not name a defined `Atom`.
    #
    # ###See also
    # `atom_names`, `window_property`, `intern_atom`, `intern_atoms`.
    def atom_name(atom : Atom | X11::C::Atom) : String
      name = X.get_atom_name(@dpy, atom.to_u64)
      str_name = String.new name
      X.free name
      str_name
    end

    # Returns the name associated with the specified atoms.
    def atom_names(atoms : Array(Atom | X11::C::Atom)) : Array(String)
      atoms.map do |atom|
        atom_name atom
      end
    end

    # Returns the value of the resource *prog.option*
    #
    # ###Arguments
    # - **display** Specifies the connection to the X server.
    # - **program** Specifies the program name for the Xlib defaults (usually argv[0] of the main program).
    # - **option** Specifies the option name.
    #
    # ###Description
    # The `default` function returns the value of the resource *prog.option*,
    # where *prog* is the program argument with the directory prefix removed and option must be a single component.
    # Note that multilevel resources cannot be used with `default`.
    # The class *"Program.Name"* is always used for the resource lookup.
    # If the specified option name does not exist for this program, `default` returns empty `String`.
    #
    # If a database has been set with `X.rm_set_database`, that database is used for the lookup.
    # Otherwise, a database is created and is set in the display (as if by calling `X.rm_set_database`).
    # The database is created in the current locale. To create a database, `default` uses resources from the `RESOURCE_MANAGER`
    # property on the root window of screen zero. If no such property exists,
    # a resource file in the user's home directory is used. On a `POSIX`-conformant system,
    # this file is `"$HOME/.Xdefaults"`. After loading these defaults, `default` merges additional
    # defaults specified by the `XENVIRONMENT` environment variable. If `XENVIRONMENT` is defined,
    # it contains a full path name for the additional resource file. If `XENVIRONMENT` is not defined,
    # `default` looks for `"$HOME/.Xdefaults-name"`, where name specifies the name of the machine on which the application is running.
    def default(program : String, option : String) : String
      pstr = X.get_default @dpy, program, option
      return "" if pstr.null?
      str = String.new pstr
      X.free pstr
      str
    end

    # Returns the name of the display.
    #
    # ###Arguments
    # - **string** Specifies the character string.
    #
    # ###Description
    # The `display_name` function returns the name of the display that `new` would attempt to use. If a **nil** string is specified,
    # `display_name` looks in the environment for the display and returns the display name that `new` would attempt to use.
    # This makes it easier to report to the user precisely which display the program attempted to open when the initial connection attempt failed.
    #
    # ###See also
    # `error_database_text`, `error_text`, `new`, `synchronize`.
    def self.display_name(string : String?) : String
      if string.is_a? String
        pstr = X.display_name string.to_unsafe
      else
        pstr = X.display_name nil
      end
      return "" if pstr.null?
      str = String.new pstr
      X.free pstr
      str
    end

    # Returns the previous after function.
    #
    # ###Arguments
    # - **onoff** Specifies a Boolean value that indicates whether to enable or disable synchronization.
    #
    # ###Description
    # The `synchronize` function returns the previous after function.
    # If onoff is **true**, `synchronize` turns on synchronous behavior.
    # If onoff is **false**, `synchronize` turns off synchronous behavior.
    #
    # ###See also
    # `set_after_function`, `set_error_handler`.
    def synchronize(onoff : Bool) : X11::C::X::PDisplay -> Int32
      X.synchronize @dpy, onoff ? X::True : X::False
    end

    # Returns the previous after function.
    #
    # ###Arguments
    # - **procedure** Specifies the procedure to be called.
    #
    # ###Description
    # The specified procedure is called with only a display pointer.
    # `set_after_function` returns the previous after function.
    #
    # ###See also
    # `set_error_handler`, `synchronize`.
    def set_after_function(procedure : X11::C::X::PDisplay -> Int32) : X11::C::X::PDisplay -> Int32
      X.set_after_function @dpy, procedure
    end

    # Returns the atom identifier.
    #
    # ###Arguments
    # - **atom_name** Specifies the *name* associated with the atom you want returned.
    # - **only_if_exists** Specifies a `Bool` value that indicates whether the atom must be created.
    #
    # ###Description
    # `intern_atom` function returns the atom identifier associated with the specified `atom_name` string.
    # If `only_if_exists` is **false**, the atom is created if it does not exist.
    # Therefore, `intern_atom` can return `None`. If the atom name is not in the Host Portable Character Encoding,
    # the result is implementation dependent. Uppercase and lowercase matter; the strings ``thing'', ``Thing'', and ``thinG'' all designate different atoms.
    # The atom will remain defined even after the client's connection closes.
    # It will become undefined only when the last connection to the X server closes.
    #
    # `intern_atom` can generate **BadAlloc** and **BadValue** errors.
    #
    # ###Diagnostics
    # - **BadAlloc** The server failed to allocate the requested source or server memory.
    # - **BadValue** Some numeric value falls outside the range of values accepted by the request.
    # Unless a specific range is specified for an argument, the full range defined by the argument's type is accepted.
    # Any argument defined as a set of alternatives can generate this error.
    #
    # ###See also
    # `atom_name`, `window_property`, `intern_atoms`.
    def intern_atom(atom_name : String, only_if_exists : Bool) : X11::C::Atom
      X.intern_atom @dpy, atom_name.to_unsafe, only_if_exists ? X::True : X::False
    end

    # Creates a colormap
    #
    # ###Arguments
    # - **colormap** Specifies the colormap.
    #
    # ###Description
    # The `copy_colormap_and_free` function creates a colormap of the same visual
    # type and for the same screen as the specified colormap and returns the new colormap ID.
    # It also moves all of the client's existing allocation from the specified colormap to the new
    # colormap with their color values intact and their read-only or writable characteristics
    # intact and frees those entries in the specified colormap. Color values
    # in other entries in the new colormap are undefined. If the specified
    # colormap was created by the client with alloc set to **AllocAll**,
    # the new colormap is also created with **AllocAll**, all color values
    # for all entries are copied from the specified colormap, and then all
    # entries in the specified colormap are freed. If the specified colormap
    # was not created by the client with **AllocAll**, the allocations to be
    # moved are all those pixels and planes that have been allocated by the
    # client using `alloc_color`, `alloc_named_color`, `alloc_color_cells`,
    # or `alloc_color_planes` and that have not been freed since they were allocated.
    #
    # `copy_colormap_and_free` can generate **BadAlloc** and **BadColor** errors.
    #
    # ###Diagnostics
    # - **BadAlloc** The server failed to allocate the requested source or server memory.
    # - **BadColor** A value for a `Colormap` argument does not name a defined `Colormap`.
    #
    # ###See Also
    # `alloc_color`, `change_window_attributes`, `create_window`, `query_color`, `store_colors`.
    def copy_colormap_and_free(colormap : X11::C::Colormap) : X11::C::Colormap
      X.copy_colormap_and_free @dpy, colormap
    end

    # Creates a colormap
    #
    # ###Arguments
    # - **w** Specifies the window on whose screen you want to create a colormap.
    # - **visual** Specifies a visual type supported on the screen. If the visual type is not one supported by the screen, a **BadMatch** error results.
    # - **alloc** Specifies the colormap entries to be allocated. You can pass **AllocNone** or **AllocAll**.
    #
    # ###Description
    # The `create_colormap` function creates a colormap of the specified visual type
    # for the screen on which the specified window resides and returns the colormap ID#
    # associated with it. Note that the specified window is only used to determine the screen.
    #
    # The initial values of the colormap entries are undefined for the visual classes
    # *GrayScale*, *PseudoColor*, and *DirectColor*. For *StaticGray*, *StaticColor*,
    # and `TrueColor`, the entries have defined values, but those values are specific
    # to the visual and are not defined by X. For *StaticGray*, *StaticColor*, and *TrueColor*,
    # alloc must be **AllocNone**, or a **BadMatch** error results. For the other visual classes,
    # if alloc is **AllocNone**, the colormap initially has no allocated entries,
    # and clients can allocate them.
    #
    # If alloc is **AllocAll the entire colormap is allocated writable.
    # The initial values of all allocated entries are undefined.
    # For *GrayScale* and *PseudoColor*, the effect is as if an `alloc_color_cells` call returned
    # all pixel values from zero to `N - 1`, where `N` is the colormap entries value in the specified visual.
    # For *DirectColor*, the effect is as if an `alloc_color_planes` call returned a
    # pixel value of zero and red_mask, green_mask, and blue_mask values containing the same
    # bits as the corresponding masks in the specified visual. However, in all cases,
    # none of these entries can be freed by using `free_colors`.
    #
    # `create_colormap` can generate **BadAlloc**, **BadMatch**, **BadValue**, and **BadWindow** errors.
    #
    # ###Diagnostics
    # - **BadAlloc** The server failed to allocate the requested source or server memory.
    # - **BadMatch** An *InputOnly* window is used as a *Drawable*.
    # - **BadMatch** Some argument or pair of arguments has the correct type and range but fails to match in some other way required by the request.
    # - **BadPixmap** A value for a *Pixmap* argument does not name a defined *Pixmap*.
    # - **BadValue** Some numeric value falls outside the range of values accepted by the request.
    # Unless a specific range is specified for an argument, the full range defined by the argument's type is accepted.
    # Any argument defined as a set of alternatives can generate this error.
    # - **BadWindow** A value for a Window argument does not name a defined *Window*.
    #
    # ###See also
    # `alloc_color`, `change_window_attributes`, `copy_colormap_and_free`,
    # `create_window`, `free_colormap`, `query_color`, `store_colors`.
    def create_colormap(w : X11::C::Window, visual : Visual, alloc : Int32) : X11::C::Colormap
      X.create_colormap @dpy, w, visual.visual, alloc
    end

    # Creates a cursor.
    #
    # ###Arguments
    # - **source** Specifies the shape of the source cursor.
    # - **mask** Specifies the cursor's source bits to be displayed or **None**.
    # - **foreground_color** Specifies the RGB values for the foreground of the source.
    # - **background_color** Specifies the RGB values for the background of the source.
    # - **x**, **y** Specify the x and y coordinates, which indicate the hotspot relative to the source's origin.
    #
    # ###Description
    # The `create_pixmap_cursor` function creates a cursor and returns the cursor ID associated with it.
    # The foreground and background RGB values must be specified using *foreground_color* and *background_color*,
    # even if the X server only has a *StaticGray* or *GrayScale* screen.
    # The foreground color is used for the pixels set to 1 in the source,
    # and the background color is used for the pixels set to 0. Both source and mask,
    # if specified, must have depth one (or a **BadMatch** error results) but can have any root.
    # The mask argument defines the shape of the cursor. The pixels set to 1 in
    # the mask define which source pixels are displayed, and the pixels set to 0
    # define which pixels are ignored. If no mask is given, all pixels of the
    # source are displayed. The mask, if present, must be the same size as the
    # pixmap defined by the source argument, or a **BadMatch** error results.
    # The hotspot must be a point within the source, or a **BadMatch** error results.
    #
    # The components of the cursor can be transformed arbitrarily to meet display limitations.
    # The pixmaps can be freed immediately if no further explicit references to
    # them are to be made. Subsequent drawing in the source or mask pixmap has
    # an undefined effect on the cursor. The X server might or might not make a copy of the pixmap.
    #
    # `create_pixmap_cursor` can generate **BadAlloc** and **BadPixmap** errors.
    #
    # ###Diagnostics
    # - **BadAlloc** The server failed to allocate the requested source or server memory.
    # - **BadPixmap** A value for a *Pixmap* argument does not name a defined *Pixmap*.
    #
    # ###See also
    # `create_font_cursor`, `create_glyph_cursor`, `define_cursor`, `load_font`, `recolor_cursor`.
    def create_pixmap_cursor(source : X11::C::Pixmap, mask : X11::C::Pixmap, foreground_color : Color, background_color : Color, x : UInt32, y : UInt32) : X11::C::Cursor
      X.create_pixmap_cursor @dpy, source, mask, foreground_color, background_color, x, y
    end

    # Creates a cursor.
    #
    # ###Arguments
    # - **source_font** Specifies the font for the source glyph.
    # - **mask_font** Specifies the font for the mask glyph or **None**.
    # - **source_char** Specifies the character glyph for the source.
    # - **mask_char-** Specifies the glyph character for the mask.
    # - **foreground_color** Specifies the RGB values for the foreground of the source.
    # - **background_color** Specifies the RGB values for the background of the source.
    #
    # ###Description
    # The `create_glyph_cursor` function is similar to `create_pixmap_cursor`
    # except that the source and mask bitmaps are obtained from the specified font glyphs.
    # The source_char must be a defined glyph in *source_font*, or a **BadValue** error results.
    # If *mask_font* is given, mask_char must be a defined glyph in *mask_font*, or a **BadValue** error results.
    # The *mask_font* and character are optional. The origins of the *source_char* and *mask_char*
    # (if defined) glyphs are positioned coincidently and define the hotspot.
    # The source_char and mask_char need not have the same bounding box metrics,
    # and there is no restriction on the placement of the hotspot relative to the bounding boxes.
    # If no mask_char is given, all pixels of the source are displayed. You can
    # free the fonts immediately by calling `free_font` if no further explicit references to them are to be made.
    #
    # For 2-byte matrix fonts, the 16-bit value should be formed with the byte1
    # member in the most-significant byte and the byte2 member in the least-significant byte.
    #
    # `create_glyph_cursor` can generate **BadAlloc**, **BadFont**, and **BadValue** errors.
    #
    # ###Diagnostics
    # - **BadAlloc** 	The server failed to allocate the requested source or server memory.
    # - **BadFont** A value for a font argument does not name a defined font (or, in some cases, `GContext`).
    # - **BadValue** Some numeric value falls outside the range of values accepted by the request.
    # Unless a specific range is specified for an argument, the full range defined by the argument's
    # type is accepted. Any argument defined as a set of alternatives can generate this error.
    #
    # ###See also
    # `create_font_cursor`, `create_pixmap_cursor`, `define_cursor`, `load_font`, `recolor_cursor`.
    def create_glyph_cursor(source_font : X11::C::Font, mask_font : X11::C::Font, source_char : UInt32, mask_char : UInt32, foreground_color : Color, background_color : Color) : X11::C::Cursor
      X.create_glyph_cursor @dpy, source_font, mask_font, source_char, mask_char, foreground_color, background_color
    end

    # Creates a cursor.
    #
    # ###Arguments
    # - **shape** Specifies the shape of the cursor.
    #
    # ###Description
    # X provides a set of standard cursor shapes in a special font named cursor.
    # Applications are encouraged to use this interface for their cursors because
    # the font can be customized for the individual display type.
    # The shape argument specifies which glyph of the standard fonts to use.
    #
    # The hotspot comes from the information stored in the cursor font.
    # The initial colors of a cursor are a black foreground and a white background
    # (see `recolor_cursor`).
    #
    # `create_font_cursor` can generate **BadAlloc** and **BadValue** errors.
    #
    # ###Diagnostics
    # - **BadAlloc** The server failed to allocate the requested source or server memory.
    # - **BadValue** Some numeric value falls outside the range of values accepted by the request.
    # Unless a specific range is specified for an argument, the full range defined by the argument's
    # type is accepted. Any argument defined as a set of alternatives can generate this error.
    #
    # ###See also
    # `create_glyph_cursor`, `create_pixmap_cursor`, `define_cursor`, `load_font`, `recolor_cursor`.
    def create_font_cursor(shape : UInt32) : X11::C::Cursor
      X.create_font_cursor @dpy, shape
    end

    # Loads the specified font
    #
    # ###Arguments
    # - **name** Specifies the name of the font, which is a string.
    #
    # ###Description
    # The `load_font` function loads the specified font and returns its
    # associated font ID. If the font name is not in the Host Portable Character Encoding,
    # the result is implementation dependent. Use of uppercase or lowercase does not matter.
    # When the characters "?" and "*" are used in a font name, a pattern match
    # is performed and any matching font is used. In the pattern, the "?" character
    # will match any single character, and the "*" character will match any number of characters.
    # A structured format for font names is specified in the X Consortium standard
    # **X Logical Font Description Conventions**. If `load_font` was unsuccessful at loading the specified font,
    # a **BadName** error results. Fonts are not associated with a particular
    # screen and can be stored as a component of any `X11::C::X::GC`.
    # When the font is no longer needed, call `unload_font`.
    #
    # `load_font` can generate **BadAlloc** and **BadName** errors.
    #
    # ###Diagnostics
    # - **BadAlloc** The server failed to allocate the requested source or server memory.
    # - **BadName** A font or color of the specified name does not exist.
    #
    # ###See also
    # `create_gc`, `free_font`, `FontStruct::property`, `list_fonts`,
    # `load_query_font`, `query_font`, `set_font_path`, `unload_font`.
    def load_font(name : String) : X11::X::Font
      X.load_font @dpy, name.to_unsafe
    end

    # Creates a graphics context.
    #
    # ###Arguments
    # - **d** Specifies the drawable.
    # - **valuemask** Specifies which components in the GC are to be set using
    # the information in the specified values structure. This argument is the
    # bitwise inclusive OR of zero or more of the valid GC component mask bits.
    # - **values** Specifies any values as specified by the valuemask.
    #
    # ###Description
    # The `create_gc` function creates a graphics context and returns a GC.
    # The GC can be used with any destination drawable having the same root and
    # depth as the specified drawable. Use with other drawables results in a **BadMatch** error.
    #
    # `create_gc` can generate **BadAlloc**, **BadDrawable**, **BadFont**, **BadMatch**, **BadPixmap**, and **BadValue** errors.
    #
    # ###Diagnostics
    # - **BadAlloc** The server failed to allocate the requested source or server memory.
    # - **BadDrawable** A value for a *Drawable* argument does not name a defined *Window* or *Pixmap*.
    # - **BadFont** A value for a font argument does not name a defined font (or, in some cases, *GContext*).
    # - **BadMatch** An **InputOnly** window is used as a *Drawable*.
    # - **BadMatch** Some argument or pair of arguments has the correct type and range but fails to match in some other way required by the request.
    # - **BadPixmap** A value for a *Pixmap* argument does not name a defined *Pixmap*.
    # - **BadValue** Some numeric value falls outside the range of values accepted by the request.
    # Unless a specific range is specified for an argument, the full range defined
    # by the argument's type is accepted. Any argument defined as a set of alternatives can generate this error.
    #
    # ###See also
    # `all_planes`, `change_gc`, `copy_area`, `copy_gc`, `draw_arc`, `draw_line`,
    # `draw_rectangle`, `draw_text`, `fill_rectangle`, `free_gc`, `g_context_from_gc`,
    # `gc_values`, `query_best_size`, `set_arc_mode`, `set_clip_origin`.
    def create_gc(d : X11::C::Drawable, valuemask : UInt64, values : GCValues) : X11::C::X::GC
      X.create_gc @dpy, d, valuemask, values.to_unsafe
    end

    # Forces GC component change.
    #
    # ###Arguments
    # - **display** Specifies the connection to the X server.
    # - **gc** Specifies the GC.
    #
    # ###Description
    # Force sending GC component changes.
    def flush_gc(gc : X11::C::X::GC)
      X.flush_gc @dpy, fc
      self
    end

    # Creates a pixmap.
    #
    # ###Arguments
    # - **d** Specifies which screen the pixmap is created on.
    # - **width**, **height** Specify the width and height, which define the dimensions of the pixmap.
    # - **depth** Specifies the depth of the pixmap.
    #
    # ###Description
    # The `create_pixmap` function creates a pixmap of the width, height,
    # and depth you specified and returns a pixmap ID that identifies it.
    # It is valid to pass an **InputOnly** window to the drawable argument.
    # The width and height arguments must be nonzero, or a **BadValue** error results.
    # The depth argument must be one of the depths supported by the screen of the specified drawable, or a **BadValue** error results.
    #
    # The server uses the specified drawable to determine on which screen to create the pixmap.
    # The pixmap can be used only on this screen and only with other drawables of the same depth (see `copy_plane`
    # for an exception to this rule). The initial contents of the pixmap are undefined.
    #
    # `create_pixmap` can generate **BadAlloc**, **BadDrawable**, and **BadValue** errors.
    #
    # ###Diagnostics
    # - **BadAlloc** The server failed to allocate the requested source or server memory.
    # - **BadDrawable** A value for a *Drawable* argument does not name a defined *Window* or *Pixmap*.
    # - **BadValue** Some numeric value falls outside the range of values accepted by the request.
    # Unless a specific range is specified for an argument, the full range defined
    # by the argument's type is accepted. Any argument defined as a set of alternatives can generate this error.
    #
    # ###See also
    # `copy_area`, `free_pixmap`.
    def create_pixmap(d : X11::C::Drawable, width : UInt32, height : UInt32, depth : UInt32) : X11::C::Pixmap
      X.create_pixmap @dpy, d, width, height, depth
    end

    # Creates a pixmap from data.
    #
    # ###Arguments
    # - **d** Specifies the drawable that indicates the screen.
    # - **data** Specifies the location of the bitmap data.
    # - **width**, **height** Specify the width and height.
    #
    # ###Description
    # The `create_bitmap_from_data` function allows you to include in your C program (using #include)
    # a bitmap file that was written out by `write_bitmap_file` (X version 11 format only)
    # without reading in the bitmap file. The following example creates a gray bitmap:
    # ```c
    # #include "gray.bitmap"
    #
    # Pixmap bitmap;
    # bitmap = XCreateBitmapFromData(display, window, gray_bits, gray_width, gray_height);
    # ```
    # If insufficient working storage was allocated, `create_bitmap_from_data` returns **None**.
    # It is your responsibility to free the bitmap using `free_pixmap` when finished.
    #
    # `create_bitmap_from_data` can generate a **BadAlloc** and **BadGC** errors.
    #
    # ###Diagnostics
    # - **BadAlloc** The server failed to allocate the requested source or server memory.
    # - **BadGC** A value for a `X11::C::GContext` argument does not name a defined `X11::C::GContext`.
    #
    # ###See also
    # `create_pixmap`, `create_pixmap_from_bitmap_data`, `put_image`, `read_bitmap_file`, `write_bitmap_file`.
    def create_bitmap_from_data(d : X11::C::Drawable, data : Bytes, width : UInt32, height : UInt32) : X11::C::Pixmap
      X.create_bitmap_from_data @dpy, d, data.to_unsafe, width, height
    end

    # Creates a pixmap.
    #
    # ###Arguments
    # - **d** Specifies the drawable that indicates the screen.
    # - **data** Specifies the data in bitmap format.
    # - **width**, **height** Specify the width and height.
    # - **fg**, **bg** Specify the foreground and background pixel values to use.
    # - **depth** Specifies the depth of the pixmap.
    #
    # ###Description
    # The `create_pixmap_from_bitmap_data` function creates a pixmap of the given
    # depth and then does a bitmap-format `put_image` of the data into it.
    # The depth must be supported by the screen of the specified drawable, or a **BadMatch** error results.
    #
    # `create_pixmap_from_bitmap_data` can generate **BadAlloc**, **BadDrawable**, **BadGC**, and **BadValue** errors.
    #
    # ###Diagnostics
    # - **BadAlloc** The server failed to allocate the requested source or server memory.
    # - **BadDrawable** A value for a *Drawable* argument does not name a defined *Window* or *Pixmap*.
    # - **BadGC** A value for a `X11::C::GContext` argument does not name a defined `X11::C::GContext`.
    # - **BadMatch** An **InputOnly** window is used as a *Drawable*.
    # - **BadMatch** Some argument or pair of arguments has the correct type and range but fails to match in some other way required by the request.
    #
    # ###See also
    # `create_bitmap_from_data`, `create_pixmap`, `put_image`, `read_bitmap_file`, `write_bitmap_file`.
    def create_pixmap_from_bitmap_data(d : X11::C::Drawable, data : Bytes, width : UInt32, height : UInt32, fg : UInt64, bg : UInt64, depth : UInt64) : X11::C::Pixmap
      X.create_pixmap_from_bitmap_data @dpy, d, data.to_unsafe, width, height, fg, bg, depth
    end

    # Creates an unmapped subwindow.
    #
    # ###Description
    # The `create_simple_window function creates an unmapped **InputOutput** subwindow
    # for a specified parent window, returns the window ID of the created window,
    # and causes the X server to generate a **CreateNotify** event.
    # The created window is placed on top in the stacking order with respect to siblings.
    # Any part of the window that extends outside its parent window is clipped.
    # The `border_width` for an **InputOnly** window must be zero, or a **BadMatch** error results.
    # `create_simple_window` inherits its depth, class, and visual from its parent.
    # All other window attributes, except background and border, have their default values.
    #
    # `create_simple_window` can generate **BadAlloc**, **BadMatch**, **BadValue**, and **BadWindow** errors.
    #
    # For more information see: `create_window`.
    def create_simple_window(parent : X11::C::Window, x : Int32, y : Int32, width : UInt32, height : UInt32, border_width : UInt32, border : UInt64, background : UInt64) : X11::C::Window
      X.create_simple_window @dpy, parent, x, y, width, height, border_width, border, background
    end

    # Returns the selection owner.
    #
    # ###Arguments
    # - **display** Specifies the connection to the X server.
    # - **selection** Specifies the selection atom whose owner you want returned.
    #
    # ###Description
    # The `selection_owner` function returns the window ID associated with
    # the window that currently owns the specified selection. If no selection was
    # specified, the function returns the constant `None`. If `None` is returned, there is no owner for the selection.
    #
    # `selection_owner` can generate a **BadAtom** error.
    #
    # ###Diagnostics
    # - **BadAtom** A value for an `Atom` argument does not name a defined `Atom`.
    #
    # ###See also
    # `convert_selection`, `set_selection_owner`.
    def selection_owner(selection : Atom | X11::C::Atom) : X11::C::Window
      X.get_selection_owner @dpy, selection.to_u64
    end

    # Creates a window.
    #
    # ###Arguments
    # - **attributes** Specifies the structure from which the values (as specified by the value mask) are to be taken. The value mask should have the appropriate bits set to indicate which attributes have been set in the structure.
    # - **background** Specifies the background pixel value of the window.
    # - **border** Specifies the border pixel value of the window.
    # - **border_width** Specifies the width of the created window's border in pixels.
    # - **class** Specifies the created window's class. You can pass `InputOutput`,
    # `InputOnly`, or **CopyFromParent**. A class of **CopyFromParent** means the class is taken from the parent.
    # - **depth** Specifies the window's depth. A depth of **CopyFromParent** means the depth is taken from the parent.
    # - **parent** Specifies the parent window.
    # - **valuemask** Specifies which window attributes are defined in the attributes argument.
    # This mask is the bitwise inclusive OR of the valid attribute mask bits. If valuemask is zero, the attributes are ignored and are not referenced.
    # - **visual**Specifies the visual type. A visual of **CopyFromParent** means the visual type is taken from the parent.
    # - **width**, **height** Specify the width and height, which are the created window's inside dimensions and do not include the created window's borders
    # - **x**, **y** Specify the x and y coordinates, which are the top-left outside corner of the window's borders and are relative to the inside of the parent window's borders.
    #
    # ###Description
    # The `create_window` function creates an unmapped subwindow for a specified parent window,
    # returns the window ID of the created window, and causes the X server to generate a `CreateNotify` event.
    # The created window is placed on top in the stacking order with respect to siblings.
    #
    # The coordinate system has the X axis horizontal and the Y axis vertical with the origin [0, 0] at the upper-left corner.
    # Coordinates are integral, in terms of pixels, and coincide with pixel centers.
    # Each window and pixmap has its own coordinate system. For a window, the origin is inside the border at the inside, upper-left corner.
    #
    # The border_width for an **InputOnly** window must be zero, or a **BadMatch** error results.
    # For class **InputOutput**, the visual type and depth must be a combination supported for the screen,
    # or a BadMatch error results. The depth need not be the same as the parent,
    # but the parent must not be a window of class **InputOnly**, or a **BadMatch** error results.
    # For an **InputOnly** window, the depth must be zero, and the visual must be
    # one supported by the screen. If either condition is not met, a **BadMatch** error results.
    # The parent window, however, may have any depth and class. If you specify any invalid window attribute for a window, a **BadMatch** error results.
    #
    # The created window is not yet displayed (mapped) on the user's display.
    # To display the window, call `map_window`. The new window initially uses
    # the same cursor as its parent. A new cursor can be defined for the new window
    # by calling `define_cursor`. The window will not be visible on the screen
    # unless it and all of its ancestors are mapped and it is not obscured by any of its ancestors.
    #
    # `create_window can generate **BadAlloc**, **BadColor**, **BadCursor**, **BadMatch**, **BadPixmap**, **BadValue**, and **BadWindow** errors.
    #
    # ###Diagnostics
    # - **BadAlloc** The server failed to allocate the requested resource or server memory.
    # - **BadColor** A value for a `Colormap` argument does not name a defined `Colormap`.
    # - **BadCursor** A value for a `Cursor` argument does not name a defined `Cursor`.
    # - **BadMatch** The values do not exist for an **InputOnly** window.
    # - **BadMatch** Some argument or pair of arguments has the correct type and range but fails to match in some other way required by the request.
    # - **BadPixmap** A value for a `Pixmap` argument does not name a defined `Pixmap`.
    # - **BadValue** Some numeric value falls outside the range of values accepted by the request.
    # Unless a specific range is specified for an argument, the full range defined by the argument's type is accepted.
    # Any argument defined as a set of alternatives can generate this error.
    # - **BadWindow** A value for a `Window` argument does not name a defined `Window`.
    #
    # ###See also
    # `change_window_attributes`, `configure_window`, `define_cursor`,
    # `destroy_window`, `map_window`, `raise_window`, `unmap_window`.
    def create_window(parent : X11::C::Window, x : Int32, y : Int32, width : UInt32, height : UInt32, border_width : UInt32, depth : Int32, c_class : UInt32, visual : Visual, valuemask : UInt64, attributes : SetWindowAttributes) : X11::C::Window
      X.create_window @dpy, parent, x, y, width, height, border_width, depth, c_class, visual.to_unsafe, valuemask, attributes.to_unsafe
    end

    # Returns a list of the currently installed colormaps.
    #
    # ###Arguments
    # - **w** Specifies the window that determines the screen.
    #
    # ###Description
    # The `installed_colormaps` function returns a list of the currently installed
    # colormaps for the screen of the specified window. The order of the colormaps
    # in the list is not significant and is no explicit indication of the required list.
    # When the allocated list is no longer needed.
    #
    # `installed_colormaps` can generate a **BadWindow** error.
    #
    # ###Diagnostics
    # - **BadWindow** A value for a Window argument does not name a defined Window.
    #
    # ###See also
    # `change_window_attributes`, `create_colormap`, `create_window`,
    # `install_colormap`, `uninstall_colormap`.
    def installed_colormaps(w : X11::C::Window) : Array(X11::C::Colormap)
      pcolormaps = X.list_installed_colormaps @dpy, w, out num
      return [] of X11::C::Colormap if pcolormaps.null? || num <= 0
      colormaps = Array(X11::C::Colormap).new
      (0...num).each do |i|
        colormaps << (pcolormaps + i).value
      end
      X.free pcolormaps.as(PChar)
      colormaps
    end

    # Returns an array of available font names.
    #
    # ###Arguments
    # - **pattern** Specifies the null-terminated pattern string that can contain wildcard characters.
    # - **max_names** Specifies the maximum number of names to be returned.
    #
    # ###Description
    # The `fonts` function returns an array of available font names
    # (as controlled by the font search path; see `set_font_path`) that match
    # the string you passed to the pattern argument. The pattern string can
    # contain any characters, but each asterisk (*) is a wildcard for any number
    # of characters, and each question mark (?) is a wildcard for a single character.
    # If the pattern string is not in the Host Portable Character Encoding, the
    # result is implementation dependent. Use of uppercase or lowercase does
    # not matter. If the data returned
    # by the server is in the Latin Portable Character Encoding, then the
    # returned strings are in the Host Portable Character Encoding. Otherwise,
    # the result is implementation dependent. If there are no matching font names,
    # `fonts` returns empty array.
    #
    # ###See also
    # `fonts_with_info`, `load_font`, `set_font_path`.
    def fonts(pattern : String, max_names : Int32) : Array(String)
      pstrings = X.list_fonts @dpy, pattern.to_unsafe, max_names, out count
      return [] of String if pstrings.null? || count <= 0
      font_names = Array(String).new
      (0...count).each do |i|
        font_names << String.new pstrings[i]
      end
      X.free_font_names pstrings
      font_names
    end

    # Returns a list of font names and infos.
    #
    # ###Arguments
    # - **pattern** Specifies the null-terminated pattern string that can contain wildcard characters.
    # - **max_names** Specifies the maximum number of names to be returned.
    #
    # ###Description
    # The `fonts_with_info` function returns a list of font names and infos that
    # match the specified pattern and their associated font information.
    # The list of names is limited to size specified by maxnames. The information
    # returned for each font is identical to what `load_query_font` would return
    # except that the per-character metrics are not returned. The pattern string
    # can contain any characters, but each asterisk (*) is a wildcard for any
    # number of characters, and each question mark (?) is a wildcard for a single character.
    # If the pattern string is not in the Host Portable Character Encoding,
    # the result is implementation dependent. Use of uppercase or lowercase does not matter.
    # If the data returned by the server is in the Latin Portable Character Encoding,
    # then the returned strings are in the Host Portable Character Encoding.
    # Otherwise, the result is implementation dependent.
    # If there are no matching font names, `fonts_with_info` returns empty array.
    #
    # ###See also
    # `list_fonts`, `load_font`, `set_font_path`.
    def fonts_with_info(pattern : String, max_names : Int32) : Array(NamedTuple(name: String, info: FontStruct))
      pstrings = X.list_fonts_with_info @dpy, pattern.to_unsafe, max_names, out count, out infos
      return [] of NamedTuple(name: String, info: FontStruct) if pstrings.null? || count <= 0
      font_names_with_info = Array(NamedTuple(name: String, info: FontStruct)).new
      (0...count).each do |i|
        name = String.new (pstrings + i).value
        info = FontStruct.new self, (infos + 1)
        font_names_with_info << {name: name, info: info}
      end
      X.free_font_info pstrings, infos, count
      font_names_with_info
    end

    # Returns an array of strings containing the search path.
    #
    # ###Description
    # The `font_path` function allocates and returns an array of strings containing
    # the search path. The contents of these strings are implementation dependent
    # and are not intended to be interpreted by client applications.
    #
    # ###See also
    # `set_font_path`, `fonts`, `load_font`.
    def font_path : Array(String)
      pstrings = X.get_font_path @dpy, out count
      return [] of String if pstrings.null? || count <= 0
      pathes = Array(String).new
      (0...count).each do |i|
        pathes << String.new (pstrings + i).value
      end
      X.free_font_path pstrings
      pathes
    end

    # Lists supported extensions.
    #
    # ###Description
    #
    # The `extensions` function returns a list of all extensions supported by the server.
    # If the data returned by the server is in the Latin Portable Character Encoding,
    # then the returned strings are in the Host Portable Character Encoding.
    # Otherwise, the result is implementation dependent.
    #
    # ###See also
    # `query_extension`.
    def extensions : Array(String)
      pstrings = X.list_extensions @dpy, out num_extensions
      return [] of String if pstrings.null? || num_extensions <= 0
      strings = Array(String).new
      (0...num_extensions).each do |i|
        strings << String.new (pstrings + i).value
      end
      X.free_extension_list pstrings
      strings
    end

    # Return property-atoms.
    #
    # ###Arguments
    # - **w** Specifies the window whose property list you want to obtain.
    #
    # ###Description
    # The `properties` function returns an array of atom properties
    # that are defined for the specified window or returns empty array if no properties were found.
    #
    # `properties` can generate a **BadWindow** error.
    #
    # ###Diagnostics
    # - **BadWindow** A value for a Window argument does not name a defined Window.
    #
    # ###See also
    # `change_property`, `delete_property`, `window_property`, `rotate_window_properties`.
    def properties(w : X11::C::Window) : Array(X11::C::Atom)
      patoms = X.list_properties @dpy, w, out num_properties
      return [] of X11::C::Atom if patoms.null? || num_properties <= 0
      atoms = Array(X11::C::Atom).new
      (0...num_properties).each do |i|
        atoms << patoms[i]
      end
      X.free patoms.as(PChar)
      atoms
    end

    # Returns current access control list.
    #
    # ###Description
    #
    # The `hosts` function returns the current access control list as well as whether
    # the use of the list at connection setup was enabled or disabled. `hosts` allows a
    # program to find out what machines can make connections. It also returns an array of host objects
    # that were allocated by the function.
    #
    # ###See also
    # `add_host`, `add_hosts`, `disable_access_control`, `enable_access_control`
    # `remove_host`, `remove_hosts`, `set_access_control`.
    def hosts : Array(HostAddress)
      phosts = X.list_hosts @dpy, out count, out state
      return [] of HostAddress if phosts.null? || count <= 0
      addresses = Array(HostAddress).new
      (0...count).each do |i|
        addresses << HostAddress.new(phosts + i)
      end
      X.free phosts.as(PChar)
      addresses
    end

    # Returns the KeySym defined for the specified KeyCode.
    #
    # ###Arguments
    # - **keycode** Specifies the KeyCode.
    # - **index** Specifies the element of KeyCode vector.
    #
    # ###Description
    # The `keycode_to_keysym` function uses internal Xlib tables and returns the
    # KeySym defined for the specified KeyCode and the element of the KeyCode vector.
    # If no symbol is defined, `keycode_to_keysym` returns `NoSymbol`.
    #
    # ###See also
    # `keysym_to_keycode`.
    def keycode_to_keysym(keycode : X11::C::KeyCode, index : Int32) : X11::C::KeySym
      X.keycode_to_keysym @dpy, keycode, index
    end

    # Returns the symbols for the specified number of KeyCodes starting with first_keycode.
    #
    # ###Arguments
    # - **first_keycode** Specifies the first KeyCode that is to be returned.
    # - **keycode_count** Specifies the number of KeyCodes that are to be returned.
    #
    # ###Description
    # The `keyboard_mapping` function returns the symbols for the specified
    # number of KeyCodes starting with first_keycode. The value specified in
    # first_keycode must be greater than or equal to min_keycode as returned by
    # `display_keycodes`, or a **BadValue** error results. In addition, the
    # following expression must be less than or equal to max_keycode as returned by `display_keycodes`:
    # ```
    # first_keycode + keycode_count - 1
    # ```
    # If this is not the case, a **BadValue** error results. The number of elements in the KeySyms list is:
    # ```
    # keycode_count * keysyms_per_keycode
    # ```
    # KeySym number N, counting from zero, for KeyCode K has the following index in the list, counting from zero:
    # ```
    # (K - first_code) * keysyms_per_code + N
    # ```
    # The X server arbitrarily chooses the keysyms_per_keycode value to be large
    # enough to report all requested symbols. A special KeySym value of
    # **NoSymbol** is used to fill in unused elements for individual KeyCodes.
    #
    # `keyboard_mapping` can generate a **BadValue** error.
    #
    # ###Diagnostics
    # - **BadValue** Some numeric value falls outside the range of values
    # accepted by the request. Unless a specific range is specified for an
    # argument, the full range defined by the argument's type is accepted.
    # Any argument defined as a set of alternatives can generate this error.
    #
    # ###See also
    # `change_keyboard_mapping`, `ModifierKeymap::delete_entry`, `display_keycodes`,
    # `ModifierKeymap::finalize`, `modifier_mapping`, `ModifierKeymap::insert_entry`,
    # `ModifierKeymap::new`, `set_modifier_mapping`, `set_pointer_mapping`.
    def keyboard_mapping(first_keycode : X11::C::KeyCode, keycode_count : Int32) : Array(X11::C::KeySym)
      pkeysyms = X.get_keyboard_mapping @dpy, first_keycode, keycode_count, out keysyms_per_keycode
      return [] of X11::C::KeySym if keysyms_per_keycode == 0 || pkeysyms.null?
      keysyms = Array(X11::C::KeySym).new
      (0...keycode_count * keysyms_per_keycode).each do |i|
        keysyms << (pkeysyms + i).value
      end
      X.free pkeysyms.as(PChar)
      keysyms
    end

    # Returns the maximum request size.
    #
    # ###Description
    # The `max_request_size` function returns the maximum request size (in 4-byte units)
    # supported by the server without using an extended-length protocol encoding.
    # Single protocol requests to the server can be no larger than this size unless
    # an extended-length protocol encoding is supported by the server. The protocol
    # guarantees the size to be no smaller than 4096 units (16384 bytes). Xlib
    # automatically breaks data up into multiple protocol requests as necessary
    # for the following functions: `draw_points`, `draw_rectangles`,
    # `draw_segments`, `fill_arcs`, `fill_rectangles`, and `put_image`.
    def max_request_size : Int64
      X.max_request_size @dpy
    end

    # Returns the maximum request size.
    #
    # ###Description
    # The `extended_max_request_size` function returns zero if the specified
    # display does not support an extended-length protocol encoding; otherwise,
    # it returns the maximum request size (in 4-byte units) supported by the
    # server using the extended-length encoding. The Xlib functions
    # `draw_lines`, `draw_arcs`, `fill_polygon`, `change_property`,
    # `set_clip_rectangles`, and `set_region` will use the extended-length
    # encoding as necessary, if supported by the server. Use of the
    # extended-length encoding in other Xlib functions (for example,
    # `draw_points`, `draw_rectangles`, `draw_degments`, `fill_arcs`,
    # `fill_rectangles`, `put_image`) is permitted but not required; an Xlib
    # implementation may choose to split the data across multiple smaller requests instead.
    def extended_max_request_size : Int64
      X.extended_max_request_size @dpy
    end

    # Returns the RESOURCE_MANAGER property from the server's root window of screen zero.
    #
    # ###Description
    # The `resource_manager_string` function returns the RESOURCE_MANAGER property
    # from the server's root window of screen zero, which was returned when the
    # connection was opened using `Display::new`. The property is converted from
    # type STRING to the current locale. The conversion is identical to that produced
    # by `mb_text_property_to_text_list` for a single element STRING property.
    # The returned string is owned by Xlib and should not be freed by the client.
    # The property value must be in a format that is acceptable to `X11::rm_get_string_database`.
    # If no property exists, empty string is returned.
    #
    # ###See also
    # `Screen::resource_string`.
    def resource_manager_string : String
      pstr = X.resource_manager_string @dpy
      return "" if pstr.null?
      str = String.new pstr
      X.free pstr
      str
    end

    # Returns the motion-buffer size.
    #
    # ###Description
    # The server may retain the recent history of the pointer motion and do so
    # to a finer granularity than is reported by `MotionNotify` events.
    # The `motion_events` function makes this history available.
    #
    # ###See also
    # `motion_events`, `if_event`, `next_event`, `put_back_event`, `send_event`.
    def motion_buffer_size : UInt64
      X.display_motion_buffer_size @dpy
    end

    # Locks out all other threads from using the actual display.
    #
    # ###Description
    # The `lock` function locks out all other threads from using the actual display.
    # Other threads attempting to use the display will block until the display is
    # unlocked by this thread. Nested calls to `lock` work correctly; the display
    # will not actually be unlocked until `unlock` has been called the same number
    # of times as `lock_display`. This function has no effect unless Xlib was
    # successfully initialized for threads using `X11::init_threads`.
    #
    # ###See also
    # `X11::init_threads`, `unlock_display`.
    def lock
      X.lock_display
      self
    end

    # Allows other threads to use the specified display again.
    #
    # ###Description
    # The `unlock` function allows other threads to use the specified display again.
    # Any threads that have blocked on the display are allowed to continue.
    # Nested locking works correctly; if `lock` has been called multiple times by a thread,
    # then `unlock` must be called an equal number of times before the display
    # is actually unlocked. This function has no effect unless Xlib was successfully
    # initialized for threads using `X11::init_threads`.
    #
    # ###See also
    # `X11::init_threads`, `lock`.
    def unlock
      X.unlock_display @dpy
      self
    end

    # Determines if the named extension exists.
    #
    # ###Arguments
    # - **name** Specifies the extension name.
    #
    # ###Description
    # The `init_extension` function determines if the named extension exists.
    # Then, it allocates storage for maintaining the information about the
    # extension on the connection, chains this onto the extension list for the
    # connection, and returns the information the stub implementor will need to
    # access the extension. If the extension does not exist, `init_extension` returns **nil**.
    #
    # If the extension name is not in the Host Portable Character Encoding, the
    # result is implementation dependent. Uppercase and lowercase matter; the
    # strings "thing", "Thing", and "thinG" are all considered different names.
    #
    # The extension number in the `ExtCodes` structure is needed in the other
    # calls that follow. This extension number is unique only to a single connection.
    #
    # ###See also
    # `add_extension`.
    def init_extension(name : String) : ExtCodes?
      pcodes = X.init_extension @dpy, name.to_unsafe
      return nil if pcodes.null?
      ExtCodes.new pcodes
    end

    # Allocates the `ExtCodes` structure.
    #
    # ###Description
    # For local Xlib extensions, the `add_extension` function allocates the
    # `ExtCodes` structure, bumps the extension number count, and chains the
    # extension onto the extension list. (This permits extensions to Xlib without
    # requiring server extensions.)
    #
    # ###See also
    # `init_extension`.
    def add_extension : ExtCodes?
      pcodes = X.add_extension @dpy
      return nil if pcodes.null?
      ExtCodes.new pcodes
    end

    # Returns the root window of the specified screen.
    #
    # ###Arguments
    # - **screen_number** Specifies the appropriate screen number on the host server.
    #
    # ###See Also
    # `default_root_window`.
    def root_window(screen_number : Int32) : X11::C::Window
      X.root_window @dpy, screen_number
    end

    # Returns the root window of the default screen.
    def default_root_window : X11::C::Window
      X.default_root_window @dpy
    end

    # Returns the default visual type for the specified screen.
    #
    # ###Arguments
    # - **screen_number** Specifies the appropriate screen number on the host server.
    def default_visual(screen_number : Int32) : Visual
      Visual.new(X.default_visual(@dpy, screen_number))
    end

    # Returns the default graphics context for the root window of the specified screen.
    #
    # ###Arguments
    # - **screen_number** Specifies the appropriate screen number on the host server.
    #
    # ###Description
    # This GC is created for the convenience of simple applications and contains
    # the default GC components with the foreground and background pixel values initialized to the black and white pixels for the screen, respectively.
    def default_gc(screen_number : Int32) : X11::C::X::GC
      X.default_gc @dpy, screen_number
    end

    # Returns the black pixel value for the specified screen.
    #
    # ###Arguments
    # - **screen_number** Specifies the appropriate screen number on the host server.
    def black_pixel(screen_number : Int32) : UInt64
      X.black_pixel @dpy, screen_number
    end

    # Returns the white pixel value for the specified screen.
    #
    # ###Arguments
    # - **screen_number** Specifies the appropriate screen number on the host server.
    def white_pixel(screen_number : Int32) : UInt64
      X.white_pixel @dpy, screen_number
    end

    # Returns the full serial number that is to be used for the next request.
    # Serial numbers are maintained separately for each display connection.
    def next_request : UInt64
      X.next_request @dpy
    end

    # Returns the full serial number of the last request known by Xlib to have
    # been processed by the X server. Xlib automatically sets this number when replies,
    # events, and errors are received. extract the full serial number of the last
    # request known by Xlib to have been processed by the X server.
    # Xlib automatically sets this number when replies, events, and errors are received.
    def last_known_request_processed : UInt64
      X.last_known_request_processed @dpy
    end

    # Returns string that provides some identification of the owner of the X server implementation.
    # If the data returned by the server is in the Latin Portable Character Encoding,
    # then the string is in the Host Portable Character Encoding. Otherwise,
    # the contents of the string are implementation dependent.
    def server_vendor : String
      pstr = X.server_vendor @dpy
      return "" if pstr.null?
      String.new pstr
    end

    # Returns the string that was passed to `new` when the current display was opened.
    # On POSIX-conformant systems, if the passed string was **nil**,
    # these return the value of the DISPLAY environment variable when the current display was opened.
    # These are useful to applications that invoke the **fork** system call
    # and want to open a new connection to the same display from the child process as well as for printing error messages.
    def display_string : String
      pstr = X.display_string @dpy
      return "" if pstr.null?
      String.new pstr
    end

    # Returns the default colormap ID for allocation on the specified screen.
    # Most routine allocations of color should be made out of this colormap.
    #
    # ###Arguments
    # - **screen_number** Specifies the appropriate screen number on the host server.
    def default_colormap(screen_number : Int32) : X11::C::Colormap
      X.default_colormap @dpy, screen_number
    end

    # Returns the indicated screen.
    #
    # ###Arguments
    # - **screen_number** Specifies the appropriate screen number on the host server.
    def screen(screen_number : Int32) : Screen
      Screen.new(X.screen_of_display(@dpy, screen_number))
    end

    # Returns default screen.
    def default_screen : Screen
      Screen.new(X.default_screen_of_display(@dpy))
    end

    # Returns informations of the supported pixel formats.
    #
    # ###Description
    # The `pixmap_formats` function returns an array of `PixmapFormatValues` objects
    # that describe the types of Z format images supported by the specified display.
    # If insufficient memory is available, `pixmap_formats` returns empty array.
    def pixmap_formats : Array(PixmapFormatValues)
      pvalues = X.list_pixmap_formats @dpy, out count
      return [] of PixmapFormatValues if count <= 0
      values = Array(PixmapFormatValues).new
      (0...count).each do |i|
        values << PixmapFormatValues.new pvalues[i]
      end
      X.free pvalues.as(PChar)
      values
    end

    # Returns the array of depths that are available on the specified screen.
    #
    # ###Arguments
    # - **screen_number** Specifies the appropriate screen number on the host server.
    #
    # ###Description
    # The `depths` function returns the array of depths that are available on the specified screen.
    # If the specified screen_number is valid and sufficient memory for the array can be allocated,
    # otherwise it returns an empty array.
    def depths(screen_number : Int32) : Array(Int32)
      pvalues = X.list_depths @dpy, screen_number, out count
      return [] of Int32 if count <= 0
      values = Array(Int32).new
      (0...count).each do |i|
        values << pvalues[i]
      end
      X.free pvalues.as(PChar)
      values
    end

    # Issues a **ConfigureWindow** request on the specified top-level window.
    #
    # ###Arguments
    # - **w** Specifies the window.
    # - **screen_number** Specifies the appropriate screen number on the host server.
    # - **value_mask** Specifies which values are to be set using information in
    # the values structure. This mask is the bitwise inclusive OR of the valid configure window values bits.
    # - **values** Specifies the `WindowChanges` structure.
    #
    # ###Description
    # The `reconfigure_wm_window` function issues a **ConfigureWindow** request
    # on the specified top-level window. If the stacking mode is changed and the
    # request fails with a **BadMatch** error, the error is trapped by Xlib and
    # a synthetic **ConfigureRequestEvent** containing the same configuration
    # parameters is sent to the root of the specified window. Window managers
    # may elect to receive this event and treat it as a request to reconfigure
    # the indicated window. It returns a nonzero status if the request or event
    # is successfully sent; otherwise, it returns a zero status.
    #
    # `reconfigure_wm_window` can generate **BadValue** and **BadWindow** errors.
    #
    # ###Diagnostics
    # - **BadWindow** A value for a Window argument does not name a defined Window.
    #
    # ###See also
    # `change_window_attributes`, `configure_window`, `create_window`, `destroy_window`,
    # `iconify_window`, `map_window`, `raise_window`, `unmap_window`, `withdraw_window`.
    def reconfigure_wm_window(w : X11::C::Window, screen_number : Int32, mask : UInt32, changes : WindowChanges) : X11::C::Status
      X.reconfigure_wm_window @dpy, w, screen_number, mask, changes.to_unsafe
    end

    # Returns the list of atoms stored in the WM_PROTOCOLS propertystored in the WM_PROTOCOLS property.
    #
    # ###Arguments
    # - **w** Specifies the window.
    #
    # ###Description
    # The `wm_protocols` function returns the list of atoms stored in the WM_PROTOCOLS property on the specified window.
    # These atoms describe window manager protocols in which the owner of this window
    # is willing to participate. If the property exists, is of type `Atom`,
    # is of format 32, and the atom WM_PROTOCOLS can be interned.
    #
    # `wm_protocols` can generate a **BadWindow** error.
    #
    # ###Diagnostics
    # - **BadWindow** A value for a Window argument does not name a defined Window.
    #
    # ###See also
    # `X11::alloc_class_hint`, `X11::alloc_icon_size`, `X11::alloc_size_hints`,
    # `X11::alloc_wm_hints`, `set_command`, `set_text_property`, `set_transient_for_hint`,
    # `set_wm_client_machine`, `set_wm_colormap_windows`, `set_wm_icon_name`,
    # `set_wm_name`, `set_wm_properties`, `set_wm_protocols`, `X11::string_list_to_text_property`.
    def wm_protocols(w : X11::C::Window) : Array(X11::C::Atom)
      status = X.get_wm_protocols @dpy, w, out patoms, out count
      return [] of X11::C::Atom if status == 0 || count <= 0
      atoms = Array(X11::C::Atom).new
      (0...count).each do |i|
        atoms << patoms[i]
      end
      X.free patoms.as(PChar)
      atoms
    end

    # Replaces the WM_PROTOCOLS property on the specified window.
    #
    # ###Arguments
    # - **w** Specifies the window.
    # - **protocols** Specifies the list of protocols.
    #
    # ###Description
    # The `set_wm_protocols` function replaces the WM_PROTOCOLS property on the
    # specified window with the list of atoms specified by the protocols argument.
    # If the property does not already exist, `set_wm_protocols` sets the WM_PROTOCOLS property
    # on the specified window to the list of atoms specified by the protocols argument.
    # The property is stored with a type of `X11::C::Atom` and a format of 32.
    # If it cannot intern the WM_PROTOCOLS atom, `set_wm_protocols` returns a zero status.
    # Otherwise, it returns a nonzero status.
    #
    # `set_wm_protocols` can generate **BadAlloc** and **BadWindow** errors.
    #
    # ###Diagnostics
    # - **BadAlloc** The server failed to allocate the requested source or server memory.
    # - **BadWindow** A value for a Window argument does not name a defined Window.
    #
    # ###See also
    # `X11::alloc_class_hint`, `X11::alloc_icon_size`, `X11::alloc_size_hints`,
    # `X11::alloc_wm_hints`, `wm_protocols`, `set_command`, `set_text_property`, `set_transient_for_hint`,
    # `set_wm_client_machine`, `set_wm_colormap_windows`, `set_wm_icon_name`,
    # `set_wm_name`, `set_wm_properties`, `X11::string_list_to_text_property`.
    def set_wm_protocols(w : X11::C::Window, protocols : Array(Atom | X11::C::Atom)) : X11::C::X::Status
      X.set_wm_protocols @dpy, w, protocols.to_unsafe.as(X11::C::PAtom), protocols.size
    end

    # Sends a WM_CHANGE_STATE ClientMessage event.
    #
    # ###Arguments
    # - **w** Specifies the window.
    # - **screen_number** Specifies the appropriate screen number on the host server.
    #
    # ###Description
    # The `iconify_window` function sends a WM_CHANGE_STATE ClientMessage event
    # with a format of 32 and a first data element of **IconicState** and a window
    # of w to the root window of the specified screen with an event mask set to
    # **SubstructureNotifyMask** | **SubstructureRedirectMask**.
    # Window managers may elect to receive this message and if the window is in
    # its normal state, may treat it as a request to change the window's state
    # from normal to iconic. If the WM_CHANGE_STATE property cannot be interned,
    # `iconify_window` does not send a message and returns a zero status.
    # It returns a nonzero status if the client message is sent successfully; otherwise, it returns a zero status.
    #
    # ###See also
    # `change_window_attributes`, `configure_window`, `create_window`, `destroy_window`,
    # `map_window`, `raise_window`, `reconfigure_wm_window`, `unmap_window`, `withdraw_window`.
    def iconify_window(w : X11::C::Window, screen_number : Int32) : X11::C::X::Status
      X.iconify_window @dpy, w, screen_number
    end

    # Unmaps the specified window.
    #
    # ###Arguments
    # - **w** Specifies the window.
    # - **screen_number** Specifies the appropriate screen number on the host server.
    #
    # ###Description
    # The `withdraw_window` function unmaps the specified window and sends a
    # synthetic **UnmapNotify** event to the root window of the specified screen.
    # Window managers may elect to receive this message and may treat it as a
    # request to change the window's state to withdrawn. When a window is in
    # the withdrawn state, neither its normal nor its iconic representations is visible.
    # It returns a nonzero status if the **UnmapNotify** event is successfully sent; otherwise, it returns a zero status.
    #
    # `withdraw_window` can generate a **BadWindow** error.
    # ###Diagnostics
    # - **BadWindow** A value for a Window argument does not name a defined Window.
    #
    # ###See also
    # `change_window_attributes`, `configure_window`, `create_window`, `destroy_window`,
    # `map_window`, `raise_window`, `reconfigure_wm_window`, `unmap_window`, `withdraw_window`.
    def withdraw_window(w : X11::C::Window, screen_number : Int32) : X11::C::X::Status
      X.withdraw_window @dpy, w, screen_number
    end

    # Reads the WM_COMMAND property from the specified window.
    #
    # ###Arguments
    # - **w** Specifies the window.
    #
    # ###Description
    # The `command` function reads the WM_COMMAND property from the
    # specified window and returns a string list. If the WM_COMMAND property exists,
    # it is of type STRING and format 8. If sufficient memory can be allocated
    # to contain the string list, `get_command` returns an array of strings.
    # Otherwise, it returns an empty array. If the data returned by the server is in the Latin Portable Character Encoding,
    # then the returned strings are in the Host Portable Character Encoding.
    # Otherwise, the result is implementation dependent.
    #
    # See also
    # `X11::alloc_class_hint`, `X11::alloc_icon_size`, `X11::alloc_size_hints`,
    # `X11::alloc_wm_hints`, `set_command`, `set_text_property`, `set_transient_for_hint`,
    # `set_wm_client_machine`, `set_wm_colormap_windows`, `set_wm_icon_name`,
    # `set_wm_name`, `set_wm_properties`, `set_wm_protocols`, `X11::string_list_to_text_property`.
    def command(w : X11::C::Window) : Array(String)
      status = X.get_command @dpy, w, out argv, out argc
      return [] of String if status == 0 || argc <= 0
      commands = Array(String).new
      (0...argc).each do |i|
        commands << String.new argv[i]
      end
      X.free argv[0]
      commands
    end

    # Returns the list of window identifiers stored in the WM_COLORMAP_WINDOWS property.
    #
    # ###Arguments
    # - **w** Specifies the window.
    #
    # ###Description
    # The `wm_colormap_windows` function returns the list of window identifiers
    # stored in the WM_COLORMAP_WINDOWS property on the specified window.
    # These identifiers indicate the colormaps that the window manager may need
    # to install for this window.
    #
    # `wm_colormap_windows` can generate a **BadWindow** error.
    #
    # ###Diagnostics
    # - **BadWindow** A value for a Window argument does not name a defined Window.
    #
    # ###See also
    # `X11::alloc_class_hint`, `X11::alloc_icon_size`, `X11::alloc_size_hints`,
    # `X11::alloc_wm_hints`, `set_command`, `set_text_property`, `set_transient_for_hint`,
    # `set_wm_client_machine`, `set_wm_colormap_windows`, `set_wm_icon_name`,
    # `set_wm_name`, `set_wm_properties`, `set_wm_protocols`, `X11::string_list_to_text_property`.
    def wm_colormap_windows(w : X11::C::Window) : Array(X11::C::Window)
      status = X.get_wm_colormap_windows @dpy, w, out pwindows, out count
      return [] of X11::C::Window if status == 0 | count <= 0
      windows = Array(X11::C::Window).new
      (0...count).each do |i|
        windows << pwindows[i]
      end
      windows
    end

    # Replaces the WM_COLORMAP_WINDOWS property on the specified window.
    #
    # ###Arguments
    # - **w** Specifies the window.
    # - **colormap_windows** Specifies the list of windows.
    #
    # ###Description
    # The `set_wm_colormap_windows` function replaces the WM_COLORMAP_WINDOWS
    # property on the specified window with the list of windows specified by
    # the colormap_windows argument. It the property does not already exist,
    # `set_wm_colormap_windows` sets the WM_COLORMAP_WINDOWS property on the
    # specified window to the list of windows specified by the colormap_windows argument.
    # The property is stored with a type of WINDOW and a format of 32.
    # If it cannot intern the WM_COLORMAP_WINDOWS atom, `set_wm_colormap_windows` returns a zero status.
    # Otherwise, it returns a nonzero status.
    #
    # `set_wm_colormap_windows` can generate **BadAlloc** and **BadWindow** errors.
    #
    # ###Diagnostics
    # - **BadAlloc** The server failed to allocate the requested source or server memory.
    # - **BadWindow** A value for a Window argument does not name a defined Window.
    #
    # ###See also
    # `X11::alloc_class_hint`, `X11::alloc_icon_size`, `X11::alloc_size_hints`,
    # `X11::alloc_wm_hints`, `wm_colormap_windows`, `set_command`, `set_text_property`,
    # `set_transient_for_hint`,`set_transient_for_hint`, `set_wm_client_machine`,
    # `set_wm_colormap_windows`, `set_wm_icon_name`, `set_wm_name`,
    # `set_wm_properties`, `set_wm_protocols`, `X11::string_list_to_text_property`.
    def set_wm_colormap_windows(w : X11::C::Window, colormap_windows : Array(X11::C::Window)) : X11::C::X::Status
      X.set_wm_colormap_windows @dpy, w, colormap_windows.to_unsafe, colormap_windows.size
    end

    # Sets the WM_TRANSIENT_FOR property of the specified window to the specified prop_window.
    #
    # ###Arguments
    # - **w** Specifies the window.
    # - **prop_window** Specifies the window that the WM_TRANSIENT_FOR property is to be set to.
    #
    # ###Description
    # The `set_transient_for_hint` function sets the WM_TRANSIENT_FOR property of the specified window to the specified prop_window.
    # `set_transient_for_hint` can generate **BadAlloc** and **BadWindow** errors.
    # ###Diagnostics
    # - **BadAlloc** The server failed to allocate the requested source or server memory.
    # - **BadWindow** A value for a Window argument does not name a defined Window.
    #
    # See also
    # `X11::alloc_class_hint`, `X11::alloc_icon_size`, `X11::alloc_size_hints`,
    # `X11::alloc_wm_hints`, `transient_for_hint`, `set_command`, `set_text_property`,
    # `set_wm_client_machine`, `set_wm_colormap_windows`, `set_wm_icon_name`,
    # `set_wm_name`, `set_wm_properties`, `set_wm_protocols`, `X11::string_list_to_text_property`.
    def set_transient_for_hint(w : X11::C::Window, prop_window : X11::C::Window) : Int32
      X.set_transient_for_hint @dpy, w, prop_window
    end

    # Activates the screen saver.
    #
    # ###See also
    # `set_screen_saver`, `force_screen_saver`, `reset_screen_saver`, `screen_saver`.
    def activate_screen_saver : Int32
      X.activate_screen_saver @dpy
    end

    #
    #
    # ###Arguments
    # - **host** Specifies the host that is to be added.
    #
    # ###Description
    # The `add_host` function adds the specified host to the access control list
    # for the display. The server must be on the same host as the client issuing
    # the command, or a **BadAccess** error results.
    #
    # `add_host` can generate **BadAccess** and **BadValue** errors.
    #
    # ###Diagnostics
    # - **BadAccess** A client attempted to free a color map entry that it did not already allocate.
    # - **BadAccess** A client attempted to store into a read-only color map entry.
    # - **BadValue** Some numeric value falls outside the range of values accepted
    # by the request. Unless a specific range is specified for an argument, the full
    # range defined by the argument's type is accepted. Any argument defined as a set of alternatives can generate this error.
    #
    # ###See also
    # `add_hosts`, `disable_access_control`, `enable_access_control`, `X11::free`,
    # `list_hosts`, `remove_host`, `remove_hosts`, `set_access_control`.
    def add_host(host : HostAddress | ServerInterpretedAddress) : Int32
      case host
      when HostAddress
        X.add_host @dpy, host.to_unsafe
      when ServerInterpretedAddress
        host_address = HostAddress.new host
        X.add_host @dpy, host_address.to_unsafe
      end
    end

    # Adds each specified host to the access control list.
    #
    # ###Arguments
    # - **hosts** Specifies each host that is to be added.
    #
    # ###Description
    # The `add_hosts` function adds each specified host to the access control list
    # for the display. The server must be on the same host as the client issuing the command, or a **BadAccess** error results.
    #
    # `add_hosts` can generate **BadAccess** and **BadValue** errors.
    #
    # ###Diagnostics
    # - **BadAccess** A client attempted to free a color map entry that it did not already allocate.
    # - **BadAccess** A client attempted to store into a read-only color map entry.
    # - **BadValue** Some numeric value falls outside the range of values accepted by the request.
    # Unless a specific range is specified for an argument, the full range defined
    # by the argument's type is accepted. Any argument defined as a set of alternatives can generate this error.
    #
    # ###See also
    # `add_host`, `disable_access_control`, `enable_access_control`, `X11::free`,
    # `list_hosts`, `remove_host`, `remove_hosts`, `set_access_control`.
    def add_hosts(hosts : Array(HostAddress)) : Int32
      X.add_hosts @dpy, hosts.to_unsafe, hosts.size
    end

    # Adds the specified window to the client's save-set.
    #
    # ###Arguments
    # - **w** Specifies the window that you want to add to the client's save-set.
    #
    # ###Description
    # The `add_to_save_set` function adds the specified window to the client's save-set.
    # The specified window must have been created by some other client, or a **BadMatch** error results.
    # `add_to_save_set` can generate **BadMatch** and **BadWindow** errors.
    #
    # ###Diagnostics
    # - **BadMatch** An **InputOnly** window is used as a *Drawable*.
    # - **BadMatch** Some argument or pair of arguments has the correct type and range but fails to match in some other way required by the request.
    # - **BadWindow** A value for a Window argument does not name a defined Window.
    #
    # ###See also
    # `change_save_set`, `remove_from_save_set`, `reparent_window`.
    def add_to_save_set(w : X11::C::Window) : Int32
      X.add_to_save_set @dpy, w
    end

    # Allocates a read-only colormap entry.
    #
    # ###Arguments
    # - **colormap** Specifies the colormap.
    # - **screen_in** Specifies and returns the values actually used in the colormap.
    #
    # ###Description
    # The `alloc_color` function allocates a read-only colormap entry corresponding
    # to the closest RGB value supported by the hardware. `alloc_color` returns
    # the pixel value of the color closest to the specified RGB elements supported
    # by the hardware and returns the RGB value actually used. The corresponding
    # colormap cell is read-only. Multiple clients that request the same effective
    # RGB value can be assigned the same read-only entry, thus allowing entries
    # to be shared. When the last client deallocates a shared cell, it is deallocated.
    # `alloc_color` does not use or affect the flags in the `Color` structure.
    #
    # `alloc_color` can generate a **BadColor** error.
    #
    # ###Diagnostics
    # - **BadColor** A value for a `Colormap` argument does not name a defined `Colormap`.
    #
    # ###See also
    # `alloc_color_cells`, `alloc_color_planes`, `alloc_named_color`,
    # `create_colormap`, `free_colors`, `query_color`, `store_colors`.
    def alloc_color(colormap : X11::C::Colormap, screen_in : Color) : Color
      screen_in_out = screen_in.to_x
      X.alloc_color @dpy, colormap, pointerof(screen_in_out)
      Color.new screen_in_out
    end

    # Allocates read/write color cells.
    #
    # ###Arguments
    # - **colormap** Specifies the colormap.
    # - **contig** Specifies a Boolean value that indicates whether the planes must be contiguous.
    # - **nplanes** Specifies the number of plane masks that are to be returned in the plane masks array.
    # - **npixels** Specifies the number of pixel values that are to be returned in the pixels_return array.
    #
    # ###Description
    # The `alloc_color_cells` function allocates read/write color cells.
    # The number of colors must be positive and the number of planes nonnegative,
    # or a **BadValue** error results. No mask will have any bits set to 1 in
    # common with any other mask or with any of the pixels. All of these are
    # allocated writable by the request. For **GrayScale** or **PseudoColor**,
    # each mask has exactly one bit set to 1. For **DirectColor**, each has exactly
    # three bits set to 1. If contig is **true** and if all masks are **ORed** together,
    # a single contiguous set of bits set to 1 will be formed for **GrayScale** or
    # **PseudoColor** and three contiguous sets of bits set to 1 (one within
    # each pixel subfield) for **DirectColor**. The RGB values of the allocated
    # entries are undefined.
    #
    # `alloc_color_cells` can generate **BadColor** and **BadValue** errors.
    #
    # ###Diagnostics
    # - **BadColor** A value for a Colormap argument does not name a defined Colormap.
    # - **BadValue** Some numeric value falls outside the range of values accepted by the request.
    # Unless a specific range is specified for an argument, the full range defined by the argument's type is accepted.
    # Any argument defined as a set of alternatives can generate this error.
    #
    # ###See also
    # `alloc_color`, `alloc_color_planes`, `alloc_named_color`, `create_colormap`,
    # `free_colors`, `query_color`, `store_colors`.
    def alloc_color_cells(colormap : X11::C::Colormap, contig : Bool, nplanes : UInt32, npixels : UInt32) : NamedTuple(status: X11::C::X::Status, plane_masks: Array(UInt64), pixels: Array(UInt64))
      status = X.alloc_color_cells @dpy, colormap, contig ? X::True : X::False, out plane_masks_return, nplanes, out pixels_return, npixels
      plane_masks = Array(UInt64).new(nplanes) { |i| plane_masks_return[i] }
      pixels = Array(UInt64).new(npixels) { |i| pixels_return[i] }
      {status: status, plane_masks: plane_masks, pixels: pixels}
    end

    # Allocates color planes.
    #
    # ###Arguments
    # - **colormap** Specifies the colormap.
    # - **contig** Specifies a Boolean value that indicates whether the planes must be contiguous.
    # - **ncolors** Specifies the number of pixel values that are to be returned in the pixels_return array.
    # - **nreds**, **ngreens**, **nblues** Specify the number of red, green, and blue planes. The value you pass must be nonnegative.
    #
    # ###Description
    # The specified ncolors must be positive; and nreds, ngreens, and nblues must be nonnegative,
    # or a **BadValue** error results. If ncolors colors, nreds reds, ngreens greens,
    # and nblues blues are requested, ncolors pixels are returned; and the masks have
    # nreds, ngreens, and nblues bits set to 1, respectively. If contig is **true**,
    # each mask will have a contiguous set of bits set to 1. No mask will have
    # any bits set to 1 in common with any other mask or with any of the pixels.
    # For **DirectColor**, each mask will lie within the corresponding pixel subfield.
    # By **ORing** together subsets of masks with each pixel value, `ncolors * 2^(nreds+ngreens+nblues)`
    # distinct pixel values can be produced. All of these are allocated by the request.
    # However, in the colormap, there are only `ncolors * 2^nreds` independent red entries,
    # `ncolors * 2^ngreens` independent green entries, and `ncolors * 2^nblues`
    # independent blue entries. This is true even for **PseudoColor**. When the
    # colormap entry of a pixel value is changed (using `store_colors`, `store_color`,
    # or `store_named_color`), the pixel is decomposed according to the masks,
    # and the corresponding independent entries are updated. `alloc_color_planes` returns
    # nonzero if it succeeded or zero if it failed.
    #
    # `alloc_color_planes` can generate **BadColor** and **BadValue** errors.
    #
    # ###Diagnostics
    # - **BadColor** A value for a Colormap argument does not name a defined Colormap.
    # - **BadValue** Some numeric value falls outside the range of values accepted
    # by the request. Unless a specific range is specified for an argument, the
    # full range defined by the argument's type is accepted. Any argument defined as a set of alternatives can generate this error.
    #
    # ###See also
    # `alloc_color`, `alloc_color_cells`, `alloc_named_color`, `create_colormap`,
    # `free_colors`, `query_color`, `store_colors`.
    def alloc_color_planes(colormap : X11::C::Colormap, contig : Bool, ncolors : Int32, nreds : Int32, ngreens : Int32, nblues : Int32) : NamedTuple(status: X11::C::X::Status, pixels: Array(UInt64), rmask: UInt64, gmask: UInt64, bmask: UInt64)
      status = X.alloc_color_planes @dpy, colormap, contig ? X::True : X::False, out pixels_return, ncolors, nreds, nblues, out rmask, out gmask, out bmask
      pixels = Array(UInt64).new(ncolors) { |i| pixels_return[i] }
      {status: status, pixels: pixels, rmask: rmask, gmask: gmask, bmask: bmask}
    end

    # Looks up the named color with respect to the screen that is associated with the specified colormap.
    #
    # ###Arguments
    # - **colormap** Specifies the colormap.
    # - **color_name** Specifies the color name string (for example, red) whose color definition structure you want returned.
    #
    # ###Return
    # - **screen_def** The closest RGB values provided by the hardware.
    # - **exact_def** The exact RGB values.
    # - **status** Nonzero if a cell is allocated; otherwise, it is zero.
    #
    # ###Description
    # The `alloc_named_color` function looks up the named color with respect to
    # the screen that is associated with the specified colormap. It returns both
    # the exact database definition and the closest color supported by the screen.
    # The allocated color cell is read-only. The pixel value is returned in
    # screen_def. If the color name is not in the Host Portable Character Encoding,
    # the result is implementation dependent. Use of uppercase or lowercase does not matter.
    # If screen_def and exact_def point to the same structure, the pixel field will
    # be set correctly but the color values are undefined. `alloc_named_color` returns
    # nonzero status if a cell is allocated; otherwise, it returns zero.
    #
    # `alloc_named_color` can generate a **BadColor** error.
    #
    # ###Diagnostics
    # - **BadColor** A value for a Colormap argument does not name a defined Colormap.
    #
    # ###See also
    # `alloc_color`, `alloc_color_cells`, `alloc_color_planes`, `create_colormap`,
    # `free_colors`, `query_color`, `store_colors`.
    def alloc_named_color(colormap : X11::C::Colormap, color_name : String) : NamedTuple(status: X11::C::X::Status, screen_def: Color, exact_def: Color)
      status = X.alloc_named_color @dpy, colormap, color_name.to_unsafe, out screen_def, out exact_def
      {status: status, screen_def: Color.new(screen_def), exact_def: Color.new(exact_def)}
    end

    # Releases some queued events if the client has caused a device to freeze.
    #
    # ###Arguments
    # - **event_mode** Specifies the event mode. You can pass **AsyncPointer**,
    # **SyncPointer**, **AsyncKeyboard**, **SyncKeyboard**, **ReplayPointer**,
    # **ReplayKeyboard**, **AsyncBoth**, or **SyncBoth**.
    # - **time** Specifies the time. You can pass either a timestamp or **CurrentTime**.
    #
    # ###Description
    # The `allow_events` function releases some queued events if the client has caused a device to freeze.
    # It has no effect if the specified time is earlier than the last-grab time of the
    # most recent active grab for the client or if the specified time is later
    # than the current X server time. Depending on the event_mode argument, the following occurs:
    # - **AsyncPointer** If the pointer is frozen by the client, pointer event
    # processing continues as usual. If the pointer is frozen twice by the client
    # on behalf of two separate grabs, **AsyncPointer** thaws for both.
    # **AsyncPointer** has no effect if the pointer is not frozen by the client,
    # but the pointer need not be grabbed by the client.
    # - **SyncPointer** If the pointer is frozen and actively grabbed by the client,
    # pointer event processing continues as usual until the next **ButtonPress**
    # or **ButtonRelease** event is reported to the client. At this time, the
    # pointer again appears to freeze. However, if the reported event causes the
    # pointer grab to be released, the pointer does not freeze. **SyncPointer**
    # has no effect if the pointer is not frozen by the client or if the pointer is not grabbed by the client.
    # - **ReplayPointer** If the pointer is actively grabbed by the client and
    # is frozen as the result of an event having been sent to the client
    # (either from the activation of a `grab_button` or from a previous
    # `allow_events` with mode **SyncPointer** but not from a `grab_pointer`),
    # the pointer grab is released and that event is completely reprocessed.
    # This time, however, the function ignores any passive grabs at or above
    # (towards the root of) the grab_window of the grab just released. The request
    # has no effect if the pointer is not grabbed by the client or if the pointer
    # is not frozen as the result of an event.
    # - **AsyncKeyboard** If the keyboard is frozen by the client, keyboard event
    # processing continues as usual. If the keyboard is frozen twice by the
    # client on behalf of two separate grabs, **AsyncKeyboard** thaws for both.
    # **AsyncKeyboard** has no effect if the keyboard is not frozen by the client,
    # but the keyboard need not be grabbed by the client.
    # - **SyncKeyboard** If the keyboard is frozen and actively grabbed by the client,
    # keyboard event processing continues as usual until the next **KeyPress** or
    # **KeyRelease** event is reported to the client. At this time, the keyboard
    # again appears to freeze. However, if the reported event causes the keyboard
    # grab to be released, the keyboard does not freeze. **SyncKeyboard** has no
    # effect if the keyboard is not frozen by the client or if the keyboard is not grabbed by the client.
    # - **ReplayKeyboard** If the keyboard is actively grabbed by the client and
    # is frozen as the result of an event having been sent to the client
    # (either from the activation of a `grab_key` or from a previous `allow_events`
    # with mode **SyncKeyboard** but not from a `grab_keyboard`), the keyboard
    # grab is released and that event is completely reprocessed. This time,
    # however, the function ignores any passive grabs at or above (towards the root of)
    # the grab_window of the grab just released. The request has no effect if the
    # keyboard is not grabbed by the client or if the keyboard is not frozen as the result of an event.
    # - **SyncBoth** If both pointer and keyboard are frozen by the client,
    # event processing for both devices continues as usual until the next
    # **ButtonPress**, **ButtonRelease**, **KeyPress**, or **KeyRelease** event
    # is reported to the client for a grabbed device (button event for the pointer,
    # key event for the keyboard), at which time the devices again appear to freeze.
    # However, if the reported event causes the grab to be released, then the
    # devices do not freeze (but if the other device is still grabbed, then a
    # subsequent event for it will still cause both devices to freeze).
    # **SyncBoth** has no effect unless both pointer and keyboard are frozen by
    # the client. If the pointer or keyboard is frozen twice by the client on
    # behalf of two separate grabs, **SyncBoth** thaws for both (but a subsequent
    # freeze for **SyncBoth** will only freeze each device once).
    # - **AsyncBoth** If the pointer and the keyboard are frozen by the client,
    # event processing for both devices continues as usual. If a device is frozen
    # twice by the client on behalf of two separate grabs, **AsyncBoth** thaws
    # for both. **AsyncBoth** has no effect unless both pointer and keyboard are frozen by the client.
    # - **AsyncPointer**, **SyncPointer**, and **ReplayPointer** have no effect
    # on the processing of keyboard events. **AsyncKeyboard**, **SyncKeyboard**,
    # and **ReplayKeyboard** have no effect on the processing of pointer events.
    # It is possible for both a pointer grab and a keyboard grab (by the same or
    # different clients) to be active simultaneously. If a device is frozen on
    # behalf of either grab, no event processing is performed for the device.
    # It is possible for a single device to be frozen because of both grabs.
    # In this case, the freeze must be released on behalf of both grabs before
    # events can again be processed. If a device is frozen twice by a single client,
    # then a single **AllowEvents** releases both.
    #
    # `allow_events` can generate a **BadValue** error.
    #
    # ###Diagnostics
    # - **BadValue** Some numeric value falls outside the range of values
    # accepted by the request. Unless a specific range is specified for an argument,
    # the full range defined by the argument's type is accepted. Any argument
    # defined as a set of alternatives can generate this error.
    def allow_events(event_mode : Int32, time : X11::C::Time) : Int32
      X.allow_events @dpy, event_mode, time
    end

    # Turns off auto-repeat for the keyboard on the specified display.
    def auto_repeat_off : Int32
      X.auto_repeat_off @dpy
    end

    # Turns on auto-repeat for the keyboard on the specified display
    def auto_repeat_on : Int32
      X.auto_repeat_on
    end

    # Rings the bell on the keyboard.
    #
    # ###Arguments
    # - **percent** Specifies the volume for the bell, which can range from -100 to 100 inclusive.
    #
    # ###Description
    # The `bell` function rings the bell on the keyboard, if possible.
    # The specified volume is relative to the base volume for the keyboard.
    # If the value for the percent argument is not in the range -100 to 100 inclusive,
    # a **BadValue** error results. The volume at which the bell rings when the percent argument is nonnegative is:
    # ```
    # base - [(base * percent) / 100] + percent
    # ```
    # The volume at which the bell rings when the percent argument is negative is:
    # ```
    # base + [(base * percent) / 100]
    # ```
    # To change the base volume of the bell, use `change_keyboard_control`.
    #
    # `bell` can generate a **BadValue** error.
    #
    # ###Diagnostics
    # - **BadValue** Some numeric value falls outside the range of values
    # accepted by the request. Unless a specific range is specified for an argument,
    # the full range defined by the argument's type is accepted. Any argument
    # defined as a set of alternatives can generate this error.
    def bell(percent : Int32) : Int32
      X.bell @dpy, percent
    end

    # Within each bitmap unit, the left-most bit in the bitmap as displayed on
    # the screen is either the least-significant or most-significant bit in the unit.
    # This function can return **LSBFirst** or **MSBFirst**.
    def bitmap_bit_order : Int32
      X.bitmap_bit_order @dpy
    end

    # Each scanline must be padded to a multiple of bits returned by this function.
    def bitmap_pad : Int32
      X.bitmap_pad @dpy
    end

    # Returns the size of a bitmap's scanline unit in bits.
    # The scanline is calculated in multiples of this value.
    def bitmap_unit : Int32
      X.bitmap_pad @dpy
    end

    # Changes the specified dynamic parameters if the pointer is actively grabbed by the client.
    #
    # ###Arguments
    # - **event_mask** Specifies which pointer events are reported to the client.
    # The mask is the bitwise inclusive OR of the valid pointer event mask bits.
    # - **cursor** Specifies the cursor that is to be displayed or **None**.
    # - **time** Specifies the time. You can pass either a timestamp or **CurrentTime**.
    #
    # ###Description
    # The `change_active_pointer_grab` function changes the specified dynamic
    # parameters if the pointer is actively grabbed by the client and if the specified
    # time is no earlier than the last-pointer-grab time and no later than the
    # current X server time. This function has no effect on the passive parameters
    #  of a `grab_button`. The interpretation of event_mask and cursor is the
    # same as described in `grab_pointer`.
    # `change_active_pointer_grab` can generate **BadCursor** and **BadValue** errors.
    #
    # ###Diagnostics
    # - **BadCursor** A value for a Cursor argument does not name a defined Cursor.
    # - **BadValue** Some numeric value falls outside the range of values accepted by the request.
    # Unless a specific range is specified for an argument, the full range
    # defined by the argument's type is accepted. Any argument defined as a set
    # of alternatives can generate this error.
    #
    # ###See also
    # `allow_events`, `grab_button`, `grab_key`, `grab_keyboard`, `grab_pointer`, `ungrab_pointer`.
    def change_active_pointer_grab(event_mask : UInt32, cursor : X11::C::Cursor, time : X11::C::Time) : Int32
      X.change_active_pointer_grab @dpy, event_mask, cursor, time
    end

    # Changes the components specified by valuemask for the specified GC.
    #
    # ###Arguments
    # - **gc** Specifies the GC.
    # - **valuemask** Specifies which components in the GC are to be changed
    # using information in the specified values structure. This argument is
    # the bitwise inclusive OR of zero or more of the valid GC component mask bits.
    # - **values** Specifies any values as specified by the valuemask.
    #
    # ###Description
    # The `change_gc` function changes the components specified by valuemask for
    # the specified GC. The values argument contains the values to be set. The
    # values and restrictions are the same as for `create_gc`. Changing the
    # clip-mask overrides any previous `set_clip_rectangles` request on the context.
    # Changing the dash-offset or dash-list overrides any previous `set_dashes`
    # request on the context. The order in which components are verified and
    # altered is server-dependent. If an error is generated, a subset of the components may have been altered.
    # `change_gc` can generate **BadAlloc**, **BadFont**, **BadGC**, **BadMatch**,
    # **BadPixmap**, and **BadValue** errors.
    #
    # ###Diagnostics
    # - **BadAlloc** The server failed to allocate the requested source or server memory.
    # - **BadFont** A value for a font argument does not name a defined font (or, in some cases, GContext).
    # - **BadGC** A value for a GContext argument does not name a defined GContext.
    # - **BadMatch** An **InputOnly** window is used as a *Drawable*.
    # - **BadMatch** Some argument or pair of arguments has the correct type and
    # range but fails to match in some other way required by the request.
    # - **BadPixmap** A value for a Pixmap argument does not name a defined `Pixmap`.
    # - **BadValue** Some numeric value falls outside the range of values
    #  accepted by the request. Unless a specific range is specified for an argument,
    # the full range defined by the argument's type is accepted.
    # Any argument defined as a set of alternatives can generate this error.
    #
    # ###See also
    # `X11::all_planes` `copy_area`, `copy_gc`, `create_gc`, `X11::create_region`,
    # `draw_arc`, `draw_line`, `draw_rectangle`, `draw_text`, `fill_rectangle`,
    # `free_gc`, `g_context_from_gc`, `get_gc_values`, `query_best_size`,
    # `set_arc_mode`, `set_clip_origin`.
    def change_gc(gc : X11::C::X::GC, valuemask : UInt64, values : GCValues) : Int32
      X.change_gc @dpy, gc, valuemask. values.to_unsafe
    end

    # Controls the keyboard characteristics.
    #
    # ###Arguments
    # - **value_mask** Specifies which controls to change.
    # This mask is the bitwise inclusive OR of the valid control mask bits.
    # - **values** Specifies one value for each bit set to 1 in the mask.
    #
    # ###Description
    # `change_keyboard_control` function controls the keyboard characteristics
    # defined by the `KeyboardControl` object. The **value_mask** argument specifies which values are to be changed.
    #
    # `change_keyboard_control` can generate **BadMatch** and **BadValue** errors.
    #
    # ###Diagnostics
    # - **BadValue** Some numeric value falls outside the range of values accepted
    # by the request. Unless a specific range is specified for an argument, the
    # full range defined by the argument's type is accepted.
    # Any argument defined as a set of alternatives can generate this error.
    #
    # ###See also
    # `auto_repeat_off`, `auto_repeat_on`, `bell`, `change_keyboard_mapping`,
    # `keyboard_control`, `query_keymap`, `set_pointer_mapping`.
    def change_keyboard_control(value_mask : UInt64, values : KeyboardControl) : Int32
      X.change_keyboard_control @dpy, value_mask, values.to_unsafe
    end

    # Defines the symbols for the specified number of KeyCodes starting with first_keycode.
    #
    # ###Arguments
    # - **first_keycode** Specifies the first KeyCode that is to be changed.
    # - **keysyms_per_keycode** Specifies the number of KeySyms per KeyCode.
    # - **keysyms** Specifies an array of KeySyms.
    #
    # ###Description
    # The `change_keyboard_mapping` function defines the symbols for the
    # specified number of KeyCodes starting with first_keycode. The symbols for
    # KeyCodes outside this range remain unchanged. The number of elements in keysyms must be:
    # ```
    # kysyms.size * keysyms_per_keycode
    # ```
    # The specified first_keycode must be greater than or equal to min_keycode
    # returned by `display_keycodes`, or a **BadValue** error results.
    # In addition, the following expression must be less than or equal to
    # max_keycode as returned by `display_keycodes`, or a **BadValue** error results:
    # ```
    # first_keycode + keysyms.size - 1
    # ```
    # KeySym number N, counting from zero, for KeyCode K has the following index in keysyms, counting from zero:
    # ```
    # (K - first_keycode) * keysyms_per_keycode + N
    # ```
    # The specified keysyms_per_keycode can be chosen arbitrarily by the client
    # to be large enough to hold all desired symbols. A special KeySym value
    # of **NoSymbol** should be used to fill in unused elements for individual
    # KeyCodes. It is legal for **NoSymbol** to appear in nontrailing positions
    # of the effective list for a KeyCode. `change_keyboard_mapping` generates a **MappingNotify** event.
    #
    # There is no requirement that the X server interpret this mapping. It is merely stored for reading and writing by clients.
    #
    # `change_keyboard_mapping` can generate **BadAlloc** and **BadValue** errors.
    #
    # ###Diagnostics
    # - **BadAlloc** The server failed to allocate the requested source or server memory.
    # - **BadValue** Some numeric value falls outside the range of values
    # accepted by the request. Unless a specific range is specified for an argument,
    # the full range defined by the argument's type is accepted. Any argument defined as a set of alternatives can generate this error.
    #
    # ###See also
    # `ModifierKeymap::delete_entry`, `keycodes`, `X11::free`, `ModifierKeymap::finalize`,
    # `keyboard_mapping`, `modifier_mapping`, `ModifierKeymap::insert_entry`,
    # `ModifierKeymap::new`, `set_modifier_mapping`, `set_pointer_mapping`.
    def change_keyboard_mapping(first_keycode : Int32, keysyms_per_keycode : Int32, keysyms : Array(X11::C::KeySym)) : Int32
      X.change_keyboard_mapping @dpy, first_keycode, keysyms_per_keycode, keysyms.to_unsafe, keysyms.size
    end

    # Defines how the pointing device moves.
    #
    # ###Arguments
    # - **do_accel** Specifies a Boolean value that controls whether the values for the accel_numerator or accel_denominator are used.
    # - **do_threshold** Specifies a Boolean value that controls whether the value for the threshold is used.
    # - **accel_numerator** Specifies the numerator for the acceleration multiplier.
    # - **accel_denominator** Specifies the denominator for the acceleration multiplier.
    # - **threshold** Specifies the acceleration threshold.
    #
    # ###Description
    # The `change_pointer_control` function defines how the pointing device moves.
    # The acceleration, expressed as a fraction, is a multiplier for movement.
    # For example, specifying 3/1 means the pointer moves three times as fast as normal.
    # The fraction may be rounded arbitrarily by the X server. Acceleration only
    # takes effect if the pointer moves more than threshold pixels at once and only
    # applies to the amount beyond the value in the threshold argument. Setting
    # a value to \-1 restores the default. The values of the do_accel and do_threshold
    # arguments must be True for the pointer values to be set, or the parameters are unchanged.
    # Negative values (other than \-1) generate a BadValue error, as does a zero value for the accel_denominator argument.
    #
    # `change_pointer_control` can generate a `BadValue` error.
    #
    # ###Diagnostics
    # - **BadValue** Some numeric value falls outside the range of values accepted
    # by the request. Unless a specific range is specified for an argument,
    # the full range defined by the argument's type is accepted. Any argument defined as a set of alternatives can generate this error.
    #
    # ###See also
    # `pointer_control`.
    def change_pointer_control(do_accel : Bool, do_threshold : Bool, accel_numerator : Int32, accel_denominator : Int32, threshold : Int32) : Int32
      X.change_pointer_control @dpy, do_accel ? X::True : X::False, do_threshold ? X::True : X::False, accel_numerator, accel_denominator, threshold
    end

    # Alters the property for the specified window.
    #
    # ###Arguments
    # - **w** Specifies the window whose property you want to change.
    # - **property** Specifies the property name.
    # - **type** Specifies the type of the property. The X server does not
    # interpret the type but simply passes it back to an application that later calls `window_property`.
    # - **mode** Specifies the mode of the operation.
    # You can pass **PropModeReplace**, **PropModePrepend**, or **PropModeAppend**.
    # - **data** Specifies the property data.
    #
    # ###Description
    # The `change_property` function alters the property for the specified window
    # and causes the X server to generate a **PropertyNotify** event on that window.
    # `change_property` performs the following:
    # - If mode is **PropModeReplace**, `change_property` discards the previous property value and stores the new data.
    # - If mode is **PropModePrepend** or **PropModeAppend**, `change_property`
    # inserts the specified data before the beginning of the existing data or
    # onto the end of the existing data, respectively. The type and format must
    # match the existing property value, or a **BadMatch** error results.
    #
    # The lifetime of a property is not tied to the storing client.
    # Properties remain until explicitly deleted, until the window is destroyed,
    # or until the server resets. For a discussion of what happens when the
    # connection to the X server is closed, see section "X Server Connection Close Operations".
    # The maximum size of a property is server dependent and can vary dynamically
    # depending on the amount of memory the server has available.
    # (If there is insufficient space, a **BadAlloc** error results.)
    #
    # `change_property` can generate **BadAlloc**, **BadAtom**, **BadMatch**, **BadValue**, and **BadWindow** errors.
    #
    # ###Diagnostics
    # - **BadAlloc** The server failed to allocate the requested source or server memory.
    # - **BadAtom** A value for an Atom argument does not name a defined Atom.
    # - **BadMatch** An **InputOnly** window is used as a Drawable.
    # - **BadMatch** Some argument or pair of arguments has the correct type
    # and range but fails to match in some other way required by the request.
    # - **BadPixmap** A value for a Pixmap argument does not name a defined Pixmap.
    # - **BadValue** Some numeric value falls outside the range of values accepted
    # by the request. Unless a specific range is specified for an argument,
    # the full range defined by the argument's type is accepted. Any argument defined as a set of alternatives can generate this error.
    # - **BadWindow** A value for a Window argument does not name a defined Window.
    #
    # ###See also
    # `delete_property`, `window_property`, `properties`, `rotate_window_properties`.
    def change_property(w : X11::C::Window, property : Atom | X11::C::Atom, type : Atom | X11::C::Atom, mode : Int32, data : Bytes | Slice(Int16) | Slice(Int32)) : Int32
      format = case data
      in Bytes then 8
      in Slice(Int16) then 16
      in Slice(Int32) then 32
      end

      X.change_property @dpy, w, property.to_u64, type.to_u64, format, mode, data.to_unsafe.as(PChar), data.size
    end

    # Inserts or deletes the specified window from the client's save-set.
    #
    # ###Arguments
    # - **w** Specifies the window that you want to add to or delete from the client's save-set.
    # - **change_mode** Specifies the mode. You can pass **SetModeInsert** or **SetModeDelete**.
    #
    # ###Description
    # Depending on the specified mode, `change_save_set` either inserts or deletes
    # the specified window from the client's save-set. The specified window must
    # have been created by some other client, or a **BadMatch** error results.
    #
    # `change_save_set` can generate **BadMatch**, **BadValue**, and **BadWindow** errors.
    #
    # ###Diagnostics
    # - **BadMatch** An **InputOnly** window is used as a Drawable.
    # - **BadMatch** Some argument or pair of arguments has the correct type and
    # range but fails to match in some other way required by the request.
    # - **BadValue** Some numeric value falls outside the range of values accepted
    # by the request. Unless a specific range is specified for an argument,
    # the full range defined by the argument's type is accepted.
    # Any argument defined as a set of alternatives can generate this error.
    # - **BadWindow** A value for a Window argument does not name a defined Window.
    #
    # ###See also
    # `add_to_save_set`, `remove_from_save_set`, `reparent_window`.
    def change_save_set(w : X11::C::Window, change_mode : Int32) : Int32
      X.change_save_set @dpy, w, change_mode
    end

    # Changes the specified window attributes
    #
    # ###Arguments
    # - **w** Specifies the window.
    # - **valuemask** Specifies which window attributes are defined in the
    # attributes argument. This mask is the bitwise inclusive OR of the valid
    # attribute mask bits. If valuemask is zero, the attributes are ignored and
    # are not referenced. The values and restrictions are the same as for `create_window`.
    # - **attributes** Specifies the structure from which the values
    # (as specified by the value mask) are to be taken. The value mask should
    # have the appropriate bits set to indicate which attributes have been set in the structure (see "Window Attributes").
    #
    # ###Description
    # Depending on the valuemask, the `change_window_attributes` function uses
    # the window attributes in the `set_window_attributes` structure to change
    # the specified window attributes. Changing the background does not cause
    # the window contents to be changed. To repaint the window and its background,
    # use `clear_window`. Setting the border or changing the background such that
    # the border tile origin changes causes the border to be repainted. Changing
    # the background of a root window to **None** or **ParentRelative** restores
    # the default background pixmap. Changing the border of a root window to
    # **CopyFromParent** restores the default border pixmap. Changing the
    # win-gravity does not affect the current position of the window. Changing
    # the backing-store of an obscured window to **WhenMapped** or **Always**, or
    # changing the backing-planes, backing-pixel, or save-under of a mapped window
    # may have no immediate effect. Changing the colormap of a window (that is,
    # defining a new map, not changing the contents of the existing map) generates
    # a **ColormapNotify** event. Changing the colormap of a visible window may
    # have no immediate effect on the screen because the map may not be installed
    # (see `install_colormap`). Changing the cursor of a root window to **None**
    # restores the default cursor. Whenever possible, you are encouraged to share colormaps.
    #
    # Multiple clients can select input on the same window. Their event masks are maintained separately.
    # When an event is generated, it is reported to all interested clients.
    # However, only one client at a time can select for **SubstructureRedirectMask**,
    # **ResizeRedirectMask** and **ButtonPressMask**. If a client attempts to
    # select any of these event masks and some other client has already selected one,
    # a **BadAccess** error results. There is only one do-not-propagate-mask for a window, not one per client.
    #
    # `change_window_attributes` can generate **BadAccess**, **BadColor**,
    # **BadCursor**, **BadMatch**, **BadPixmap**, **BadValue**, and **BadWindow** errors.
    #
    # ###Diagnostics
    # - **BadAccess** A client attempted to free a color map entry that it did not already allocate.
    # - **BadAccess** A client attempted to store into a read-only color map entry.
    # - **BadColor** A value for a Colormap argument does not name a defined Colormap.
    # - **BadCursor** A value for a Cursor argument does not name a defined Cursor.
    # - **BadMatch** An **InputOnly** window is used as a Drawable.
    # - **BadMatch** Some argument or pair of arguments has the correct type and
    # range but fails to match in some other way required by the request.
    # - **BadPixmap** A value for a Pixmap argument does not name a defined Pixmap.
    # - **BadValue** Some numeric value falls outside the range of values accepted by the request.
    # Unless a specific range is specified for an argument, the full range defined
    # by the argument's type is accepted. Any argument defined as a set of alternatives can generate this error.
    # - **BadWindow** A value for a Window argument does not name a defined Window.
    #
    # ###See also
    # `configure_window`, `create_window`, `destroy_window`, `install_colormap`,
    # `map_window`, `raise_window`, `set_window_background`, `set_window_background_pixmap`,
    # `set_window_border`, `set_window_border_pixmap`, `set_window_colormap`, `unmap_window`.
    def change_window_attributes(w : X11::C::Window, valuemask : UInt64, attributes : SetWindowAttributes) : Int32
      X.change_window_attributes @dpy, w, valuemask, attributes.to_unsafe
    end

    # When the predicate procedure finds a match, returns the matched event.
    #
    # ###Arguments
    # - **predicate** Specifies the procedure that is to be called to determine if the next event in the queue matches what you want.
    # - **arg** Specifies the user-supplied argument that will be passed to the predicate procedure.
    #
    # ###Description
    # When the predicate procedure finds a match, `check_if_event` returns the matched event.
    # (This event is removed from the queue.) If the predicate procedure finds no match,
    # `check_if_event` returns **nil**, and the output buffer will have been flushed.
    # All earlier events stored in the queue are not discarded.
    #
    # ###See also
    # `if_event`, `next_event`, `peek_if_event`, `put_back_event`, `send_event`.
    def check_if_event(predicate : X11::C::X::PDisplay, X11::C::X::PEvent, X11::C::X::Pointer -> X11::C::Bool, arg : X11::C::X::Pointer) : Event?
      if X.check_if_event @dpy, out event_return, predicate, arg
        Event.from_xevent event_return
      else
        nil
      end
    end

    # Removes and returns the first event that matches the specified mask.
    #
    # ###Arguments
    # - **event_mask** Specifies the event mask.
    #
    # ###Description
    # The `check_mask_event` function searches the event queue and then any events
    # available on the server connection for the first event that matches the specified mask.
    # If it finds a match, `check_mask_event` removes that event, and returns it.
    # The other events stored in the queue are not discarded. If the event you
    # requested is not available, `check_mask_event` returns **nil**, and the output buffer will have been flushed.
    #
    # ###See also
    # `check_typed_event`, `check_typed_window_event`, `check_window_event`,
    # `if_event`, `mask_event`, `next_event`, `peek_event`, `put_back_event`,
    # `send_event`, `window_event`.
    def check_mask_event(event_mask : Int64) : Event?
      if X.check_mask_event @dpy, event_mask, out event_return
        Event.from_xevent event_return
      else
        nil
      end
    end

    # Removes and returns the first event that matches the specified type.
    #
    # ###Arguments
    # - **event_type** Specifies the event type to be compared.
    #
    # ###Description
    # The `check_typed_event` function searches the event queue and then any events
    #available on the server connection for the first event that matches the specified type.
    # If it finds a match, `check_typed_event` removes that event, and returns it.
    # The other events in the queue are not discarded. If the event is not available,
    # `check_typed_event` returns **nil**, and the output buffer will have been flushed.
    #
    # ###See also
    # `check_mask_event`, `check_typed_window_event`, `check_window_event`,
    # `if_event`, `mask_event`, `next_event`, `peek_event`, `put_back_event`,
    # `send_event`, `window_event`.
    def check_typed_event(event_type : Int32) : Event?
      if X.check_typed_event @dpy, event_type, out event_return
        Event.from_xevent event_return
      else
        nil
      end
    end

    # Removes and returns the first event that matches the specified window and type.
    #
    # ###Arguments
    # - **w** Specifies the window.
    # - **event_type** Specifies the event type to be compared.
    #
    # ###Description
    # The `check_typed_window_event` function searches the event queue and then
    # any events available on the server connection for the first event that matches
    # the specified type and window. If it finds a match, `check_typed_window_event`
    # removes the event from the queue, and returns it. The other events in the
    # queue are not discarded. If the event is not available, `check_typed_window_event`
    # returns **nil**, and the output buffer will have been flushed.
    #
    # ###See also
    # `check_mask_event`, `check_window_event`, `if_event`, `mask_event`,
    # `next_event`, `peek_event`, `put_back_event`, `send_event`, `window_event`.
    def check_typed_window_event(w : X11::C::Window, event_type : Int32) : Event?
      if X.check_typed_window_event @dpy, w, event_type, out event_return
        Event.from_xevent event_return
      else
        nil
      end
    end

    # Removes and returns the first event that matches the specified window and event mask.
    #
    # ###Arguments
    # - **w** Specifies the window whose events you are interested in.
    # - **event_mask** Specifies the event mask.
    #
    # ###Description
    # The `check_window_event` function searches the event queue and then the events
    # available on the server connection for the first event that matches the specified window and event mask.
    # If it finds a match, `check_window_event` removes that event, and returns it.
    # The other events stored in the queue are not discarded. If the event you
    # requested is not available, `check_window_event` returns **nil**,
    # and the output buffer will have been flushed.
    #
    # ###See also
    # `check_mask_event`, `check_typed_event`, `check_typed_window_event`,
    # `if_event`, `mask_event`, `next_event`, `peek_event`, `put_back_event`, `send_event`, `window_event`.
    def check_window_event(w : X11::C::Window, event_mask : Int64) : Event?
      if X.check_window_event @dpy, w, event_mask, out event_return
        Event.from_xevent event_return
      else
        nil
      end
    end

    # Circulates children of the specified window in the specified direction.
    #
    # ###Arguments
    # - **w** Specifies the window.
    # - **direction** Specifies the direction (up or down) that you want to
    # circulate the window. You can pass **RaiseLowest** or **LowerHighest**.
    #
    # ###Description
    # The `circulate_subwindows` function circulates children of the specified
    # window in the specified direction. If you specify **RaiseLowest**,
    # `circulate_subwindows` raises the lowest mapped child (if any) that is
    # occluded by another child to the top of the stack. If you specify
    # **LowerHighest**, `circulate_subwindows` lowers the highest mapped child
    # (if any) that occludes another child to the bottom of the stack.
    # Exposure processing is then performed on formerly obscured windows.
    # If some other client has selected **SubstructureRedirectMask** on the window,
    # the X server generates a **CirculateRequest** event, and no further
    # processing is performed. If a child is actually restacked,
    # the X server generates a **CirculateNotify** event.
    #
    # `circulate_subwindows` can generate **BadValue** and **BadWindow** errors.
    #
    # ###Diagnostics
    # - **BadValue** Some numeric value falls outside the range of values
    # accepted by the request. Unless a specific range is specified for an argument,
    # the full range defined by the argument's type is accepted.
    # Any argument defined as a set of alternatives can generate this error.
    # - **BadWindow** A value for a Window argument does not name a defined Window.
    #
    # ###See also
    # `change_window_attributes`, `circulate_subwindows_down`, `circulate_subwindows_up`,
    # `configure_window`, `create_window`, `destroy_window`, `lower_window`,
    # `map_window`, `raise_window`, `restack_windows`.
    def circulate_subwindows(w : X11::C::Window, direction : Int32) : Int32
      X.circulate_subwindows @dpy, w, direction
    end

    # Lowers the highest mapped child of the specified window that partially or completely occludes another child.
    #
    # ###Arguments
    # - **w** Specifies the window.
    #
    # ###Description
    # The `circulate_subwindows_down` function lowers the highest mapped child
    # of the specified window that partially or completely occludes another child.
    # Completely unobscured children are not affected. This is a convenience
    # function equivalent to `circulate_subwindows` with **LowerHighest** specified.
    #
    # `circulate_subwindows_down` can generate a **BadWindow** error.
    #
    # ###Diagnostics
    # - **BadWindow** A value for a Window argument does not name a defined Window.
    #
    # ###See also
    # `change_window_attributes`, `circulate_subwindows`, `circulate_subwindows_up`,
    # `configure_window`, `create_window`, `destroy_window`, `lower_window`,
    # `map_window`, `raise_window`, `restack_windows`.
    def circulate_subwindows_down(w : X11::C::Window) : Int32
      X.circulate_subwindows_down @dpy, w
    end

    # Raises the lowest mapped child of the specified window that is partially or completely occluded by another child.
    #
    # ###Arguments
    # - **w** Specifies the window.
    #
    # ###Description
    # The `circulate_subwindows_up` function raises the lowest mapped child of
    # the specified window that is partially or completely occluded by another child.
    # Completely unobscured children are not affected. This is a convenience
    # function equivalent to `circulate_subwindows` with **RaiseLowest** specified.
    #
    # `circulate_subwindows_up` can generate a **BadWindow** error.
    #
    # ###Diagnostics
    # - **BadWindow** A value for a Window argument does not name a defined Window.
    #
    # ###See also
    # `change_window_attributes`, `circulate_subwindows`, `circulate_subwindows_down`,
    # `configure_window`, `create_window`, `destroy_window`, `lower_window`,
    # `map_window`, `raise_window`, `restack_windows`.
    def circulate_subwindows_up(w : X11::C::Window) : Int32
      X.circulate_subwindows_up @dpy, w
    end

    # Paints a rectangular area in the specified window.
    #
    # ###Arguments
    # - **w** Specifies the window. and specify the upper-left corner of the rectangle
    # - **x**, **y** Specify the x and y coordinates, which are relative to the origin of the window.
    # - **width**, **height** Specify the width and height, which are the dimensions of the rectangle.
    # - **exposures** Specifies a Boolean value that indicates if **Expose** events are to be generated.
    #
    # ###Description
    # The `clear_area` function paints a rectangular area in the specified
    # window according to the specified dimensions with the window's background
    # pixel or pixmap. The subwindow-mode effectively is **ClipByChildren**.
    # If width is zero, it is replaced with the current width of the window minus x.
    # If height is zero, it is replaced with the current height of the window minus y.
    # If the window has a defined background tile, the rectangle clipped by any children
    # is filled with this tile. If the window has background **None**,
    # the contents of the window are not changed. In either case, if exposures
    # is True, one or more **Expose** events are generated for regions of the
    # rectangle that are either visible or are being retained in a backing store.
    # If you specify a window whose class is **InputOnly**, a **BadMatch** error results.
    #
    # `clear_area` can generate **BadMatch**, **BadValue**, and **BadWindow** errors.
    #
    # ###Diagnostics
    # - **BadMatch** An **InputOnly** window is used as a Drawable.
    # - **BadMatch** Some argument or pair of arguments has the correct type
    # and range but fails to match in some other way required by the request.
    # - **BadValue** Some numeric value falls outside the range of values
    # accepted by the request. Unless a specific range is specified for an argument,
    # the full range defined by the argument's type is accepted.
    # Any argument defined as a set of alternatives can generate this error.
    # - **BadWindow** A value for a Window argument does not name a defined Window.
    #
    # ###See also
    # `clear_area`, `copy_area`.
    def clear_area(w : X11::C::Window, x : Int32, y : Int32, width : UInt32, height : UInt32, exposures : Bool) : Int32
      X.clear_area @dpy, w, x, y, width, height, exposures ? X::True : X::False
    end

    # Clears the entire area in the specified window.
    #
    # ###Arguments
    # - **w** Specifies the window.
    #
    # ###Description
    # The `clear_window` function clears the entire area in the specified window
    # and is equivalent to:
    # ```
    # clear_area(w, 0, 0, 0, 0, false)
    # ```
    # If the window has a defined background tile, the rectangle is tiled with a
    # plane-mask of all ones and `copy` function. If the window has background
    # **None**, the contents of the window are not changed. If you specify a
    # window whose class is **InputOnly**, a **BadMatch** error results.
    #
    # `clear_window` can generate **BadMatch** and **BadWindow** errors.
    #
    # ###Diagnostics
    # - **BadMatch** An **InputOnly** window is used as a Drawable.
    # - **BadMatch** Some argument or pair of arguments has the correct type and
    # range but fails to match in some other way required by the request.
    # - **BadWindow** A value for a Window argument does not name a defined Window.
    #
    # ###See also
    # `clear_area`, `copy_area`.
    def clear_window(w : X11::C::Window) : Int32
      X.clear_window @dpy, w
    end

    # Reconfigures a window's size, position, border, and stacking order.
    #
    # ###Arguments
    # - **w** Specifies the window to be reconfigured.
    # - **value_mask** Specifies which values are to be set using information in
    # the values structure. This mask is the bitwise inclusive OR of the valid configure window values bits.
    # - **values** Specifies the `WindowChanges` structure.
    #
    # ###Description
    # The `configure_window` function uses the values specified in the `WindowChanges`
    # structure to reconfigure a window's size, position, border, and stacking order.
    # Values not specified are taken from the existing geometry of the window.
    #
    # If a sibling is specified without a stack_mode or if the window is not actually
    # a sibling, a **BadMatch** error results. Note that the computations for
    # **BottomIf**, **TopIf**, and **Opposite** are performed with respect to the
    # window's final geometry (as controlled by the other arguments passed to
    # `configure_window`), not its initial geometry. Any backing store contents
    # of the window, its inferiors, and other newly visible windows are either
    # discarded or changed to reflect the current screen contents (depending on the implementation).
    #
    # `configure_window` can generate **BadMatch**, **BadValue**, and **BadWindow** errors.
    #
    # ###Diagnostics
    # - **BadMatch** An **InputOnly** window is used as a *Drawable*.
    # - **BadMatch** Some argument or pair of arguments has the correct type and
    # range but fails to match in some other way required by the request.
    # - **BadValue** Some numeric value falls outside the range of values accepted
    # by the request. Unless a specific range is specified for an argument, the
    # full range defined by the argument's type is accepted. Any argument defined
    # as a set of alternatives can generate this error.
    # - **BadWindow** A value for a Window argument does not name a defined Window.
    #
    # ###See also
    # `change_window_attributes`, `create_window`, `destroy_window`, `map_window`,
    # `move_window`, `move_resize_window`, `raise_window`, `resize_window`,
    # `set_window_border_width`, `unmap_window`.
    def configure_window(w : X11::C::Window, value_mask : UInt32, values : WindowChanges) : Int32
      X.configure_window @dpy, w, value_mask, values.to_unsafe
    end

    # Returns a connection number for the specified display.
    # On a POSIX-conformant system, this is the file descriptor of the connection.
    def connection_number : Int32
      X.connection_number @dpy
    end

    # Requests that the specified selection be converted to the specified target type.
    #
    # ###Arguments
    # - **selection** Specifies the selection atom.
    # - **target** Specifies the target atom.
    # - **property** Specifies the property name. You also can pass **None**.
    # - **requestor** Specifies the requestor.
    # - **time** Specifies the time. You can pass either a timestamp or **CurrentTime**.
    #
    # ###Description
    # `convert_selection` requests that the specified selection be converted to the specified target type:
    # - If the specified selection has an owner, the X server sends a `SelectionRequest` event to that owner.
    # - If no owner for the specified selection exists, the X server generates a
    # `SelectionNotify` event to the requestor with property **None**.
    #
    # The arguments are passed on unchanged in either of the events.
    # There are two predefined selection atoms: PRIMARY and SECONDARY.
    #
    # convert_selection can generate **BadAtom** and **BadWindow** errors.
    #
    # ###Diagnostics
    # - **BadAtom** A value for an Atom argument does not name a defined Atom.
    # - **BadWindow** A value for a Window argument does not name a defined Window.
    #
    # ###See also
    # `selection_owner`, set_selection_owner`.
    def convert_selection(selection : Atom | X11::C::Atom, target : Atom | X11::C::Atom, property : Atom | X11::C::Atom, requestor : X11::C::Window, time : X11::C::Time) : Int32
      X.convert_selection @dpy, selection.to_u64, target.to_u64, property.to_u64, requestor, time
    end

    # Combines the specified rectangle of src with the specified rectangle of dest.
    #
    # ###Arguments
    # - **src**, **dest** Specify the source and destination rectangles to be combined.
    # - **gc** Specifies the GC.
    # - **src_x**, **src_y** Specify the x and y coordinates, which are relative
    # to the origin of the source rectangle and specify its upper-left corner.
    # - **width**, **height** Specify the width and height, which are the dimensions
    # of both the source and destination rectangles.
    # - **dest_x**, **dest_y** Specify the x and y coordinates, which are relative
    # to the origin of the destination rectangle and specify its upper-left corner
    #
    # ###Description
    # The `copy_area` function combines the specified rectangle of src with the
    # specified rectangle of dest. The drawables must have the same root and depth, or a **BadMatch** error results.
    #
    # If regions of the source rectangle are obscured and have not been retained
    # in backing store or if regions outside the boundaries of the source drawable
    # are specified, those regions are not copied. Instead, the following occurs
    # on all corresponding destination regions that are either visible or are retained
    # in backing store. If the destination is a window with a background other
    # than **None**, corresponding regions of the destination are tiled with that
    # background. Regardless of tiling or whether the destination is a window or a pixmap,
    # if graphics-exposures is **true**, then `GraphicsExpose` events for all
    # corresponding destination regions are generated. If graphics-exposures is
    # **true** but no `GraphicsExpose` events are generated, a **NoExpose** event
    # is generated. Note that by default graphics-exposures is **true** in new GCs.
    #
    # This function uses these GC components: function, plane-mask, subwindow-mode,
    # graphics-exposure, clip-x-origin, clip-y-origin, and clip-mask.
    #
    # `copy_area` can generate **BadDrawable**, **BadGC**, and **BadMatch** errors.
    #
    # ###Diagnostics
    # - **BadDrawable** A value for a *Drawable* argument does not name a defined *Window* or *Pixmap*.
    # - **BadGC** A value for a `GContext` argument does not name a defined `GContext`.
    # - **BadMatch** An **InputOnly** window is used as a *Drawable*.
    # - **BadMatch** Some argument or pair of arguments has the correct type and
    # range but fails to match in some other way required by the request.
    #
    # ###See also
    # `clear_area`, `copy_plane`.
    def copy_area(src : X11::C::Drawable, dest : X11::C::Drawable, gc : X11::C::C::GC, src_x : Int32, src_y : Int32, width : UInt32, height : UInt32, dest_x : Int32, dest_y : Int32) : Int32
      X.copy_area @dpy, src, dest, gc, src_x, src_y, width, height, dest_x, dest_y
    end

    # Copies the specified components from the source GC to the destination GC
    #
    # ###Arguments
    # - **src** Specifies the components of the source GC.
    # - **valuemask** Specifies which components in the GC are to be copied to
    # the destination GC. This argument is the bitwise inclusive OR of zero or more of the valid GC component mask bits.
    # - **dest** Specifies the destination GC.
    #
    # ###Description
    # The `copy_gc` function copies the specified components from the source GC
    # to the destination GC. The source and destination GCs must have the same
    # root and depth, or a **BadMatch** error results. The valuemask
    # specifies which component to copy, as for `create_gc`.
    #
    # `copy_gc` can generate **BadAlloc**, **BadGC**, and **BadMatch** errors.
    #
    # ###Diagnostics
    # - **BadAlloc** The server failed to allocate the requested source or server memory.
    # - **BadGC** A value for a `GContext` argument does not name a defined `GContext`.
    # - **BadMatch** An **InputOnly** window is used as a *Drawable*.
    # - **BadMatch** Some argument or pair of arguments has the correct type and
    # range but fails to match in some other way required by the request.
    #
    # ###See also
    # `X11::all_planes`, `change_gc`, `copy_area`, `create_gc`, `X11::create_region`,
    # `draw_arc`, `draw_line`, `draw_rectangle`, `draw_text`, `fill_rectangle`,
    # `free_gc`, `X11::g_context_from_gc`, `gc_values`, `query_best_size`, `set_arc_mode`, `set_clip_origin`.
    def copy_gc(src : X11::C::X::GC, valuemask : UInt64, dest : X11::C::X::GC) : Int32
      X.copy_gc @dpy, src, valuemask, dest
    end

    # Uses a single bit plane of the specified source rectangle combined with the specified GC to modify the specified rectangle of dest.
    #
    # ###Arguments
    # - **src**, **dest** Specify the source and destination rectangles to be combined.
    # - **gc** Specifies the GC.
    # - **src_x**, **src_y** Specify the x and y coordinates, which are relative
    # to the origin of the source rectangle and specify its upper-left corner.
    # - **width**, **height** Specify the width and height, which are the dimensions
    # of both the source and destination rectangles.
    # - **dest_x**, **dest_y** Specify the x and y coordinates, which are relative
    # to the origin of the destination rectangle and specify its upper-left corner.
    # - **plane** Specifies the bit plane. You must set exactly one bit to 1.
    #
    # ###Description
    # The `copy_plane` function uses a single bit plane of the specified source
    # rectangle combined with the specified GC to modify the specified rectangle of dest.
    # The drawables must have the same root but need not have the same depth.
    # If the drawables do not have the same root, a BadMatch error results.
    # If plane does not have exactly one bit set to 1 and the value of plane is
    # not less than 2<sup>**n**</sup>, where **n** is the depth of src, a **BadValue** error results.
    #
    # Effectively, `copy_plane` forms a pixmap of the same depth as the rectangle
    # of dest and with a size specified by the source region. It uses the
    # foreground/background pixels in the GC (foreground everywhere the bit plane
    # in src contains a bit set to 1, background everywhere the bit plane in src
    # contains a bit set to 0) and the equivalent of a **CopyArea** protocol request
    # is performed with all the same exposure semantics. This can also be thought
    # of as using the specified region of the source bit plane as a stipple with a
    # fill-style of **FillOpaqueStippled** for filling a rectangular area of the destination.
    #
    # This function uses these GC components: function, plane-mask, foreground,
    # background, subwindow-mode, graphics-exposures, clip-x-origin, clip-y-origin, and clip-mask.
    #
    # `copy_plane` can generate **BadDrawable**, **BadGC**, **BadMatch**, and **BadValue** errors.
    #
    # ###Diagnostics
    # - **BadDrawable** A value for a *Drawable* argument does not name a defined *Window* or *Pixmap*.
    # - **BadGC** A value for a `GContext` argument does not name a defined `GContext`.
    # - **BadMatch** An **InputOnly** window is used as a *Drawable*.
    # - **BadMatch** Some argument or pair of arguments has the correct type and
    # range but fails to match in some other way required by the request.
    # - **BadValue** Some numeric value falls outside the range of values accepted
    # by the request. Unless a specific range is specified for an argument, the
    # full range defined by the argument's type is accepted. Any argument defined
    # as a set of alternatives can generate this error.
    #
    # ###See also
    # `copy_area`, `clear_area`.
    def copy_plane(src : X11::C::Drawable, dest : X11::C::Drawable, gc : X11::C::X::GC, src_x : Int32, src_y : Int32, width : UInt32, height : UInt32, dest_x : Int32, dest_y : Int32, plane : UInt64) : Int32
      X.copy_plane @dpy, src, dest, gc, src_x, src_y, width, height, dest_x, dest_y, plane
    end

    # Returns the depth (number of planes) of the default root window for the specified screen. Other depths may also be supported on this screen.
    #
    # ###Arguments
    # - **screen_number** Specifies the appropriate screen number on the host server.
    def default_depth(screen_number : Int32) : Int32
      X.default_depth @dpy, screen_number
    end

    # Returns the default screen number.
    def default_screen_number : Int32
      X.default_screen @dpy
    end

    # Defines a cursor.
    #
    # ###Arguments
    # - **w** Specifies the window.
    # - **cursor** Specifies the cursor that is to be displayed or **None**.
    #
    # ###Description
    # If a cursor is set, it will be used when the pointer is in the window.
    # If the cursor is **None**, it is equivalent to `undefine_cursor`.
    #
    # `define_cursor` can generate **BadCursor** and **BadWindow** errors.
    #
    # ###Diagnostics
    # - **BadCursor** A value for a *Cursor* argument does not name a defined *Cursor*.
    # - **BadWindow** A value for a *Window* argument does not name a defined *Window*.
    #
    # ###See also
    # `create_font_cursor`, `recolor_cursor`, `undefine_cursor`.
    def define_cursor(w : X11::C::Window, cursor : X11::C::Cursor) : Int32
      X.define_cursor @dpy, w, cursor
    end

    # Deletes the specified property.
    #
    # ###Arguments
    # - **w** Specifies the window whose property you want to delete.
    # - **property** Specifies the property name.
    #
    # ###Description
    # The `delete_property` function deletes the specified property only if the
    # property was defined on the specified window and causes the X server to
    # generate a `PropertyNotify` event on the window unless the property does not exist.
    #
    # `delete_property` can generate **BadAtom** and **BadWindow** errors.
    #
    # ###Diagnostics
    # - **BadAtom** A value for an Atom argument does not name a defined Atom.
    # - **BadWindow** A value for a Window argument does not name a defined Window.
    #
    # ###See also
    # `change_property`, `window_property`, `properties`, `rotate_window_properties`.
    def delete_property(w : X11::C::Window, property : Atom | X11::C::Atom) : Int32
      X.delete_property @dpy, w, property.to_u64
    end

    # Destroys the specified window as well as all of its subwindows.
    #
    # ###Arguments
    # - **w** Specifies the window.
    #
    # ###Description
    # The `destroy_window` function destroys the specified window as well as all
    # of its subwindows and causes the X server to generate a `DestroyNotify` event
    # for each window. The window should never be referenced again. If the window
    # specified by the w argument is mapped, it is unmapped automatically. The
    # ordering of the `DestroyNotify` events is such that for any given window
    # being destroyed, `DestroyNotify` is generated on any inferiors of the window
    # before being generated on the window itself. The ordering among siblings
    # and across subhierarchies is not otherwise constrained. If the window you
    # specified is a root window, no windows are destroyed. Destroying a mapped
    # window will generate `Expose` events on other windows that were obscured by the window being destroyed.
    #
    # `destroy_window` can generate a **BadWindow** error.
    #
    # ###Diagnostics
    # - **BadWindow** A value for a *Window* argument does not name a defined *Window*.
    #
    # ###See also
    # `change_window_attributes`, `configure_window`, `create_window`, `destroy_subwindows`,
    # `map_window`, `raise_window`, `unmap_window`.
    def destroy_window(w : X11::C::Window) : Int32
      X.destroy_window @dpy, w
    end

    # Destroys all inferior windows of the specified window, in bottom-to-top stacking order.
    #
    # ###Arguments
    # - **w** Specifies the window.
    #
    # ###Description
    # The `destroy_subwindows` function destroys all inferior windows of the
    # specified window, in bottom-to-top stacking order. It causes the X server
    # to generate a `DestroyNotify` event for each window. If any mapped subwindows
    # were actually destroyed, `destroy_subwindows` causes the X server to generate
    # `Expose` events on the specified window. This is much more efficient than
    # deleting many windows one at a time because much of the work need be
    # performed only once for all of the windows, rather than for each window.
    # The subwindows should never be referenced again.
    #
    # `destroy_subwindows` can generate a **BadWindow** error.
    #
    # ###Diagnostics
    # - **BadWindow** A value for a *Window* argument does not name a defined *Window*.
    #
    # ###See also
    # `change_window_attributes`, `configure_window`, `create_window`,
    # `destroy_window`, `map_window`,  `raise_window`, `unmap_window`.
    def destroy_subwindows(w : X11::C::Window) : Int32
      X.destroy_subwindows @dpy, w
    end

    # Disables the use of the access control list at each connection setup.
    #
    # ###Description
    # The `disable_access_control` function disables the use of the access control list at each connection setup.
    #
    # `disable_access_control` can generate a **BadAccess** error.
    #
    # ###Diagnostics
    # - **BadAccess** A client attempted to free a color map entry that it did not already allocate.
    # - **BadAccess** A client attempted to store into a read-only color map entry.
    #
    # ###See also
    # `add_host`, `add_hosts`, `enable_access_control`, `X11::free`, `hosts`,
    # `remove_host`, `remove_hosts`, `set_access_control`.
    def disable_access_control : Int32
      X.disable_access_control @dpy
    end

    # Returns the number of entries in the default colormap.
    #
    # ###Arguments
    # - **screen_number** Specifies the appropriate screen number on the host server.
    def cells(screen_number : Int32) : Int32
      X.display_cells @dpy, screen_number
    end

    # Returns an integer that describes the height of the screen in pixels.
    #
    # ###Arguments
    # - **screen_number** Specifies the appropriate screen number on the host server.
    def height(screen_number : Int32) : Int32
      X.display_height @dpy, screen_number
    end

    # Returns the height of the specified screen in millimeters.
    #
    # ###Arguments
    # - **screen_number** Specifies the appropriate screen number on the host server.
    def height_mm(screen_number : Int32) : Int32
      X.display_height_mm @dpy, screen_number
    end

    # Returns the min-keycodes and max-keycodes supported by the specified display.
    #
    # ###Return
    # - **min_keycodes** Returns the minimum number of KeyCodes.
    # - **max_keycodes** Returns the maximum number of KeyCodes.
    #
    # ###Description
    # Then `keycodes` function returns the min-keycodes and max-keycodes supported
    # by the specified display. The minimum number of KeyCodes returned is never
    # less than 8, and the maximum number of KeyCodes returned is never greater
    # than 255. Not all KeyCodes in this range are required to have corresponding keys.
    #
    # ###See also
    # `change_keyboard_mapping`, `ModifierKeymap::delete_entry`, `X11::free`,
    # `ModifierKeymap::finalize`, `keyboard_mapping`, `modifier_mapping`,
    # `ModifierKeymap::insert_entry`, `ModifierKeymap::new`,
    # `set_modifier_mapping`, `set_pointer_mapping`.
    def keycodes : NamedTuple{min_keycodes : Int32, max_keycode : Int32, res : Int32}
      res = X.display_keycodes @dpy, out min, out max
      {min_keycodes: min, max_keycodes: max, result: res}
    end

    # Returns the depth of the root window of the specified screen.
    #
    # ###Arguments
    # - **screen_number** Specifies the appropriate screen number on the host server.
    def planes(screen_number : Int32) : Int32
      X.display_planes @dpy, screen_number
    end

    # Returns the width of the screen in pixels.
    #
    # ###Arguments
    # - **screen_number** Specifies the appropriate screen number on the host server.
    def width(screen_number : Int32) : Int32
      X.display_width @dpy, screen_number
    end

    # Returns the width of the specified screen in millimeters.
    #
    # ###Arguments
    # - **screen_number** Specifies the appropriate screen number on the host server.
    def width_mm(screen_number : Int32) : Int32
      X.display_width_mm @dpy, screen_number
    end

    # Draws a single circular or elliptical arc.
    #
    # ###Arguments
    # - **d** Specifies the drawable.
    # - **gc** Specifies the GC.
    # - **x**, **y** Specify the x and y coordinates, which are relative to the
    # origin of the drawable and specify the upper-left corner of the bounding rectangle.
    # - **width**, **height** Specify the width and height, which are the major and minor axes of the arc.
    # - **angle1** Specifies the start of the arc relative to the three-o'clock position from the center, in units of degrees * 64.
    # - **angle2** Specifies the path and extent of the arc relative to the start of the arc, in units of degrees * 64.
    #
    # ###Description
    # `draw_arc` draws a single circular or elliptical arc. The arc is specified
    # by a rectangle and two angles. The center of the circle or ellipse is the
    # center of the rectangle, and the major and minor axes are specified by the
    # width and height. Positive angles indicate counterclockwise motion, and negative
    # angles indicate clockwise motion. If the magnitude of angle2 is greater
    # than 360 degrees, `draw_arc` truncates it to 360 degrees.
    #
    # For an arc specified as *[ x, y, width, height, angle1, angle2 ]*, the origin
    # of the major and minor axes is at *[ x + width / 2 , y + height / 2 ]*,
    # and the infinitely thin path describing the entire circle or ellipse intersects
    # the horizontal axis at *[ x, y + height / 2 ]* and *[ x + width , y + height / 2 ]*
    # and intersects the vertical axis at *[ x + width / 2, y ]* and *[ x + width / 2, y + height ]*.
    # These coordinates can be fractional and so are not truncated to discrete coordinates.
    # The path should be defined by the ideal mathematical path. For a wide line
    # with line-width lw, the bounding outlines for filling are given by the two
    # infinitely thin paths consisting of all points whose perpendicular distance
    # from the path of the circle/ellipse is equal to lw/2 (which may be a fractional value).
    # The cap-style and join-style are applied the same as for a line corresponding to the tangent of the circle/ellipse at the endpoint.
    #
    # For an arc specified as *[ x, y, width, height, angle1, angle2 ]*, the
    # angles must be specified in the effectively skewed coordinate system of the
    # ellipse (for a circle, the angles and coordinate systems are identical).
    # The relationship between these angles and angles expressed in the normal
    # coordinate system of the screen (as measured with a protractor) is as follows:
    # ```
    # skewed-angle = atan ( tan ( normal-angle ) * width / height ) + adjust
    # ```
    # The skewed-angle and normal-angle are expressed in radians (rather than
    # in degrees scaled by 64) in the range *[ 0, 2 pi ]* and where atan returns
    # a value in the range *[ -pi / 2 , pi / 2 ]* and adjust is:
    # -  0 for normal-angle in the range *[ 0, pi / 2 ]*
    # - pi for normal-angle in the range *[ pi / 2 , 3 pi / 2 ]*
    # - 2 pi for normal-angle in the range *[ 3 pi / 2 , 2 pi ]*
    # For any given arc, `draw_arc` does not draw a pixel more than once. If
    # two arcs join correctly and if the line-width is greater than zero and the
    # arcs intersect, `draw_arc` does not draw a pixel more than once. Otherwise,
    # the intersecting pixels of intersecting arcs are drawn multiple times.
    # Specifying an arc with one endpoint and a clockwise extent draws the same
    # pixels as specifying the other endpoint and an equivalent counterclockwise extent, except as it affects joins.
    #
    # If the last point in one arc coincides with the first point in the following arc,
    # the two arcs will join correctly. If the first point in the first arc coincides
    # with the last point in the last arc, the two arcs will join correctly. By specifying
    # one axis to be zero, a horizontal or vertical line can be drawn. Angles are computed
    # based solely on the coordinate system and ignore the aspect ratio.
    #
    # This function uses these GC components: function, plane-mask, line-width,
    # line-style, cap-style, join-style, fill-style, subwindow-mode, clip-x-origin,
    # clip-y-origin, and clip-mask. It also uses these GC mode-dependent components:
    # foreground, background, tile, stipple, tile-stipple-x-origin, tile-stipple-y-origin, dash-offset, and dash-list.
    #
    # `draw_arc` can generate **BadDrawable**, **BadGC**, and **BadMatch** errors.
    #
    # ###Diagnostics
    # - **BadDrawable** A value for a *Drawable* argument does not name a defined *Window* or *Pixmap*.
    # - **BadGC** A value for a `GContext` argument does not name a defined `GContext`.
    # - **BadMatch** An **InputOnly** window is used as a *Drawable*.
    # - **BadMatch** Some argument or pair of arguments has the correct type and
    # range but fails to match in some other way required by the request.
    #
    # ###See also
    # `draw_arc`, `draw_rectangle`, `draw_point`.
    def draw_arc(d : X11::C::Drawable, gc : X11::C::X::GC, x : Int32, y : Int32, width : UInt32, height : UInt32, angle1 : Int32, angle2 : Int32) : Int32
      X.draw_arc @dpy, d, gc, x, y, width, height, angle1, angle2
    end

    # Draws multiple circular or elliptical arcs.
    #
    # ###Arguments
    # - **d** Specifies the drawable.
    # - **gc** Specifies the GC.
    # - **arcs** Specifies an array of arcs.
    # - **narcs** Specifies the number of arcs in the array.
    #
    # ###Description
    # `draw_arcs` draws multiple circular or elliptical arcs. Each arc is specified
    # by a rectangle and two angles. The center of the circle or ellipse is the
    # center of the rectangle, and the major and minor axes are specified by the
    # width and height. Positive angles indicate counterclockwise motion, and negative
    # angles indicate clockwise motion. If the magnitude of angle2 is greater than 360 degrees,
    # `draw_arcs` truncates it to 360 degrees.
    #
    # For an arc specified as *[ x, y, width, height, angle1, angle2 ]*, the origin
    # of the major and minor axes is at *[ x + width / 2 , y + height / 2 ]*,
    # and the infinitely thin path describing the entire circle or ellipse intersects
    # the horizontal axis at *[ x, y + height / 2 ]* and *[ x + width , y + height / 2 ]*
    # and intersects the vertical axis at *[ x + width / 2, y ]* and *[ x + width / 2, y + height ]*.
    # These coordinates can be fractional and so are not truncated to discrete coordinates.
    # The path should be defined by the ideal mathematical path. For a wide line
    # with line-width lw, the bounding outlines for filling are given by the two
    # infinitely thin paths consisting of all points whose perpendicular distance
    # from the path of the circle/ellipse is equal to lw/2 (which may be a fractional value).
    # The cap-style and join-style are applied the same as for a line
    # corresponding to the tangent of the circle/ellipse at the endpoint.
    #
    # For an arc specified as *[ x, y, width, height, angle1, angle2 ]*, the
    # angles must be specified in the effectively skewed coordinate system of the
    # ellipse (for a circle, the angles and coordinate systems are identical).
    # The relationship between these angles and angles expressed in the normal
    # coordinate system of the screen (as measured with a protractor) is as follows:
    # ```
    # skewed-angle = atan ( tan ( normal-angle ) * width / height ) + adjust
    # ```
    # The skewed-angle and normal-angle are expressed in radians (rather than in
    # degrees scaled by 64) in the range *[ 0, 2 pi ]* and where atan returns a
    # value in the range *[ -pi / 2 , pi / 2 ]* and adjust is:
    # - 0 for normal-angle in the range *[ 0, pi / 2 ]*
    # - pi for normal-angle in the range *[ pi / 2 , 3 pi / 2 ]*
    # - 2 pi for normal-angle in the range *[ 3 pi / 2 , 2 pi ]*
    #
    # For any given arc, `draw_arcs` does not draw a pixel more than once.
    # If two arcs join correctly and if the line-width is greater than zero and
    # the arcs intersect, `draw_arc` does not draw a pixel more than once.
    # Otherwise, the intersecting pixels of intersecting arcs are drawn multiple
    # times. Specifying an arc with one endpoint and a clockwise extent draws the
    # same pixels as specifying the other endpoint and an equivalent
    # counterclockwise extent, except as it affects joins.
    #
    # If the last point in one arc coincides with the first point in the
    # following arc, the two arcs will join correctly. If the first point in the
    # first arc coincides with the last point in the last arc, the two arcs will
    # join correctly. By specifying one axis to be zero, a horizontal or vertical
    # line can be drawn. Angles are computed based solely on
    # the coordinate system and ignore the aspect ratio.
    #
    # This function uses these GC components: function, plane-mask, line-width,
    # line-style, cap-style, join-style, fill-style, subwindow-mode, clip-x-origin,
    # clip-y-origin, and clip-mask. It also uses these GC mode-dependent components:
    # foreground, background, tile, stipple, tile-stipple-x-origin,
    # tile-stipple-y-origin, dash-offset, and dash-list.
    #
    # `draw_arcs` can generate **BadDrawable**, **BadGC**, and **BadMatch** errors.
    #
    # ###Diagnostics
    # - **BadDrawable** A value for a *Drawable* argument does not name a defined *Window* or *Pixmap*.
    # - **BadGC** A value for a `GContext` argument does not name a defined `GContext`.
    # - **BadMatch** An **InputOnly** window is used as a *Drawable*.
    # - **BadMatch** Some argument or pair of arguments has the correct type and
    # range but fails to match in some other way required by the request.
    #
    # ###See also
    # `draw_arc`, `draw_rectangle`, `draw_point`.
    def draw_arcs(d : X11::C::Drawable, gc : X11::C::X::GC, arcs : Array(Arc)) : Int32
      X.draw_arcs @dpy, d, gc, arcs.to_unsafe.as(X11::C::X::PArc), arcs.size
    end

    # Paints text with the foreground pixel.
    #
    # ###Arguments
    # - **d** Specifies the drawable.
    # - **gc** Specifies the GC.
    # - **x**, **y** Specify the x and y coordinates, which are relative to the
    # origin of the specified drawable and define the origin of the first character.
    # - **string** Specifies the character string.
    # - **length** Specifies the number of characters in the string argument.
    #
    # ###Description
    # This function uses both the foreground and background pixels of the GC in the destination.
    # The effect is first to fill a destination rectangle with the background pixel
    # defined in the GC and then to paint the text with the foreground pixel.
    # The upper-left corner of the filled rectangle is at:
    # ```
    # [x, y - font-ascent]
    # ```
    # The width is:
    # ```
    # overall-width
    # ```
    # The height is:
    # ```
    # font-ascent + font-descent
    # ```
    # The overall-width, font-ascent, and font-descent are as would be returned
    # by `query_text_extents` using gc and string. The function and fill-style
    # defined in the GC are ignored for these functions. The effective function
    # is **GXcopy**, and the effective fill-style is **FillSolid**.
    #
    # For fonts defined with 2-byte matrix indexing and used with `draw_image_string`,
    # each byte is used as a byte2 with a byte1 of zero.
    #
    # The function uses these GC components: plane-mask, foreground, background,
    # font, subwindow-mode, clip-x-origin, clip-y-origin, and clip-mask.
    #
    # `draw_image_string` can generate **BadDrawable**, **BadGC**, and **BadMatch** errors.
    #
    # ###Diagnostics
    # - **BadDrawable** A value for a *Drawable* argument does not name a defined *Window* or *Pixmap*.
    # - **BadGC** A value for a `GContext` argument does not name a defined `GContext`.
    # - **BadMatch** An **InputOnly** window is used as a *Drawable*.
    # - **BadMatch** Some argument or pair of arguments has the correct type and
    # range but fails to match in some other way required by the request.
    #
    # ###See also
    # `draw_image_string_16`, `draw_string`, `draw_text`, `load_font`, `text_extents`.
    def draw_image_string(d : X11::C::Drawable, gc : X11::C::X::GC, x : Int32, y : Int32, string : String) : Int32
      X.draw_image_string @dpy, d, gc, x, y, string.to_unsafe, string.size
    end

    # Similar to `draw_image_string` except that it uses 2-byte or 16-bit characters.
    #
    # ###Arguments
    # - **d** Specifies the drawable.
    # - **gc** Specifies the GC.
    # - **x**, **y** Specify the x and y coordinates, which are relative to the
    # origin of the specified drawable and define the origin of the first character.
    # - **string** Specifies the character string.
    #
    # ###Description
    # The `draw_image_string_16` function is similar to `draw_image_string` except
    # that it uses 2-byte or 16-bit characters. Both functions also use both the
    # foreground and background pixels of the GC in the destination.
    #
    # The effect is first to fill a destination rectangle with the background pixel
    # defined in the GC and then to paint the text with the foreground pixel.
    # The upper-left corner of the filled rectangle is at:
    # ```
    # [x, y - font-ascent]
    # ```
    # The width is:
    # ```
    # overall-width
    # ```
    # The height is:
    # ```
    # font-ascent + font-descent
    # ```
    # The overall-width, font-ascent, and font-descent are as would be returned
    # by `query_text_extents` using gc and string. The function and fill-style
    # defined in the GC are ignored for these functions. The effective function
    # is **GXcopy**, and the effective fill-style is **FillSolid**.
    #
    # Both functions use these GC components: plane-mask, foreground, background,
    # font, subwindow-mode, clip-x-origin, clip-y-origin, and clip-mask.
    #
    # `draw_image_string_16` can generate **BadDrawable**, **BadGC**, and **BadMatch** errors.
    #
    # ###Diagnostics
    # - **BadDrawable** A value for a *Drawable* argument does not name a defined *Window* or *Pixmap*.
    # - **BadGC** A value for a `GContext` argument does not name a defined `GContext`.
    # - **BadMatch** An **InputOnly** window is used as a *Drawable*.
    # - **BadMatch** Some argument or pair of arguments has the correct type and
    # range but fails to match in some other way required by the request.
    #
    # ###See also
    # `draw_image_string`, `draw_string`, `draw_text`, `load_font`, `text_extents`.
    def draw_image_string_16(d : X11::C::Drawable, gc : X11::C::X::GC, x : Int32, y : Int32, string : Array(X11::C::X::PChar2b)) : Int32
      X.draw_image_string_16 @dpy, d, gc, x, y, string.to_unsafe, string.size
    end

    # Draws a line between the specified set of points (x1, y1) and (x2, y2).
    #
    # ###Arguments
    # - **d** Specifies the drawable.
    # - **gc** Specifies the GC.
    # - **x1**, **y1**, **x2**, **y2** Specify the points (x1, y1) and (x2, y2) to be connected.
    #
    # ###Description
    # The `draw_line` function uses the components of the specified GC to draw a
    # line between the specified set of points (x1, y1) and (x2, y2). It does not
    # perform joining at coincident endpoints. For any given line, `draw_line`
    # does not draw a pixel more than once. If lines intersect, the intersecting pixels are drawn multiple times.
    #
    # `draw_line` use these GC components: function, plane-mask, line-width,
    # line-style, cap-style, fill-style, subwindow-mode, clip-x-origin, clip-y-origin,
    # and clip-mask. `draw_line` also uses these GC mode-dependent components:
    # foreground, background, tile, stipple, tile-stipple-x-origin, tile-stipple-y-origin, dash-offset, and dash-list.
    #
    # `draw_line`, can generate **BadDrawable**, **BadGC**, and **BadMatch** errors.
    #
    # ###Diagnostics
    # - **BadDrawable** A value for a *Drawable* argument does not name a defined *Window* or *Pixmap*.
    # - **BadGC** A value for a `GContext` argument does not name a defined `GContext`.
    # - **BadMatch** An **InputOnly** window is used as a *Drawable*.
    # - **BadMatch** Some argument or pair of arguments has the correct type and
    # range but fails to match in some other way required by the request.
    #
    # ###See also
    # `draw_arc`, `draw_lines`, `draw_point`, `draw_rectangle`, `draw_segments`.
    def draw_line(d : X11::C::Drawable, gc : X11::C::X::GC, x1 : Int32, y1 : Int32, x2 : Int32, y2 : Int32) : Int32
      X.draw_line @dpy, d, gc, x1, y1, x2, y2
    end

    # Draws lines between each pair of *points* array.
    #
    # ###Arguments
    # - **d** Specifies the drawable.
    # - **gc** Specifies the GC.
    # - **points** Specifies an array of points.
    # - **mode** Specifies the coordinate mode. You can pass **CoordModeOrigin** or **CoordModePrevious**.
    #
    # ###Description
    # The `draw_lines` function uses the components of the specified GC to draw
    # *points.size - 1* lines between each pair of points (point[i], point[i+1])
    # in the array of `Point` structures. It draws the lines in the order listed in the array.
    # The lines join correctly at all intermediate points, and if the first and
    # last points coincide, the first and last lines also join correctly. For
    # any given line, `draw_lines` does not draw a pixel more than once. If thin
    # (zero line-width) lines intersect, the intersecting pixels are drawn multiple times.
    # If wide lines intersect, the intersecting pixels are drawn only once, as though
    # the entire **PolyLine** protocol request were a single, filled shape.
    # **CoordModeOrigin** treats all coordinates as relative to the origin, and
    # **CoordModePrevious** treats all coordinates after the first as relative to the previous point.
    #
    # `draw_lines` use these GC components: function, plane-mask, line-width,
    # line-style, cap-style, join-style, fill-style, subwindow-mode, clip-x-origin,
    # clip-y-origin, and clip-mask. `draw_lines` also uses these GC mode-dependent components:
    # foreground, background, tile, stipple, tile-stipple-x-origin, tile-stipple-y-origin, dash-offset, and dash-list.
    #
    # `draw_lines`, can generate **BadDrawable**, **BadGC**, **BadMatch** and **BadValue** errors.
    #
    # ###Diagnostics
    # - **BadDrawable** A value for a *Drawable* argument does not name a defined *Window* or *Pixmap*.
    # - **BadGC** A value for a `GContext` argument does not name a defined `GContext`.
    # - **BadMatch** An **InputOnly** window is used as a *Drawable*.
    # - **BadMatch** Some argument or pair of arguments has the correct type and
    # range but fails to match in some other way required by the request.
    # - **BadValue** Some numeric value falls outside the range of values accepted
    # by the request. Unless a specific range is specified for an argument, the
    # full range defined by the argument's type is accepted. Any argument defined
    # as a set of alternatives can generate this error.
    #
    # ###See also
    # `draw_arc`, `draw_line`, `draw_point`, `draw_rectangle`, `draw_segments`.
    def draw_lines(d : X11::C::Drawable, gc : X11::C::X::GC, points : Array(Point), mode : Int32) : Int32
      X.draw_lines @dpy, d, gc, points.to_unsafe.as(X11::C::X::PPoint), points.size, mode
    end

    # Draws a single point into the specified drawable
    #
    # ###Arguments
    # - **d** Specifies the drawable.
    # - **gc** Specifies the GC.
    # - **x**, **y** Specify the x and y coordinates where you want the point drawn.
    #
    # ###Description
    # The `draw_point` function uses the foreground pixel and function components
    # of the GC to draw a single point into the specified drawable;
    #
    # This function uses these GC components: function, plane-mask, foreground,
    # subwindow-mode, clip-x-origin, clip-y-origin, and clip-mask.
    #
    # `draw_point` can generate **BadDrawable**, **BadGC**, and **BadMatch** errors.
    #
    # ###Diagnostics
    # - **BadDrawable** A value for a *Drawable* argument does not name a defined *Window* or *Pixmap*.
    # - **BadGC** A value for a `GContext` argument does not name a defined `GContext`.
    # - **BadMatch** An **InputOnly** window is used as a *Drawable*.
    # - **BadMatch** Some argument or pair of arguments has the correct type and
    # range but fails to match in some other way required by the request.
    #
    # ###See also
    # `draw_arc`, `draw_line`, `draw_points`, `draw_rectangle`.
    def draw_point(d : X11::C::Drawable, gc : X11::C::X::GC, x : Int32, y : Int32) : Int32
      X.draw_point @dpy, d, gc, x, y
    end

    # Draws multiple points the same way `draw_point` draws one point.
    #
    # ###Arguments
    # - **d** Specifies the drawable.
    # - **gc** Specifies the GC.
    # - **points** Specifies an array of points.
    # - **mode** Specifies the coordinate mode. You can pass **CoordModeOrigin** or **CoordModePrevious**.
    #
    # ###Description
    # `draw_points` draws multiple points the same way `draw_point` draws one point.
    # **CoordModeOrigin** treats all coordinates as relative to the origin, and
    # **CoordModePrevious** treats all coordinates after the first as relative
    # to the previous point. `draw_points` draws the points in the order listed in the array.
    #
    # This function uses these GC components: function, plane-mask, foreground,
    # subwindow-mode, clip-x-origin, clip-y-origin, and clip-mask.
    # `draw_points` can generate **BadDrawable**, **BadGC**, **BadMatch**, and **BadValue** errors.
    #
    # ###Diagnostics
    # - **BadDrawable** A value for a *Drawable* argument does not name a defined *Window* or *Pixmap*.
    # - **BadGC** A value for a `GContext` argument does not name a defined `GContext`.
    # - **BadMatch** An **InputOnly** window is used as a *Drawable*.
    # - **BadMatch** Some argument or pair of arguments has the correct type and
    # range but fails to match in some other way required by the request.
    # - **BadValue** Some numeric value falls outside the range of values accepted
    # by the request. Unless a specific range is specified for an argument, the full
    # range defined by the argument's type is accepted.
    # Any argument defined as a set of alternatives can generate this error.
    #
    # ###See also
    # `draw_arc`, `draw_line`, `draw_point`, `draw_rectangle`.
    def draw_points(d : X11::Drawable, gc : X11::C::X::GC, points : Array(Point), mode : Int32) : Int32
      X.draw_points @dpy, d, gc, points.to_unsafe.as(X11::C::X::PPoint), points.size, mode
    end

    # Draws the outlines of the specified rectangle.
    #
    # ###Arguments
    # - **d** Specifies the drawable.
    # - **gc** Specifies the GC.
    # - **x**, **y** Specify the x and y coordinates, which specify the upper-left corner of the rectangle.
    # - **width**, **height** Specify the width and height, which specify the dimensions of the rectangle.
    #
    # ###Description
    # The `draw_rectangle` function draws the outlines of the specified rectangle
    # as if a five-point **PolyLine** protocol request were specified for the rectangle:
    # ```
    # [x,y] [x+width,y] [x+width,y+height] [x,y+height] [x,y]
    # ```
    # For the specified rectangle, this function does not draw a pixel more than once.
    #
    # This function uses these GC components: function, plane-mask, line-width,
    # line-style, cap-style, join-style, fill-style, subwindow-mode, clip-x-origin,
    # clip-y-origin, and clip-mask. It also uses these GC mode-dependent components:
    # foreground, background, tile, stipple, tile-stipple-x-origin, tile-stipple-y-origin, dash-offset, and dash-list.
    #
    # `draw_rectangle` can generate **BadDrawable**, **BadGC**, and **BadMatch** errors.
    #
    # ###Diagnostics
    # - **BadDrawable** A value for a *Drawable* argument does not name a defined *Window* or *Pixmap*.
    # - **BadGC** A value for a `GContext` argument does not name a defined `GContext`.
    # - **BadMatch** An **InputOnly** window is used as a *Drawable*.
    # - **BadMatch** Some argument or pair of arguments has the correct type and
    # range but fails to match in some other way required by the request.
    #
    # ###See also
    # `draw_arc`, `draw_rectangles`, `draw_point`.
    def draw_rectangle(d : X11::C::Drawable, gc : X11::C::X::GC, x : Int32, y : Int32, width : UInt32, height : UInt32) : Int32
      X.draw_rectangle @dpy, d, gc, x, y, width, height
    end

    # Draws the outlines of the specified rectangles.
    #
    # ###Arguments
    # - **d** Specifies the drawable.
    # - **gc** Specifies the GC.
    # - **rectangles** Specifies an array of rectangles.
    #
    # ###Description
    # The `draw_rectangles` functions draw the outlines of the specified rectangles
    # as if a five-point **PolyLine** protocol request were specified for each rectangle:
    # ```
    # [x,y] [x+width,y] [x+width,y+height] [x,y+height] [x,y]
    # ```
    # For the specified rectangles, this function does not draw a pixel more than once.
    # `draw_rectangles` draws the rectangles in the order listed in the array.
    # If rectangles intersect, the intersecting pixels are drawn multiple times.
    #
    # This function uses these GC components: function, plane-mask, line-width,
    # line-style, cap-style, join-style, fill-style, subwindow-mode, clip-x-origin,
    # clip-y-origin, and clip-mask. It also uses these GC mode-dependent components:
    # foreground, background, tile, stipple, tile-stipple-x-origin, tile-stipple-y-origin, dash-offset, and dash-list.
    #
    # `draw_rectangles` can generate **BadDrawable**, **BadGC**, and **BadMatch** errors.
    #
    # ###Diagnostics
    # - **BadDrawable** A value for a *Drawable* argument does not name a defined *Window* or *Pixmap*.
    # - **BadGC** A value for a `GContext` argument does not name a defined `GContext`.
    # - **BadMatch** An **InputOnly** window is used as a *Drawable*.
    # - **BadMatch** Some argument or pair of arguments has the correct type and
    # range but fails to match in some other way required by the request.
    #
    # ###See also
    # `draw_arc`, `draw_rectangle`, `draw_point`.
    def draw_rectangles(d : X11::C::Drawable, gc : X11::C::X::GC, rectangles : Array(Rectangle)) : Int32
      X.draw_rectangles @dpy, d, gc, rectangles.to_unsafe.as(X11::C::X::PRectangle), rectangles.size
    end

    # Draws multiple, unconnected lines.
    #
    # ###Arguments
    # - **d** Specifies the drawable.
    # - **gc** Specifies the GC.
    # - **segments** Specifies an array of segments.
    #
    # ###Description
    # The `draw_segments` function draws multiple, unconnected lines. For each
    # segment, `draw_segments` draws a line between (x1, y1) and (x2, y2).
    # It draws the lines in the order listed in the array of `Segment` structures
    # and does not perform joining at coincident endpoints. For any given line,
    # `draw_segments` does not draw a pixel more than once.
    # If lines intersect, the intersecting pixels are drawn multiple times.
    #
    # `draw_segments` use these GC components: function, plane-mask, line-width,
    # line-style, cap-style, fill-style, subwindow-mode, clip-x-origin, clip-y-origin,
    # and clip-mask. `draw_segments` also uses these GC mode-dependent components:
    # foreground, background, tile, stipple, tile-stipple-x-origin, tile-stipple-y-origin, dash-offset, and dash-list.
    #
    # `draw_segments` can generate **BadDrawable**, **BadGC**, and **BadMatch** errors.
    #
    # ###Diagnostics
    # - **BadDrawable** A value for a *Drawable* argument does not name a defined *Window* or *Pixmap*.
    # - **BadGC** A value for a `GContext` argument does not name a defined `GContext`.
    # - **BadMatch** An **InputOnly** window is used as a *Drawable*.
    # - **BadMatch** Some argument or pair of arguments has the correct type and
    # range but fails to match in some other way required by the request.
    #
    # ###See also
    # `draw_arc`, `draw_line`, `draw_lines`, `draw_point`, `draw_rectangle`.
    def draw_segments(d : X11::C::Drawable, gc : X11::C::X::GC, segments : Array(Segment)) : Int32
      X.draw_segments @dpy, d, gc, segments.to_unsafe.as(X11::C::X::PSegment), segments.size
    end

    # Draws a string.
    #
    # ###Arguments
    # - **d** Specifies the drawable.
    # - **gc** Specifies the GC.
    # - **x**, **y** Specify the x and y coordinates, which are relative to the
    # origin of the specified drawable and define the origin of the first character.
    # - **string** Specifies the character string.
    #
    # ###Description
    # Each character image, as defined by the font in the GC, is treated as an
    # additional mask for a fill operation on the drawable. The drawable is
    # modified only where the font character has a bit set to 1.
    #
    # Both functions use these GC components: function, plane-mask, fill-style,
    # font, subwindow-mode, clip-x-origin, clip-y-origin, and clip-mask.
    # They also use these GC mode-dependent components: foreground, background,
    # tile, stipple, tile-stipple-x-origin, and tile-stipple-y-origin.
    #
    # `draw_string` can generate **BadDrawable**, **BadGC**, and **BadMatch** errors.
    #
    # ###Diagnostics
    # - **BadDrawable** A value for a *Drawable* argument does not name a defined *Window* or *Pixmap*.
    # - **BadGC** A value for a `GContext` argument does not name a defined `GContext`.
    # - **BadMatch** An **InputOnly** window is used as a *Drawable*.
    # - **BadMatch** Some argument or pair of arguments has the correct type and
    # range but fails to match in some other way required by the request.
    #
    # ###See also
    # `draw_image_string`, `load_font`, `draw_string_16`, `draw_text`.
    def draw_string(d : X11::C::Drawable, gc : X11::C::X::GC, x : Int32, y : Int32, string : String) : Int32
      X.draw_string @dpy, d, gc, x, y, string.to_unsafe, string.size
    end

    # Draws a string.
    #
    # ###Arguments
    # - **d** Specifies the drawable.
    # - **gc** Specifies the GC. which are relative to the origin of the
    # specified drawable and define the origin of the first character.
    # - **x**, **y** Specify the x and y coordinates.
    # - **string** Specifies the character string.
    #
    # ###Description
    # Each character image, as defined by the font in the GC, is treated as an
    # additional mask for a fill operation on the drawable. The drawable is
    # modified only where the font character has a bit set to 1. For fonts defined
    # with 2-byte matrix indexing and used with `draw_string_16`, each byte
    # is used as a byte2 with a byte1 of zero.
    #
    # Both functions use these GC components: function, plane-mask, fill-style,
    # font, subwindow-mode, clip-x-origin, clip-y-origin, and clip-mask.
    # They also use these GC mode-dependent components: foreground, background,
    # tile, stipple, tile-stipple-x-origin, and tile-stipple-y-origin.
    #
    # `draw_string_16` can generate **BadDrawable**, **BadGC**, and **BadMatch** errors.
    #
    # ###Diagnostics
    # - **BadDrawable** A value for a *Drawable* argument does not name a defined *Window* or *Pixmap*.
    # - **BadGC** A value for a `GContext` argument does not name a defined `GContext`.
    # - **BadMatch** An **InputOnly** window is used as a *Drawable*.
    # - **BadMatch** Some argument or pair of arguments has the correct type and
    # range but fails to match in some other way required by the request.
    #
    # ###See also
    # `draw_image_string`, `draw_string`, `load_font`, `draw_text`.
    def draw_string_16(d : Drawable, gc : X11::C::X::GC, x : Int32, y : Int32, string : Array(X11::C::X::PChar2b)) : Int32
      X.draw_string_16 @dpy, d, gc, x, y, string, string.size
    end

    # Allows complex spacing and font shifts between counted strings.
    #
    # ###Arguments
    # - **d** Specifies the drawable.
    # - **gc** Specifies the GC.
    # - **x**, **y** Specify the x and y coordinates, which are relative to the
    # origin of the specified drawable and define the origin of the first character.
    # - **items** Specifies an array of text items.
    #
    # ###Description
    # The `draw_text` function allows complex spacing and font shifts between counted strings.
    #
    # Each text item is processed in turn. A font member other than **None** in
    # an item causes the font to be stored in the GC and used for subsequent text.
    # A text element delta specifies an additional change in the position along
    # the x axis before the string is drawn. The delta is always added to the
    # character origin and is not dependent on any characteristics of the font.
    # Each character image, as defined by the font in the GC, is treated as an
    # additional mask for a fill operation on the drawable. The drawable is modified
    # only where the font character has a bit set to 1. If a text item generates
    # a **BadFont** error, the previous text items may have been drawn.
    #
    # For fonts defined with linear indexing rather than 2-byte matrix indexing,
    # each `X11::C::X::Char2b` structure is interpreted as a 16-bit number with byte1 as the most-significant byte.
    #
    # The function uses these GC components: function, plane-mask, fill-style,
    # font, subwindow-mode, clip-x-origin, clip-y-origin, and clip-mask. It also
    # uses these GC mode-dependent components: foreground, background, tile, stipple,
    # tile-stipple-x-origin, and tile-stipple-y-origin.
    #
    # `draw_text` can generate **BadDrawable**, **BadFont**, **BadGC**, and **BadMatch** errors.
    #
    # ###Diagnostics
    # - **BadDrawable** A value for a *Drawable* argument does not name a defined *Window* or *Pixmap*.
    # - **BadFont** A value for a font argument does not name a defined font (or, in some cases, `GContext`).
    # - **BadGC** A value for a `GContext` argument does not name a defined `GContext`.
    # - **BadMatch** An **InputOnly** window is used as a *Drawable*.
    # - **BadMatch** Some argument or pair of arguments has the correct type and
    # range but fails to match in some other way required by the request.
    #
    # ###See also
    # `draw_image_string`, `load_font`, `draw_string`, `draw_text_16`.
    def draw_text(d : X11::C::Drawable, gc : X11::C::X::GC, x : Int32, y : Int32, items : Array(TextItem)) : Int32
      X.draw_text @dpy, d, gc, x, y, items.to_unsafe.as(X11::C::X::PTextItem), items.size
    end

    # Similar to `draw_text` except that it uses 2-byte or 16-bit characters.
    #
    # ###Arguments
    # - *d** Specifies the drawable.
    # - **gc** Specifies the GC.
    # - **x**, **y** Specify the x and y coordinates, which are relative to the
    # origin of the specified drawable and define the origin of the first character.
    # - **items** Specifies an array of text items.
    #
    # ###Description
    # The `draw_text_16` function is similar to `draw_text` except that it uses
    # 2-byte or 16-bit characters. Both functions allow complex spacing and font
    # shifts between counted strings.
    #
    # Each text item is processed in turn. A font member other than **None** in
    # an item causes the font to be stored in the GC and used for subsequent text.
    # A text element delta specifies an additional change in the position along
    # the x axis before the string is drawn. The delta is always added to the
    # character origin and is not dependent on any characteristics of the font.
    # Each character image, as defined by the font in the GC, is treated as an
    # additional mask for a fill operation on the drawable. The drawable is
    # modified only where the font character has a bit set to 1. If a text item
    # generates a **BadFont** error, the previous text items may have been drawn.
    #
    # For fonts defined with linear indexing rather than 2-byte matrix indexing,
    # each `X11::C::X::Char2b` structure is interpreted as a 16-bit number with
    # byte1 as the most-significant byte.
    #
    # The function uses these GC components: function, plane-mask, fill-style,
    # font, subwindow-mode, clip-x-origin, clip-y-origin, and clip-mask. It also
    # uses these GC mode-dependent components: foreground, background, tile,
    # stipple, tile-stipple-x-origin, and tile-stipple-y-origin.
    #
    # `draw_text_16` can generate **BadDrawable**, **BadFont**, **BadGC**, and **BadMatch** errors.
    #
    # ###Diagnostics
    # - **BadDrawable** A value for a *Drawable* argument does not name a defined *Window* or *Pixmap*.
    # - **BadFont** A value for a font argument does not name a defined font (or, in some cases, `GContext`).
    # - **BadGC** A value for a `GContext` argument does not name a defined `GContext`.
    # - **BadMatch** An **InputOnly** window is used as a *Drawable*.
    # - **BadMatch** Some argument or pair of arguments has the correct type and
    # range but fails to match in some other way required by the request.
    #
    # ###See also
    # `draw_text`, `draw_image_string`, `load_font`, `draw_string`.
    def draw_text_16(d : X11::C::Drawable, gc : X11::C::X::GC, x : Int32, y : Int32, items : Array(TextItem16)) : Int32
      X.draw_text_16 @dpy, d, gc, x, y, items.to_unsafe.as(X11::C::X::PTextItem16), items.size
    end

    # Enables the use of the access control list at each connection setup.
    #
    # ###Description
    # The `enable_access_control` function enables the use of the access control list at each connection setup.
    #
    # `enable_access_control` can generate a **BadAccess** error.
    #
    # ###Diagnostics
    # - **BadAccess** A client attempted to free a color map entry that it did not already allocate.
    # - **BadAccess** A client attempted to store into a read-only color map entry.
    #
    # ###See also
    # `add_host`, `add_hosts`, `disable_access_control`, `X11::free`, `hosts`,
    # `remove_host`, `remove_hosts`, `set_access_control`.
    def enable_access_control : Int32
      X.enable_access_control @dpy
    end

    # Returns the number of events already in the event queue.
    #
    # ###Arguments
    # - **mode** Specifies the mode. You can pass **QueuedAlready**,
    # **QueuedAfterFlush**, or **QueuedAfterReading**.
    #
    # ###Description
    # If mode is **QueuedAlready**, `events_queued` returns the number of events
    # already in the event queue (and never performs a system call). If mode is
    # **QueuedAfterFlush**, `events_queued` returns the number of events already
    # in the queue if the number is nonzero. If there are no events in the queue,
    # `events_queued` flushes the output buffer, attempts to read more events out
    # of the application's connection, and returns the number read. If mode is
    # **QueuedAfterReading**, `events_queued` returns the number of events already
    # in the queue if the number is nonzero. If there are no events in the queue,
    # `events_queued` attempts to read more events out of the application's connection
    # without flushing the output buffer and returns the number read.
    #
    # `events_queued` always returns immediately without I/O if there are events
    # already in the queue. `events_queued` with mode **QueuedAfterFlush** is
    # identical in behavior to `pending`. `events_queued` with mode
    # **QueuedAlready** is identical to the `q_length` function.
    #
    # ###See also
    # `flush`, `if_event`, `next_event`, `pending`, `put_back_event`, `sync`.
    def events_queued(mode : Int32) : Int32
      X.events_queued @dpy, mode
    end

    # Returns then window name.
    #
    # ###Arguments
    # - **w** Specifies the window.
    #
    # ###Description
    # The `fetch_name` function returns the name of the specified window. If it
    # succeeds, it returns a string; otherwise, no name has been set for the window,
    # and it returns empty string. If the data returned by the server is in the
    # Latin Portable Character Encoding, then the returned string is in the
    # Host Portable Character Encoding. Otherwise, the result is implementation dependent.
    #
    # `fetch_name` can generate a **BadWindow** error.
    #
    # ###Diagnostics
    # - **BadWindow** A value for a Window argument does not name a defined Window.
    #
    # ###See also
    # `X11::alloc_class_hint`, `X11::alloc_icon_size`, `X11::alloc_size_hints`,
    # `X11::alloc_wm_hints`, `X11::free`, `wm_name`, `set_command`, `set_text_property`,
    # `set_transient_for_hint`, `set_wm_client_machine`, `set_wm_colormap_windows`,
    # `set_wm_colormap_windows`, `set_wm_icon_name`, `set_wm_icon_name`, `set_wm_name`,
    # `set_wm_properties`, `set_wm_protocols`, `store_name`, `X11::string_list_to_text_property`.
    def fetch_name(w : X11::C::Window) : String
      status = X.fetch_name @dpy, w, out window_name_return
      return "" if status == 0
      name = String.new window_name_return
      X.free window_name_return
      name
    end

    # Fills the region closed by the infinitely thin path described by the specified arc.
    #
    # ###Arguments
    # - **d** Specifies the drawable.
    # - **gc** Specifies the GC.
    # - **x**, **y** Specify the x and y coordinates, which are relative to the
    # origin of the drawable and specify the upper-left corner of the bounding rectangle.
    # - **width**, **height** Specify the width and height, which are the major and minor axes of the arc.
    # - **angle1** Specifies the start of the arc relative to the three-o'clock position from the center, in units of degrees * 64.
    # - **angle2** Specifies the path and extent of the arc relative to the start of the arc, in units of degrees * 64.
    #
    # ###Description
    # For each arc, `fill_arc` fills the region closed by the infinitely thin path
    # described by the specified arc and, depending on the arc-mode specified in the GC,
    # one or two line segments. For **ArcChord**, the single line segment joining
    # the endpoints of the arc is used. For **ArcPieSlice** , the two line segments
    # joining the endpoints of the arc with the center point are used. For any given arc,
    # `fill_arc` does not draw a pixel more than once. If regions intersect,
    # the intersecting pixels are drawn multiple times.
    #
    # Both functions use these GC components: function, plane-mask, fill-style,
    # arc-mode, subwindow-mode, clip-x-origin, clip-y-origin, and clip-mask.
    # They also use these GC mode-dependent components: foreground, background,
    # tile, stipple, tile-stipple-x-origin, and tile-stipple-y-origin.
    #
    # `fill_arc` can generate **BadDrawable**, **BadGC**, and **BadMatch** errors.
    #
    # ###Diagnostics
    # - **BadDrawable** A value for a *Drawable* argument does not name a defined *Window* or *Pixmap*.
    # - **BadGC** A value for a `GContext` argument does not name a defined `GContext`.
    # - **BadMatch** An **InputOnly** window is used as a *Drawable*.
    # - **BadMatch** Some argument or pair of arguments has the correct type and
    # range but fails to match in some other way required by the request.
    #
    # ###See also
    # `draw_arc`, ``draw_point`, `draw_rectangle`, `fill_arcs`, `fill_polygon`,
    # `fill_rectangle`, `fill_rectangles`.
    def fill_arc(d : X11::C::Drawable, gc : X11::C::X::GC, x : Int32, y : Int32, width : UInt32, height : UInt32, angle1 : Int32, angle2 : Int32) : Int32
      X.fill_arc @dpy, d, gc, x, y, width, height, angle1, angle2
    end

    # Fills the region closed by the infinitely thin path described by the specified arc.
    #
    # ###Arguments
    # - **d** Specifies the drawable.
    # - **gc** Specifies the GC.
    # - **arcs** Specifies an array of arcs.
    #
    # ###Description
    # For each arc, `fill_arcs` fills the region closed by the infinitely thin
    # path described by the specified arc and, depending on the arc-mode specified
    # in the GC, one or two line segments. For **ArcChord**, the single line
    # segment joining the endpoints of the arc is used. For **ArcPieSlice**, the
    # two line segments joining the endpoints of the arc with the center point are used.
    # `fill_arcs` fills the arcs in the order listed in the array. For any given arc,
    # `fill_arcs` do not draw a pixel more than once. If regions intersect, the
    # intersecting pixels are drawn multiple times.
    #
    # Both functions use these GC components: function, plane-mask, fill-style,
    # arc-mode, subwindow-mode, clip-x-origin, clip-y-origin, and clip-mask.
    # They also use these GC mode-dependent components: foreground, background,
    # tile, stipple, tile-stipple-x-origin, and tile-stipple-y-origin.
    #
    # `fill_arcs` can generate **BadDrawable**, **BadGC**, and **BadMatch** errors.
    #
    # ###Diagnostics
    # - **BadDrawable** A value for a *Drawable* argument does not name a defined *Window* or *Pixmap*.
    # - **BadGC** A value for a `GContext` argument does not name a defined `GContext`.
    # - **BadMatch** An **InputOnly** window is used as a *Drawable*.
    # - **BadMatch** Some argument or pair of arguments has the correct type and
    # range but fails to match in some other way required by the request.
    #
    # ###See also
    # `draw_arc`, `draw_point`, `draw_rectangle`, `fill_arcs`, `fill_polygon`,
    # `fill_rectangle`, `fill_rectangles`.
    def fill_arcs(d : X11::C::Drawable, gc : X11::C::X::GC, arcs : Array(Arc)) : Int32
      X.fill_arcs @dpy, d, gc, arcs.to_unsafe.as(X11::C::X::PArc), arcs.size
    end

    # Fills the region closed by the specified path.
    #
    # ###Arguments
    # - **d** Specifies the drawable.
    # - **gc** Specifies the GC.
    # - **points** Specifies an array of points.
    # - **shape** Specifies a shape that helps the server to improve performance.
    # You can pass **Complex**, **Convex**, or **Nonconvex**.
    # - **mode** Specifies the coordinate mode.
    # You can pass **CoordModeOrigin** or **CoordModePrevious**.
    #
    # ###Description
    # `fill_polygon` fills the region closed by the specified path. The path is
    # closed automatically if the last point in the list does not coincide with
    # the first point. `fill_polygon` does not draw a pixel of the region more
    # than once. **CoordModeOrigin** treats all coordinates as relative to the
    # origin, and **CoordModePrevious** treats all coordinates after the first
    # as relative to the previous point.
    #
    # Depending on the specified shape, the following occurs:
    # - If shape is **Complex**, the path may self-intersect. Note that contiguous
    # coincident points in the path are not treated as self-intersection.
    # - If shape is **Convex**, for every pair of points inside the polygon, the
    # line segment connecting them does not intersect the path. If known by the
    # client, specifying **Convex** can improve performance. If you specify
    # **Convex** for a path that is not convex, the graphics results are undefined.
    # - If shape is **Nonconvex**, the path does not self-intersect, but the
    # shape is not wholly convex. If known by the client, specifying **Nonconvex**
    # instead of **Complex** may improve performance. If you specify **Nonconvex**
    # for a self-intersecting path, the graphics results are undefined.
    #
    # The fill-rule of the GC controls the filling behavior of self-intersecting polygons.
    #
    # This function uses these GC components: function, plane-mask, fill-style,
    # fill-rule, subwindow-mode, clip-x-origin, clip-y-origin, and clip-mask.
    # It also uses these GC mode-dependent components: foreground, background,
    # tile, stipple, tile-stipple-x-origin, and tile-stipple-y-origin.
    #
    # `fill_polygon` can generate **BadDrawable**, **BadGC**, **BadMatch**, and **BadValue** errors.
    #
    # ###Diagnostics
    # - **BadDrawable** A value for a *Drawable* argument does not name a defined *Window* or *Pixmap*.
    # - **BadGC** A value for a `GContext` argument does not name a defined `GContext`.
    # - **BadMatch** An **InputOnly** window is used as a *Drawable*.
    # - **BadMatch** Some argument or pair of arguments has the correct type and
    # range but fails to match in some other way required by the request.
    # - **BadValue** Some numeric value falls outside the range of values accepted
    # by the request. Unless a specific range is specified for an argument, the
    # full range defined by the argument's type is accepted. Any argument
    # defined as a set of alternatives can generate this error.
    #
    # ###See also
    # `draw_arc`, `draw_point`, `draw_rectangle`, `fill_arc`, `fill_arcs`,
    # `fill_rectangle`, `fill_rectangles`.
    def fill_polygon(d : X11::C::Drawable, gc : X11::C::X::GC, points : Array(Point), shape : Int32, mode : Int32) : Int32
      X.fill_polygon @dpy, d, gc, points.to_unsafe.as(X11::C::X::PPoint), points.size, shape, mode
    end

    # Fills the specified rectangle.
    #
    # ###Arguments
    # - **d** Specifies the drawable.
    # - **gc** Specifies the GC.
    # - **x**, **y** Specify the x and y coordinates, which are relative to the
    # origin of the drawable and specify the upper-left corner of the rectangle.
    # - **width**, **height** Specify the width and height, which are the
    # dimensions of the rectangle to be filled.
    #
    # ###Description
    # The `fill_rectangle` function fills the specified rectangle as if a
    # four-point **FillPolygon** protocol request were specified for each rectangle:
    # ```
    # [x,y] [x+width,y] [x+width,y+height] [x,y+height]
    # ```
    # The function uses the x and y coordinates, width and height dimensions, and GC you specify.
    #
    # For any given rectangle, `fill_rectangle` does not draw a pixel more than once.
    # If rectangles intersect, the intersecting pixels are drawn multiple times.
    #
    # The function uses these GC components: function, plane-mask, fill-style,
    # subwindow-mode, clip-x-origin, clip-y-origin, and clip-mask. They also use
    # these GC mode-dependent components: foreground, background, tile, stipple,
    # tile-stipple-x-origin, and tile-stipple-y-origin.
    #
    # `fill_rectangle` can generate **BadDrawable**, **BadGC**, and **BadMatch** errors.
    #
    # ###Diagnostics
    # - **BadDrawable** A value for a *Drawable* argument does not name a defined *Window* or *Pixmap*.
    # - **BadGC** A value for a `GContext` argument does not name a defined `GContext`.
    # - **BadMatch** An **InputOnly** window is used as a *Drawable*.
    # - **BadMatch** Some argument or pair of arguments has the correct type and
    # range but fails to match in some other way required by the request.
    #
    # ###See also
    # `draw_arc`, `draw_point`, `draw_rectangle`, `fill_arc`, `fill_arcs`,
    # `fill_polygon`, `fill_rectangles`.
    def fill_rectangle(d : X11::C::Drawable, gc : X11::C::X::GC, x : Int32, y : Int32, width : UInt32, height : UInt32) : Int32
      X.fill_rectangle @dpy, gc, x, y, width, height
    end

    # Fills the specified rectangles.
    #
    # ###Arguments
    # - **d** Specifies the drawable.
    # - **gc** Specifies the GC.
    # - **rectangles** Specifies an array of rectangles.
    #
    # ###Description
    # The `fill_rectangles` function fills rectangles as if a four-point
    # **FillPolygon** protocol request were specified for each rectangle:
    # ```
    # [x,y] [x+width,y] [x+width,y+height] [x,y+height]
    # ```
    # The function uses the x and y coordinates, width and height dimensions, and GC you specify.
    #
    # `fill_rectangles` fills the rectangles in the order listed in the array.
    # For any given rectangle, `fill_rectangles` does not draw a pixel more than once.
    # If rectangles intersect, the intersecting pixels are drawn multiple times.
    #
    # The function uses these GC components: function, plane-mask, fill-style,
    # subwindow-mode, clip-x-origin, clip-y-origin, and clip-mask. They also use
    # these GC mode-dependent components: foreground, background, tile, stipple,
    # tile-stipple-x-origin, and tile-stipple-y-origin.
    #
    # `fill_rectangles` can generate **BadDrawable**, **BadGC**, and **BadMatch** errors.
    #
    # ###Diagnostics
    # - **BadDrawable** A value for a *Drawable* argument does not name a defined *Window* or *Pixmap*.
    # - **BadGC** A value for a `GContext` argument does not name a defined `GContext`.
    # - **BadMatch** An **InputOnly** window is used as a *Drawable*.
    # - **BadMatch** Some argument or pair of arguments has the correct type and
    # range but fails to match in some other way required by the request.
    #
    # ###See also
    # `draw_arc`, `draw_point`, `draw_rectangles`, `fill_arcs`, `fill_arcs`,
    # `fill_polygon`, `fill_rectangles`.
    def fill_rectangles(d : X11::C::Drawable, gc : X11::C::X::GC, rectangles : Array(Rectangle)) : Int32
      X.fill_rectangles @dpy, d, gc, rectangles.to_unsafe.as(X11::C::X::PRectangle), rectangles.size
    end

    # Flushes the output buffer.
    #
    # ###Description
    # The `flush` function flushes the output buffer. Most client applications
    # need not use this function because the output buffer is automatically flushed
    # as needed by calls to `pending`, `next_event`, and `window_event`.
    # Events generated by the server may be enqueued into the library's event queue.
    #
    # ###See also
    # `events_queued`, `pending`, `sync`.
    def flush : Int32
      X.flush @dpy
    end

    # Activates the screen saver even if the screen saver had been disabled with a timeout of zero.
    #
    # ###Arguments
    # - **mode** Specifies the mode that is to be applied.
    # You can pass **ScreenSaverActive** or **ScreenSaverReset**.
    #
    # ###Description
    # If the specified mode is **ScreenSaverActive** and the screen saver currently
    # is deactivated, `force_screen_saver` activates the screen saver even if the
    # screen saver had been disabled with a timeout of zero. If the specified mode
    # is **ScreenSaverReset** and the screen saver currently is enabled,
    # `force_screen_saver` deactivates the screen saver if it was activated, and
    # the activation timer is reset to its initial state (as if device input had been received).
    #
    # `force_screen_saver` can generate a **BadValue** error.
    #
    # ###Diagnostics
    # - **BadValue** Some numeric value falls outside the range of values accepted
    # by the request. Unless a specific range is specified for an argument, the
    # full range defined by the argument's type is accepted. Any argument defined
    # as a set of alternatives can generate this error.
    #
    # ###See also
    # `set_screen_saver`, `activate_screen_saver`, `reset_screen_saver`, `screen_saver`.
    def force_screen_saver(mode : Int32) : Int32
      X.force_screen_saver @dpy
    end

    # Frees the colormap storage.
    #
    # ###Arguments
    # - **colormap** Specifies the colormap that you want to destroy.
    #
    # ###Description
    # The `free_colormap` function deletes the association between the colormap
    # resource ID and the colormap and frees the colormap storage. However, this
    # function has no effect on the default colormap for a screen. If the
    # specified colormap is an installed map for a screen, it is uninstalled
    # (see `uninstall_colormap`). If the specified colormap is defined as the
    # colormap for a window (by `create_window`, `set_window_colormap`, or
    # `change_window_attributes`), `free_colormap` changes the colormap associated
    # with the window to **None** and generates a **ColormapNotify** event.
    # X does not define the colors displayed for a window with a colormap of **None**.
    #
    # `free_colormap` can generate a **BadColor** error.
    #
    # ###Diagnostics
    # - **BadColor** A value for a *Colormap* argument does not name a defined *Colormap*.
    #
    # ###See also
    # `alloc_color`, `change_window_attributes`, `copy_colormap_and_free`,
    # `create_colormap`, `create_window`, `query_color`, `store_colors`.
    def free_colormap(colormap : X11::C::Colormap) : Int32
      X.free_colormap @dpy, colormap
    end

    # Frees the cells represented by pixels.
    #
    # ###Arguments
    # - **colormap** Specifies the colormap.
    # - **pixels** Specifies an array of pixel values that map to the cells in the specified colormap.
    # - **planes** Specifies the planes you want to free.
    #
    # ###Description
    # The `free_colors` function frees the cells represented by pixels whose
    # values are in the pixels array. The planes argument should not have any
    # bits set to 1 in common with any of the pixels. The set of all pixels is
    # produced by **ORing** together subsets of the planes argument with the pixels.
    # The request frees all of these pixels that were allocated by the client
    # (using `alloc_color`, `alloc_named_color`, `alloc_color_cells`, and `alloc_color_planes`).
    # Note that freeing an individual pixel obtained from `alloc_color_planes`
    # may not actually allow it to be reused until all of its related pixels are
    # also freed. Similarly, a read-only entry is not actually freed until it has
    # been freed by all clients, and if a client allocates the same read-only entry
    # multiple times, it must free the entry that many times before the entry is actually freed.
    #
    # All specified pixels that are allocated by the client in the colormap are freed,
    # even if one or more pixels produce an error. If a specified pixel is not a
    # valid index into the colormap, a **BadValue** error results. If a specified
    # pixel is not allocated by the client (that is, is unallocated or is only allocated
    # by another client) or if the colormap was created with all entries writable
    # (by passing **AllocAll** to `create_colormap`), a **BadAccess** error results.
    # If more than one pixel is in error, the one that gets reported is arbitrary.
    #
    # `free_colors` can generate **BadAccess**, **BadColor**, and **BadValue** errors.
    #
    # ###Diagnostics
    # - **BadAccess** A client attempted to free a color map entry that it did not already allocate.
    # - **BadAccess** A client attempted to store into a read-only color map entry.
    # - **BadColor** A value for a *Colormap* argument does not name a defined *Colormap*.
    # - **BadValue** Some numeric value falls outside the range of values accepted
    # by the request. Unless a specific range is specified for an argument, the full
    # range defined by the argument's type is accepted. Any argument defined as
    # a set of alternatives can generate this error.
    #
    # ###See also
    # `alloc_color`, `alloc_color_cells`, `alloc_color_planes`, `alloc_named_color`,
    # `create_colormap`, `query_color`, `store_colors`.
    def free_colors(colormap : X11::C::Colormap, pixels : Array(UInt64), planes : UInt64) : Int32
      X.free_colors @dpy, colormap, pixels.to_unsafe, pixels.size, planes
    end

    # Deletes the association between the cursor resource ID and the specified cursor.
    #
    # ###Arguments
    # - **cursor** Specifies the cursor.
    #
    # ###Description
    # The `free_cursor` function deletes the association between the cursor resource
    # ID and the specified cursor. The cursor storage is freed when no other
    # resource references it. The specified cursor ID should not be referred to again.
    #
    # `free_cursor` can generate a **BadCursor** error.
    #
    # ###Diagnostics
    # - **BadCursor** A value for a *Cursor* argument does not name a defined *Cursor*.
    #
    # ###See also
    # `create_colormap`, `create_font_cursor`, `define_cursor`,
    # `query_best_cursor`, `recolor_cursor`.
    def free_cursor(cursor : X11::C::Cursor) : Int32
      X.free_cursor @dpy, cursor
    end

    # Destroys the specified GC.
    #
    # ###Arguments
    # - gc** Specifies the GC.
    #
    # ###Description
    # The `free_gc` function destroys the specified GC as well as all the associated storage.
    #
    # `free_gc` can generate a **BadGC** error.
    #
    # ###Diagnostics
    # - **BadGC** A value for a `GContext` argument does not name a defined `GContext`.
    #
    # ###See also
    # `X11::all_planes`, `change_gc`, `copy_area`, `copy_gc`, `create_gc`,
    # `X11::create_region`, `draw_arc`, `draw_line`, `draw_rectangle`, `draw_text`,
    # `fill_rectangle`, `X11::g_context_from_gc`, `gc_values`, `query_best_size`,
    # `set_arc_mode`, `set_clip_origin`.
    def free_gc(gc : X12::C::GC) : Int32
      X.free_gc @dpy, gc
    end

    # Frees the pixmap storage.
    #
    # ###Arguments
    # - **pixmap** Specifies the pixmap.
    #
    # ###Description
    # The `free_pixmap` function first deletes the association between the pixmap
    # ID and the pixmap. Then, the X server frees the pixmap storage when there
    # are no references to it. The pixmap should never be referenced again.
    #
    # `free_pixmap` can generate a **BadPixmap** error.
    #
    # ###Diagnostics
    # - **BadPixmap** A value for a *Pixmap* argument does not name a defined *Pixmap*.
    #
    # ###See also
    # `create_pixmap`, `copy_area`.
    def free_pixmap(pixmap : X11::C::Pixmap) : Int32
      X.free_pixmap @dpy, pixmap
    end

    # Determines the placement of a window using a geometry specification.
    #
    # ###Arguments
    # - **screen** Specifies the screen.
    # - **position**, **default_position** Specify the geometry specifications.
    # - **bwidth** Specifies the border width.
    # - **fheight**, **fwidth** Specify the font height and width in pixels (increment size).
    # - **xadder**, **yadder** Specify additional interior padding needed in the window.
    #
    # ###Return
    # - **x**, **y** Return the x and y offsets.
    # - **width**, **height** Return the width and height determined.
    #
    # ###Description
    # You pass in the border width (bwidth), size of the increments fwidth and
    # fheight (typically font width and height), and any additional interior space
    # (xadder and yadder) to make it easy to compute the resulting size.
    # The `geometry` function returns the position the window should be placed given
    # a position and a default position. `geometry` determines the placement of a
    # window using a geometry specification as specified by `parse_geometry` and
    # the additional information about the window. Given a fully qualified default
    # geometry specification and an incomplete geometry specification,
    # `parse_geometry` returns a bitmask value as defined above in the
    # `parse_geometry` call, by using the position argument.
    #
    # The returned width and height will be the width and height specified by
    # default_position as overridden by any user-specified position. They are not
    # affected by fwidth, fheight, xadder, or yadder. The x and y coordinates are
    # computed by using the border width, the screen width and height, padding as
    # specified by xadder and yadder, and the fheight and fwidth times the width
    # and height from the geometry specifications.
    def geometry(screen : Int32, position : String, default_position : String, bwidth : UInt32, fwidth : UInt32, fheight : UInt32, xadder : Int32, yadder : Int32) : NamedTuple(x: Int32, y: Int32, width: Int32, height: Int32, res: Int32)
      res = X.geometry @dpy, screen, position.to_unsafe, default_position.to_unsafe, bwidth, fwidth, fheight, xadder, yadder, out x_return, out y_return, out width_return, out height_return
      {x: x_return, y: y_return, width: width_return, height: height_return, res: res}
    end

    # Returns a message from the error message database.
    #
    # ###Arguments
    # - **name** Specifies the name of the application.
    # - **message** Specifies the type of the error message.
    # - **default_string** Specifies the default error message if none is found in the database.
    #
    # ###Description
    # The `error_database_text` function returns a message (or the default message)
    # from the error message database. Xlib uses this function internally to look
    # up its error messages. The text in the default_string argument is assumed
    # to be in the encoding of the current locale, and the text stored in the
    # buffer_return argument is in the encoding of the current locale.
    #
    # The name argument should generally be the name of your application. The
    # message argument should indicate which type of error message you want.
    # If the name and message are not in the Host Portable Character Encoding,
    # the result is implementation dependent. Xlib uses three predefined
    #  +application names+ to report errors. In these names, uppercase and
    # lowercase matter.
    #
    # - **XProtoError** The protocol error number is used as a string for the message argument.
    # - **XlibMessage** These are the message strings that are used internally by the library.
    # - **XRequest** For a core protocol request, the major request protocol number
    # is used for the message argument. For an extension request, the extension name
    # (as given by `init_extension`) followed by a period (.) and the minor request
    # protocol number is used for the message argument. If no string is found in
    # the error database, the default_string is returned to the buffer argument.
    #
    # ###See also
    # `name`, `error_text`, `new`, `set_error_handler`, `set_io_error_handler`, `synchronize`.
    def error_database_text(name : String, message : String, default_string : String) : String
      buffer = Array(UInt8).new 1024
      X.get_error_database_text @dpy, name.to_unsafe, message.to_unsafe, default_string.to_unsafe, buffer.to_unsafe 1024
      String.new buffer.to_unsafe
    end

    # Returns a string describing the specified error code.
    #
    # ###Arguments
    # - **code** Specifies the error code for which you want to obtain a description.
    #
    # ###Description
    # The `error_text` function returns a string describing the
    # specified error code. The returned text is in the
    # encoding of the current locale. It is recommended that you use this function
    # to obtain an error description because extensions to Xlib may define their own error codes and error strings.
    #
    # ###See also
    # `name`, `error_database_text`, `new`, `set_error_handler`, `set_io_error_handler`, `synchronize`.
    def error_text(code : Int32) : String
      buffer = Array(UInt8).new 1024
      X.error_database_text @dpy, name.to_unsafe, message.to_unsafe, default_string.to_unsafe, buffer.to_unsafe 1024
      String.new buffer.to_unsafe
    end

    # Returns the components specified by valuemask for the specified GC.
    #
    # ###Arguments
    # - **gc** Specifies the GC.
    # - **valuemask** Specifies which components in the GC are to be returned.
    # This argument is the bitwise inclusive OR of zero or more of the valid GC component mask bits.
    #
    # ###Description
    # The `gc_values` function returns the components specified by valuemask for
    # the specified GC. If the valuemask contains a valid set of GC mask bits
    # (**GCFunction**, **GCPlaneMask**, **GCForeground**, **GCBackground**,
    # **GCLineWidth**, **GCLineStyle**, **GCCapStyle**, **GCJoinStyle**,
    # **GCFillStyle**, **GCFillRule**, **GCTile**, **GCStipple**,
    # **GCTileStipXOrigin**, **GCTileStipYOrigin**, **GCFont**, **GCSubwindowMode**,
    # **GCGraphicsExposures**, **GCClipXOrigin**, **GCCLipYOrigin**, **GCDashOffset**,
    # or **GCArcMode**) and no error occurs, `gc_values` sets the requested components
    # in values_return and returns a nonzero status. Otherwise, it returns a
    # zero status. Note that the clip-mask and dash-list (represented by the
    # **GCClipMask** and **GCDashList** bits, respectively, in the valuemask)
    # cannot be requested. Also note that an invalid resource ID (with one or
    # more of the three most-significant bits set to 1) will be returned for
    # **GCFont**, **GCTile**, and **GCStipple** if the component has never been explicitly set by the client.
    #
    # ###See also
    # `X11::all_planes`, `change_gc`, `copy_area`, `copy_gc`, `create_gc`,
    # `X11::create_region`, `draw_arc`, `draw_line`, `draw_rectangle`, `draw_text`,
    # `fill_rectangle`, `free_gc`, `X11::g_context_from_gc`, `query_best_size`,
    # `set_arc_mode`, `set_clip_origin`.
    def gc_values(gc : X11::C::X::GC, valuemask : UInt64) : GCValues
      X.get_gc_values @dpy, gc, valuemask, out pgcvalues
      GCValues.new pgcvalues
    end

    # Returns the root window and the current geometry of the drawable.
    #
    # ###Arguments
    # - **d** Specifies the drawable, which can be a window or a pixmap.
    #
    # ###Return
    # - **root** Returns the root window.
    # - **x**, **y** Return the x and y coordinates that define the location of
    # the drawable. For a window, these coordinates specify the upper-left outer
    # corner relative to its parent's origin. For pixmaps, these coordinates are always zero.
    # - **width**, **height** Return the drawable's dimensions (width and height).
    # For a window, these dimensions specify the inside size, not including the border.
    # - **border_width** Returns the border width in pixels. If the drawable is a pixmap, it returns zero.
    # - **depth** Returns the depth of the drawable (bits per pixel for the object).
    #
    # ###Description
    # The `geometry` function returns the root window and the current geometry of
    # the drawable. The geometry of the drawable includes the x and y coordinates,
    # width and height, border width, and depth. These are described in the argument
    # list. It is legal to pass to this function a window whose class is **InputOnly**.
    #
    # `geometry` can generate a **BadDrawable** error.
    #
    # ###Diagnostics
    # - **BadDrawable** A value for a *Drawable* argument does not name a defined *Window* or *Pixmap*.
    #
    # ###See also
    # `window_attributes`, `query_pointer`, `query_tree`.
    def geometry(d : X11::C::Drawable) : NamedTuple(root: X11::C::Window, x: Int32, y: Int32, width: UInt32, height: UInt32, border_width: Int32, depth: Int32, res: X11::C::X::Status)
      res = X.get_geometry @dpy, d, out root_return, out x_return, out y_return, out width_return, out height_return, out border_width_return
      {root: root_return, x: x_return, y: y_return, width: width_return, height: height_return, border_width: border_width_return, depth: depth_return, res: res}
    end

    # Returns the name to be displayed in the specified window's icon.
    #
    # ###Arguments
    # - **w** Specifies the window.
    #
    # ###Description
    # The `icon_name` function returns the name to be displayed in the specified
    # window's icon. If it succeeds, it returns a string; otherwise, if no icon
    # name has been set for the window, it returns empty string. If the
    # data returned by the server is in the Latin Portable Character Encoding,
    # then the returned string is in the Host Portable Character Encoding.
    # Otherwise, the result is implementation dependent.
    #
    # `icon_name` can generate a **BadWindow** error.
    #
    # ###Diagnostics
    # - **BadWindow** A value for a Window argument does not name a defined Window.
    #
    # ###See also
    # `X11::alloc_class_hint`, `X11::alloc_icon_size`, `X11::alloc_size_hints`,
    # `X11::alloc_wm_hints`, `X11::free`, `wm_icon_name`, `set_command`,
    # `set_icon_name`, `set_text_property`, `set_transient_for_hint`,
    # `set_wm_client_machine`, `set_wm_colormap_windows`, `set_wm_icon_name`,
    # `set_wm_name`, `set_wm_properties`, `set_wm_protocols`, `X11:string_list_to_text_property`.
    def icon_name(w : X11::C::Window) : String
      X.get_icon_name @dpy, w, out pstring
      return "" if pstring.null?
      str = String.new pstring
      X.free pstring
      str
    end

    # Returns the focus window and the current focus state.
    #
    # ###Return
    # - **focus** Returns the focus window, **PointerRoot**, or **None**.
    # - **revert_to** Returns the current focus state (**RevertToParent**,
    # **RevertToPointerRoot**, or **RevertToNone**).
    #
    # ###Description
    # The `input_focus` function returns the focus window and the current focus state.
    #
    # ###See also
    # `set_input_focus`, `warp_pointer`.
    def input_focus : NamedTuple(focus: X11::C::Window, revert_to: Int32, res: Int32)
      res = X.get_input_focus @dpy, out focus_return, out revert_to_return
      {focus: focus_return, revert_to: revert_to_return, res: res}
    end

    # Returns the current keyboard controls in the specified `KeyboardState` structure.
    #
    # ###Description
    # The `keyboard_control` function returns the current control values for the
    # keyboard to the `KeyboardState` structure.
    #
    # For the LEDs, the least-significant bit of **led_mask** corresponds to LED
    # one, and each bit set to 1 in led_mask indicates an LED that is lit.
    # The **global_auto_repeat** member can be set to **AutoRepeatModeOn** or
    # **AutoRepeatModeOff**. The **auto_repeats** member is a bit vector. Each
    # bit set to 1 indicates that auto-repeat is enabled for the corresponding key.
    # The vector is represented as 32 bytes. Byte N (from 0) contains the bits
    # for keys 8N to 8N + 7 with the least-significant bit in the byte representing key 8N.
    #
    # ###See also
    # `auto_repeat_off`, `auto_repeat_on`, `bell`, `change_keyboard_control`,
    # `change_keyboard_mapping`, `keyboard_control`, `query_keymap`, `set_pointer_mapping`.
    def keyboard_control : KeyboardState
      X.get_keyboard_control @dpy, out pstate
      KeyboardState.new pstate
    end

    # Returns the pointer's current acceleration multiplier and acceleration threshold.
    #
    # ###Return
    # - **accel_numerator** Returns the numerator for the acceleration multiplier.
    # - **accel_denominator** Returns the denominator for the acceleration multiplier.
    # - **threshold** Returns the acceleration threshold.
    #
    # ###Description
    # The `pointer_control` function returns the pointer's current acceleration multiplier and acceleration threshold.
    #
    # ###See also
    # `change_pointer_control`.
    def pointer_control : NamedTuple(accel_numerator: Int32, accel_denominator: Int32, threshold: Int32, res: Int32)
      res = X.get_pointer_control @dpy, out accel_numerator_return, out accel_denominator_return, out threshold_return
      {accel_numerator: accel_numerator_return, accel_denominator: accel_denominator_return, threshold: threshold_return, res: res}
    end

    # Returns the current mapping of the pointer.
    #
    # ###Arguments
    # - nmap	Specifies the number of items in the mapping list.
    #
    # ###Description
    # The `pointer_mapping` function returns the current mapping of the pointer.
    # Pointer buttons are numbered starting from one. `pointer_mapping` returns
    # the number of physical buttons actually on the pointer. The nominal mapping
    # for a pointer is map[i]=i+1. The nmap argument specifies the length of the
    # array where the pointer mapping is returned,
    # and only the first nmap elements are returned.
    #
    # ###See also
    # `change_keyboard_control`, `change_keyboard_mapping`, `set_pointer_mapping`.
    def pointer_mapping(nmap : Int32) : Array(UInt8)
      X.get_pointer_mapping @dpy, out map_return, nmap
      Array(UInt8).new(nmap) do |i|
        (pointerof(map_return) + i).value
      end
    end

    # Returns the current screen saver values.
    #
    # ###Return
    # - **timeout** Returns the timeout, in seconds, until the screen saver turns on.
    # - **interval** Returns the interval between screen saver invocations.
    # - **prefer_blanking** Returns the current screen blanking preference
    # (**DontPreferBlanking**, **PreferBlanking**, or **DefaultBlanking**).
    # - **allow_exposures** Returns the current screen save control value
    # (**DontAllowExposures**, **AllowExposures**, or **DefaultExposures**).
    #
    # ###Description
    # The `screen_saver` function gets the current screen saver values.
    #
    # ###See also
    # `set_screen_saver`, `force_screen_saver`, `activate_screen_saver`, `reset_screen_saver`.
    def screen_saver : NamedTuple(timeout: Int32, interval: Int32, prefer_blanking: Int32, allow_exposures: Int32, res: Int32)
      res = X.get_screen_saver @dpy, out timeout_return, out interval_return, out prefer_blanking_return, out allow_exposures_return
      {timeout: timeout_return, interval: interval_return, prefer_blanking: prefer_blanking_return, allow_exposures: allow_exposures_return, res: res}
    end

    # Returns the WM_TRANSIENT_FOR property for the specified window.
    #
    # ###Arguments
    # - **w** Specifies the window.
    #
    # ###Description
    # The `transient_for_hint` function returns the WM_TRANSIENT_FOR property
    # for the specified window. It returns a nonzero Window on success;
    # otherwise, it returns a zero.
    #
    # `transient_for_hint` can generate a **BadWindow** error.
    #
    # ###Diagnostics
    # - **BadWindow** A value for a Window argument does not name a defined Window.
    #
    # ###See also
    # `X11::alloc_class_hint`, `X11::alloc_icon_size`, `X11::alloc_size_hints`,
    # `X11::alloc_wm_hints`, `set_command`, `set_text_property`, `set_transient_for_hint`,
    # `set_wm_client_machine`, `set_wm_colormap_windows`, `set_wm_icon_name`,
    # `set_wm_name`, `set_wm_properties`, `set_wm_protocols`, `X11::string_list_to_text_property`.
    def transient_for_hint(w : X11::C::Window) : X11::C::Window
      X.get_transient_for_hint @dpy, w, out prop_window_return
      prop_window_return
    end

    # Returns the actual type of the property; the actual format of the property;
    # the number of 8-bit, 16-bit, or 32-bit items transferred; the number of
    # bytes remaining to be read in the property; and a string of the data actually returned.
    #
    # ###Arguments
    # - **w** Specifies the window whose property you want to obtain.
    # - **property** Specifies the property name.
    # - **long_offset** Specifies the offset in the specified property
    # (in 32-bit quantities) where the data is to be retrieved.
    # - **long_length** Specifies the length in 32-bit multiples of the data to be retrieved.
    # - **delete** Specifies a Boolean value that determines whether the property is deleted.
    # - **req_type** Specifies the atom identifier associated with the property type or **AnyPropertyType**.
    #
    # ###Return
    # - **actual_type** Returns the atom identifier that defines the actual type of the property.
    # - **actual_format** Returns the actual format of the property.
    # - **nitems** Returns the actual number of 8-bit, 16-bit, or 32-bit items stored in the prop_return data.
    # - **bytes_after** Returns the number of bytes remaining to be read in the property if a partial read was performed.
    # - **prop** Returns the data in the specified format.
    #
    # ###Description
    # The `window_property` function returns the actual type of the property;
    # the actual format of the property; the number of 8-bit, 16-bit, or 32-bit
    # items transferred; the number of bytes remaining to be read in the property;
    # and a string of the data actually returned. `window_property` sets the return arguments as follows:
    # - If the specified property does not exist for the specified window,
    # `window_property` returns **None** to actual_type_return and the value zero
    # to actual_format_return and bytes_after_return. The nitems_return argument
    # is empty. In this case, the delete argument is ignored.
    # - If the specified property exists but its type does not match the
    # specified type, `window_property` returns the actual property type to
    # actual_type_return, the actual property format (never zero) to actual_format_return,
    # and the property length in bytes (even if the actual_format_return is 16 or 32)
    # to bytes_after_return. It also ignores the delete argument. The nitems_return argument is empty.
    # - If the specified property exists and either you assign **AnyPropertyType**
    # to the req_type argument or the specified type matches the actual property type,
    # `window_property` returns the actual property type to actual_type_return and
    # the actual property format (never zero) to actual_format_return. It also returns
    # a value to bytes_after_return and nitems_return, by defining the following values:
    # ```
    # N = actual length of the stored property in bytes (even if the format is 16 or 32)
    # I = 4 * long_offset
    # T = N - I
    # L = MINIMUM(T, 4 * long_length)
    # A = N - (I + L)
    # ```
    #The returned value starts at byte index I in the property (indexing from zero),
    # and its length in bytes is L. If the value for long_offset causes L to be negative,
    # a **BadValue** error results. The value of bytes_after_return is A, giving
    # the number of trailing unread bytes in the stored property.
    #
    # If the returned format is 8, the returned data is represented as a char array.
    # If the returned format is 16, the returned data is represented as a short array
    # and should be cast to that type to obtain the elements. If the returned format
    # is 32, the returned data is represented as a long array and should be cast
    # to that type to obtain the elements.
    #
    # If delete is **true** and bytes_after is zero, `window_property` deletes the
    # property from the window and generates a **PropertyNotify** event on the window.
    #
    # The function returns **Success** in res if it executes successfully.
    #
    # `window_property` can generate **BadAtom**, **BadValue**, and **BadWindow** errors.
    #
    # ###Diagnostics
    # - **BadAtom** A value for an *Atom* argument does not name a defined *Atom*.
    # - **BadValue** Some numeric value falls outside the range of values accepted
    # by the request. Unless a specific range is specified for an argument, the
    # full range defined by the argument's type is accepted. Any argument defined
    # as a set of alternatives can generate this error.
    # - **BadWindow** A value for a *Window* argument does not name a defined *Window*.
    #
    # ###See also
    # `change_property`, `delete_property`, `properties`, `rotate_window_properties`.
    def window_property(w : X11::C::Window, property : Atom | X11::C::Atom, long_offset : Int64, long_length : Int64, delete : Bool, req_type : Atom | X11::C::Atom) : NamedTuple(actual_type: X11::C::Atom, actual_format: Int32, nitems: UInt64, bytes_after: UInt64, prop: String, res: Int32)
      res = X.get_window_property @dpy, w, property.to_u64, long_offset, long_length, delete ? X::True : X::False, req_type.to_u64, out actual_type_return, out actual_format_return, out nitems_return, out bytes_after_return, out prop_return
      if prop_return.null?
        string = ""
      else
        string = String.new prop_return
        X.free prop_return
      end
      {actual_type: actual_type_return, actual_format: actual_format_return, nitems: nitems_return, bytes_after: bytes_after_return, prop: string, res: res}
    end

    # Returns the specified window's attributes in the `WindowAttributes` structure.
    #
    # ###Arguments
    # - **w** Specifies the window whose current attributes you want to obtain.
    #
    # ###Description
    # The `window_attributes` function returns the current attributes for the
    # specified window to an `WindowAttributes` structure.
    #
    # The **x** and **y** members are set to the upper-left outer corner relative to the parent window's origin.
    #
    # The **width** and **height** members are set to the inside size of the window, not including the border.
    #
    # The **border_width** member is set to the window's border width in pixels.
    #
    # The **depth** member is set to the depth of the window (that is, bits per pixel for the object).
    #
    # The **visual** member is a pointer to the screen's associated `Visual` structure.
    #
    # The **root** member is set to the root window of the screen containing the window.
    #
    # The **class** member is set to the window's class and can be either **InputOutput** or **InputOnly**.
    #
    # The **bit_gravity** member is set to the window's bit gravity and can be one of the following:
    # - **ForgetGravity**    **EastGravity**
    # - **NorthWestGravity** **SouthWestGravity**
    # - **NorthGravity**     **SouthGravity**
    # - **NorthEastGravity** **SouthEastGravity**
    # - **WestGravity**      **StaticGravity**
    # - **CenterGravity**
    #
    # The **win_gravity** member is set to the window's window gravity and can be one of the following:
    # - **UnmapGravity**     **EastGravity**
    # - **NorthWestGravity** **SouthWestGravity**
    # - **NorthGravity**     **SouthGravity**
    # - **NorthEastGravity** **SouthEastGravity**
    # - **WestGravity**      **StaticGravity**
    # - **CenterGravity**
    #
    # The **backing_store** member is set to indicate how the X server should maintain
    # the contents of a window and can be **WhenMapped**, **Always**, or **NotUseful**.
    #
    # The **backing_planes** member is set to indicate (with bits set to 1) which
    # bit planes of the window hold dynamic data that must be preserved in backing_stores and during save_unders.
    #
    # The **backing_pixel** member is set to indicate what values to use for planes not set in backing_planes.
    #
    # The **save_under** member is set to **true** or **false**.
    #
    # The **colormap** member is set to the colormap for the specified window and can be a colormap ID or **None**.
    #
    # The **map_installed** member is set to indicate whether the colormap is currently installed and can be **true** or **false**.
    #
    # The **map_state** member is set to indicate the state of the window and can
    # be **IsUnmapped**, **IsUnviewable**, or **IsViewable**. **IsUnviewable** is
    # used if the window is mapped but some ancestor is unmapped.
    #
    # The **all_event_masks** member is set to the bitwise inclusive OR of all
    # event masks selected on the window by all clients.
    #
    # The **your_event_mask** member is set to the bitwise inclusive OR of all
    # event masks selected by the querying client.
    #
    # The **do_not_propagate_mask** member is set to the bitwise inclusive OR of
    # the set of events that should not propagate.
    #
    # The **override_redirect** member is set to indicate whether this window
    # overrides structure control facilities and can be **true** or **false**.
    # Window manager clients should ignore the window if this member is **true**.
    #
    # The **screen** member is set to a screen pointer that gives you a back
    # pointer to the correct screen. This makes it easier to obtain the screen
    # information without having to loop over the root window fields to see which field matches.
    #
    # `window_attributes` can generate **BadDrawable** and **BadWindow** errors.
    #
    # ###Diagnostics
    # - **BadDrawable** A value for a *Drawable* argument does not name a defined *Window* or *Pixmap*.
    # - **BadWindow** A value for a *Window* argument does not name a defined *Window*.
    #
    # ###See also
    # `geometry`, `query_pointer`, `query_tree`.
    def window_attributes(w : X11::C::Window) : WindowAttributes
      X.get_window_property @dpy, w, out pattributes
      WindowAttributes.new pattributes
    end

    # Establishes a passive grab.
    #
    # ###Arguments
    # - **button** Specifies the pointer button that is to be grabbed or **AnyButton**.
    # - **modifiers** Specifies the set of keymasks or **AnyModifier**. The mask
    # is the bitwise inclusive OR of the valid keymask bits.
    # - **grab_window** Specifies the grab window.
    # - **owner_events** Specifies a Boolean value that indicates whether the
    # pointer events are to be reported as usual or reported with respect to the
    # grab window if selected by the event mask.
    # - **event_mask** Specifies which pointer events are reported to the client.
    # The mask is the bitwise inclusive OR of the valid pointer event mask bits.
    # - **pointer_mode** Specifies further processing of pointer events.
    # You can pass **GrabModeSync** or **GrabModeAsync**.
    # - **keyboard_mode** Specifies further processing of keyboard events.
    # You can pass **GrabModeSync** or **GrabModeAsync**.
    # - **confine_to*** Specifies the window to confine the pointer in or **None**.
    # - **cursor** Specifies the cursor that is to be displayed or **None**.
    #
    # ###Description
    # The `grab_button` function establishes a passive grab. In the future, the
    # pointer is actively grabbed (as for `grab_pointer`), the last-pointer-grab
    # time is set to the time at which the button was pressed (as transmitted in
    # the **ButtonPress** event), and the **ButtonPress** event is reported if
    # all of the following conditions are true:
    # - The pointer is not grabbed, and the specified button is logically pressed
    # when the specified modifier keys are logically down,
    # and no other buttons or modifier keys are logically down.
    # - The **grab_window** contains the pointer.
    # - The **confine_to** window (if any) is viewable.
    # - A passive grab on the same button/key combination does not exist on any ancestor of grab_window.
    #
    # The interpretation of the remaining arguments is as for `grab_pointer`.
    # The active grab is terminated automatically when the logical state of the
    # pointer has all buttons released (independent of the state of the logical modifier keys).
    #
    # Note that the logical state of a device (as seen by client applications)
    # may lag the physical state if device event processing is frozen.
    #
    # This request overrides all previous grabs by the same client on the same
    # button/key combinations on the same window. A modifiers of **AnyModifier**
    # is equivalent to issuing the grab request for all possible modifier combinations
    # (including the combination of no modifiers). It is not required that all
    # modifiers specified have currently assigned **KeyCodes**. A button of
    # **AnyButton** is equivalent to issuing the request for all possible buttons.
    # Otherwise, it is not required that the specified button currently be assigned to a physical button.
    #
    # If some other client has already issued a `grab_button` with the same
    # button/key combination on the same window, a **BadAccess** error results.
    # When using **AnyModifier** or **AnyButton**, the request fails completely,
    # and a **BadAccess** error results (no grabs are established) if there is a
    # conflicting grab for any combination. `grab_button` has no effect on an active grab.
    #
    # `grab_button` can generate **BadCursor**, **BadValue**, and **BadWindow** errors.
    #
    # ###Diagnostics
    # - **BadCursor** A value for a *Cursor* argument does not name a defined *Cursor*.
    # - **BadValue** Some numeric value falls outside the range of values accepted
    # by the request. Unless a specific range is specified for an argument, the
    # full range defined by the argument's type is accepted. Any argument defined
    # as a set of alternatives can generate this error.
    # - **BadWindow** A value for a *Window* argument does not name a defined *Window*.
    #
    # ###See also
    # `allow_events`, `change_active_pointer_grab`, `grab_key`, `grab_keyboard`,
    # `grab_pointer`, `ungrab_pointer`.
    def grab_button(button : UInt32, modifiers : UInt32, grab_window : X11::C::Window, owner_events : Bool, event_mask : UInt32, pointer_mode : Int32, keyboard_mode : Int32, confine_to : X11::C::Window, cursor : X11::C::Cursor) : Int32
      X.grab_button @dpy, button, modifiers, grab_window, owner_events ? X::True : X::False, event_mask, pointer_mode, keyboard_mode, confine_to, cursor
    end

    # Establishes a passive grab on the keyboard.
    #
    # ###Arguments
    # - **keycode** Specifies the *KeyCode* or **AnyKey**.
    # - **modifiers** Specifies the set of keymasks or **AnyModifier**.
    # The mask is the bitwise inclusive OR of the valid keymask bits.
    # - **grab_window** Specifies the grab window.
    # - **owner_events** Specifies a Boolean value that indicates whether the
    # keyboard events are to be reported as usual.
    # - **pointer_mode** Specifies further processing of pointer events.
    # You can pass **GrabModeSync** or **GrabModeAsync**.
    # - **keyboard_mode** Specifies further processing of keyboard events.
    # You can pass **GrabModeSync** or **GrabModeAsync**.
    #
    # ###Description
    # The `grab_key` function establishes a passive grab on the keyboard. In the
    # future, the keyboard is actively grabbed (as for `grab_keyboard`), the
    # last-keyboard-grab time is set to the time at which the key was pressed
    # (as transmitted in the **KeyPress** event), and the **KeyPress** event is
    # reported if all of the following conditions are true:
    # - The keyboard is not grabbed and the specified key (which can itself be
    # a modifier key) is logically pressed when the specified modifier keys are
    # logically down, and no other modifier keys are logically down.
    # - Either the grab_window is an ancestor of (or is) the focus window, or the
    # grab_window is a descendant of the focus window and contains the pointer.
    # - A passive grab on the same key combination does not exist on any ancestor of grab_window.
    #
    # The interpretation of the remaining arguments is as for `grab_keyboard`.
    # The active grab is terminated automatically when the logical state of the
    # keyboard has the specified key released (independent of the logical state of the modifier keys).
    #
    # Note that the logical state of a device (as seen by client applications)
    # may lag the physical state if device event processing is frozen.
    #
    # A modifiers argument of **AnyModifier** is equivalent to issuing the request
    # for all possible modifier combinations (including the combination of no modifiers).
    # It is not required that all modifiers specified have currently assigned KeyCodes.
    # A keycode argument of **AnyKey** is equivalent to issuing the request for all
    # possible KeyCodes. Otherwise, the specified keycode must be in the range
    # specified by min_keycode and max_keycode in the connection setup, or a **BadValue** error results.
    #
    # If some other client has issued a `grab_key` with the same key combination
    # on the same window, a **BadAccess** error results. When using **AnyModifier**
    # or **AnyKey**, the request fails completely, and a **BadAccess** error results
    # (no grabs are established) if there is a conflicting grab for any combination.
    #
    # `grab_key` can generate **BadAccess**, **BadValue**, and **BadWindow** errors.
    #
    # ###Diagnostics
    # - **BadAccess** A client attempted to free a color map entry that it did not already allocate.
    # - **BadAccess** A client attempted to store into a read-only color map entry.
    # - **BadValue** Some numeric value falls outside the range of values accepted
    # by the request. Unless a specific range is specified for an argument, the full
    # range defined by the argument's type is accepted. Any argument defined as a set of alternatives can generate this error.
    # - **BadWindow** A value for a *Window* argument does not name a defined *Window*.
    #
    # ###See also
    # `allow_events`, `grab_button`, `grab_keyboard`, `grab_pointer`, `ungrab_key`.
    def grab_key(keycode : Int32, modifiers : UInt32, grab_window : X11::C::Window, owner_events : Bool, pointer_mode : Int32, keyboard_mode : Int32) : Int32
      X.grab_key @dpy, keycode, modifiers, grab_window, owner_events, pointer_mode, keyboard_mode
    end

    # Actively grabs control of the keyboard and generates **FocusIn** and **FocusOut** events.
    #
    # ###Arguments
    # - **grab_window** Specifies the grab window.
    # - **owner_events** Specifies a Boolean value that indicates whether the
    # keyboard events are to be reported as usual.
    # - **pointer_mode** Specifies further processing of pointer events.
    # You can pass **GrabModeSync** or **GrabModeAsync**.
    # - **keyboard_mode** Specifies further processing of keyboard events.
    # You can pass **GrabModeSync** or **GrabModeAsync**.
    # - **time** Specifies the time. You can pass either a timestamp or **CurrentTime**.
    #
    # ###Description
    # The `grab_keyboard` function actively grabs control of the keyboard and
    # generates **FocusIn** and **FocusOut** events. Further key events are
    # reported only to the grabbing client. `grab_keyboard` overrides any active
    # keyboard grab by this client. If owner_events is **false**, all generated key
    # events are reported with respect to grab_window. If owner_events is **true**
    # and if a generated key event would normally be reported to this client, it
    # is reported normally; otherwise, the event is reported with respect to the grab_window.
    # Both **KeyPress** and **KeyRelease** events are always reported, independent
    # of any event selection made by the client.
    #
    # If the keyboard_mode argument is **GrabModeAsync**, keyboard event processing
    # continues as usual. If the keyboard is currently frozen by this client, then
    # processing of keyboard events is resumed. If the keyboard_mode argument is
    # **GrabModeSync**, the state of the keyboard (as seen by client applications)
    # appears to freeze, and the X server generates no further keyboard events until
    # the grabbing client issues a releasing `allow_events` call or until the keyboard
    # grab is released. Actual keyboard changes are not lost while the keyboard is
    # frozen; they are simply queued in the server for later processing.
    #
    # If pointer_mode is **GrabModeAsync**, pointer event processing is unaffected
    # by activation of the grab. If pointer_mode is **GrabModeSync**, the state
    # of the pointer (as seen by client applications) appears to freeze, and the
    # X server generates no further pointer events until the grabbing client issues
    # a releasing `allow_events` call or until the keyboard grab is released.
    # Actual pointer changes are not lost while the pointer is frozen;
    # they are simply queued in the server for later processing.
    #
    # If the keyboard is actively grabbed by some other client, `grab_keyboard`
    # fails and returns **AlreadyGrabbed**. If grab_window is not viewable, it
    # fails and returns **GrabNotViewable**. If the keyboard is frozen by an active
    # grab of another client, it fails and returns **GrabFrozen**. If the specified time
    # is earlier than the last-keyboard-grab time or later than the current X server
    # time, it fails and returns **GrabInvalidTime**. Otherwise, the last-keyboard-grab
    # time is set to the specified time (**CurrentTime** is replaced by the current X server time).
    #
    # `grab_keyboard` can generate **BadValue** and **BadWindow** errors.
    #
    # ###Diagnostics
    # - **BadValue** Some numeric value falls outside the range of values accepted
    # by the request. Unless a specific range is specified for an argument, the
    # full range defined by the argument's type is accepted.
    # Any argument defined as a set of alternatives can generate this error.
    # - **BadWindow** A value for a *Window* argument does not name a defined *Window*.
    #
    # ###See also
    # `allow_events`, `grab_button`, `grab_key`, `grab_pointer`, `ungrab_keyboard`.
    def grab_keyboard(grab_window : X11::C::Window, owner_events : Bool, pointer_mode : Int32, keyboard_mode : Int32, time : X11::C::Time) : Int32
      X.grab_keyboard @dpy, grab_window, owner_events ? X::True : X::False, pointer_mode, keyboard_mode, time
    end

    # Actively grabs control of the pointer and returns **GrabSuccess** if the grab was successful.
    #
    # ###Arguments
    # - **grab_window** Specifies the grab window.
    # - **owner_events** Specifies a Boolean value that indicates whether the
    # pointer events are to be reported as usual or reported with respect to the
    # grab window if selected by the event mask.
    # - **event_mask** Specifies which pointer events are reported to the client.
    # The mask is the bitwise inclusive OR of the valid pointer event mask bits.
    # - **pointer_mode** Specifies further processing of pointer events.
    # You can pass **GrabModeSync** or **GrabModeAsync**.
    # - **keyboard_mode** Specifies further processing of keyboard events.
    # You can pass **GrabModeSync** or **GrabModeAsync**.
    # - **confine_to** Specifies the window to confine the pointer in or **None**.
    # - **cursor** Specifies the cursor that is to be displayed during the grab or **None**.
    # - **time** Specifies the time. You can pass either a timestamp or **CurrentTime**.
    #
    # ###Description
    # The `grab_pointer` function actively grabs control of the pointer and
    # returns **GrabSuccess** if the grab was successful. Further pointer events
    # are reported only to the grabbing client. `grab_pointer` overrides any
    # active pointer grab by this client. If owner_events is **false**, all
    # generated pointer events are reported with respect to grab_window and are
    # reported only if selected by event_mask. If owner_events is **true** and
    # if a generated pointer event would normally be reported to this client, it
    # is reported as usual. Otherwise, the event is reported with respect to the
    # grab_window and is reported only if selected by event_mask. For either value
    # of owner_events, unreported events are discarded.
    #
    # If the pointer_mode is **GrabModeAsync**, pointer event processing continues
    # as usual. If the pointer is currently frozen by this client, the processing
    # of events for the pointer is resumed. If the pointer_mode is **GrabModeSync**,
    # the state of the pointer, as seen by client applications, appears to freeze,
    # and the X server generates no further pointer events until the grabbing client
    # calls `allow_events` or until the pointer grab is released. Actual pointer
    # changes are not lost while the pointer is frozen;
    # they are simply queued in the server for later processing.
    #
    # If the keyboard_mode is **GrabModeAsync**, keyboard event processing is
    # unaffected by activation of the grab. If the keyboard_mode is **GrabModeSync**,
    # the state of the keyboard, as seen by client applications, appears to freeze,
    # and the X server generates no further keyboard events until the grabbing client
    # calls `allow_events` or until the pointer grab is released. Actual keyboard
    # changes are not lost while the pointer is frozen;
    # they are simply queued in the server for later processing.
    #
    # If a cursor is specified, it is displayed regardless of what window the pointer
    # is in. If **None** is specified, the normal cursor for that window is displayed
    # when the pointer is in grab_window or one of its subwindows; otherwise, the cursor for grab_window is displayed.
    #
    # If a confine_to window is specified, the pointer is restricted to stay contained
    # in that window. The confine_to window need have no relationship to the
    # grab_window. If the pointer is not initially in the confine_to window, it
    # is warped automatically to the closest edge just before the grab activates
    # and enter/leave events are generated as usual. If the confine_to window is
    # subsequently reconfigured, the pointer is warped automatically, as necessary,
    # to keep it contained in the window.
    #
    # The time argument allows you to avoid certain circumstances that come up if
    # applications take a long time to respond or if there are long network delays.
    # Consider a situation where you have two applications, both of which normally
    # grab the pointer when clicked on. If both applications specify the timestamp
    # from the event, the second application may wake up faster and successfully
    # grab the pointer before the first application. The first application then will
    # get an indication that the other application grabbed the pointer before its request was processed.
    #
    # `grab_pointer` generates **EnterNotify** and **LeaveNotify** events.
    #
    # Either if grab_window or confine_to window is not viewable or if the
    # confine_to window lies completely outside the boundaries of the root window,
    # `grab_pointer` fails and returns **GrabNotViewable**. If the pointer is
    # actively grabbed by some other client, it fails and returns **AlreadyGrabbed**.
    # If the pointer is frozen by an active grab of another client, it fails and
    # returns **GrabFrozen**. If the specified time is earlier than the
    # last-pointer-grab time or later than the current X server time, it fails
    # and returns GrabInvalidTime. Otherwise, the last-pointer-grab time is set
    # to the specified time (**CurrentTime** is replaced by the current X server time).
    #
    # `grab_pointer` can generate **BadCursor**, **BadValue**, and **BadWindow** errors.
    #
    # ###Diagnostics
    # - **BadCursor** A value for a *Cursor* argument does not name a defined *Cursor*.
    # - **BadValue** Some numeric value falls outside the range of values accepted
    # by the request. Unless a specific range is specified for an argument, the full
    # range defined by the argument's type is accepted.
    # Any argument defined as a set of alternatives can generate this error.
    # - **BadWindow** A value for a *Window* argument does not name a defined *Window*.
    #
    # ###See also
    # `allow_events`, `change_active_pointer_grab`, `grab_button`, `grab_key`,
    # `grab_keyboard`, `ungrab_pointer`.
    def grab_pointer(grab_window : X11::C::Window, owner_events : Bool, event_mask : UInt32, pointer_mode : Int32, keyboard_mode : Int32, confine_to : X11::C::Window, cursor : X11::C::Cursor, time : X11::C::Time) : Int32
      X.grab_pointer @dpy, grab_window, owner_events ? X::True : X::False, event_mask, pointer_mode, keyboard_mode, confine_to, cursor, time
    end

    # Disables processing of requests and close downs
    # on all other connections than the one this request arrived on.
    #
    # ###Description
    # The `grab_server` function disables processing of requests and close downs
    # on all other connections than the one this request arrived on.
    # You should not grab the X server any more than is absolutely necessary.
    #
    # ###See also
    # `grab_key`, `grab_keyboard`, `grab_pointer`, `ungrab_server`.
    def grab_server : Int32
      X.grab_server @dpy
    end

    # Returns the matched event's associated structure.
    #
    # ###Arguments
    # - **predicate** Specifies the procedure that is to be called to determine
    # if the next event in the queue matches what you want.
    # - **arg** Specifies the user-supplied argument that will be passed to the predicate procedure.
    #
    # ###Description
    # The `if_event` function completes only when the specified predicate procedure.
    # `if_event` removes the matching event from the queue and returns it.
    #
    # ###See also
    # `check_if_event`, `next_event`, `peek_if_event`, `put_back_event`, `send_event`.
    def if_event(predicate : X11::C::X::PDisplay, PEvent, Pointer -> Bool, arg : X11::C::X::Pointer) : Event?
      X.if_event @dpy, out pevent, predicate, arg
      if pevent.null?
        nil
      else
        Event.from_xevent pevent.value
      end
    end

    # Specify the required byte order for images for each scanline unit in XY
    # format (bitmap) or for each pixel value in Z format.
    # The function can return either **LSBFirst** or **MSBFirst**.
    def image_byte_order : Int32
      X.image_byte_order @dpy
    end

    # Installs the specified colormap for its associated screen.
    #
    # ###Arguments
    # - **colormap** Specifies the colormap.
    #
    # ###Description
    # The `install_colormap` function installs the specified colormap for its
    # associated screen. All windows associated with this colormap immediately
    # display with true colors. You associated the windows with this colormap
    # when you created them by calling `create_window`, `create_simple_window`,
    # `change_window_attributes`, or `set_window_colormap`.
    #
    # If the specified colormap is not already an installed colormap, the X
    # server generates a **ColormapNotify** event on each window that has that
    # colormap. In addition, for every other colormap that is installed as a
    # result of a call to `install_colormap`, the X server generates a
    # **ColormapNotify** event on each window that has that colormap.
    #
    # `install_colormap` can generate a **BadColor** error.
    #
    # ###Diagnostics
    # - **BadColor** A value for a *Colormap* argument does not name a defined *Colormap*.
    #
    # ###See also
    # `change_window_attributes`, `create_colormap`, `create_window`, `X11::free`,
    # `installed_colormaps`, `uninstall_colormap`.
    def install_colormap(colormap : X11::C::Colormap) : Int32
      X.install_colormap @dpy, colormap
    end

    # Returns KeyCode for the specified KeySym.
    #
    # ###Arguments
    # - **keysym** Specifies the *KeySym* that is to be searched for or converted.
    #
    # ###Description
    # Standard *KeySym* names are obtained from `c/keysymdef.cr` by removing the
    # XK_ prefix from each name. *KeySyms* that are not part of the Xlib standard
    # also may be obtained with this function. The set of *KeySyms* that are
    # available in this manner and the mechanisms by which Xlib obtains them is implementation-dependent.
    #
    # If the *KeySym* name is not in the Host Portable Character Encoding, the result is implementation-dependent.
    #
    # ###See also
    # `KeyEvent::lookup_keysym`.
    def keysym_to_keycode(keysym : X11::C::KeySym) : X11::C::KeyCode
      X.keysym_to_keycode @dpy, keysym
    end

    # Forces a close-down of the client.
    #
    # ###Arguments
    # - **resource** Specifies any resource associated with the client
    # that you want to destroy or **AllTemporary**.
    #
    # ###Description
    # The `kill_client` function forces a close-down of the client that created
    # the resource if a valid resource is specified. If the client has already
    # terminated in either **RetainPermanent** or **RetainTemporary** mode, all
    # of the client's resources are destroyed. If **AllTemporary** is specified,
    # the resources of all clients that have terminated in **RetainTemporary**
    # are destroyed. This permits implementation of window manager facilities
    # that aid debugging. A client can set its close-down mode to **RetainTemporary**.
    # If the client then crashes, its windows would not be destroyed. The programmer
    #can then inspect the application's window tree and use the window manager to destroy the zombie windows.
    #
    # `kill_client` can generate a **BadValue** error.
    #
    # ###Diagnostics
    # - **BadValue** Some numeric value falls outside the range of values accepted
    # by the request. Unless a specific range is specified for an argument, the
    # full range defined by the argument's type is accepted. Any argument defined
    # as a set of alternatives can generate this error.
    #
    # ###See also
    # `set_close_down_mode`.
    def kill_client(resource : X11::C::XID) : Int32
      X.kill_client @dpy, resource
    end

    # Looks up the string name of a color with respect
    # to the screen associated with the specified colormap.
    #
    # ###Arguments
    # - **colormap** Specifies the colormap.
    # - **color_name** Specifies the color name string (for example, red) whose
    # color definition structure you want returned.
    #
    # ###Return
    # - **exact_def** Returns the exact RGB values.
    # - **screen_def** Returns the closest RGB values provided by the hardware.
    #
    # ###Description
    # The `lookup_color` function looks up the string name of a color with respect
    # to the screen associated with the specified colormap. It returns both the
    # exact color values and the closest values provided by the screen with respect
    # to the visual type of the specified colormap. If the color name is not in
    # the Host Portable Character Encoding, the result is implementation dependent.
    # Use of uppercase or lowercase does not matter.
    #
    # `lookup_color` can generate a **BadColor** error.
    #
    # ###Diagnostics
    # - **BadColor** A value for a *Colormap* argument does not name a defined *Colormap*.
    #
    # ###See also
    # `alloc_color`, `create_colormap`, `lookup_color`, `parse_color`,
    # `query_color`, `query_colors`, `store_colors`.
    def lookup_color(colormap : X11::C::Colormap, color_name : String) : NamedTuple(exact_def: Color, screen_def: Color, res: X11::C::Status)
      res = X.lookup_color @dpy, colormap, color_name.to_unsafe, out exact_def_return, out screen_def_return
      {exact_def: Color.new(exact_def_return), screen_def: Color.new(screen_def_return), res: res}
    end

    # Lowers the specified window to the bottom of
    # the stack so that it does not obscure any sibling windows.
    #
    # ###Arguments
    # - **w** Specifies the window.
    #
    # ###Description
    # The `lower_window` function lowers the specified window to the bottom of
    # the stack so that it does not obscure any sibling windows. If the windows
    # are regarded as overlapping sheets of paper stacked on a desk, then lowering
    # a window is analogous to moving the sheet to the bottom of the stack but
    # leaving its x and y location on the desk constant. Lowering a mapped window
    # will generate **Expose** events on any windows it formerly obscured.
    #
    # If the override-redirect attribute of the window is **false** and some
    # other client has selected **SubstructureRedirectMask** on the parent, the
    # X server generates a **ConfigureRequest** event, and no processing is performed.
    # Otherwise, the window is lowered to the bottom of the stack.
    #
    # `lower_window` can generate a **BadWindow** error.
    #
    # ###Diagnostics
    # - **BadWindow** A value for a *Window* argument does not name a defined *Window*.
    #
    # ###See also
    # `change_window_attributes`, `circulate_subwindows`, `circulate_subwindows_down`,
    # `circulate_subwindows_up`, `configure_window`, `create_window`,
    # `destroy_window`, `map_window`, `raise_window`, `restack_windows`.
    def lower_window(w : X11::C::Window) : Int32
      X.lower_window @dpy, w
    end

    # Maps the window and all of its subwindows that have had map requests.
    #
    # ###Arguments
    # - **w** Specifies the window.
    #
    # ###Description
    # The `map_raised` function essentially is similar to `map_window` in that
    # it maps the window and all of its subwindows that have had map requests.
    # However, it also raises the specified window to the top of the stack.
    # For additional information, see `map_window`.
    #
    # `map_raised` can generate multiple **BadWindow** errors.
    #
    # ###Diagnostics
    # - **BadWindow** A value for a *Window* argument does not name a defined *Window*.
    #
    # ###See also
    # `change_window_attributes`, `configure_window`, `create_window`,
    # `destroy_window`, `map_subwindows`, `map_window`, `unmap_window`.
    def map_raised(w : X11::C::Window) : Int32
      X.map_raised @dpy, w
    end

    # Maps all subwindows for a specified window in top-to-bottom stacking order.
    #
    # ###Arguments
    # - **w** Specifies the window.
    #
    # ###Description
    # The `map_subwindows` function maps all subwindows for a specified window
    # in top-to-bottom stacking order. The X server generates **Expose** events
    # on each newly displayed window. This may be much more efficient than mapping
    # many windows one at a time because the server needs to perform much of the
    # work only once, for all of the windows, rather than for each window.
    #
    # `map_subwindows` can generate a **BadWindow** error.
    #
    # ###Diagnostics
    # - **BadWindow** A value for a **Window** argument does not name a defined *Window*.
    #
    # ###See also
    # `change_window_attributes`, `configure_window`, `create_window`,
    # `destroy_window`, `map_raised`, `map_window`, `unmap_window`.
    def map_subwindows(w : X11::C::Window) : Int32
      X.map_subwindows @dpy, w
    end

    # Maps the window and all of its subwindows that have had map requests.
    #
    # ###Arguments
    # - **w** Specifies the window.
    #
    # ###Description
    # The `map_window` function maps the window and all of its subwindows that
    # have had map requests. Mapping a window that has an unmapped ancestor does
    # not display the window but marks it as eligible for display when the ancestor
    # becomes mapped. Such a window is called unviewable. When all its ancestors
    # are mapped, the window becomes viewable and will be visible on the screen
    # if it is not obscured by another window. This function has no effect if
    # the window is already mapped.
    #
    # If the override-redirect of the window is **false** and if some other client
    # has selected **SubstructureRedirectMask** on the parent window, then the
    # X server generates a **MapRequest** event, and the `map_window` function
    # does not map the window. Otherwise, the window is mapped,
    # and the X server generates a **MapNotify** event.
    #
    # If the window becomes viewable and no earlier contents for it are remembered,
    # the X server tiles the window with its background. If the window's background
    # is undefined, the existing screen contents are not altered, and the X server
    # generates zero or more **Expose** events. If backing-store was maintained
    # while the window was unmapped, no **Expose** events are generated. If
    # backing-store will now be maintained, a full-window exposure is always
    # generated. Otherwise, only visible regions may be reported. Similar
    # tiling and exposure take place for any newly viewable inferiors.
    #
    # If the window is an **InputOutput** window, `map_window` generates
    # **Expose** events on each **InputOutput** window that it causes to be displayed.
    # If the client maps and paints the window and if the client begins processing
    # events, the window is painted twice. To avoid this, first ask for **Expose**
    # events and then map the window, so the client processes input events as usual.
    # The event list will include Expose for each window that has appeared on the screen.
    # The client's normal response to an Expose event should be to repaint the window.
    # This method usually leads to simpler programs and to proper interaction with window managers.
    #
    # `map_window` can generate a **BadWindow** error.
    #
    # ###Diagnostics
    # - **BadWindow** A value for a *Window* argument does not name a defined *Window*.
    #
    # ###See also
    # `change_window_attributes`, `configure`, `create_window`,
    # `destroy_window`, `map_raised`, `map_subwindows`, `unmap_window`.
    def map_window(w : X11::C::Window) : Int32
      X.map_window @dpy, w
    end

    # Returns the matched event's associated structure.
    #
    # ###Arguments
    # - **event_mask** Specifies the event mask.
    #
    # ###Description
    # The `mask_event` function searches the event queue for the events associated
    # with the specified mask. When it finds a match, `mask_event` removes that event.
    # The other events stored in the queue are not discarded. If the event you
    # requested is not in the queue, `mask_event` flushes the output buffer and blocks until one is received.
    #
    # ###See also
    # `check_mask_event`, `check_typed_event`, `check_typed_window_event`,
    # `check_window_event`, `if_event`, `next_event`, `peek_event`,
    # `put_back_event`, `send_event`, `window_event`.
    def mask_event(event_mask : Int64) : Event?
      X.mask_event @dpy, event_mask, out pevent
      if pevent.null?
        nil
      else
        Event.from_xevent pevent.value
      end
    end

    # Changes the size and location of the specified window without raising it.
    #
    # ###Arguments
    # - **w** Specifies the window to be reconfigured.
    # - **x**, **y** Specify the x and y coordinates, which define the new
    # position of the window relative to its parent.
    # - **width**, **height** Specify the width and height, which define the interior size of the window.
    #
    # ###Description
    # The `move_resize_window` function changes the size and location of the
    # specified window without raising it. Moving and resizing a mapped window
    # may generate an **Expose** event on the window. Depending on the new size
    # and location parameters, moving and resizing a window may generate **Expose**
    # events on windows that the window formerly obscured.
    #
    # If the override-redirect flag of the window is **false** and some other
    # client has selected **SubstructureRedirectMask** on the parent, the X server
    # generates a **ConfigureRequest** event, and no further processing is performed.
    # Otherwise, the window size and location are changed.
    #
    # `move_resize_window` can generate **BadValue** and **BadWindow** errors.
    #
    # ###Diagnostics
    # - **BadValue** Some numeric value falls outside the range of values accepted
    # by the request. Unless a specific range is specified for an argument, the
    # full range defined by the argument's type is accepted. Any argument defined
    # as a set of alternatives can generate this error.
    # - **BadWindow** A value for a *Window* argument does not name a defined *Window*.
    #
    # ###See also
    # `change_window_attributes`, `configure_window`, `create_window`,
    # `destroy_window`, `map_window`, `move_window`, `raise_window`,
    # `resize_window`, `set_window_border_width`, `unmap_window`.
    def move_resize_window(w : X11::C::Window, x : Int32, y : Int32, width : UInt32, height : UInt32) : Int32
      X.move_resize_window @dpy, w, x, y, width, height
    end

    # Function moves the specified window to the specified x and y coordinates.
    #
    # ###Arguments
    # - **w** Specifies the window to be moved
    # - **x**, **y** Specify the x and y coordinates, which define the new
    # location of the top-left pixel of the window's border or the window itself if it has no border.
    #
    # ###Description
    # The `move_window` function moves the specified window to the specified x
    # and y coordinates, but it does not change the window's size, raise the window,
    # or change the mapping state of the window. Moving a mapped window may or may
    # not lose the window's contents depending on if the window is obscured by
    # nonchildren and if no backing store exists. If the contents of the window
    # are lost, the X server generates **Expose** events. Moving a mapped window
    # generates **Expose** events on any formerly obscured windows.
    #
    # If the override-redirect flag of the window is False and some other client
    # has selected **SubstructureRedirectMask** on the parent, the X server
    # generates a **ConfigureRequest** event, and no further processing is
    # performed. Otherwise, the window is moved.
    #
    # `move_window` can generate a **BadWindow** error.
    #
    # ###Diagnostics
    # - **BadWindow** A value for a *Window* argument does not name a defined *Window*.
    #
    # ###See also
    # `change_window_attributes`, `configure_window`, `create_window`,
    # `destroy_window`, `map_window`, `move_resize_window`, `raise_window`,
    # `resize_window`, `set_window_border_width`, `unmap_window`.
    def move_window(w : X11::C::Window, x : Int32, y : Int32) : Int32
      X.move_window @dpy, w, x, y
    end

    # Returns the next event in the queue.
    #
    # ###See also
    # `AnyEvent`, `check_mask_event`, `check_typed_event`, `check_typed_window_event`,
    # `check_window_event`, `if_event`, `mask_event`, `peek_event`,
    # `put_back_event`, `send_event`, `window_event`.
    def next_event : Event?
      if X.next_event @dpy, out xevent
        Event.from_xevent xevent
      else
        nil
      end
    end

    # sends a **NoOperation** protocol request to the X server, thereby exercising the connection.
    def no_op : Int32
      X.no_op @dpy
    end

    # Returns the exact color value for later use and sets the **DoRed**, **DoGreen**, and **DoBlue** flags.
    #
    # ###Arguments
    # - **colormap** Specifies the colormap.
    # - **spec** Specifies the color name string; case is ignored.
    #
    # ###Description
    # The `parse_color` function looks up the string name of a color with respect
    # to the screen associated with the specified colormap. It returns the exact
    # color value. If the color name is not in the Host Portable Character Encoding,
    # the result is implementation dependent. Use of uppercase or lowercase does
    # not matter.
    #
    # `parse_color` can generate a **BadColor** error.
    #
    # ###Diagnostics
    # - **BadColor** A value for a *Colormap* argument does not name a defined *Colormap*.
    #
    # ###See also
    # `alloc_color`, `create_colormap`, `lookup_color`,
    # `query_color`, `query_colors`, `store_colors`.
    def parse_color(colormap : X11::C::Colormap, spec : String) : String
      if X.parse_color @dpy, colormap, out exact_def_return
        str = String.new exact_def_return
        X.free exact_def_return
        str
      else
        ""
      end
    end

    # Returns a copy of the matched event's associated structure.
    #
    # ###Description
    # The `peek_event` function returns the first event from the event queue,
    # but it does not remove the event from the queue. If the queue is empty,
    # `peek_event` flushes the output buffer and blocks until an event is received.
    # It then copies the event into the client-supplied `Event` structure without
    # removing it from the event queue.
    #
    # ###See also
    # `check_mask_event`, `check_typed_event`, `check_typed_window_event`,
    # `check_window_event`, `if_event`, `mask_event`, `next_event`,
    # `put_back_event`, `send_event`, `window_event`.
    def peek_event : Event?
      if X.peek_event @dpy, out xevent
        Event.from_xevent xevent
      else
        nil
      end
    end

    # Returns the matched event's structure.
    #
    # ###Arguments
    # - **predicate** Specifies the procedure that is to be called to determine
    # if the next event in the queue matches what you want.
    # - **arg** Specifies the user-supplied argument that will be passed to the predicate procedure.
    #
    # ###Description
    # The `peek_if_event` function returns only when the specified predicate
    # procedure returns **True** for an event. After the predicate procedure finds
    # a match, `peek_if_event` copies the matched event into the client-supplied `Event`
    # structure without removing the event from the queue.
    #
    # ###See also
    # `check_if_event`, `if_event`, `next_event`, `put_back_event`, `send_event`.
    def peek_if_event(predicate : X11::C::X::PDisplay, PEvent, Pointer -> Bool, arg : X11::C::X::Pointer) : Event?
      if X.peek_if_event @dpy, out xevent, predicate, arg
        Event.from_xevent xevent
      else
        nil
      end
    end

    # Returns the number of events that have been received from the X server.
    #
    # ###Description
    # The `pending` function returns the number of events that have been received
    # from the X server but have not been removed from the event queue.
    # `pending` is identical to `events_queued` with the mode **QueuedAfterFlush** specified.
    #
    # ###See also
    # `events_queued`, `flush`, `if_event`, `next_event`, `put_back_event`, `sync`.
    def pending : Int32
      X.pending @dpy
    end

    # Returns the minor protocol revision number of the X server.
    def protocol_revision : Int32
      X.protocol_revision @dpy
    end

    # Returns the major version number (11) of the X protocol associated with the connected display.
    def protocol_version : Int32
      X.protocol_version @dpy
    end

    # Pushes an event back onto the head of the display's event queue.
    #
    # ###Arguments
    # - **event** Specifies the event.
    #
    # ###Description
    # The `put_back_event` function pushes an event back onto the head of the
    # display's event queue by copying the event into the queue. This can be
    # useful if you read an event and then decide that you would rather deal
    # with it later. There is no limit to the number of times in succession that you can call `put_back_event`.
    #
    # ###See also
    # `if_event`, `next_event`, `send_event`.
    def put_back_event(event : Event) : Int32
      X.put_back_event @dpy, event.to_unsafe
    end

    # Combines an image with a rectangle of the specified drawable.
    #
    # ###Arguments
    # - **d** Specifies the drawable.
    # - **gc** Specifies the GC.
    # - **image** Specifies the image you want combined with the rectangle.
    # - **src_x** Specifies the offset in X from the left edge of the image defined by the `Image` object.
    # - **src_y** Specifies the offset in Y from the top edge of the image defined by the `Image` object.
    # - **dest_x**, **dest_y** Specify the x and y coordinates, which are relative
    # to the origin of the drawable and are the coordinates of the subimage.
    # - **width**, **height** Specify the width and height of the subimage,
    # which define the dimensions of the rectangle.
    #
    # ###Description
    # The `put_image` function combines an image with a rectangle of the specified
    # drawable. The section of the image defined by the src_x, src_y, width, and
    # height arguments is drawn on the specified part of the drawable. If
    # **XYBitmap** format is used, the depth of the image must be one, or a
    # **BadMatch** error results. The foreground pixel in the GC defines the
    # source for the one bits in the image, and the background pixel defines the
    # source for the zero bits. For **XYPixmap** and **ZPixmap**, the depth of
    # the image must match the depth of the drawable, or a **BadMatch** error results.
    #
    # If the characteristics of the image (for example, byte_order and bitmap_unit)
    # differ from what the server requires, `put_image` automatically makes the appropriate conversions.
    #
    # This function uses these GC components: function, plane-mask, subwindow-mode,
    # clip-x-origin, clip-y-origin, and clip-mask. It also uses these GC
    # mode-dependent components: foreground and background.
    #
    # `put_image` can generate **BadDrawable**, **BadGC**, **BadMatch**, and **BadValue** errors.
    #
    # ###Diagnostics
    # - **BadDrawable** A value for a *Drawable* argument does not name a defined *Window* or *Pixmap*.
    # - **BadGC** A value for a `GContext` argument does not name a defined `GContext`.
    # - **BadMatch** An **InputOnly** window is used as a *Drawable*.
    # - **BadMatch** Some argument or pair of arguments has the correct type and
    # range but fails to match in some other way required by the request.
    # - **BadValue** Some numeric value falls outside the range of values accepted
    # by the request. Unless a specific range is specified for an argument, the
    # full range defined by the argument's type is accepted.
    # Any argument defined as a set of alternatives can generate this error.
    #
    # ###See also
    # `add_pixel`, `create_image`, `destroy_image`, `get_pixel`, `init_image`,
    # `put_pixel`, `get_sub_image`.
    def put_image(d : X11::C::Drawable, gc : X11::C::X::GC, image : Image, src_x : Int32, src_y : Int32, dest_x : Int32, dest_y : Int32, width : UInt32, height : UInt32) : Int32
      X.put_image @dpy, d, gc, image.to_unsafe, src_x, src_y, dest_x, dest_y, width, height
    end

    # Returns the length of the event queue for the connected display. Note that
    # there may be more events that have not been read into the queue yet (see `events_queued`).
    def q_length : Int32
      X.q_length @dpy
    end

    # Provides a way to find out what size cursors are actually possible on the display.
    #
    # ###Arguments
    # - **d** Specifies the drawable, which indicates the screen.
    # - **width**, **height** Specify the width and height of the cursor that you want the size information for.
    #
    # ###Returns
    # - **width**, **height** Returns the best width and height that is closest to the specified width and height.
    #
    # ###Description
    # Some displays allow larger cursors than other displays. The `query_best_cursor`
    # function provides a way to find out what size cursors are actually possible on
    # the display. It returns the largest size that can be displayed. Applications
    # should be prepared to use smaller cursors on displays that cannot support large ones.
    #
    # `query_best_cursor` can generate a **BadDrawable** error.
    #
    # ###Diagnostics
    # - **BadDrawable** A value for a *Drawable* argument does not name a defined *Window* or *Pixmap*.
    #
    # ###See also
    # `create_colormap`, `create_font_cursor`, `define_cursor`, `free_cursor`, `recolor_cursor`.
    def query_best_cursor(d : X11::C::Drawable, width : UInt32, height : UInt32) : NamedTuple(width: UInt32, height: UInt32, status: X11::C::X::Status)
      status = X.query_best_cursor @dpy, d, width, height, out width_return, out height_return
      {width: width_return, height: height_return, status: status}
    end

    # Returns the best or closest size to the specified size.
    #
    # ###Arguments
    # - **c_class** Specifies the class that you are interested in.
    # You can pass **TileShape**, **CursorShape**, or **StippleShape**.
    # - **which_screen** Specifies any drawable on the screen.
    # - **width**, **height** Specify the width and height.
    #
    # ###Returns
    # - **width**, **height** Return the width and height of the object best supported by the display hardware.
    #
    # ###Description
    # The `query_best_size` function returns the best or closest size to the
    # specified size. For **CursorShape**, this is the largest size that can be
    # fully displayed on the screen specified by which_screen. For **TileShape**,
    # this is the size that can be tiled fastest. For **StippleShape**, this is
    # the size that can be stippled fastest. For **CursorShape**, the drawable
    # indicates the desired screen. For **TileShape** and **StippleShape**, the
    # drawable indicates the screen and possibly the window class and depth.
    # An **InputOnly** window cannot be used as the drawable for **TileShape** or
    # **StippleShape**, or a **BadMatch** error results.
    #
    # `query_best_size` can generate **BadDrawable**, **BadMatch**, and **BadValue** errors.
    #
    # ###Diagnostics
    # - **BadDrawable** A value for a *Drawable* argument does not name a defined *Window* or *Pixmap*.
    # - **BadMatch** An **InputOnly** window is used as a *Drawable*.
    # - **BadMatch** Some argument or pair of arguments has the correct type and
    # range but fails to match in some other way required by the request.
    # - **BadValue** Some numeric value falls outside the range of values accepted
    # by the request. Unless a specific range is specified for an argument, the full
    # range defined by the argument's type is accepted. Any argument defined as a set of alternatives can generate this error.
    #
    # ###See also
    # `create_gc`, `query_best_tile`, `query_best_stipple`, `set_arc_mode`,
    # `set_clip_origin`, `set_fill_style`, `set_font`, `set_line_attributes`,
    # `set_state`, `set_tile`.
    def query_best_size(c_class : Int32, which_screen : X11::C::Drawable, width : UInt32, height : UInt32) : NamedTuple(width: UInt32, height: UInt32, status: X11::C::X::Status)
      status = X.query_best_size @dpy, c_class, which_screen, width, height, out width_return, out height_return
      {width: width_return, height: height_return, status: status}
    end

    # Returns the best or closest size.
    #
    # ###Arguments
    # - **which_screen** Specifies any drawable on the screen.
    # - **width**, **height** Specify the width and height.
    #
    # ###Returns
    # - **width**, **height** Return the width and height of the object best
    # supported by the display hardware.
    #
    # ###Description
    # The `query_best_stipple` function returns the best or closest size, that
    # is, the size that can be stippled fastest on the screen specified by
    # which_screen. The drawable indicates the screen and possibly the window
    # class and depth. If an **InputOnly** window is used as the drawable, a **BadMatch** error results.
    # `query_best_stipple` can generate **BadDrawable** and **BadMatch** errors.
    #
    # ###Diagnostics
    # - **BadDrawable** A value for a *Drawable* argument does not name a defined *Window* or *Pixmap*.
    # - **BadMatch** An **InputOnly** window is used as a *Drawable*.
    # - **BadMatch** Some argument or pair of arguments has the correct type and
    # range but fails to match in some other way required by the request.
    #
    # ###See also
    # `create_gc`, `query_best_tile`, `query_best_size`, `set_arc_mode`,
    # `set_clip_origin`, `set_fill_style`, `set_font`, `set_line_attributes`,
    # `set_state`, `set_tile`.
    def query_best_stipple(which_screen : X11::C::Drawable, width : UInt32, height : UInt32) : NamedTuple(width: UInt32, height: UInt32, status: X11::C::X::Status)
      status = X.query_best_stipple @dpy, which_screen, width, height, out width_return, out height_return
      {width: width_return, height: height_return, status: status}
    end

    # Returns the best or closest size.
    #
    # ###Arguments
    # - **which** Specifies any drawable on the screen.
    # - **width**, **height** Specify the width and height.
    #
    # ###Returns
    # - **width**, **height** Return the width and height of the object best
    # supported by the display hardware.
    #
    # ###Description
    # The `query_best_tile` function returns the best or closest size, that is,
    # the size that can be tiled fastest on the screen specified by which_screen.
    # The drawable indicates the screen and possibly the window class and depth.
    # If an **InputOnly** window is used as the drawable, a **BadMatch** error results.
    #
    # `query_best_tile` can generate **BadDrawable** and **BadMatch** errors.
    #
    # ###Diagnostics
    # - **BadDrawable** A value for a *Drawable* argument does not name a defined *Window* or *Pixmap*.
    # - **BadMatch** An **InputOnly** window is used as a *Drawable*.
    # - **BadMatch** Some argument or pair of arguments has the correct type and
    # range but fails to match in some other way required by the request.
    #
    # ###See also
    # `create_gc`, `query_best_size`, `query_best_stipple`, `set_arc_mode`,
    # `set_clip_origin`, `set_fill_style`, `set_font`,
    # `set_line_attributes`, `set_state`, `set_tile`.
    def query_best_tile(which_screen : X11::C::Drawable, width : UInt32, height : UInt32) : NamedTuple(width: UInt32, height: UInt32, status: X11::C::X::Status)
      status = X.query_best_tile @dpy, which_screen, width, height, out width_return, out height_return
      {width: width_return, height: height_return, status: status}
    end

    # Returns the current RGB value for the pixel in the `Color` structure.
    #
    # ###Arguments
    # - **colormap** Specifies the colormap.
    # - **def_in** Specifies and returns the RGB values for the pixel specified in the structure.
    #
    # ###Description
    # The `query_color` function returns the current RGB value for the pixel in
    # the `Color` structure and sets the **DoRed**, **DoGreen**, and **DoBlue** flags.
    #
    # `query_color` can generate **BadColor** and **BadValue** errors.
    #
    # ###Diagnostics
    # - **BadColor** A value for a *Colormap* argument does not name a defined *Colormap*.
    # - **BadValue** Some numeric value falls outside the range of values accepted
    # by the request. Unless a specific range is specified for an argument, the
    # full range defined by the argument's type is accepted.
    # Any argument defined as a set of alternatives can generate this error.
    #
    # ###See also
    # `alloc_color`, `create_colormap`, `lookup_color`, `parse_color`,
    # `query_colors`, `store_colors`.
    def query_color(colormap : X11::C::Colormap, def_in : Color) : Color
      xcolor = def_in.to_x
      X.query_color @dpy, colormap, pointerof(xcolor)
      Color.new xcolor
    end

    # Returns the RGB value for each pixel in each `Color` structure.
    #
    # ###Arguments
    # - **colormap** Specifies the colormap.
    # - **defs_in Specifies and returns an array of color definition structures
    # for the pixel specified in the structure.
    #
    # ###Description
    # The `query_colors` function returns the RGB value for each pixel in each
    # `Color` structure and sets the **DoRed**, **DoGreen**, and **DoBlue** flags in each structure.
    #
    # `query_colors` can generate **BadColor** and **BadValue** errors.
    #
    # ###Diagnostics
    # - **BadColor** A value for a *Colormap* argument does not name a defined *Colormap*.
    # - **BadValue** Some numeric value falls outside the range of values accepted
    # by the request. Unless a specific range is specified for an argument,
    # the full range defined by the argument's type is accepted.
    # Any argument defined as a set of alternatives can generate this error.
    #
    # ###See also
    # `alloc_color`, `create_colormap`, `lookup_color`, `parse_color`,
    # `query_color`, `query_colors`, `store_colors`.
    def query_colors(colormap : X11::C::Colormap, defs_in : Array(Color)) : Array(Color)
      xcolors = defs_in.map(&.to_x)
      X.query_colors @dpy, colormap xcolors.to_unsafe, xcolors.size
      xcolors.map { |xcolor| Color.new xcolor }
    end

    # Determines if the named extension is present.
    #
    # ###Arguments
    # - **name** Specifies the extension name.
    #
    # ###Returns
    # - **major_opcode** Returns the major opcode.
    # - **first_event** Returns the first event code, if any. Specifies the extension list.
    #
    # ###Description
    # The `query_extension` function determines if the named extension is present.
    # If the extension is not present, `query_extension` returns **false**;
    # otherwise, it returns **true**. If the extension is present,
    # `query_extension` returns the major opcode for the extension to major_opcode;
    # otherwise, it returns zero. Any minor opcode and the request formats are specific
    # to the extension. If the extension involves additional event types,
    # `query_extension` returns the base event type code to first_event;
    # otherwise, it returns zero. The format of the events is specific to the extension.
    # If the extension involves additional error codes, `query_extension` returns
    # the base error code to first_error; otherwise, it returns zero.
    # The format of additional data in the errors is specific to the extension.
    #
    # ###See also
    # `extensions`.
    def query_extension(name : String) : NamedTuple(major_opcode: Int32, first_event: Int32, first_error: Int32, res: Bool)
      res = X.query_extension @dpy, name.to_unsafe, out major_opcode_return, out first_event_return, out first_error_return
      {major_opcode: major_opcode_return, first_event: first_event_return, first_error: first_error_return, res: res == X::True ? true : false}
    end

    # Returns a bit vector for the logical state of the keyboard.
    #
    # ###Description
    # The `query_keymap` function returns a bit vector for the logical state of
    # the keyboard, where each bit set to 1 indicates that the corresponding key
    # is currently pressed down. The vector is represented as 32 bytes.
    # Byte N (from 0) contains the bits for keys 8N to 8N + 7 with the
    # least-significant bit in the byte representing key 8N.
    #
    # Note that the logical state of a device (as seen by client applications)
    # may lag the physical state if device event processing is frozen.
    #
    # ###See also
    # `auto_repeat_off`, `auto_repeat_on`, `bell`, `change_keyboard_control`,
    # `change_keyboard_mapping`, `keyboard_control`, `set_pointer_mapping`.
    def query_keymap : StaticArray(UInt8, 32)
      keys_return = StaticArray(UInt8, 32).new
      X.query_keymap @dpy, keys_return.to_unsafe
      keys_return
    end

    # Returns the root window the pointer is logically
    # on and the pointer coordinates relative to the root window's origin.
    #
    # ###Arguments
    # - **w** Specifies the window.
    #
    # ###Returns
    # - **root** Returns the root window that the pointer is in.
    # - **child** Returns the child window that the pointer is located in, if any.
    # - **root_x**, **root_y** Return the pointer coordinates relative to the root window's origin.
    # - **win_x**, **win_y** Return the pointer coordinates relative to the specified window.
    # - **mask** Returns the current state of the modifier keys and pointer buttons.
    #
    # ###Description
    # The `query_pointer` function returns the root window the pointer is logically
    # on and the pointer coordinates relative to the root window's origin.
    # If `query_pointer` returns **false**, the pointer is not on the same screen
    # as the specified window, and `query_pointer` returns **None** to child
    # and zero to win_X and win_y. If `query_pointer` returns **true**,
    # the pointer coordinates returned to win_x and win_y are relative
    # to the origin of the specified window. In this case, `query_pointer` returns
    # the child that contains the pointer, if any, or else **None** to child.
    #
    # `query_pointer` returns the current logical state of the keyboard buttons
    # and the modifier keys in mask. It sets mask_return to the bitwise inclusive
    # OR of one or more of the button or modifier key bitmasks to match the
    # current state of the mouse buttons and the modifier keys.
    #
    # Note that the logical state of a device (as seen through Xlib) may lag the
    # physical state if device event processing is frozen.
    #
    # `query_pointer` can generate a **BadWindow** error.
    #
    # ###Diagnostics
    # - **BadWindow** A value for a *Window* argument does not name a defined *Window*.
    #
    # ###See also
    # `window_attributes`, `query_tree`.
    def query_pointer(w : X11::C::Window) : NamedTuple(root: X11::C::Window, child: X11::C::Window, root_x: Int32, root_y: Int32, win_x: Int32, win_y: Int32, mask: UInt32, res: Bool)
      res = X.query_pointer @dpy, w, out root_return, out child_return, out root_x_return, out root_y_return, out win_x_return, out win_y_return, out mask_return
      {root: root_return, child: child_return, root_x: root_x_return, root_y: root_y_return, win_x: win_x_return, win_y: win_y_return, mask: mask_return, res: res == X::True ? true : false}
    end

    # Returns the bounding box of the specified 8-bit character string in the
    # specified font or the font contained in the specified GC.
    #
    # ###Arguments
    # - **font_id** Specifies either the font ID or the `GContext` ID that contains the font.
    # - **string** Specifies the character string.
    #
    # ###Returns
    # - **direction** Returns the value of the direction hint (**FontLeftToRight** or **FontRightToLeft**).
    # - **font_ascent** Returns the font ascent.
    # - **font_descent** Returns the font descent.
    # - **overall** Returns the overall size in the specified `CharStruct` structure.
    #
    # ###Description
    # The `query_text_extents` function returns the bounding box of the specified 8-bit
    # character string in the specified font or the font contained in the specified GC.
    # This function queries the X server and, therefore, suffer the round-trip overhead
    # that is avoided by `text_extents`. The function returns a `CharStruct` structure,
    # whose members are set to the values as follows.
    #
    # The ascent member is set to the maximum of the ascent metrics of all characters
    # in the string. The descent member is set to the maximum of the descent metrics.
    # The width member is set to the sum of the character-width metrics of all characters
    # in the string. For each character in the string, let W be the sum of the
    # character-width metrics of all characters preceding it in the string.
    # Let L be the left-side-bearing metric of the character plus W. Let R be the
    # right-side-bearing metric of the character plus W. The lbearing member is
    # set to the minimum L of all characters in the string. The rbearing member
    # is set to the maximum R.
    #
    # For fonts defined with linear indexing rather than 2-byte matrix indexing,
    # each `X11::C::X::Char2b` structure is interpreted as a 16-bit number with
    # byte1 as the most-significant byte. If the font has no defined default
    # character, undefined characters in the string are taken to have all zero metrics.
    #
    # Characters with all zero metrics are ignored. If the font has no defined
    # default_char, the undefined characters in the string are also ignored.
    #
    # `query_text_extents` can generate **BadFont** and **BadGC** errors.
    #
    # ###Diagnostics
    # - **BadFont** A value for a font argument does not name a defined font (or, in some cases, `GContext`).
    # - **BadGC** A value for a `GContext` argument does not name a defined `GContext`.
    #
    # ###See also
    # `load_font`, `query_text_extents_16`, `text_extents`, `text_extents_16`, `text_width`.
    def query_text_extents(font_id : X11::C::XID, string : String) : NamedTuple(direction: Int32, font_ascent: Int32, font_descent: Int32, overall: CharStruct, res: Int32)
      res = X.query_text_extents @dpy, font_id, string.to_unsafe, string.size, out direction_return, out font_ascent_return, out font_descent_return, out overall_return
      {direction: direction_return, font_ascent: font_ascent_return, font_descent: font_descent_return, overall: overall_return, res: res}
    end

    # Returns the bounding box of the specified 16-bit character string in the
    # specified font or the font contained in the specified GC.
    #
    # ###Arguments
    # - **font_id** Specifies either the font ID or the `GContext` ID that contains the font.
    # - **string** Specifies the character string.
    #
    # ###Returns
    # - **direction** Returns the value of the direction hint (**FontLeftToRight** or **FontRightToLeft**).
    # - **font_ascent** Returns the font ascent.
    # - **font_descent** Returns the font descent.
    # - **overall** Returns the overall size in the specified `CharStruct` structure.
    #
    # ###Description
    # The `query_text_extents_16` function returns the bounding box of the
    # specified 16-bit character string in the specified font or the font contained
    # in the specified GC. This function queries the X server and, therefore,
    # suffer the round-trip overhead that is avoided by `text_extents_16`.
    # The function returns a `CharStruct` structure, whose members are set to the values as follows.
    #
    # The ascent member is set to the maximum of the ascent metrics of all
    # characters in the string. The descent member is set to the maximum of the
    # descent metrics. The width member is set to the sum of the character-width
    # metrics of all characters in the string. For each character in the string,
    # let W be the sum of the character-width metrics of all characters preceding
    # it in the string. Let L be the left-side-bearing metric of the character
    # plus W. Let R be the right-side-bearing metric of the character plus W.
    # The lbearing member is set to the minimum L of all characters in the string.
    # The rbearing member is set to the maximum R.
    #
    # For fonts defined with linear indexing rather than 2-byte matrix indexing,
    # each `X11::C::X::Char2b` structure is interpreted as a 16-bit number with
    # byte1 as the most-significant byte. If the font has no defined default character,
    # undefined characters in the string are taken to have all zero metrics.
    #
    # Characters with all zero metrics are ignored. If the font has no defined
    # default_char, the undefined characters in the string are also ignored.
    #
    # `query_text_extents_16` can generate **BadFont** and **BadGC** errors.
    #
    # ###Diagnostics
    # - **BadFont** A value for a font argument does not name a defined font (or, in some cases, `GContext`).
    # - **BadGC** A value for a `GContext` argument does not name a defined `GContext`.
    #
    # ###See also
    # `load_font`, `query_text_extents`, `text_extents`,
    # `text_extents_16`, `text_width`.
    def query_text_extents_16(font_id : X11::C::XID, string : Array(X11::C::X::Char2b)) : NamedTuple(direction: Int32, font_ascent: Int32, font_descent: Int32, overall: CharStruct, res: Int32)
      res = X.query_text_extents_16 @dpy, font_id, string.to_unsafe, string.size, out direction_return, out font_ascent_return, out font_descent_return, out overall_return
      {direction: direction_return, font_ascent: font_ascent_return, font_descent: font_descent_return, overall: overall_return, res: res}
    end

    # Returns the root ID, the parent window ID, a the list of children windows.
    #
    # ###Arguments
    # - **w** Specifies the window whose list of children, root, parent, and
    # number of children you want to obtain.
    #
    # ###Returns
    # - **root** Returns the root window.
    # - **parent** Returns the parent window.
    # - **children** Returns the list of children.
    #
    # ###Description
    # - The `query_tree` function returns the root ID, the parent window ID,
    # a pointer to the list of children windows (empty array when there are no
    # children), and the number of children in the list for the specified window.
    # The children are listed in current stacking order, from bottommost (first)
    # to topmost (last).
    #
    # `query_tree` can generate a **BadWindow** error.
    #
    # ###Diagnostics
    # - **BadWindow** A value for a *Window* argument does not name a defined *Window*.
    #
    # ###See also
    # `window_attributes`, `query_pointer`.
    def query_tree(w : X11::C::Window) : NamedTuple(root: X11::C::Window, parent: X11::C::Window, children: Array(X11::C::Window), status: X11::C::X::Status)
      status = X.query_tree @dpy, w, out root_return, out parent_return, out children_return, out nchildren_return
      if nchildren_return > 0
        children = Array(X11::C::Window).new(nchildren_return) do |i|
          (children_return + i).value
        end
      else
        children = [] of X11::C::Window;
      end
      {root: root_return, parent: parent_return, children: children, status: status}
    end

    # Raises the specified window to the top of the
    # stack so that no sibling window obscures it.
    #
    # ###Arguments
    # - **w** Specifies the window.
    #
    # ###Description
    # The `raise_window` function raises the specified window to the top of the
    # stack so that no sibling window obscures it. If the windows are regarded as
    # overlapping sheets of paper stacked on a desk, then raising a window is
    # analogous to moving the sheet to the top of the stack but leaving its x and
    # y location on the desk constant. Raising a mapped window may generate
    # **Expose** events for the window and any mapped subwindows that were formerly obscured.
    #
    # If the override-redirect attribute of the window is **false** and some other
    # client has selected **SubstructureRedirectMask** on the parent, the X
    # server generates a **ConfigureRequest** event, and no processing is performed.
    # Otherwise, the window is raised.
    #
    # `raise_window` can generate a **BadWindow** error.
    #
    # ###Diagnostics
    # - **BadWindow** A value for a *Window* argument does not name a defined *Window*.
    #
    # ###See also
    # `change_window_attributes`, `circulate_subwindows`, `circulate_subwindows_down`m
    # `circulate_subwindows_up`, `configure_window`, `create_window`, `destroy_window`,
    # `lower_window`, `map_window`, `restack_windows`.
    def raise_window(w : X11::C::Window) : Int32
      X.raise_window @dpy, w
    end

    # Reads in a file containing a bitmap.
    #
    # ###Arguments
    # - **d** Specifies the drawable that indicates the screen.
    # - **filename** Specifies the file name to use.
    # The format of the file name is operating-system dependent.
    #
    # ###Returns
    # - **width**, **height** Return the width and height values of the read in bitmap file.
    # - **bitmap** Returns the bitmap that is created.
    # - **x_hot**, **y_hot** Return the hotspot coordinates.
    #
    # ###Description
    # The `read_bitmap_file` function reads in a file containing a bitmap.
    # The file is parsed in the encoding of the current locale. The ability to
    # read other than the standard format is implementation dependent. If the
    # file cannot be opened, `read_bitmap_file` returns **BitmapOpenFailed**.
    # If the file can be opened but does not contain valid bitmap data, it
    # returns **BitmapFileInvalid**. If insufficient working storage is allocated,
    # it returns **BitmapNoMemory**. If the file is readable and valid, it returns **BitmapSuccess**.
    #
    # `read_bitmap_file` returns the bitmap's height and width, as read from the
    # file, to width and height. It then creates a pixmap of the appropriate size,
    # reads the bitmap data from the file into the pixmap, and assigns the pixmap
    # to the caller's variable bitmap. The caller must free the bitmap using
    # `free_pixmap` when finished. If name_x_hot and name_y_hot exist,
    # `read_bitmap_file` returns them to x_hot and y_hot; otherwise, it returns -1,-1.
    #
    # `read_bitmap_file` can generate **BadAlloc**, **BadDrawable**, and **BadGC** errors.
    #
    # ###Diagnostics
    # - **BadAlloc** The server failed to allocate the requested source or server memory.
    # - **BadDrawable** A value for a *Drawable* argument does not name a defined *Window* or *Pixmap*.
    # - **BadGC** A value for a `GContext` argument does not name a defined `GContext`.
    #
    # ###See also
    # `create_bitmap_from_data`, `create_pixmap`, `create_pixmap_from_bitmap_data`,
    # `put_image`, `write_bitmap_file`.
    def read_bitmap_file(d : X11::C::Drawable, filename : String) : NamedTuple(width: UInt32, height: UInt32, bitmap: Pixmap, x_hot: Int32, y_hot: Int32, res: Int32)
      res = X.read_bitmap_file @dpy, d, filename.to_unsafe, out width_return, out height_return. out bitmap_return, out x_hot_return, out y_hot_return
      {width: width_return, height: height_return, bitmap: bitmap_return, x_hot: x_hot_return, y_hot: y_hot_return, res: res}
    end

    # Rebind the meaning of a KeySym for the client.
    #
    # ###Arguments
    # - **keysym** Specifies the KeySym that is to be rebound.
    # - **list** Specifies the KeySyms to be used as modifiers.
    # - **string** Specifies the string that is copied and will
    # be returned by `KeyEvent::lookup_string`.
    #
    # ###Description
    # The `rebind_keysym` function can be used to rebind the meaning of a KeySym
    # for the client. It does not redefine any key in the X server but merely
    # provides an easy way for long strings to be attached to keys.
    # `KexEvent::lookup_string` returns this string when the appropriate set of
    # modifier keys are pressed and when the KeySym would have been used for the
    # translation. No text conversions are performed; the client is responsible
    # for supplying appropriately encoded strings. Note that you can rebind a KeySym that may not exist.
    #
    # ###See also
    # `lookup_keysym`, `KeyEvent::lookup_string`, `refresh_keyboard_mapping`,
    # `string_to_keysym`, `ButtonEvent`, `MapEvent`.
    def rebind_keysym(keysym : KeySym, list : Array(KeySym), string : String) : Int32
      X.rebind_keysym @dpy, keysym, list.to_unsafe, list.size, string.to_unsafe, string.size
    end

    # Changes the color of the specified cursor.
    #
    # ###Arguments
    # - **cursor** Specifies the cursor.
    # - **foreground_color** Specifies the RGB values for the foreground of the source.
    # - **background_color** Specifies the RGB values for the background of the source.
    #
    # ###Description
    # The `recolor_cursor` function changes the color of the specified cursor,
    # and if the cursor is being displayed on a screen, the change is visible
    # immediately. The pixel members of the `Color` structures are ignored; only the RGB values are used.
    #
    # `recolor_cursor` can generate a **BadCursor** error.
    #
    # ###See also
    # `create_colormap`, `create_font_cursor`, `define_cursor`,
    # `free_cursor`, `query_best_cursor`.
    def recolor_cursor(cursor : X11::C::Cursor, foreground_color : Color, background_color : Color) : Int32
      X.recolor_cursor @dpy, cursor, foreground_color.to_unsafe, background_color.to_unsafe
    end

    # Removes the specified window from the client's save-set.
    #
    # ###Arguments
    # - **w** Specifies the window that you want to delete from the client's save-set.
    #
    # ###Description
    # The `remove_from_save_set` function removes the specified window from the
    # client's save-set. The specified window must have been created by
    # some other client, or a **BadMatch** error results.
    #
    # `remove_from_save_set` can generate **BadMatch** and **BadWindow** errors.
    #
    # ###Diagnostics
    # - **BadMatch** An **InputOnly** window is used as a *Drawable*.
    # - **BadMatch** Some argument or pair of arguments has the correct type
    # and range but fails to match in some other way required by the request.
    # - **BadWindow** A value for a *Window* argument does not name a defined *Window*.
    #
    # ###See also
    # `add_to_save_set`, `change_save_set`, `reparent_window`.
    def remove_from_save_set(w : X11::C::Window) : Int32
      X.remove_from_save_set @dpy, w
    end

    # Removes the specified host from the access control list for that display.
    #
    # ###Arguments
    # - **host** Specifies the host that is to be removed.
    #
    # ###Description
    # The `remove_host` function removes the specified host from the access control
    # list for that display. The server must be on the same host as the client
    # process, or a **BadAccess** error results. If you remove your machine from
    # the access list, you can no longer connect to that server, and this
    # operation cannot be reversed unless you reset the server.
    #
    # `remove_host` can generate **BadAccess** and **BadValue** errors.
    #
    # ###Diagnostics
    # - **BadAccess** A client attempted to free a color map entry that it did not already allocate.
    # - **BadAccess** A client attempted to store into a read-only color map entry.
    # - **BadValue** Some numeric value falls outside the range of values accepted
    # by the request. Unless a specific range is specified for an argument, the
    # full range defined by the argument's type is accepted. Any argument defined
    # as a set of alternatives can generate this error.
    #
    # ###See also
    # `add_host`, `add_hosts`, `disable_access_control`, `enable_access_control`,
    # `hosts`, `remove_hosts`, `set_access_control`.
    def remove_host(host : HostAddress) : Int32
      X.remove_host @dpy, host.to_unsafe
    end

    # Removes each specified host from the access control list for that display.
    #
    # ###Arguments
    # - **hosts** Specifies each host that is to be removed.
    #
    # ###Description
    # The `remove_hosts` function removes each specified host from the access
    # control list for that display. The X server must be on the same host as
    # the client process, or a **BadAccess** error results. If you remove your
    # machine from the access list, you can no longer connect to that server,
    # and this operation cannot be reversed unless you reset the server.
    #
    # `remove_hosts` can generate **BadAccess** and **BadValue** errors.
    #
    # ###Diagnostics
    # - **BadAccess** A client attempted to free a color map entry that it did not already allocate.
    # - **BadAccess** A client attempted to store into a read-only color map entry.
    # - **BadValue** Some numeric value falls outside the range of values accepted
    # by the request. Unless a specific range is specified for an argument, the
    # full range defined by the argument's type is accepted. Any argument defined
    # as a set of alternatives can generate this error.
    #
    # ###See also
    # `add_host`, `add_hosts`, `disable_access_control`, `enable_access_control`,
    # `hosts`, `remove_host`, `remove_hosts`, `set_access_control`.
    def remove_hosts(hosts : Array(HostAddress)) : Int32
      X.remove_hosts @dpy, hosts.to_unsafe.as(X11::C::X::PHostAddress), hosts.size
    end

    # Places the window in the stacking order on top with respect to sibling windows.
    #
    # ###Arguments
    # - **w** Specifies the window.
    # - **parent** Specifies the parent window.
    # - **x**, **y** Specify the x and y coordinates of the position in the new parent window.
    #
    # ###Description
    # If the specified window is mapped, `reparent_window` automatically performs
    # an **UnmapWindow** request on it, removes it from its current position in
    # the hierarchy, and inserts it as the child of the specified parent. The
    # window is placed in the stacking order on top with respect to sibling windows.
    #
    # After reparenting the specified window, `reparent_window` causes the X server
    # to generate a **ReparentNotify** event. The override_redirect member returned
    # in this event is set to the window's corresponding attribute. Window manager
    # clients usually should ignore this window if this member is set to **true**.
    # Finally, if the specified window was originally mapped, the X server
    # automatically performs a **MapWindow** request on it.
    #
    # The X server performs normal exposure processing on formerly obscured windows.
    # The X server might not generate **Expose** events for regions from the initial
    # **UnmapWindow** request that are immediately obscured by the final
    # **MapWindow** request. A **BadMatch** error results if:
    # - The new parent window is not on the same screen as the old parent window.
    # - The new parent window is the specified window or an inferior of the specified window.
    # - The new parent is **InputOnly**, and the window is not.
    # - The specified window has a ParentRelative background, and the
    # new parent window is not the same depth as the specified window.
    #
    # `reparent_window` can generate **BadMatch** and **BadWindow** errors.
    #
    # ###Diagnostics
    # - **BadMatch** An **InputOnly** window is used as a *Drawable*.
    # - **BadMatch** Some argument or pair of arguments has the correct type and
    # range but fails to match in some other way required by the request.
    # - **BadWindow** A value for a *Window* argument does not name a defined *Window*.
    #
    # ###See also
    # `change_save_set`.
    def reparent_window(w : X11::C::Window, parent : X11::C::Window, x : Int32, y : Int32) : Int32
      X.reparent_window @dpy, w, parent, x, y
    end

    # Resets the screen saver.
    #
    # ###Description
    # The `reset_screen_saver` function resets the screen saver.
    #
    # ###See also
    # `set_screen_saver`, `force_screen_saver`, `activate_screen_saver`, `screen_saver`.
    def reset_screen_saver : Int32
      X.reset_screen_saver @dpy
    end

    # Changes the inside dimensions of the specified window, not including its borders.
    #
    # ###Arguments
    # - **w** Specifies the window.
    # - **width**, **height** Specify the width and height, which are the
    # interior dimensions of the window after the call completes.
    #
    # ###Description
    # The `resize_window` function changes the inside dimensions of the specified
    # window, not including its borders. This function does not change the
    # window's upper-left coordinate or the origin and does not restack the window.
    # Changing the size of a mapped window may lose its contents and generate
    # **Expose** events. If a mapped window is made smaller, changing its size
    # generates **Expose** events on windows that the mapped window formerly obscured.
    #
    # If the override-redirect flag of the window is **false** and some other client
    # has selected **SubstructureRedirectMask** on the parent, the X server generates
    # a **ConfigureRequest** event, and no further processing is performed. If
    # either width or height is zero, a **BadValue** error results.
    #
    # `resize_window` can generate **BadValue** and **BadWindow** errors.
    #
    # ###Diagnostics
    # - **BadValue** Some numeric value falls outside the range of values accepted
    # by the request. Unless a specific range is specified for an argument, the
    # full range defined by the argument's type is accepted.
    # Any argument defined as a set of alternatives can generate this error.
    # - **BadWindow** A value for a *Window* argument does not name a defined *Window*.
    #
    # ###See also
    # `change_window_attributes`, `configure_window`, `create_window`,
    # `destroy_window`, `map_window`, `move_resize_window`, `move_window`,
    # `raise_window`, `set_window_border_width`, `unmap_window`.
    def resize_window(w : X11::C::Window, width : UInt32, height : UInt32) : Int32
      X.resize_window @dpy, w, width, height
    end

    # Restacks the windows in the order specified, from top to bottom.
    #
    # ###Arguments
    # - **windows** Specifies an array containing the windows to be restacked.
    #
    # ###Description
    # The `restack_windows` function restacks the windows in the order specified,
    # from top to bottom. The stacking order of the first window in the windows
    # array is unaffected, but the other windows in the array are stacked
    # underneath the first window, in the order of the array. The stacking order
    # of the other windows is not affected. For each window in the window array
    # that is not a child of the specified window, a **BadMatch** error results.
    #
    # If the override-redirect attribute of a window is **false** and some other
    # client has selected **SubstructureRedirectMask** on the parent, the X server
    # generates **ConfigureRequest** events for each window whose override-redirect
    # flag is not set, and no further processing is performed.
    # Otherwise, the windows will be restacked in top to bottom order.
    #
    # `restack_windows` can generate a **BadWindow** error.
    #
    # ###Diagnostics
    # - **BadWindow** A value for a *Window* argument does not name a defined *Window*.
    #
    # ###See also
    # `change_window_attributes`, `circulate_subwindows`,
    # `circulate_subwindows_down`, `circulate_subwindows_up`, `configure_window`,
    # `create_window`, `destroy_window`, `lower_window`, `map_window`, `raise_window`.
    def restack_windows(windows : Array(X11::C::Window)) : Int32
      X.restack_windows @dpy, windows.to_unsafe, windows.size
    end

    # Rotates the cut buffers.
    #
    # ###Arguments
    # - **rotate** Specifies how much to rotate the cut buffers.
    #
    # ###Description
    # The `rotate_buffers` function rotates the cut buffers, such that buffer
    # 0 becomes buffer n, buffer 1 becomes n + 1 mod 8, and so on. This cut
    # buffer numbering is global to the display. Note that `rotate_buffers`
    # generates **BadMatch** errors if any of the eight buffers have not been created.
    #
    # ###Diagnostics
    # - **BadMatch** An **InputOnly** window is used as a *Drawable*.
    # - **BadMatch** Some argument or pair of arguments has the correct type and
    # range but fails to match in some other way required by the request.
    #
    # ###See also
    # `fetch_buffer`, `fetch_bytes`, `store_buffer`, `store_bytes`.
    def rotate_buffers(rotate : Int32) : Int32
      X.rotate_buffers @dpy, rotate
    end

    # Allows you to rotate properties on a window.
    #
    # ###Arguments
    # - **w** Specifies the window.
    # - **properties** Specifies the array of properties that are to be rotated.
    # - **npositions** Specifies the rotation amount.
    #
    # ###Description
    # The `rotate_window_properties` function allows you to rotate properties on
    # a window and causes the X server to generate **PropertyNotify** events.
    # If the property names in the properties array are viewed as being numbered
    # starting from zero and if there are `properties.size` property names in the list,
    # then the value associated with property name I becomes the value associated with
    # property name (I + npositions) mod N for all I from zero to N - 1.
    # The effect is to rotate the states by npositions places around the virtual
    # ring of property names (right for positive npositions, left for negative npositions).
    # If npositions mod N is nonzero, the X server generates a **PropertyNotify**
    # event for each property in the order that they are listed in the array.
    # If an atom occurs more than once in the list or no property with that name
    # is defined for the window, a **BadMatch** error results. If a **BadAtom**
    # or **BadMatch** error results, no properties are changed.
    #
    # `rotate_window_properties` can generate **BadAtom**, **BadMatch**, and **BadWindow** errors.
    #
    # ###Diagnostics
    # - **BadAtom** A value for an Atom argument does not name a defined Atom.
    # - **BadMatch** An **InputOnly** window is used as a *Drawable*.
    # - **BadMatch** Some argument or pair of arguments has the correct type and
    # range but fails to match in some other way required by the request.
    # - **BadPixmap** A value for a *Pixmap* argument does not name a defined *Pixmap*.
    # - **BadWindow** A value for a *Window* argument does not name a defined *Window*.
    #
    # ###See also
    # `change_property`, `delete_property`, `window_property`, `properties`.
    def rotate_window_properties(w : X11::C::Window, properties : Array(Atom | X11::C::Atom), npositions : Int32) : Int32
      X.rotate_window_properties @dpy, w, properties.to_unsafe.as(X11::C::Atom*), properties.size, npositions
    end

    # Returns the number of available screens.
    def screen_count : Int32
      X.screen_count @dpy
    end

    # Requests that the X server report the events associated with the specified event mask.
    #
    # ###Arguments
    # - **w** Specifies the window whose events you are interested in.
    # - **event_mask** Specifies the event mask.
    #
    # ###Description
    # The `select_input` function requests that the X server report the events
    # associated with the specified event mask. Initially, X will not report any
    # of these events. Events are reported relative to a window. If a window is
    # not interested in a device event, it usually propagates to the closest
    # ancestor that is interested, unless the do_not_propagate mask prohibits it.
    #
    # Setting the event-mask attribute of a window overrides any previous call
    # for the same window but not for other clients. Multiple clients can select
    # for the same events on the same window with the following restrictions:
    # - Multiple clients can select events on the same window because their event
    # masks are disjoint. When the X server generates an event, it reports it to all interested clients.
    # - Only one client at a time can select **CirculateRequest**,
    # **ConfigureRequest**, or **MapRequest** events, which are associated with
    # the event mask **SubstructureRedirectMask**.
    # - Only one client at a time can select a **ResizeRequest** event,
    # which is associated with the event mask **ResizeRedirectMask**.
    # - Only one client at a time can select a **ButtonPress** event, which
    # is associated with the event mask **ButtonPressMask**.
    # The server reports the event to all interested clients.
    #
    # `select_input` can generate a **BadWindow** error.
    #
    # ###Diagnostics
    # - **BadWindow** A value for a *Window* argument does not name a defined *Window*.
    def select_input(w : X11::C::Window, event_mask : Int64) : Int32
      X.select_input @dpy, w, event_mask
    end

    # Identifies the destination window, determines which clients should
    # receive the specified events, and ignores any active grabs.
    #
    # ###Arguments
    # - **w** Specifies the window the event is to be sent to,
    # or **PointerWindow**, or **InputFocus**.
    # - **propagate** Specifies a Boolean value.
    # - **event_mask** Specifies the event mask.
    # - **event_send** Specifies the event that is to be sent.
    #
    # ###Description
    # The `send_event` function identifies the destination window, determines
    # which clients should receive the specified events, and ignores any active
    # grabs. This function requires you to pass an event mask. For a discussion
    # of the valid event mask names, see section "Event Masks". This function
    # uses the w argument to identify the destination window as follows:
    # - If w is **PointerWindow**, the destination window is the window that contains the pointer.
    # - If w is **InputFocus** and if the focus window contains the pointer,
    # the destination window is the window that contains the pointer; otherwise,
    # the destination window is the focus window.
    # To determine which clients should receive the specified events,
    # `send_event` uses the propagate argument as follows:
    # - If event_mask is the empty set, the event is sent to the client that
    # created the destination window. If that client no longer exists, no event is sent.
    # - If propagate is **false**, the event is sent to every client selecting
    # on destination any of the event types in the event_mask argument.
    # - If propagate is **true** and no clients have selected on destination any
    # of the event types in event-mask, the destination is replaced with the closest
    # ancestor of destination for which some client has selected a type in event-mask
    # and for which no intervening window has that type in its do-not-propagate-mask.
    # If no such window exists or if the window is an ancestor of the focus window
    # and **InputFocus** was originally specified as the destination, the event
    # is not sent to any clients. Otherwise, the event is reported to every client
    # selecting on the final destination any of the types specified in event_mask.
    #
    # The event in the `Event` object must be one of the core events or one of
    # the events defined by an extension (or a **BadValue** error results) so that
    # the X server can correctly byte-swap the contents as necessary. The contents
    # of the event are otherwise unaltered and unchecked by the X server except to
    # force send_event to **true** in the forwarded event and to set the serial
    # number in the event correctly; therefore these fields and the display
    # field are ignored by `send_event`.
    #
    # `send_event` returns zero if the conversion to wire protocol
    # format failed and returns nonzero otherwise.
    #
    # `send_event` can generate **BadValue** and **BadWindow** errors.
    #
    # ###Diagnostics
    # - **BadValue** Some numeric value falls outside the range of values
    # accepted by the request. Unless a specific range is specified for an
    # argument, the full range defined by the argument's type is accepted.
    # Any argument defined as a set of alternatives can generate this error.
    # - **BadWindow** A value for a *Window* argument does not name a defined *Window*.
    #
    # ###See also
    # `motion_buffer_size`, `motion_events`, `if_event`, `next_event`, `put_back_event`.
    def send_event(w : X11::C::Window, propagate : Bool, event_mask : Int64, event_send : Event) : X11::C::X::Status
      X.send_event @dpy, w, propagate ? X::True : X::False, event_mask, event_send.to_unsafe.as(X11::C::X::PEvent)
    end

    # Enables or disables the use of the access control list at each connection setup.
    #
    # ###Arguments
    # - **mode** Specifies the mode. You can pass **EnableAccess** or **DisableAccess**.
    #
    # ###Description
    # The `set_access_control` function either enables or disables the use of
    # the access control list at each connection setup.
    #
    # `set_access_control` can generate **BadAccess** and **BadValue** errors.
    #
    # ###Diagnostics
    # - **BadAccess** A client attempted to free a color map entry that it did not already allocate.
    # - **BadAccess** A client attempted to store into a read-only color map entry.
    # - **BadValue** Some numeric value falls outside the range of values accepted
    # by the request. Unless a specific range is specified for an argument, the
    # full range defined by the argument's type is accepted. Any argument
    # defined as a set of alternatives can generate this error.
    #
    # ###See also
    # `add_host`, `add_hosts`, `disable_access_control`, `enable_access_control`,
    # `hosts`, `remove_host`, `remove_hosts`.
    def set_access_control(mode : Int32) : Int32
      X.set_access_control @dpy, mode
    end

    # Sets the arc mode.
    #
    # ###Arguments
    # - **gc** Specifies the GC.
    # - **arc_mode** Specifies the arc mode. You can pass **ArcChord** or **ArcPieSlice**.
    #
    # ###Description
    # `set_arc_mode` can generate **BadAlloc**, **BadGC**, and **BadValue** errors.
    #
    # ###Diagnostics
    # - **BadAlloc** The server failed to allocate the requested source or server memory.
    # - **BadGC** A value for a `GContext` argument does not name a defined `GContext`.
    # - **BadValue** Some numeric value falls outside the range of values accepted
    # by the request. Unless a specific range is specified for an argument, the
    # full range defined by the argument's type is accepted. Any argument
    # defined as a set of alternatives can generate this error.
    #
    # ###See also
    # `copy_area`, `create_gc`, `query_best_size`, `set_clip_origin`,
    # `set_fill_style`, `set_font`, `set_graphics_exposures`, `set_line_attributes`,
    # `set_state`, `set_subwindow_mode`, `set_tile`.
    def set_arc_mode(gc : X11::C::X::GC, arc_mode : Int32) : Int32
      X.set_arc_mode @dpy, gc, arc_mode
    end

    # Sets the background.
    #
    # ###Arguments
    # - **gc** Specifies the GC.
    # - **background** Specifies the background you want to set for the specified GC.
    #
    # ###Description
    # `set_background` can generate **BadAlloc** and **BadGC** errors.
    #
    # ###Diagnostics
    # - **BadAlloc** The server failed to allocate the requested source or server memory.
    # - **BadGC** A value for a `GContext` argument does not name a defined `GContext`.
    #
    # ###See also
    # `create_gc`, `query_best_size`, `set_arc_mode`, `set_background`,
    # `set_clip_origin`, `set_fill_style`, `set_font`, `set_foreground`,
    # `set_function`, `set_line_attributes`, `set_plane_mask`,
    # `set_state`, `set_tile`.
    def set_background(gc : X11::C::X::GC, background : UInt64) : Int32
      X.set_background @dpy, gc, background
    end

    # Sets the clip mask.
    #
    # ###Arguments
    # - **gc** Specifies the GC.
    # - **pixmap** Specifies the pixmap or **None**.
    #
    # ###Description
    # If the clip-mask is set to **None**, the pixels are are always drawn (regardless of the clip-origin).
    #
    # `set_clip_mask` can generate **BadAlloc**, **BadGC**, **BadMatch**, and **BadPixmap** errors.
    #
    # ###Diagnostics
    # - **BadAlloc** The server failed to allocate the requested source or server memory.
    # - **BadGC** A value for a `GContext` argument does not name a defined `GContext`.
    # - **BadMatch** An **InputOnly** window is used as a *Drawable*.
    # - **BadMatch** Some argument or pair of arguments has the correct type and
    # range but fails to match in some other way required by the request.
    # - **BadPixmap** A value for a *Pixmap* argument does not name a defined *Pixmap*.
    #
    # ###See also
    # `create_gc`, `draw_rectangle`, `query_best_size`, `set_arc_mode`,
    # `set_clip_origin`, `set_clip_rectangles`, `set_fill_style`, `set_font`,
    # `set_line_attributes`, `set_state`, `set_tile`.
    def set_clip_mask(gc : X11::C::X::GC, pixmap : X11::C::Pixmap) : Int32
      X.set_clip_mask @dpy, gc, pixmap
    end

    # Sets clip origin.
    #
    # ###Arguments
    # - **gc** Specifies the GC.
    # - **clip_x_origin**, **clip_y_origin** Specify the x and y coordinates of the clip-mask origin.
    #
    # ###Description
    # The clip-mask origin is interpreted relative to the origin of whatever
    # destination drawable is specified in the graphics request.
    #
    # `set_clip_origin` can generate **BadAlloc** and **BadGC** errors.
    #
    # ###Diagnostics
    # - **BadAlloc** The server failed to allocate the requested source or server memory.
    # - **BadGC** A value for a `GContext` argument does not name a defined `GContext`.
    #
    # ###See also
    # `create_gc`, `draw_rectangle`, `query_best_size`, `set_arc_mode`,
    # `set_clip_mask`, `set_clip_rectangles`, `set_fill_style`, `set_font`,
    # `set_line_attributes`, `set_state`, `set_tile`.
    def set_clip_origin(gc : X11::C::GC, clip_x_origin : Int32, clip_y_origin : Int32) : Int32
      X.set_clip_origin @dpy, gc, clip_x_origin, clip_y_origin
    end

    # Changes the clip-mask in the specified
    # GC to the specified list of rectangles and sets the clip origin.
    #
    # ###Arguments
    # - **gc** Specifies the GC.
    # - **clip_x_origin**, **clip_y_origin** Specify the x and y coordinates of the clip-mask origin.
    # - **rectangles** Specifies an array of rectangles that define the clip-mask.
    # - **ordering** Specifies the ordering relations on the rectangles.
    # You can pass **Unsorted**, **YSorted**, **YXSorted**, or **YXBanded**.
    #
    # ###Description
    # The `set_clip_rectangles` function changes the clip-mask in the specified
    # GC to the specified list of rectangles and sets the clip origin. The output
    # is clipped to remain contained within the rectangles. The clip-origin is
    # interpreted relative to the origin of whatever destination drawable is specified
    # in a graphics request. The rectangle coordinates are interpreted relative to
    # the clip-origin. The rectangles should be nonintersecting, or the graphics
    # results will be undefined. Note that the list of rectangles can be empty,
    # which effectively disables output. This is the opposite of passing **None**
    # as the clip-mask in `create_gc`, `change_gc`, and `set_clip_mask`.
    #
    # If known by the client, ordering relations on the rectangles can be specified
    # with the ordering argument. This may provide faster operation by the server.
    # If an incorrect ordering is specified, the X server may generate a **BadMatch**
    # error, but it is not required to do so. If no error is generated, the graphics
    # results are undefined. Unsorted means the rectangles are in arbitrary order.
    # **YSorted** means that the rectangles are nondecreasing in their Y origin.
    # **YXSorted** additionally constrains **YSorted** order in that all rectangles
    # with an equal Y origin are nondecreasing in their X origin. **YXBanded**
    # additionally constrains **YXSorted** by requiring that, for every possible
    # Y scanline, all rectangles that include that scanline have an identical Y origins and Y extents.
    #
    # `set_clip_rectangles` can generate **BadAlloc**, **BadGC**, **BadMatch**,
    # and **BadValue** errors.
    #
    # ###Diagnostics
    # - **BadAlloc** The server failed to allocate the requested source or server memory.
    # - **BadGC** A value for a `GContext` argument does not name a defined `GContext`.
    # - **BadMatch** An **InputOnly** window is used as a *Drawable*.
    # - **BadMatch** Some argument or pair of arguments has the correct type and
    # range but fails to match in some other way required by the request.
    # - **BadValue** Some numeric value falls outside the range of values accepted
    # by the request. Unless a specific range is specified for an argument, the
    # full range defined by the argument's type is accepted. Any argument
    # defined as a set of alternatives can generate this error.
    #
    # ###See also
    # `create_gc`, `draw_rectangle`, `query_best_size`, `set_arc_mode`,
    # `set_clip_mask`, `set_clip_origin`, `set_fill_style`, `set_font`,
    # `set_line_attributes`, `set_state`, `set_title`.
    def set_clip_rectangles(gc : X11::C::X::GC, clip_x_origin : Int32, clip_y_origin : Int32, rectangles : Array(Rectangle), ordering : Int32) : Int32
      X.set_clip_rectangles @dpy, gc, clip_x_origin, clip_y_origin, rectangles.to_unsafe.as(X11::C::X::PRectangle), rectangles.size, ordering
    end

    # Defines what will happen to the client's resources at connection close.
    #
    # ###Arguments
    # - **close_mode** Specifies the client close-down mode. You can pass
    # **DestroyAll**, **RetainPermanent**, or **RetainTemporary**.
    #
    # ###Description
    # The `set_close_down_mode` defines what will happen to the client's resources
    # at connection close. A connection starts in **DestroyAll** mode.
    # For information on what happens to the client's resources when the
    # close_mode argument is **RetainPermanent** or **RetainTemporary**,
    # see "X Server Connection Close Operations".
    #
    # `set_close_down_mode` can generate a **BadValue** error.
    #
    # ###Diagnostics
    # - **BadValue** Some numeric value falls outside the range of values
    # accepted by the request. Unless a specific range is specified for an
    # argument, the full range defined by the argument's type is accepted.
    # Any argument defined as a set of alternatives can generate this error.
    def set_close_down_mode(close_mode : Int32) : Int32
      X.set_close_down_mode @dpy, close_mode
    end

    # Sets the command and arguments used to invoke the application.
    #
    # ###Arguments
    # - **w** Specifies the window.
    # - **argv** Specifies the application's argument list.
    #
    # ###Description
    # The `set_command` function sets the command and arguments used to invoke
    # the application. (Typically, argv is the argv array of your main program.)
    # If the strings are not in the Host Portable Character Encoding,
    # the result is implementation dependent.
    #
    # `set_command` can generate **BadAlloc** and **BadWindow** errors.
    #
    # ###Diagnostics
    # - **BadAlloc** The server failed to allocate the requested source or server memory.
    # - **BadWindow** A value for a *Window* argument does not name a defined *Window*.
    #
    # ###See also
    # `X11::alloc_class_hint`, `X11::alloc_icon_size`, `X11::alloc_size_hints`,
    # `X11::alloc_wm_hints`, `command`, `set_text_property`,
    # `set_transient_for_hint`, `set_wm_client_machine`, `set_wm_colormap_windows`,
    # `set_wm_icon_name`, `set_wm_name`, `set_wm_properties`,
    # `set_wm_protocols`, `X11::string_list_to_text_property`.
    def set_command(w : X11::C::Window, argv : Array(String)) : Int32
      pargv = argv.map(&.to_unsafe)
      X.set_command @dpy, w, pargv.to_unsafe, pargv.size
    end

    # Sets the dash-offset and dash-list attributes for
    # dashed line styles in the specified GC.
    #
    # ###Arguments
    # - **gc** Specifies the GC.
    # - **dash_offset** Specifies the phase of the pattern for the dashed line-style you want to set for the specified GC.
    # - **dash_list** Specifies the dash-list for the dashed line-style you want to set for the specified GC.
    #
    # ###Description
    # The `set_dashes` function sets the dash-offset and dash-list attributes for
    # dashed line styles in the specified GC. There must be at least one element
    # in the specified dash_list, or a **BadValue** error results. The initial
    # and alternating elements (second, fourth, and so on) of the dash_list are
    # the even dashes, and the others are the odd dashes. Each element specifies
    # a dash length in pixels. All of the elements must be nonzero, or a
    # **BadValue** error results. Specifying an odd-length list is equivalent to
    # specifying the same list concatenated with itself to produce an even-length list.
    #
    # The dash-offset defines the phase of the pattern, specifying how many
    # pixels into the dash-list the pattern should actually begin in any single
    # graphics request. Dashing is continuous through path elements combined with
    # a join-style but is reset to the dash-offset between each sequence of joined lines.
    #
    # The unit of measure for dashes is the same for the ordinary coordinate system.
    # Ideally, a dash length is measured along the slope of the line, but
    # implementations are only required to match this ideal for horizontal and
    # vertical lines. Failing the ideal semantics, it is suggested that the length
    # be measured along the major axis of the line. The major axis is defined as
    # the x axis for lines drawn at an angle of between -45 and +45 degrees or
    # between 135 and 225 degrees from the x axis. For all other lines, the major axis is the y axis.
    #
    # `set_dashes` can generate **BadAlloc**, **BadGC**, and **BadValue** errors.
    #
    # ###Diagnostics
    # - **BadAlloc** The server failed to allocate the requested source or server memory.
    # - **BadGC** A value for a `GContext` argument does not name a defined `GContext`.
    # - **BadValue** Some numeric value falls outside the range of values accepted
    # by the request. Unless a specific range is specified for an argument, the
    # full range defined by the argument's type is accepted. Any argument
    # defined as a set of alternatives can generate this error.
    #
    # ###See also
    # `create_gc`, `query_best_size`, `set_arc_mode`, `set_clip_origin`,
    # `set_fill_style`, `set_font`, `set_line_attributes`, `set_state`, `set_tile`.
    def set_dashes(gc : X11::C::X::GC, dash_offset : Int32, dash_list : String) : Int32
      X.set_dashes @dpy, gc, dash_offset, dash_list.to_unsafe, dash_list.size
    end

    # Sets the fill rule.
    #
    # ###Arguments
    # - **gc** Specifies the GC.
    # - **fill_rule** Specifies the fill-rule you want to set for the specified GC.
    # You can pass **EvenOddRule** or **WindingRule**.
    #
    # ###Description
    # `set_fill_rule` can generate **BadAlloc**, **BadGC**, and **BadValue** errors.
    #
    # ###Diagnostics
    # - **BadAlloc** The server failed to allocate the requested source or server memory.
    # - **BadGC** A value for a `GContext` argument does not name a defined `GContext`.
    # - **BadValue** Some numeric value falls outside the range of values accepted
    # by the request. Unless a specific range is specified for an argument, the
    # full range defined by the argument's type is accepted. Any argument
    # defined as a set of alternatives can generate this error.
    #
    # ###See also
    # `create_gc`, `query_best_size`, `set_arc_mode`, `set_clip_origin`,
    # `set_fill_rule`, `set_fill_style`, `set_font`, `set_line_attributes`,
    # `set_state`, `set_tile`.
    def set_fill_rule(gc : X11::C::X::GC, fill_rule : Int32) : Int32
      X.set_fill_rule @dpy, gc, fill_rule
    end

    # Sets the fill style.
    #
    # ###Arguments
    # - **gc** Specifies the GC.
    # - **fill_style** Specifies the fill-style you want to set for the
    # specified GC. You can pass **FillSolid**, **FillTiled**,
    # **FillStippled**, or **FillOpaqueStippled**.
    #
    # ###Description
    # `set_fill_style` can generate **BadAlloc**, **BadGC**, and **BadValue** errors.
    #
    # ###Diagnostics
    # - **BadAlloc** The server failed to allocate the requested source or server memory.
    # - **BadGC** A value for a `GContext` argument does not name a defined `GContext`.
    # - **BadValue** Some numeric value falls outside the range of values accepted
    # by the request. Unless a specific range is specified for an argument, the
    # full range defined by the argument's type is accepted.
    # Any argument defined as a set of alternatives can generate this error.
    #
    # ###See also
    # `create_gc`, `query_best_size`, `set_arc_mode`, `set_clip_origin`,
    # `set_fill_rule`, `set_font`, `set_line_attributes`, `set_state`, `set_tile`.
    def set_fill_style(gc : X11::C::X::GC, fill_style : Int32) : Int32
      X.set_fill_style @dpy, gc, fill_style
    end

    # Sets the font.
    #
    # ###Arguments
    # - **gc** Specifies the GC.
    # - **font** Specifies the font.
    #
    # ###Description
    # `set_font` can generate **BadAlloc**, **BadFont**, and **BadGCs** errors.
    #
    # ###Diagnostics
    # - **BadAlloc** The server failed to allocate the requested source or server memory.
    # - **BadFont** A value for a font argument does not name a defined font (or, in some cases, `GContext`).
    # - **BadGC** A value for a `GContext` argument does not name a defined `GContext`.
    #
    # ###See also
    # `create_gc`, `query_best_size`, `set_arc_mode`, `set_clip_origin`,
    # `set_fill_style`, `set_line_attributes`, `set_state`, `set_tile`.
    def set_font(gc : X11::C::X::GC, font : X11::C::Font) : Int32
      X.set_font @dpy, gc, font
    end

    # Defines the directory search path for font lookup.
    #
    # ###Arguments
    # - **directories** Specifies the directory path used to look for a font.
    # Setting the path to the empty list restores the default path defined for the X server.
    #
    # ###Description
    # The `set_font_path` function defines the directory search path for font lookup.
    # There is only one search path per X server, not one per client. The encoding
    # and interpretation of the strings is implementation dependent, but typically
    # they specify directories or font servers to be searched in the order listed.
    # An X server is permitted to cache font information internally; for example,
    # it might cache an entire font from a file and not check on subsequent opens
    # of that font to see if the underlying font file has changed. However, when
    # the font path is changed, the X server is guaranteed to flush all cached
    # information about fonts for which there currently are no explicit resource
    # IDs allocated. The meaning of an error from this request is implementation dependent.
    #
    # `set_font_path`  can generate a **BadValue** error.
    #
    # ###Diagnostics
    # - **BadValue** Some numeric value falls outside the range of values accepted
    # by the request. Unless a specific range is specified for an argument, the
    # full range defined by the argument's type is accepted. Any argument defined
    # as a set of alternatives can generate this error.
    #
    # ###See also
    # `font_path`, `fonts`, `load_font`.
    def set_font_path(directories : Array(String)) : Int32
      pdirs = directories.map(&.to_unsafe)
      X.set_font_path @dpy, pdirst.to_unsafe, pdirs.size
    end

    # Sets foreground.
    #
    # ###Arguments
    # - **gc** Specifies the GC.
    # - **foreground** Specifies the foreground you want to set for the specified GC.
    #
    # ###Description
    # `set_foreground` can generate **BadAlloc** and **BadGC** errors.
    #
    # ###Diagnostics
    # - **BadAlloc** The server failed to allocate the requested source or server memory.
    # - **BadGC** A value for a `GContext` argument does not name a defined `GContext`.
    #
    # ###See also
    # `create_gc`, `query_best_size`, `set_arc_mode`, `set_background`,
    # `set_clip_origin`, `set_fill_style`, `set_font`, `set_foreground`,
    # `set_function`, `set_line_attributes`, `set_plane_mask`, `set_state`, `set_tile`.
    def set_foreground(gc : X11::C::X::GC, foreground : UInt64) : Int32
      X.set_foreground @dpy, gc, foreground
    end

    # Sets the display function.
    #
    # ###Arguments
    # - **gc** Specifies the GC.
    # - **function** Specifies the function you want to set for the specified GC.
    #
    # ###Description
    # `set_function` can generate **BadAlloc**, **BadGC**, and **BadValue** errors.
    #
    # ###Diagnostics
    # - **BadAlloc** The server failed to allocate the requested source or server memory.
    # - **BadGC** A value for a `GContext` argument does not name a defined `GContext`.
    # - **BadValue** Some numeric value falls outside the range of values accepted
    # by the request. Unless a specific range is specified for an argument, the
    # full range defined by the argument's type is accepted.
    # Any argument defined as a set of alternatives can generate this error.
    #
    # ###See also
    # `create_gc`, `query_best_size`, `set_arc_mode`, `set_background`,
    # `set_clip_origin`, `set_fill_style`, `set_font`, `set_foreground`,
    # `set_function`, `set_line_attributes`, `set_plane_mask`, `set_state`, `set_tile`.
    def set_function(gc : X11::C::GC, function : Int32) : Int32
      X.set_function @dpy, gc, function
    end

    # Sets the graphics-exposures flag of a given GC.
    #
    # ###Arguments
    # - **gc** Specifies the GC.
    # - **graphics_exposures** Specifies a Boolean value that indicates whether
    # you want **GraphicsExpose** and **NoExpose** events to be reported when calling
    # `copy_area` and `copy_plane` with this GC.
    #
    # ###Description
    # `set_graphics_exposures` can generate **BadAlloc**, **BadGC**, and **BadValue** errors.
    #
    # ###Diagnostics
    # - **BadAlloc** The server failed to allocate the requested source or server memory.
    # - **BadGC** A value for a `GContext` argument does not name a defined `GContext`.
    # - **BadValue** Some numeric value falls outside the range of values accepted
    # by the request. Unless a specific range is specified for an argument, the
    # full range defined by the argument's type is accepted.
    # Any argument defined as a set of alternatives can generate this error.
    #
    # ###See also
    # `copy_area`, `create_gc`, `query_best_size`, `set_arc_mode`, `set_clip_origin`,
    # `set_fill_style`, `set_font`, `set_line_attributes`, `set_state`,
    # `set_subwindow_mode`, `set_tile`.
    def set_graphics_exposures(gc : X11::C::X::GC, graphics_exposures : Bool) : Int32
      X.set_graphics_exposures @dpy, gc, graphics_exposures ? X::True : X::False
    end

    # Set a window's WM_ICON_NAME property.
    #
    # ###Arguments
    # - **w** Specifies the window.
    # - **icon_name** Specifies the icon name, which should be a null-terminated string.
    #
    # ###Description
    # If the string is not in the Host Portable Character Encoding, the result
    # is implementation dependent. `set_icon_name` can generate **BadAlloc** and **BadWindow** errors.
    #
    # ###Diagnostics
    # - **BadAlloc** The server failed to allocate the requested source or server memory.
    # - **BadWindow** A value for a *Window* argument does not name a defined *Window*.
    #
    # ###See also
    # `icon_name`, `wm_icon_name`, `set_command`, `set_text_property`,
    # `set_transient_for_hint`, `set_wm_client_machine`, `set_wm_colormap_windows`,
    # `set_wm_icon_name`, `set_wm_name`, `set_wm_properties`, `set_wm_protocols`.
    def set_icon_name(w : X11::C::Window, icon_name : String) : Int32
      X.set_icon_name @dpy, w, icon_name.to_unsafe
    end

    # Changes the input focus and the last-focus-change time.
    #
    # ###Arguments
    # - **focus** Specifies the window, **PointerRoot**, or **None**.
    # - **revert_to** Specifies where the input focus reverts to if the window
    # becomes not viewable. You can pass **RevertToParent**,
    # **RevertToPointerRoot**, or **RevertToNone**.
    # - **time** Specifies the time. You can pass either a timestamp or **CurrentTime**.
    #
    # ###Description
    # The `set_input_focus` function changes the input focus and the
    # last-focus-change time. It has no effect if the specified time is earlier
    # than the current last-focus-change time or is later than the current X
    # server time. Otherwise, the last-focus-change time is set to the specified
    # time (**CurrentTime** is replaced by the current X server time).
    # `set_input_focus` causes the X server to generate **FocusIn** and **FocusOut** events.
    #
    # Depending on the focus argument, the following occurs:
    # - If focus is **None**, all keyboard events are discarded until a new focus
    # window is set, and the revert_to argument is ignored.
    # - If focus is a window, it becomes the keyboard's focus window. If a generated
    # keyboard event would normally be reported to this window or one of its inferiors,
    # the event is reported as usual. Otherwise, the event is reported relative to the focus window.
    # - If focus is **PointerRoot**, the focus window is dynamically taken to be
    # the root window of whatever screen the pointer is on at each keyboard event.
    # In this case, the revert_to argument is ignored.
    #
    # The specified focus window must be viewable at the time `set_input_focus`
    # is called, or a **BadMatch** error results. If the focus window later
    # becomes not viewable, the X server evaluates the revert_to argument to
    # determine the new focus window as follows:
    # - If revert_to is **RevertToParent**, the focus reverts to the parent
    # (or the closest viewable ancestor), and the new revert_to value is taken to be **RevertToNone**.
    # - If revert_to is **RevertToPointerRoot** or **RevertToNone**, the focus
    # reverts to **PointerRoot** or **None**, respectively. When the focus reverts,
    # the X server generates **FocusIn** and **FocusOut** events,
    # but the last-focus-change time is not affected.
    #
    # `set_input_focus` can generate **BadMatch**, **BadValue**, and **BadWindow** errors.
    #
    # ###Diagnostics
    # - **BadMatch** An **InputOnly** window is used as a *Drawable*.
    # - **BadMatch** Some argument or pair of arguments has the correct type and
    # range but fails to match in some other way required by the request.
    # - **BadMatch** An **InputOnly** window is used as a *Drawable*.
    # - **BadMatch** Some argument or pair of arguments has the correct type and
    # range but fails to match in some other way required by the request.
    # - **BadValue** Some numeric value falls outside the range of values accepted
    # by the request. Unless a specific range is specified for an argument, the
    # full range defined by the argument's type is accepted. Any argument
    # defined as a set of alternatives can generate this error.
    # - **BadWindow** A value for a *Window* argument does not name a defined *Window*.
    #
    # ###See also
    # `input_focus`, `warp_pointer`.
    def set_input_focus(focus : X11::C::Window, revert_to : Int32, time : X11::C::Time) : Int32
      X.set_input_focus @dpy, focus, revert_to, time
    end

    # Sets the line drawing components of a given GC.
    #
    # ###Arguments
    # - **gc** Specifies the GC.
    # - **line_width** Specifies the line-width you want to set for the specified GC.
    # - **line_style** Specifies the line-style you want to set for the specified GC.
    # You can pass **LineSolid**, **LineOnOffDash**, or **LineDoubleDash**.
    # - **cap_style** Specifies the line-style and cap-style you want to set for
    # the specified GC. You can pass **CapNotLast**, **CapButt**, **CapRound**, or **CapProjecting**.
    # - **join_style** Specifies the line join-style you want to set for the
    # specified GC. You can pass **JoinMiter**, **JoinRound**, or **JoinBevel**.
    #
    # ###Description
    # `set_line_attributes` can generate **BadAlloc**, **BadGC**, and **BadValue** errors.
    #
    # ###Diagnostics
    # - **BadAlloc** The server failed to allocate the requested source or server memory.
    # - *BadGC** A value for a `GContext` argument does not name a defined `GContext`.
    # - **BadValue** Some numeric value falls outside the range of values accepted
    # by the request. Unless a specific range is specified for an argument, the
    # full range defined by the argument's type is accepted. Any argument
    # defined as a set of alternatives can generate this error.
    #
    # ###See also
    # `create_gc`, `query_best_size`, `set_arc_mode`, `set_clip_origin`,
    # `set_dashes`, `set_fill_style`, `set_font`, `set_state`, `set_tile`.
    def set_line_attributes(gc : X11::C::X::GC, line_width : UInt32, line_style : Int32, cap_style : Int32, join_style : Int32) : Int32
      X.set_line_attributes @dpy, gc, line_width, line_style, cap_stype, join_style
    end

    # Specifies the KeyCodes of the keys that are to be used as modifiers.
    #
    # ###Arguments
    # - **modmap** Specifies the `ModifierKeymap` structure.
    #
    # ###Description
    # The `set_modifier_mapping` function specifies the KeyCodes of the keys
    # (if any) that are to be used as modifiers. If it succeeds, the X server
    # generates a **MappingNotify** event, and `set_modifier_mapping` returns
    # **MappingSuccess**. X permits at most eight modifier keys. If more than
    # eight are specified in the `ModifierKeymap` structure, a **BadLength** error results.
    #
    # The modifiermap member of the `ModifierKeymap` structure contains eight sets
    # of max_keypermod KeyCodes, one for each modifier in the order **Shift**,
    # **Lock**, **Control**, **Mod1**, **Mod2**, **Mod3**, **Mod4**, and **Mod5**.
    # Only nonzero KeyCodes have meaning in each set, and zero KeyCodes are ignored.
    # In addition, all of the nonzero KeyCodes must be in the range specified by
    # min_keycode and max_keycode in the `Display` object, or a **BadValue** error results.
    #
    # An X server can impose restrictions on how modifiers can be changed, for
    # example, if certain keys do not generate up transitions in hardware, if
    # auto-repeat cannot be disabled on certain keys, or if multiple modifier keys
    # are not supported. If some such restriction is violated, the status reply is
    # **MappingFailed**, and none of the modifiers are changed. If the new KeyCodes
    # specified for a modifier differ from those currently defined and any
    # (current or new) keys for that modifier are in the logically down state,
    # `set_modifier_mapping` returns **MappingBusy**, and none of the modifiers is changed.
    #
    # `set_modifier_mapping` can generate **BadAlloc** and **BadValue** errors.
    #
    # ###Diagnostics
    # - **BadAlloc** The server failed to allocate the requested source or server memory.
    #
    # ###See also
    # `change_keyboard_mapping`, `ModifierKeymap::delete_entry`, `keycodes`,
    # `keyboard_mapping`, `modifier_mapping`, `ModifierKeymap::insert_entry`,
    # `ModifierKeymap::new`, `set_pointer_mapping`.
    def set_modifier_mapping(modmap : ModifierKeymap) : Int32
      X.set_modifier_mapping @dpy, modmap.to_unsafe
    end

    # Sets the plane mask of a given GC.
    #
    # ###Arguments
    # - **gc** Specifies the GC.
    # - **plane_mask** Specifies the plane mask.
    #
    # ###Description
    # `set_plane_mask` can generate **BadAlloc** and **BadGC** errors.
    #
    # ###Diagnostics
    # - **BadAlloc** The server failed to allocate the requested source or server memory.
    # - **BadGC** A value for a `GContext` argument does not name a defined `GContext`.
    #
    # ###See also
    # `create_gc`, `query_best_size`, `set_arc_mode`, `set_background`,
    # `set_clip_origin`, `set_fill_style`, `set_font`, `set_foreground`,
    # `set_function`, `set_line_attributes`, `set_plane_mask`, `set_state`, `set_tile`.
    def set_plane_mask(gc : X11::C::X::GC, plane_mask : UInt64) : Int32
      X.set_plane_mask @dpy, gc, plane_mask
    end

    # Sets the mapping of the pointer.
    #
    # ###Arguments
    # - **map** Specifies the mapping list.
    #
    # ###Description
    # The `set_pointer_mapping` function sets the mapping of the pointer. If it
    # succeeds, the X server generates a **MappingNotify** event, and
    # `set_pointer_mapping` returns **MappingSuccess**. Element map[i] defines
    # the logical button number for the physical button i+1. The length of the
    # list must be the same as `pointer_mapping` would return, or a **BadValue**
    # error results. A zero element disables a button, and elements are not
    # restricted in value by the number of physical buttons. However, no two
    # elements can have the same nonzero value, or a **BadValue** error results.
    # If any of the buttons to be altered are logically in the down state,
    # `set_pointer_mapping` returns **MappingBusy**, and the mapping is not changed.
    #
    # `set_pointer_mapping` can generate a **BadValue** error.
    #
    # ###Diagnostics
    # - **BadValue** Some numeric value falls outside the range of values accepted
    # by the request. Unless a specific range is specified for an argument, the
    # full range defined by the argument's type is accepted. Any argument
    # defined as a set of alternatives can generate this error.
    #
    # ###See also
    # `change_keyboard_mapping`, `change_keyboard_mapping`, `pointer_mapping`.
    def set_pointer_mapping(map : Array(UInt8)) : Int32
      X.set_pointer_mapping @dpy, map.to_unsafe, map.size
    end

    # Sets the screen saver mode.
    #
    # ###Arguments
    # - **timeout** Specifies the timeout, in seconds, until the screen saver turns on.
    # - **interval* Specifies the interval, in seconds, between screen saver alterations.
    # - **prefer_blanking** Specifies how to enable screen blanking. You can pass
    # **DontPreferBlanking**, **PreferBlanking**, or **DefaultBlanking**.
    # - **allow_exposures** Specifies the screen save control values. You can pass
    # **DontAllowExposures**, **AllowExposures**, or **DefaultExposures**.
    #
    # ###Description
    # Timeout and interval are specified in seconds. A timeout of 0 disables the
    # screen saver (but an activated screen saver is not deactivated), and a
    # timeout of -1 restores the default. Other negative values generate a
    # **BadValue** error. If the timeout value is nonzero, `set_screen_saver`
    # enables the screen saver. An interval of 0 disables the random-pattern motion.
    # If no input from devices (keyboard, mouse, and so on) is generated for the
    # specified number of timeout seconds once the screen saver is enabled, the screen saver is activated.
    #
    # For each screen, if blanking is preferred and the hardware supports video
    # blanking, the screen simply goes blank. Otherwise, if either exposures are
    # allowed or the screen can be regenerated without sending **Expose** events
    # to clients, the screen is tiled with the root window background tile randomly
    # re-origined each interval seconds. Otherwise, the screens' state do not change,
    # and the screen saver is not activated. The screen saver is deactivated, and
    # all screen states are restored at the next keyboard or pointer input or at the
    # next call to `force_screen_saver` with mode **ScreenSaverReset**.
    #
    # If the server-dependent screen saver method supports periodic change, the
    # interval argument serves as a hint about how long the change period should
    # be, and zero hints that no periodic change should be made. Examples of ways
    # to change the screen include scrambling the colormap periodically, moving an
    # icon image around the screen periodically, or tiling the screen with the
    # root window background tile, randomly re-origined periodically.
    #
    # `set_screen_saver` can generate a **BadValue** error.
    #
    # ###Diagnostics
    # - **BadValue** Some numeric value falls outside the range of values
    # accepted by the request. Unless a specific range is specified for an
    # argument, the full range defined by the argument's type is accepted. Any
    # argument defined as a set of alternatives can generate this error.
    #
    # ###See also
    # `force_screen_saver`, `activate_screen_saver`, `reset_screen_saver`, `screen_saver`.
    def set_screen_saver(timeout : Int32, interval : Int32, prefer_blanking : Int32, allow_exposures : Int32) : Int32
      X.set_screen_saver @dpy, timeout, interval, prefer_blanking, allow_exposures
    end

    # Changes the owner and last-change time for the specified selection.
    #
    # ###Arguments
    # - **selection** Specifies the selection atom.
    # - **owner** Specifies the owner of the specified selection atom. You can pass a window or **None**.
    # - **time** Specifies the time. You can pass either a timestamp or **CurrentTime**.
    #
    # ###Description
    # The `set_selection_owner` function changes the owner and last-change time
    # for the specified selection and has no effect if the specified time is
    # earlier than the current last-change time of the specified selection or is
    # later than the current X server time. Otherwise, the last-change time is
    # set to the specified time, with **CurrentTime** replaced by the current
    # server time. If the owner window is specified as **None**, then the owner
    # of the selection becomes **None** (that is, no owner). Otherwise, the
    # owner of the selection becomes the client executing the request.
    #
    # If the new owner (whether a client or **None**) is not the same as the
    # current owner of the selection and the current owner is not **None**,
    # the current owner is sent a **SelectionClear** event. If the client that
    # is the owner of a selection is later terminated (that is, its connection
    # is closed) or if the owner window it has specified in the request is later
    # destroyed, the owner of the selection automatically reverts to **None**,
    # but the last-change time is not affected. The selection atom is
    # uninterpreted by the X server. `selection_owner` returns the owner window,
    # which is reported in **SelectionRequest** and **SelectionClear** events.
    # Selections are global to the X server.
    #
    # `set_selection_owner` can generate **BadAtom** and **BadWindow** errors.
    #
    # ###Diagnostics
    # - **BadAtom** A value for an *Atom* argument does not name a defined *Atom*.
    # - **BadWindow** A value for a *Window* argument does not name a defined *Window*.
    #
    # ###See also
    # `convert_selection`, `selection_owner`.
    def set_selection_owner(selection : Atom | X11::C::Atom, owner : X11::C::Window, time : X11::C::Time) : Int32
      X.set_selection_owner @dpy, selection.to_u64, owner, time
    end

    # Sets the foreground, background, plane mask, and function components for a given GC.
    #
    # ###Arguments
    # - **gc** Specifies the GC.
    # - **foreground** Specifies the foreground you want to set for the specified GC.
    # - **background** Specifies the background you want to set for the specified GC.
    # - **function** Specifies the function you want to set for the specified GC.
    # - **plane_mask** Specifies the plane mask.
    #
    # ###Description
    # `set_state` can generate **BadAlloc**, **BadGC**, and **BadValue** errors.
    #
    # ###Diagnostics
    # - **BadAlloc** The server failed to allocate the requested source or server memory.
    # - **BadGC** A value for a `GContext` argument does not name a defined `GContext`.
    # - **BadValue** Some numeric value falls outside the range of values accepted
    # by the request. Unless a specific range is specified for an argument, the
    # full range defined by the argument's type is accepted. Any argument defined
    # as a set of alternatives can generate this error.
    #
    # ###See also
    # `create_gc`, `query_best_size`, `set_arc_mode`, `set_background`,
    # `set_clip_origin`, `set_fill_style`, `set_font`, `set_foreground`,
    # `set_function`, `set_line_attributes`, `set_plane_mask`, `set_tile`.
    def set_state(gc : X11::C::X::GC, foreground : UInt64, background : UInt64, function : Int32, plane_mask : UInt64) : Int32
      X.set_state @dpy, gc, foreground, background, function, plane_mask
    end

    # Sets the stipple of a given GC.
    #
    # ###Arguments
    # - **gc** Specifies the GC.
    # - **stipple** Specifies the stipple you want to set for the specified GC.
    #
    # ###Description
    # The stipple must have a depth of one, or a **BadMatch** error results.
    # `set_stipple` can generate **BadAlloc**, **BadGC**, **BadMatch**, and **BadPixmap** errors.
    #
    # ###Diagnostics
    # - **BadAlloc** The server failed to allocate the requested source or server memory.
    # - **BadGC** A value for a `GContext` argument does not name a defined `GContext`.
    # - **BadMatch** An **InputOnly** window is used as a *Drawable*.
    # - **BadMatch** Some argument or pair of arguments has the correct type and
    # range but fails to match in some other way required by the request.
    # - **BadPixmap** A value for a *Pixmap* argument does not name a defined *Pixmap*.
    #
    # ###See also
    # `create_gc`, `query_best_size`, `set_arc_mode`, `set_clip_origin`,
    # `set_fill_style`, `set_font`, `set_line_attributes`, `set_state`,
    # `set_tile`, `set_ts_origin`.
    def set_stipple(gc : X11::C::X::GC, stipple : X11::C::Pixmap) : Int32
      X.set_stipple @dpy, gc, stipple
    end

    # Sets the subwindow mode of a given GC.
    #
    # ###Arguments
    # - **gc** Specifies the GC.
    # - **subwindow_mode** Specifies the subwindow mode.
    # You can pass **ClipByChildren** or **IncludeInferiors**.
    #
    # ###Description
    # `set_subwindow_mode` can generate **BadAlloc**, **BadGC**, and **BadValue** errors.
    #
    # ###Diagnostics
    # - **BadAlloc** The server failed to allocate the requested source or server memory.
    # - **BadGC** A value for a `GContext` argument does not name a defined `GContext`.
    # - **BadValue** Some numeric value falls outside the range of values accepted
    # by the request. Unless a specific range is specified for an argument, the
    # full range defined by the argument's type is accepted. Any argument defined
    # as a set of alternatives can generate this error.
    #
    # ###See also
    # `copy_area`, `create_gc`, `query_best_size`, `set_arc_mode`,
    # `set_clip_origin`, `set_fill_style`, `set_font`, `set_graphics_exposures`,
    # `set_line_attributes`, `set_state`, `set_tile`.
    def set_subwindow_mode(gc : X11::C::X::GC, subwindow_mode : Int32) : Int32
      X.set_subwindow_mode @dpy, gc, subwindow_mode
    end

    # Sets the tile or stipple origin of a given GC.
    #
    # ###Arguments
    # - **gc** Specifies the GC.
    # - **ts_x_origin**, **ts_y_origin** Specify the x and y coordinates of the tile and stipple origin.
    #
    # ###Description
    # When graphics requests call for tiling or stippling, the parent's origin
    # will be interpreted relative to whatever destination drawable is specified in the graphics request.
    #
    # `set_ts_origin` can generate **BadAlloc** and **BadGC** error.
    #
    # ###Diagnostics
    # - **BadAlloc** The server failed to allocate the requested source or server memory.
    # - **BadGC** A value for a `GContext` argument does not name a defined `GContext`.
    #
    # ###See also
    # `create_gc`, `query_best_size`, `set_arc_mode`, `set_clip_origin`,
    # `set_fill_style`, `set_font`, `set_line_attributes`, `set_state`,
    # `set_stipple`, `set_tile`.
    def set_ts_origin(gc : X11::C::X::GC, ts_x_origin : Int32, ts_y_origin : Int32) : Int32
      X.set_ts_origin @dpy, gc, ts_x_origin, ts_y_origin
    end

    # Sets the tile or stipple origin of a given GC.
    #
    # ###Arguments
    # - **gc** Specifies the GC.
    # - **tile** Specifies the fill tile you want to set for the specified GC.
    #
    # ###Description
    # The tile and GC must have the same depth, or a **BadMatch** error results.
    #
    # `set_tile` can generate **BadAlloc**, **BadGC**, **BadMatch**, and **BadPixmap** errors.
    #
    # ###Diagnostics
    # - **BadAlloc** The server failed to allocate the requested source or server memory.
    # - **BadGC** A value for a `GContext` argument does not name a defined `GContext`.
    # - **BadMatch** An **InputOnly** window is used as a *Drawable*.
    # - **BadMatch** Some argument or pair of arguments has the correct type and
    # range but fails to match in some other way required by the request.
    # - **BadPixmap** A value for a *Pixmap* argument does not name a defined *Pixmap*.
    #
    # ###See also
    # `create_gc`, `query_best_size`, `set_arc_mode`, `set_clip_origin`,
    # `set_fill_style`, `set_font`, `set_line_attributes`, `set_state`,
    # `set_stipple`, `set_ts_origin`.
    def set_tile(gc : X11::C::X::GC, tile : X11::C::Pixmap) : Int32
      X.set_title @dpy, gc, tile
    end

    # Sets the background of the window to the specified pixel value.
    #
    # ###Arguments
    # - **w** Specifies the window.
    # - **background_pixel** Specifies the pixel that is to be used for the background.
    #
    # ###Description
    # The `set_window_background` function sets the background of the window to
    # the specified pixel value. Changing the background does not cause the window
    # contents to be changed. `set_window_background` uses a pixmap of undefined
    # size filled with the pixel value you passed. If you try to change the
    # background of an **InputOnly** window, a **BadMatch** error results.
    #
    # `set_window_background` can generate **BadMatch** and **BadWindow** errors.
    #
    # Note `set_window_background` and `set_window_background_pixmap` do not
    # change the current contents of the window.
    #
    # ###Diagnostics
    # - **BadMatch** An **InputOnly** window is used as a *Drawable*.
    # - **BadMatch** Some argument or pair of arguments has the correct type and
    # range but fails to match in some other way required by the request.
    # - **BadWindow** A value for a *Window* argument does not name a defined *Window*.
    #
    # ###See also
    # `change_window_attributes`, `configure_window`, `create_window`,
    # `destroy_window`, `install_colormap`, `map_window`, `raise_window`,
    # `set_window_background_pixmap`, `set_window_border`,
    # `set_window_border_pixmap`, `set_window_colormap`, `unmap_window`.
    def set_window_background(w : X11::C::Window, background_pixel : UInt64) : Int32
      X.set_window_background @dpy, w, background_pixel
    end

    # Sets the background pixmap of the window to the specified pixmap.
    #
    # ###Arguments
    # - **w** Specifies the window.
    # - **background_pixmap** Specifies the background pixmap, **ParentRelative**, or **None**.
    #
    # ###Description
    # The `set_window_background_pixmap` function sets the background pixmap of
    # the window to the specified pixmap. The background pixmap can immediately
    # be freed if no further explicit references to it are to be made. If
    # **ParentRelative** is specified, the background pixmap of the window's
    # parent is used, or on the root window, the default background is restored.
    # If you try to change the background of an **InputOnly** window, a **BadMatch**
    # error results. If the background is set to **None**, the window has no defined background.
    #
    # `set_window_background_pixmap` can generate **BadMatch**, **BadPixmap**, and **BadWindow** errors.
    #
    # Note `set_window_background` and `set_window_background_pixmap` do
    # not change the current contents of the window.
    #
    # ###Diagnostics
    # - **BadMatch** An **InputOnly** window is used as a *Drawable*.
    # - **BadMatch** Some argument or pair of arguments has the correct type and
    # range but fails to match in some other way required by the request.
    # - **BadPixmap** A value for a *Pixmap* argument does not name a defined *Pixmap*.
    # - **BadWindow** A value for a *Window* argument does not name a defined *Window*.
    #
    # ###See also
    # `change_window_attributes`, `configure_window`, `create_window`,
    # `destroy_window`, `install_colormap`, `map_window`, `raise_window`,
    # `set_window_background`, `set_window_border`, `set_window_border_pixmap`,
    # `set_window_colormap`, `unmap_window`.
    def set_window_background_pixmap(w : X11::C::Window, background_pixmap : X11::C::Pixmap) : Int32
      X.set_window_background_pixmap @dpy, w, background_pixmap
    end

    # Sets the border of the window to the pixel value you specify.
    #
    # ###Arguments
    # - **w** Specifies the window.
    # - **border_pixel** Specifies the entry in the colormap.
    #
    # ###Description
    # The `set_window_border` function sets the border of the window to the
    # pixel value you specify. If you attempt to perform this on an
    # **InputOnly** window, a **BadMatch** error results.
    #
    # `set_window_border` can generate **BadMatch** and **BadWindow** errors.
    #
    # ###Diagnostics
    # - **BadMatch** An **InputOnly** window is used as a *Drawable*.
    # - **BadMatch** Some argument or pair of arguments has the correct type and
    # range but fails to match in some other way required by the request.
    # - **BadWindow** A value for a *Window* argument does not name a defined *Window*.
    #
    # ###See also
    # `change_window_attributes`, `configure_window`, `create_window`,
    # `destroy_window`, `install_colormap`, `map_window`, `raise_window`,
    # `set_window_background`, `set_window_background_pixmap`,
    # `set_window_border_pixmap`, `set_window_colormap`, `unmap_window`.
    def set_window_border(w : X11::C::Window, border_pixel : UInt64) : Int32
      X.set_window_border @dpy, w, border_pixel
    end

    # Sets the border pixmap of the window to the pixmap you specify.
    #
    # ###Arguments
    # - **w** Specifies the window.
    # - **border_pixmap** Specifies the border pixmap or **CopyFromParent**.
    #
    # ###Description
    # - The `set_window_border_pixmap` function sets the border pixmap of the
    # window to the pixmap you specify. The border pixmap can be freed immediately
    # if no further explicit references to it are to be made. If you specify
    # **CopyFromParent**, a copy of the parent window's border pixmap is used.
    # If you attempt to perform this on an **InputOnly** window, a **BadMatch** error results.
    #
    # `set_window_border_pixmap` can generate **BadMatch**, **BadPixmap**, and **BadWindow** errors.
    #
    # ###Diagnostics
    # - **BadMatch** An **InputOnly** window is used as a *Drawable*.
    # - **BadMatch** Some argument or pair of arguments has the correct type and
    # range but fails to match in some other way required by the request.
    # - **BadPixmap** A value for a *Pixmap* argument does not name a defined *Pixmap*.
    # - **BadWindow** A value for a *Window* argument does not name a defined *Window*.
    #
    # ###See also
    # `change_window_attributes`, `configure_window`, `create_window`,
    # `destroy_window`, `installed_colormap`, `map_window`, `raise_window`,
    # `set_window_background`, `set_window_background_pixmap`, `set_window_border`,
    # `set_window_colormap`, `unmap_window`.
    def set_window_border_pixmap(w : X11::C::Window, border_pixmap : X11::C::Pixmap) : Int32
      X.set_window_border_pixmap @dpy, w, border_pixmap
    end

    # Sets the specified window's border width to the specified width.
    #
    # ###Arguments
    # **w** Specifies the window.
    # - **width** Specifies the width of the window border.
    #
    # ###Description
    # The `set_window_border_width` function sets the specified window's border width to the specified width.
    #
    # `set_window_border_width` can generate a **BadWindow** error.
    #
    # ###Diagnostics
    # - **BadWindow** A value for a *Window* argument does not name a defined *Window*.
    #
    # ###See also
    # `change_window_attributes`, `configure_window`, `create_window`,
    # `destroy_window`, `map_window`, `move_resize_window`, `move_window`,
    # `raise_window`, `resize_window`, `unmap_window`.
    def set_window_border_width(w : X11::C::Window, width : UInt32) : Int32
      X.set_window_border_width @dpy, w, width
    end

    # Sets the specified colormap of the specified window.
    #
    # ###Arguments
    # **w** Specifies the window.
    # - **colormap** Specifies the colormap.
    #
    # ###Description
    # The `set_window_colormap` function sets the specified colormap of the
    # specified window. The colormap must have the same visual type as the
    # window, or a **BadMatch** error results.
    #
    # `set_window_colormap` can generate **BadColor**, **BadMatch**, and **BadWindow** errors.
    #
    # ###Diagnostics
    # - **BadColor** A value for a *Colormap* argument does not name a defined *Colormap*.
    # - **BadMatch** An **InputOnly** window is used as a *Drawable*.
    # - **BadMatch** Some argument or pair of arguments has the correct type and
    # range but fails to match in some other way required by the request.
    # - **BadWindow** A value for a *Window* argument does not name a defined *Window*.
    #
    # ###See also
    # `change_window_attributes`, `configure_window`, `create_window`,
    # `destroy_window`, `installed_colormap`, `map_window`, `raise_window`,
    # `set_window_background`, `set_window_background_pixmap`,
    # `set_window_border`, `set_window_border_pixmap`, `unmap_window`.
    def set_window_colormap(w : X11::C::Window, colormap : X11::C::Colormap) : Int32
      X.set_window_colormap @dpy, w, colormap
    end

    # Stores data in a specified cut buffer.
    #
    # ###Arguments
    # - **bytes** Specifies the bytes, which are not necessarily ASCII or null-terminated.
    # - **nbytes** Specifies the number of bytes to be stored.
    # - **buffer** Specifies the buffer in which you want to store the bytes.
    #
    # ###Description
    # If an invalid buffer is specified, the call has no effect.
    # The data can have embedded null characters and need not be null-terminated.
    #
    # `store_buffer` can generate a **BadAlloc** error.
    #
    # ###Diagnostics
    # - **BadAlloc** The server failed to allocate the requested source or server memory.
    #
    # ###See also
    # `fetch_buffer`, `fetch_bytes`, `rotate_buffers`, `store_buffer`, `store_bytes`.
    def store_buffer(bytes  : Bytes, nbytes : Int32, buffer : Int32) : Int32
      X.store_buffer @dpy, bytes.to_unsafe, nbytes, buffer
    end

    # Stores data in cut buffer 0.
    #
    # ###Arguments
    # - **bytes** Specifies the bytes, which are not necessarily ASCII or null-terminated.
    # - **nbytes** Specifies the number of bytes to be stored.
    #
    # ###Description
    # The data can have embedded null characters and need not be null-terminated.
    # The cut buffer's contents can be retrieved later by any client calling `fetch_bytes`.
    #
    # `store_bytes` can generate a **BadAlloc** error.
    #
    # ###Diagnostics
    # - **BadAlloc** The server failed to allocate the requested source or server memory.
    #
    # ###See also
    # `fetch_buffer`, `fetch_bytes`, `rotate_buffers`, `store_buffer`.
    def store_bytes(bytes : Bytes) : Int32
      X.store_bytes @dpy, bytes.to_unsafe, bytes.size
    end

    # Changes the colormap entry of the pixel value
    # specified in the pixel member of the `Color` structure.
    #
    # ###Arguments
    # - **colormap** Specifies the colormap.
    # - **color** Specifies the pixel and RGB values.
    #
    # ###Description
    # The `store_color` function changes the colormap entry of the pixel value
    # specified in the pixel member of the `Color` structure. You specified this
    # value in the pixel member of the `Color` structure. This pixel value must
    # be a read/write cell and a valid index into the colormap. If a specified
    # pixel is not a valid index into the colormap, a **BadValue** error results.
    # `store_color` also changes the red, green, and/or blue color components.
    # You specify which color components are to be changed by setting
    # **DoRed**, **DoGreen**, and/or **DoBlue** in the flags member of the
    # `Color` structure. If the colormap is an installed map for its screen,
    # the changes are visible immediately.
    #
    # `store_color` can generate **BadAccess**, **BadColor**, and **BadValue** errors.
    #
    # ###Diagnostics
    # - **BadAccess** A client attempted to free a color map entry that it did not already allocate.
    # - **BadAccess** A client attempted to store into a read-only color map entry.
    # - **BadColor** A value for a *Colormap* argument does not name a defined *Colormap*.
    # - **BadValue** Some numeric value falls outside the range of values accepted
    # by the request. Unless a specific range is specified for an argument, the
    # full range defined by the argument's type is accepted.
    # Any argument defined as a set of alternatives can generate this error.
    #
    # ###See also
    # `alloc_color`, `create_colormap`, `query_color`, `store_colors`, `store_named_color`.
    def store_color(colormap : X11::C::Colormap, color : Color) : Int32
      X.store_color @dpy, colormap, color.to_unsafe
    end

    # Changes the colormap entries of the pixel values
    # specified in the pixel members of the `Color` structures.
    #
    # ###Arguments
    # - **colormap** Specifies the colormap.
    # - **color** Specifies an array of color definition structures to be stored.
    #
    # ###Description
    # The `store_colors` function changes the colormap entries of the pixel values
    # specified in the pixel members of the `Color` structures. You specify which
    # color components are to be changed by setting **DoRed**, **DoGreen**,
    # and/or **DoBlue** in the flags member of the `Color` structures. If the
    # colormap is an installed map for its screen, the changes are visible
    # immediately. `store_colors` changes the specified pixels if they are
    # allocated writable in the colormap by any client, even if one or more
    # pixels generates an error. If a specified pixel is not a valid index into
    # the colormap, a **BadValue** error results. If a specified pixel either is
    # unallocated or is allocated read-only, a **BadAccess** error results. If
    # more than one pixel is in error, the one that gets reported is arbitrary.
    #
    # `store_colors` can generate **BadAccess**, **BadColor**, and **BadValue** errors.
    #
    # ###Diagnostics
    # - **BadAccess** A client attempted to free a color map entry that it did not already allocate.
    # - **BadAccess** A client attempted to store into a read-only color map entry.
    # - **BadColor** A value for a *Colormap* argument does not name a defined *Colormap*.
    # - **BadValue** Some numeric value falls outside the range of values accepted
    # by the request. Unless a specific range is specified for an argument, the
    # full range defined by the argument's type is accepted. Any argument
    # defined as a set of alternatives can generate this error.
    #
    # ###See also
    # `alloc_color`, `create_colormap`, `query_color`, `store_color`,
    # `store_colors`, `store_named_color`.
    def store_colors(colormap : X11::C::Colormap, color : Array(Color)) : Int32
      X.store_colors @dpy, colormap, color.to_unsafe.as(X11::C::X::PColor)
    end

    # Assigns the name passed to window_name to the specified window.
    #
    # ###Arguments
    # **w** Specifies the window.
    # - **window_name** Specifies the window name, which should be a null-terminated string.
    #
    # ###Description
    # The `store_name` function assigns the name passed to window_name to the
    # specified window. A window manager can display the window name in some
    # prominent place, such as the title bar, to allow users to identify windows
    # easily. Some window managers may display a window's name in the window's
    # icon, although they are encouraged to use the window's icon name if one is
    # provided by the application. If the string is not in the Host Portable
    # Character Encoding, the result is implementation dependent.
    #
    # `store_name` can generate **BadAlloc** and **BadWindow** errors.
    #
    # ###Diagnostics
    # - **BadAlloc** The server failed to allocate the requested source or server memory.
    # - **BadWindow** A value for a *Window* argument does not name a defined *Window*.
    #
    # ###See also
    # `fetch_name`, `wm_name`, `set_command`, `set_text_property`,
    # `set_transient_for_hint`, `set_wm_client_machine`, `set_wm_colormap_windows`,
    # `set_wm_colormap_windows`, `set_wm_icon_name`, `set_wm_icon_name`,
    # `set_wm_name`, `set_wm_properties`, `set_wm_protocols`.
    def store_name(w : X11::C::Window, window_name : String) : Int32
      X.store_name @dpy, w, window_name.to_unsafe
    end

    # Looks up the named color with respect to the screen associated with the
    # colormap and stores the result in the specified colormap.
    #
    # ###Arguments
    # **colormap** Specifies the colormap.
    # - **color** Specifies the color name string (for example, red).
    # - **pixel** Specifies the entry in the colormap.
    # - **flags** Specifies which red, green, and blue components are set.
    #
    # ###Description
    # The `store_named_color` function looks up the named color with respect to
    # the screen associated with the colormap and stores the result in the
    # specified colormap. The pixel argument determines the entry in the colormap.
    # The flags argument determines which of the red, green, and blue components are set.
    # You can set this member to the bitwise inclusive OR of the bits **DoRed**,
    # **DoGreen**, and **DoBlue**. If the color name is not in the Host Portable
    # Character Encoding, the result is implementation dependent. Use of uppercase
    # or lowercase does not matter. If the specified pixel is not a valid index
    # into the colormap, a **BadValue** error results. If the specified pixel
    # either is unallocated or is allocated read-only, a **BadAccess** error results.
    #
    # `store_named_color` can generate **BadAccess**, **BadColor**, **BadName**,
    # and **BadValue** errors.
    #
    # ###Diagnostics
    # - **BadAccess** A client attempted to free a color map entry that it did not already allocate.
    # - **BadAccess** A client attempted to store into a read-only color map entry.
    # - **BadColor** A value for a *Colormap* argument does not name a defined *Colormap*.
    # - **BadName** A font or color of the specified name does not exist.
    # - **BadValue** Some numeric value falls outside the range of values accepted
    # by the request. Unless a specific range is specified for an argument, the
    # full range defined by the argument's type is accepted. Any argument
    # defined as a set of alternatives can generate this error.
    #
    # ###See also
    # `alloc_color`, `create_colormap`, `query_color`, `store_color`, `store_colors`.
    def store_named_color(colormap : X11::C::Colormap, color : Color, pixel : UInt64, flags : Int32) : Int32
      X.store_named_color @dpy, colormap, color.to_unsafe, pixel, flags
    end

    # Flushes the output buffer and then waits until all
    # requests have been received and processed by the X server.
    #
    # ###Arguments
    # - **discard** Specifies a Boolean value that indicates whether
    # `sync` discards all events on the event queue.
    #
    # ###Description
    # The `sync` function flushes the output buffer and then waits until all
    # requests have been received and processed by the X server. Any errors
    # generated must be handled by the error handler. For each protocol error
    # received by Xlib, `sync` calls the client application's error handling
    # routine (see "Using the Default Error Handlers"). Any events generated by
    # the server are enqueued into the library's event queue.
    #
    # Finally, if you passed **false**, `sync` does not discard the events in
    # the queue. If you passed **true**, `sync` discards all events in the queue,
    # including those events that were on the queue before `sync` was called.
    # Client applications seldom need to call `sync`.
    #
    # ###See also
    # `events_queued`, `flush`, `pending`.
    def sync(discard : Bool) : Int32
      X.sync @dpy, discard ? X::True : X::False
    end

    # Transforms coordinates from the coordinate space of one window to another window.
    #
    # ###Arguments
    # - **src_w** Specifies the source window.
    # - **dest_w** Specifies the destination window.
    # - **src_x**, **src_y** Specify the x and y coordinates within the source window.
    #
    # ###Returns
    # - **dest_x**, **dest_y** Return the x and y coordinates within the destination window.
    # - **child_return** Returns the child if the coordinates are contained in a mapped child of the destination window.
    #
    # ###Description
    # If `translate_coordinates` returns **true**, it takes the src_x and src_y
    # coordinates relative to the source window's origin and returns these
    # coordinates to dest_x and dest_y relative to the destination window's origin.
    # If `translate_coordinates` returns **false**, src_w and dest_w are on
    # different screens, and dest_x and dest_y are zero. If the coordinates are
    # contained in a mapped child of dest_w, that child is returned to
    # child. Otherwise, child is set to **None**.
    #
    # `translate_coordinates` can generate a **BadWindow** error.
    #
    # ###Diagnostics
    # - **BadWindow** A value for a *Window* argument does not name a defined *Window*.
    def translate_coordinates(src_w : X11::C::Window, dest_w : X11::C::Window, src_x : Int32, src_y : Int32) : NamedTuple(dest_x: Int32, dest_y: Int32, child: X11::C::Window, res: Bool)
      X.translate_coordinates @dpy, src_w, dest_w, src_x, src_y, out dest_x_return, out dest_y_return, out child_return
      {dest_x: dest_x_return, dest_y: dest_y_return, child: child_return}
    end

    # Undoes the effect of a previous `define_cursor` for this window.
    #
    # ###Arguments
    # - **w** Specifies the window.
    #
    # ###Description
    # The `undefine_cursor` function undoes the effect of a previous
    # `define_cursor` for this window. When the pointer is in the window,
    # the parent's cursor will now be used. On the root window, the default cursor is restored.
    #
    # `undefine_cursor` can generate a **BadWindow** error.
    #
    # ###Diagnostics
    # - **BadWindow** A value for a *Window* argument does not name a defined *Window*.
    #
    # ###See also
    # `create_font_cursor`, `define_cursor`, `recolor_cursor`.
    def undefine_cursor(w : X11::C::Window) : Int32
      X.undefine_cursor @dpy, w
    end

    # Releases the passive button/key combination
    # on the specified window if it was grabbed by this client.
    #
    # ###Arguments
    # - **button** Specifies the pointer button that is to be released or **AnyButton**.
    # - **modifiers** Specifies the set of keymasks or **AnyModifier**. The mask
    # is the bitwise inclusive OR of the valid keymask bits.
    # - **grab_window** Specifies the grab window.
    #
    # ###Description
    # The `ungrab_button` function releases the passive button/key combination
    # on the specified window if it was grabbed by this client. A modifiers of
    # **AnyModifier** is equivalent to issuing the ungrab request for all
    # possible modifier combinations, including the combination of no modifiers.
    # A button of **AnyButton** is equivalent to issuing the request for all
    # possible buttons. `ungrab_button` has no effect on an active grab.
    #
    # `ungrab_button` can generate **BadValue** and **BadWindow** errors.
    #
    # ###Diagnostics
    # - **BadValue** Some numeric value falls outside the range of values
    # accepted by the request. Unless a specific range is specified for an
    # argument, the full range defined by the argument's type is accepted.
    # Any argument defined as a set of alternatives can generate this error.
    # - **BadWindow** A value for a *Window* argument does not name a defined *Window*.
    #
    # ###See also
    # `allow_events`, `change_active_pointer_grab`, `grab_button`,
    # `grab_key`, `grab_keyboard`, `grab_pointer`, `ungrab_pointer`.
    def ungrab_button(button : UInt32, modifiers : UInt32, grab_window : X11::C::Window) : Int32
      X.ungrab_button @dpy, button, modifiers, grab_window
    end

    # Releases the key combination on the specified window if it was grabbed by this client.
    #
    # ###Arguments
    # - **keycode** Specifies the KeyCode or **AnyKey**.
    # - **modifiers** Specifies the set of keymasks or **AnyModifier**.
    # The mask is the bitwise inclusive OR of the valid keymask bits.
    # - **grab_window** Specifies the grab window.
    #
    # ###Description
    # The `ungrab_key` function releases the key combination on the specified
    # window if it was grabbed by this client. It has no effect on an active grab.
    # A modifiers of **AnyModifier** is equivalent to issuing the request for all
    # possible modifier combinations (including the combination of no modifiers).
    # A keycode argument of **AnyKey** is equivalent to issuing the request for all possible key codes.
    #
    # `ungrab_key` can generate **BadValue** and **BadWindow** errors.
    #
    # ###Diagnostics
    # - **BadValue** Some numeric value falls outside the range of values
    # accepted by the request. Unless a specific range is specified for an argument,
    # the full range defined by the argument's type is accepted. Any argument
    # defined as a set of alternatives can generate this error.
    # - **BadWindow** A value for a *Window* argument does not name a defined *Window*.
    #
    # ###See also
    # `grab_key`, `allow_events`, `grab_button`, `grab_keyboard`, `grab_pointer`.
    def ungrab_key(keycode : Int32, modifiers : UInt32, grab_window : X11::C::Window) : Int32
      X.ungrab_key @dpy, keycode, modifiers, grab_window
    end

    # Releases the keyboard and any queued events if this client has it
    # actively grabbed from either `grab_keyboard` or `grab_key`.
    #
    # ###Arguments
    # - **time** Specifies the time. You can pass either a timestamp or **CurrentTime**.
    #
    # ###Description
    # The `ungrab_keyboard` function releases the keyboard and any queued events
    # if this client has it actively grabbed from either `grab_keyboard` or
    # `grab_key`. `ungrab_keyboard` does not release the keyboard and any queued
    # events if the specified time is earlier than the last-keyboard-grab time
    # or is later than the current X server time. It also generates **FocusIn**
    # and **FocusOut** events. The X server automatically performs an
    # **UngrabKeyboard** request if the event window for an active keyboard grab becomes not viewable.
    #
    # ###See also
    # `allow_events`, `grab_button`, `grab_key`, `grab_keyboard`, `grab_pointer`.
    def ungrab_keyboard(time : X11::C::Time) : Int32
      X.ungrab_keyboard @dpy, time
    end

    # Releases the pointer and any queued events.
    #
    # ###Arguments
    # - **time** Specifies the time. You can pass either a timestamp or **CurrentTime**.
    #
    # ###Description
    # The `ungrab_pointer` function releases the pointer and any queued events
    # if this client has actively grabbed the pointer from `grab_pointer`,
    # `grab_button`, or from a normal button press. `ungrab_pointer` does not
    # release the pointer if the specified time is earlier than the
    # last-pointer-grab time or is later than the current X server time. It also
    # generates **EnterNotify** and **LeaveNotify** events. The X server performs
    # an **UngrabPointer** request automatically if the event window or confine_to
    # window for an active pointer grab becomes not viewable or if window
    # reconfiguration causes the confine_to window to lie completely outside
    # the boundaries of the root window.
    #
    # ###See also
    # `allow_events`, `change_active_pointer_grab`, `grab_button`,
    # `grab_key`, `grab_keyboard`, `grab_pointer`.
    def ungrab_pointer(time : X11::C::Time) : Int32
      X.ungrab_pointer @dpy, time
    end

    # Restarts processing of requests and close downs on other connections.
    #
    # ###Description
    # The `ungrab_server` function restarts processing of requests and close
    # downs on other connections. You should avoid grabbing the X server as much as possible.
    #
    # ###See also
    # `grab_server`, `grab_key`, `grab_keyboard`, `grab_pointer`.
    def ungrab_server : Int32
      X.ungrab_server @dpy
    end

    # Removes the specified colormap from the required list for its screen.
    #
    # ###Arguments
    # - **colormap** Specifies the colormap.
    #
    # ###Description
    # The `uninstall_colormap` function removes the specified colormap from the
    # required list for its screen. As a result, the specified colormap might be
    # uninstalled, and the X server might implicitly install or uninstall
    # additional colormaps. Which colormaps get installed or uninstalled is
    # server-dependent except that the required list must remain installed.
    #
    # If the specified colormap becomes uninstalled, the X server generates a
    # **ColormapNotify** event on each window that has that colormap. In
    # addition, for every other colormap that is installed or uninstalled as a
    # result of a call to `uninstall_colormap`, the X server generates a
    # **ColormapNotify** event on each window that has that colormap.
    #
    # `uninstall_colormap` can generate a **BadColor** error.
    #
    # ###Diagnostics
    # - **BadColor** A value for a *Colormap* argument does not name a defined *Colormap*.
    #
    # ###See also
    # `change_window_attributes`, `create_colormap`, `create_window`,
    # `install_colormap`, `installed_colormap`.
    def uninstall_colormap(colormap : X11::C::Colormap) : Int32
      X.uninstall_colormap @dpy, colormap
    end

    # Deletes the association between the font resource ID and the specified font.
    #
    # ###Arguments
    # - **font** Specifies the font.
    #
    # ###Description
    # The `unload_font` function deletes the association between the font
    # resource ID and the specified font. The font itself will be freed when no
    # other resource references it. The font should not be referenced again.
    #
    # `unload_font` can generate a **BadFont** error.
    #
    # ###Diagnostics
    # - **BadFont** A value for a font argument does not name a defined
    # font (or, in some cases, `GContext`).
    #
    # ###See also
    # `create_gc`, `free_font`, `FontStruct::property`, `fonts`, `load_font`,
    # `load_query_font`, `query_font`, `set_font_path`.
    def unload_font(font : X11::C::Font) : Int32
      X.unload_font
    end

    # Unmaps all subwindows for the specified window in bottom-to-top stacking order.
    #
    # ###Arguments
    # - **w** Specifies the window.
    #
    # ###Description
    # The `unmap_subwindows` function unmaps all subwindows for the specified
    # window in bottom-to-top stacking order. It causes the X server to generate
    # an **UnmapNotify** event on each subwindow and **Expose** events on formerly
    # obscured windows. Using this function is much more efficient than unmapping
    # multiple windows one at a time because the server needs to perform much of
    # the work only once, for all of the windows, rather than for each window.
    #
    # `unmap_subwindows` can generate a **BadWindow** error.
    #
    # ###Diagnostics
    # - **BadWindow** A value for a *Window* argument does not name a defined *Window*.
    #
    # ###See also
    # `change_window_attributes`, `configure_window`, `create_window`,
    # `destroy_window`, `map_window`, `raise_window`, `unmap_window`.
    def unmap_subwindows(w : X11::C::Window) : Int32
      X.unmap_subwindows @dpy, w
    end

    # Unmaps the specified window and causes the X server to generate an **UnmapNotify** event.
    #
    # ###Arguments
    # - **w** Specifies the window.
    #
    # ###Description
    # The `unmap_window` function unmaps the specified window and causes the X
    # server to generate an **UnmapNotify** event. If the specified window is
    # already unmapped, `unmap_window` has no effect. Normal exposure processing
    # on formerly obscured windows is performed. Any child window will no longer
    # be visible until another map call is made on the parent. In other words,
    # the subwindows are still mapped but are not visible until the parent is
    # mapped. Unmapping a window will generate **Expose** events on windows that were formerly obscured by it.
    #
    # `unmap_window` can generate a **BadWindow** error.
    #
    # ###Diagnostics
    # - **BadWindow** A value for a *Window* argument does not name a defined *Window*.
    #
    # ###See also
    # `change_window_attributes`, `configure_window`, `create_window`,
    # `destroy_window`, `map_window`, `raise_window`, `unmap_subwindows`.
    def unmap_window(w : X11::C::Window) : Int32
      X.unmap_window @dpy, w
    end

    # Returns a number related to a vendor's release of the X server.
    def vendor_release : Int32
      X.vendor_release @dpy
    end

    # Moves the pointer by the offsets relative to the current position of the pointer.
    #
    # ###Arguments
    # - **src_w** Specifies the source window or **None**.
    # - **dest_w** Specifies the destination window or **None**.
    # - **src_x**, **src_y**, **src_width**, **src_height** Specify a rectangle in the source window.
    # - **dest_x**, **dest_y** Specify the x and y coordinates within the destination window.
    #
    # ###Description
    # If dest_w is **None**, `warp_pointer` moves the pointer by the offsets
    # (dest_x, dest_y) relative to the current position of the pointer.
    # If dest_w is a window, `warp_pointer` moves the pointer to the offsets
    # (dest_x, dest_y) relative to the origin of dest_w. However, if src_w is a
    # window, the move only takes place if the window src_w contains the pointer
    # and if the specified rectangle of src_w contains the pointer.
    #
    # The src_x and src_y coordinates are relative to the origin of src_w. If
    # src_height is zero, it is replaced with the current height of src_w minus
    # src_y. If src_width is zero, it is replaced with the current width of src_w minus src_x.
    #
    # There is seldom any reason for calling this function. The pointer should
    # normally be left to the user. If you do use this function, however, it
    # generates events just as if the user had instantaneously moved the
    # pointer from one position to another. Note that you cannot use `warp_pointer`
    # to move the pointer outside the confine_to window of an active pointer grab.
    # An attempt to do so will only move the pointer as far as the closest edge of the confine_to window.
    #
    # `warp_pointer` can generate a **BadWindow** error.
    #
    # ###Diagnostics
    # - **BadWindow** A value for a *Window* argument does not name a defined *Window*.
    #
    # ###See also
    # - `set_input_focus`.
    def warp_pointer(src_w : X11::C::Window, dest_w : X11::C::Window, src_x : Int32, src_y : Int32, src_width : UInt32, src_height : UInt32, dest_x : Int32, dest_y : Int32) : Int32
      X.warp_pointer @dpy, src_w, dest_w, src_x, src_y, src_width, src_height, dest_x, dest_y
    end

    # Returns the matched event's associated object.
    #
    # ###Arguments
    # - **w** Specifies the window whose events you are interested in.
    # - **event_mask** Specifies the event mask.
    #
    # ###Description
    # The `window_event` function searches the event queue for an event that
    # matches both the specified window and event mask. When it finds a match,
    # `window_event` removes that event from the queue and copies it into the
    # specified `Event` object. The other events stored in the queue are not
    # discarded. If a matching event is not in the queue, `window_event`
    # flushes the output buffer and blocks until one is received.
    #
    # ###See also
    # `check_mask_event`, `check_typed_event`, `check_typed_window_event`,
    # `check_window_event`, `if_event`, `mask_event`, `next_event`,
    # `peek_event`, `put_back_event`, `send_event`.
    def window_event(w : X11::C::Window, event_mask : Int64) : Event?
      if X.window_event @dpy, w, event_mask, xevent
        Event.from_xevent xevent
      else
        nil
      end
    end

    # Writes a bitmap out to a file in the X Version 11 format.
    #
    # ###Arguments
    # - **filename** Specifies the file name to use. The format of the file name is operating-system dependent.
    # - **bitmap** Specifies the bitmap.
    # - **width**, **height** Specify the width and height.
    # - **x_hot**, **y_hot** Specify where to place the hotspot coordinates
    # (or -1, -1 if none are present) in the file.
    #
    # ###Description
    # The `write_bitmap_file` function writes a bitmap out to a file in the X
    # Version 11 format. The name used in the output file is derived from the
    # file name by deleting the directory prefix. The file is written in the
    # encoding of the current locale. If the file cannot be opened for writing,
    # it returns **BitmapOpenFailed**. If insufficient memory is allocated,
    # `write_bitmap_file` returns **BitmapNoMemory**; otherwise, on no error,
    # it returns **BitmapSuccess**. If x_hot and y_hot are not -1, -1,
    # `write_bitmap_file` writes them out as the hotspot coordinates for the bitmap.
    #
    # `write_bitmap_file` can generate **BadDrawable** and **BadMatch** errors.
    #
    # ###Diagnostics
    # - **BadDrawable** A value for a *Drawable* argument does not name a defined *Window* or *Pixmap*.
    # - **BadMatch** An **InputOnly** window is used as a *Drawable*. **BadMatch**.
    # Some argument or pair of arguments has the correct type and range but fails
    # to match in some other way required by the request.
    #
    # ###See also
    # `create_bitmap_from_data`, `create_pixmap`, `create_pixmap_from_bitmap_data`,
    # `put_image`, `read_bitmap_file`.
    def write_bitmap_file(filename : String, bitmap : X11::C::Pixmap, width : UInt32, height : UInt32, x_hot : Int32, y_hot : Int32) : Int32
      X.write_bitmap_file @dpy, filename.to_unsafe, width, height, x_hot, y_hot
    end

    def open_om(rdb : X11::C::X::PrmHashBucketRec, res_name : String, res_class : String) : X11::C::XOM
      X.open_om @dpy, rdb, res_name.to_unsafe, res_class.to_unsafe
    end

    def create_font_set(base_font_name_list : String) : NamedTuple(font_set: X11::C::X::FontSet, missing_charset_list: Array(String), def_string: String)
      font_set = X.create_font_set @dpy, base_font_name_list.to_unsafe, out missing_charset_list_return, out missing_charset_count_return, def_string_return

      if missing_charset_count_return > 0
        missing_charset_list = Array(String).new(missing_charset_count_return) do |i|
          String.new (missing_charset_list_return + i).value
        end
        X.free missing_charset_list_return.as(PChar)
      else
        missing_charset_list = [] of String
      end

      if def_string_return.null?
        def_string = ""
      else
        def_string = String.new def_string_return
        X.free def_string_return
      end

      {font_set: font_set, missing_charset_list: missing_charset_list, def_string: def_string}
    end

    def free_font_set(font_set : X11::C::X::FontSet)
      X.free_font_set @dpy, font_set
    end

    def mb_draw_text(d : X11::C::Drawable, gc : X11::C::X::GC, x : Int32, y : Int32, text_items : Array(MbTextItem))
      X.mb_draw_text @dpy, d, gc, x, y, text_items.to_unsafe.as(X11::C::X::PmbTextItem), text_items.size
    end

    def wc_draw_text(d : X11::C::Drawable, gc : X11::C::GC, x : Int32, y : Int32, text_items : Array(WcTextItem))
      X.wc_draw_text @dpy, d, gc, x, y, text_items.to_unsafe.as(X11::C::X::PwcTextItem), text_items.size
    end

    def utf8_draw_text(d : X11::C::Drawable, gc : X11::C::X::GC, x : Int32, y : Int32, text_items : Array(MbTextItem))
      X.utf8_draw_text @dpy, d, gc, x, y, text_items.to_unsafe.as(X11::C::X::PmbTextItem), text_items.size
    end

    def mb_draw_string(d : X11::C::Drawable, font_set : X11::C::X::FontSet, gc : X11::C::X::GC, x : Int32, y : Int32, text : String)
      X.mb_draw_string @dpy, s, font_set, gc, x, y, text.to_unsafe, text.size
    end

    def wc_draw_string(d : X11::C::Drawable, font_set : X11::C::X::FontSet, gc : X11::C::X::GC, x : Int32, y : Int32, text : X11::C::X::PWCharT, num_wchars : Int32)
      X.wc_draw_string @dpy, d, font_set, gc, x, y, text, num_wchars
    end

    def utf8_draw_string(d : X11::C::Drawable, font_set : X11::C::X::FontSet, gc : X11::C::X::GC, x : Int32, y : Int32, text : String)
      X.utf8_draw_string @dpy, d, font_set, gc, x, y, text.to_unsafe, text.size
    end

    def mb_draw_image_string(d : X11::C::Drawable, font_set : X11::C::X::FontSet, gc : X11::C::X::GC, x : Int32, y : Int32, text : String)
      X.mb_draw_image_string @dpy, d, font_set, gc, x, y, text.to_unsafe, text.size
    end

    def wc_draw_image_string(d : X11::C::Drawable, font_set : X11::C::X::FontSet, gc : X11::C::X::GC, x : Int32, y : Int32, text : X11::C::X::PWCharT, num_wchars : Int32)
      X.wc_draw_image_string @dpy, font_set, gc, x, y, text, num_wchars
    end

    def utf8_draw_image_string(d : X11::C::Drawable, font_set : X11::C::X::FontSet, gc : X11::C::X::GC, x : Int32, y : Int32, text : String)
      X.utf8_draw_image_string @dpy, d, font_set, gc, x, y, text.to_unsafe, text.size
    end

    def open_im(rdb : X11::C::X::PrmHashBucketRec, res_name : String, res_class : String) : X11::C::XIM
      X.open_im @dpy, rdb, res_name.to_unsafe, res_class.to_unsafe
    end

    def register_im_instantiate_callback(rdb : X11::C::X::PrmHashBucketRec, res_name : String, res_class : String, callback : X11::C::X::IDProc, client_data : X11::C::X::Pointer) : Bool
      res = X.register_im_instantiate_callback @dpy, rdb, res_name.to_unsafe, res_class.to_unsafe, callback, client_data
      res == X::True ? true : false
    end

    def unregister_im_instantiate_callback(rdb : X11::C::X::PrmHashBucketRec, res_name : String, res_class : String, callback : X11::C::X::IDProc, client_data : X11::C::X::Pointer) : Bool
      res = X.unregister_im_instantiate_callback @dpy, edb, res_name.to_unsafe, res_class.to_unsafe, callback, client_data
      res == X::True ? true : false
    end

    def internal_connection_numbers : Array(Int32)
      X.internal_connection_numbers @dpy, out fd_return, out count_return
      if count_return > 0
        fd = Array(Int32).new(count_return) { |i| (fd_return + i).value }
      else
        fd = [] of Int32
      end
      fd
    end

    def process_internal_connection(fd : Int32)
      X.process_internal_connection @dpy, fd
    end

    def add_connectioin_watch(callback : X11::C::X::ConnectionWatchProc, client_data : X11::C::X::Pointer) : X11::C::X::Status
      X.add_connectioin_watch @dpy, callback, client_data
    end

    def remove_connection_watch(callback : X11::C::X::ConnectionWatchProc, client_data : X11::C::X::Pointer)
      X.remove_connection_watch @dpy, callback, client_data
    end

    def event_data : GenericEventCookie?
      if X.get_event_data @dpy, cookie
        GenericEventCookie.new cookie
      else
        nil
      end
    end

    # Pointer to the underlieing XDisplay object.
    def to_unsafe : X11::C::X::PDisplay
      @dpy
    end
  end
end
