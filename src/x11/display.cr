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
      X.synchronize @dpy, onoff ? 1 : 0
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
    def intern_atom(atom_name : String, only_if_exists : Bool)
      X.intern_atom @dpy, atom_name.to_unsafe, only_if_exists ? 1 : 0
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
        addresses << HostAddress.new (phosts + i)
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
      Visual.new(self, X.default_visual(@dpy, screen_number))
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
      status = X.alloc_color_cells @dpy, colormap, contig ? 1 : 0, out plane_masks_return, nplanes, out pixels_return, npixels
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
      status = X.alloc_color_planes @dpy, colormap, contig ? 1 : 0, out pixels_return, ncolors, nreds, nblues, out rmask, out gmask, out bmask
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
      X.change_pointer_control @dpy, do_accel ? 1 : 0, do_threshold ? 1 : 0, accel_numerator, accel_denominator, threshold
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
      when Bytes then 8
      when Slice(Int16) then 16
      when Slice(Int32) then 32
      end
      X.change_property @dpy, w, property.to_u64, type.to_u64, format, mode, data.to_unsafe, data.size
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
      X.change_window_attributes @dpy, w, value, attributes.to_unsafe
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
      X.clear_area @dpy, w, x, y, width, height, exposures ? 1 : 0
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
      X.draw_arcs @dpy, d, gc, arcs.to_unsafe, arcs.size
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
      X.draw_lines @dpy, d, gc, point.to_unsafe, points.size, mode
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
      X.draw_points @dpy, d, gc, points.to_unsafe, point.size, mode
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
      X.draw_rectangles @dpy, d, gc, rectangles.to_unsafe, rectangles.size
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
      X.draw_segments @dpy, d, gc, segments.to_unsafe, segments.size
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
      X.draw_text @dpy, d, gc, x, y, items.to_unsafe, items.size
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
      X.draw_text_16 @dpy, d, gc, x, y, items.to_unsafe, items.size
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

    # TODO: user String array instead
    def fetch_name(w : X11::C::Window, window_name_return : PPChar) : Status
      X.fetch_name @dpy, w, window_name_return
    end

    def fill_arc(d : X11::C::Drawable, gc : X11::C::X::GC, x : Int32, y : Int32, width : UInt32, height : UInt32, angle1 : Int32, angle2 : Int32) : Int32
      X.fill_arc @dpy, d, gc, x, y, width, height, angle1, angle2
    end

    def fill_arcs(d : X11::C::Drawable, gc : X11::C::X::GC, arcs : Array(Arc)) : Int32
      X.fill_arcs @dpy, d, gc, arcs.to_unsafe, arcs.size
    end

    def fill_polygon(d : X11::C::Drawable, gc : X11::C::X::GC, points : Array(Point), npoints :  Int32, shape : Int32, mode : Int32) : Int32
      X.fill_polygon @dpy, d, gc, points.to_unsafe, points.size, shape, mode
    end

    def fill_rectangle(d : X11::C::Drawable, gc : X11::C::X::GC, x : Int32, y : Int32, width : UInt32, height : UInt32) : Int32
      X.fill_rectangle @dpy, gc, x, y, width, height
    end

    def fill_rectangles(d : X11::C::Drawable, gc : X11::C::X::GC, rectangles : Array(Rectangle)) : Int32
      X.fill_rectangles @dpy, d, gc, rectangles.to_unsafe, rectangles.size
    end

    def flush : Int32
      X.flush @dpy
    end

    def force_screen_saver(mode : Int32) : Int32
      X.force_screen_saver @dpy
    end

    def free_colormap(colormap : X11::C::Colormap) : Int32
      X.free_colormap @dpy, colormap
    end

    def free_colors(colormap : X11::C::Colormap, pixels : Array(UInt64), planes : UInt64) : Int32
      X.free_colors @dpy, colormap, pixels.to_unsafe, pixels.size, planes
    end

    def free_cursor(cursor : X11::C::Cursor) : Int32
      X.free_cursor @dpy, cursor
    end

    def free_gc(gc : X12::C::GC) : Int32
      X.free_gc @dpy, gc
    end

    def free_pixmap(pixmap : X11::C::Pixmap) : Int32
      X.free_pixmap @dpy, pixmap
    end

    # TODO: implement & document & test
    def geometry(screen : Int32, position : String, default_position : String,
      bwidth : UInt32, fwidth : UInt32, fheight : UInt32, xadder : Int32, yadder : Int32,
      height_return : PInt32) : NamedTuple(x_return: Arrray(Int32), y_return: Array(Int32), width_return: Array(Int32), height_return: Array(Int32), res: Int32)

    end

    def get_error_database_text(
      name : String,
      message : String,
      default_string : String,
      buffer_return : String,
      length : Int32) : Int32
    end

    def get_error_text(
      code : Int32,
      buffer_return : String,
      length : Int32) : Int32
    end

    def get_gc_values(gc : X11::C::X::GC, valuemask : UInt64) : GCValues
      X.get_gc_values @dpy, gc, valuemask, out pgcvalues
      GCValues.new pgcvalues
    end

    # def get_geometry(
    #   d : X11::C::Drawable,
    #   root_return : PWindow,
    #   x_return : PInt32,
    #   y_return : PInt32,
    #   width_return : PUInt32,
    #   height_return : PInt32,
    #   border_width_return : PInt32,
    #   depth_return : PInt32
    # ) : Status
    #
    # fun get_icon_name = XGetIconName(
    #   display : PDisplay,
    #   w : Window,
    #   icon_name_return : PPChar
    # ) : Status
    #
    # fun get_input_focus = XGetInputFocus(
    #   display : PDisplay,
    #   focus_return : PWindow,
    #   revert_to_return : PInt32
    # ) : Int32
    #
    # fun get_keyboard_control = XGetKeyboardControl(
    #   display : PDisplay,
    #   values_return : PKeyboardState
    # ) : Int32
    #
    # fun get_pointer_control = XGetPointerControl(
    #   display : PDisplay,
    #   accel_numerator_return : PInt32,
    #   accel_denominator_return : PInt32,
    #   threshold_return : PInt32
    # ) : Int32
    #
    # fun get_pointer_mapping = XGetPointerMapping(
    #   display : PDisplay,
    #   map_return : PChar,
    #   nmap : Int32
    # ) : Int32
    #
    # fun get_screen_saver = XGetScreenSaver(
    #   display : PDisplay,
    #   timeout_return : PInt32,
    #   interval_return : PInt32,
    #   prefer_blanking_return : PInt32,
    #   allow_exposures_return : PInt32,
    # ) : Int32
    #
    # fun get_transient_for_hint = XGetTransientForHint(
    #   display : PDisplay,
    #   w : Window,
    #   prop_window_return : PWindow
    # ) : Status
    #
    # fun get_window_property = XGetWindowProperty(
    #   display : PDisplay,
    #   w : Window,
    #   property : Atom,
    #   long_offset : Int64,
    #   long_length : Int64,
    #   delete : Bool,
    #   req_type : Atom,
    #   actual_type_return : PAtom,
    #   actual_format_return : PInt32,
    #   nitems_return : PUInt64,
    #   bytes_after_return : PUInt64,
    #   prop_return : PPChar
    # ) : Int32

    def get_window_attributes(w : X11::C::Window) : WindowAttributes
      X.get_window_property @dpy, w, out pattributes
      WindowAttributes.new pattributes
    end

    def grab_button(button : UInt32, modifiers : UInt32, grab_window : X11::C::Window, owner_events : Bool, event_mask : UInt32, pointer_mode : Int32, keyboard_mode : Int32, confine_to : X11::C::Window, cursor : X11::C::Cursor) : Int32
      X.grab_button @dpy, buton, modifiers, grab_window, owner_events ? 1 : 0, event_mask, pointer_mode, keyboard_mode, confine_to, cursor
    end

    def grab_key(keycode : Int32, modifiers : UInt32, grab_window : X11::C::Window, owner_events : Bool, pointer_mode : Int32, keyboard_mode : Int32) : Int32
      X.grab_key @dpy, keycode, modifiers, grab_window, owner_events, pointer_mode, keyboard_mode
    end

    def grab_keyboard(grab_window : X11::C::Window, owner_events : Bool, pointer_mode : Int32, keyboard_mode : Int32, time : X11::C::Time) : Int32
      X.grab_keyboard @dpy, grab_window, owner_events ? 1 : 0, pointer_mode, keyboard_mode, time
    end

    def grab_pointer(grab_window : X11::C::Window, owner_events : Bool, event_mask : UInt32, pointer_mode : Int32, keyboard_mode : Int32, confine_to : X11::C::Window, cursor : X11::C::Cursor, time : X11::C::Time) : Int32
      X.grab_pointer @dpy, owner_events ? 1 : 0, event_mask, pointer_mode, keyboard_mode, confine_to, cursor, time
    end

    def grab_server : Int32
      X.grab_server @dpy
    end

    # fun if_event = XIfEvent(
    #   display : PDisplay,
    #   event_return : PEvent,
    #   predicate : PDisplay, PEvent, Pointer -> Bool,
    #   arg : Pointer
    # );
    #
    # fun image_byte_order = XImageByteOrder(
    #   display : PDisplay
    # ) : Int32
    #
    # fun install_colormap = XInstallColormap(
    #   display : PDisplay,
    #   colormap : Colormap
    # ) : Int32
    #
    # fun keysym_to_keycode = XKeysymToKeycode(
    #   display : PDisplay,
    #   keysym : KeySym
    # ) : KeyCode
    #
    # fun kill_client = XKillClient(
    #   display : PDisplay,
    #   resource : XID
    # ) : Int32
    #
    # fun lookup_color = XLookupColor(
    #   display : PDisplay,
    #   colormap : Colormap,
    #   color_name : PChar,
    #   exact_def_return : PColor,
    #   screen_def_return : PColor
    # ) : Status
    #
    # fun lower_window = XLowerWindow(
    #   display : PDisplay,
    #   w : Window
    # ) : Int32
    #
    # fun map_raised = XMapRaised(
    #   display : PDisplay,
    #   w : Window
    # ) : Int32
    #
    # fun map_subwindows = XMapSubwindows(
    #   display : PDisplay,
    #   w : Window
    # ) : Int32
    #
    # fun map_window = XMapWindow(
    #   display : PDisplay,
    #   w : Window
    # ) : Int32
    #
    # fun mask_event = XMaskEvent(
    #   display : PDisplay,
    #   event_mask : Int64,
    #   event_return : PEvent
    # ) : Int32

    # fun move_resize_window = XMoveResizeWindow(
    #   display : PDisplay,
    #   w : Window,
    #   x : Int32,
    #   y : Int32,
    #   width : UInt32,
    #   height : UInt32
    # ) : Int32
    #
    # fun move_window = XMoveWindow(
    #   display : PDisplay,
    #   w : Window,
    #   x : Int32,
    #   y : Int32
    # ) : Int32
    #
    # fun next_event = XNextEvent(
    #   display : PDisplay,
    #   event_return : PEvent
    # ) : Int32
    #
    # fun no_op = XNoOp(
    #   display : PDisplay
    # ) : Int32
    #
    # fun parse_color = XParseColor(
    #   display : PDisplay,
    #   colormap : Colormap,
    #   spec : PChar,
    #   exact_def_return : PColor
    # ) : Status

    # fun peek_event = XPeekEvent(
    #   display : PDisplay,
    #   event_return : PEvent
    # ) : Int32
    #
    # fun peek_if_event = XPeekIfEvent(
    #   display : PDisplay,
    #   event_return : PEvent,
    #   predicate : PDisplay, PEvent, Pointer -> Bool,
    #   arg : Pointer
    # ) : Int32
    #
    # fun pending = XPending(
    #   display : PDisplay
    # ) : Int32

    # fun protocol_revision = XProtocolRevision(
    #   display : PDisplay
    # ) : Int32
    #
    # fun protocol_version = XProtocolVersion(
    #   display : PDisplay
    # ) : Int32
    #
    # fun put_back_event = XPutBackEvent(
    #   display : PDisplay,
    #   event : PEvent
    # ) : Int32
    #
    # fun put_image = XPutImage(
    #   display : PDisplay,
    #   d : Drawable,
    #   gc : GC,
    #   image : PImage,
    #   src_x : Int32,
    #   src_y : Int32,
    #   dest_x : Int32,
    #   dest_y : Int32,
    #   width : UInt32,
    #   height : UInt32
    # ) : Int32
    #
    # fun q_length = XQLength(
    #   display : PDisplay
    # ) : Int32
    #
    # fun query_best_cursor = XQueryBestCursor(
    #   display : PDisplay,
    #   d : Drawable,
    #   width : UInt32,
    #   height : UInt32,
    #   width_return : PUInt32,
    #   height_return : PUInt32
    # ) : Status
    #
    # fun query_best_size = XQueryBestSize(
    #   display : PDisplay,
    #   c_class : Int32,
    #   which_screen : Drawable,
    #   width : UInt32,
    #   height : UInt32,
    #   width_return : PUInt32,
    #   height_return : PUInt32
    # ) : Status
    #
    # fun query_best_stipple = XQueryBestStipple(
    #   display : PDisplay,
    #   which_screen : Drawable,
    #   width : UInt32,
    #   height : UInt32,
    #   width_return : PUInt32,
    #   height_return : PUInt32
    # ) : Status
    #
    # fun query_best_tile = XQueryBestTile(
    #   display : PDisplay,
    #   which_screen : Drawable,
    #   width : UInt32,
    #   height : UInt32,
    #   width_return : PUInt32,
    #   height_return : PUInt32
    # ) : Status
    #
    # fun query_color = XQueryColor(
    #   display : PDisplay,
    #   colormap : Colormap,
    #   def_in_out : PColor
    # ) : Int32
    #
    # fun query_colors = XQueryColors(
    #   display : PDisplay,
    #   colormap : Colormap,
    #   defs_in_out : PColor,
    #   ncolors : Int32
    # ) : Int32
    #
    # fun query_extension = XQueryExtension(
    #   display : PDisplay,
    #   name : PChar,
    #   major_opcode_return : PInt32,
    #   first_event_return : PInt32,
    #   first_error_return : PInt32
    # ) : Bool
    #
    # fun query_keymap = XQueryKeymap(
    #   display : PDisplay,
    #   keys_return : Char[32]
    # ) : Int32
    #
    # fun query_pointer = XQueryPointer(
    #   display : PDisplay,
    #   w : Window,
    #   root_return : PWindow,
    #   child_return : PWindow,
    #   root_x_return : PInt32,
    #   root_y_return : PInt32,
    #   win_x_return : PInt32,
    #   win_y_return : PInt32,
    #   mask_return : PUInt32
    # ) : Bool
    #
    # fun query_text_extents = XQueryTextExtents(
    #   display : PDisplay,
    #   font_ID : XID,
    #   string : PChar,
    #   nchars : Int32,
    #   direction_return : PInt32,
    #   font_ascent_return : PInt32,
    #   font_descent_return : PInt32,
    #   overall_return : PCharStruct
    # ) : Int32
    #
    # fun query_text_extents_16 = XQueryTextExtents16(
    #   display : PDisplay,
    #   font_ID : XID,
    #   string : PChar2b,
    #   nchars : Int32,
    #   direction_return : PInt32,
    #   font_ascent_return : PInt32,
    #   font_descent_return : PInt32,
    #   overall_return : PCharStruct
    # ) : Int32
    #
    # fun query_tree = XQueryTree(
    #   display : PDisplay,
    #   w : Window,
    #   root_return : PWindow,
    #   parent_return : PWindow,
    #   children_return : PWindow*,
    #   nchildren_return : UInt32
    # ) : Status
    #
    # fun raise_window = XRaiseWindow(
    #   display : PDisplay,
    #   w : Window
    # ) : Int32
    #
    # fun read_bitmap_file = XReadBitmapFile(
    #   display : PDisplay,
    #   d : Drawable,
    #   filename : PChar,
    #   width_return : PUInt32,
    #   height_return : PUInt32,
    #   bitmap_return : PPixmap,
    #   x_hot_return : PInt32,
    #   y_hot_return : PInt32
    # ) : Int32

    # fun rebind_keysym = XRebindKeysym(
    #   display : PDisplay,
    #   keysym : KeySym,
    #   list : PKeySym,
    #   mod_count : Int32,
    #   string : PChar,
    #   bytes_string : Int32
    # ) : Int32
    #
    # fun recolor_cursor = XRecolorCursor(
    #   display : PDisplay,
    #   cursor : Cursor,
    #   foreground_color : PColor,
    #   background_color : PColor
    # ) : Int32

    # fun remove_from_save_set = XRemoveFromSaveSet(
    #   display : PDisplay,
    #   w : Window
    # ) : Int32
    #
    # fun remove_host = XRemoveHost(
    #   display : PDisplay,
    #   host : PHostAddress
    # ) : Int32
    #
    # fun remove_hosts = XRemoveHosts(
    #   display : PDisplay,
    #   hosts : PHostAddress,
    #   num_hosts : Int32
    # ) : Int32
    #
    # fun reparent_window = XReparentWindow(
    #   display : PDisplay,
    #   w : Window,
    #   parent : Window,
    #   x : Int32,
    #   y : Int32
    # ) : Int32
    #
    # fun reset_screen_saver = XResetScreenSaver(
    #   display : PDisplay
    # ) : Int32
    #
    # fun resize_window = XResizeWindow(
    #   display : PDisplay,
    #   w : Window,
    #   width : UInt32,
    #   height : UInt32
    # ) : Int32
    #
    # fun restack_windows = XRestackWindows(
    #   display : PDisplay,
    #   windows : PWindow,
    #   nwindows : Int32
    # ) : Int32
    #
    # fun rotate_buffers = XRotateBuffers(
    #   display : PDisplay,
    #   rotate : Int32
    # ) : Int32
    #
    # fun rotate_window_properties = XRotateWindowProperties(
    #   display : PDisplay,
    #   w : Window,
    #   properties : PAtom,
    #   num_prop : Int32,
    #   npositions : Int32
    # ) : Int32
    #
    # fun screen_count = XScreenCount(
    #   display : PDisplay
    # ) : Int32
    #
    # fun select_input = XSelectInput(
    #   display : PDisplay,
    #   w : Window,
    #   event_mask : Int64
    # ) : Int32
    #
    # fun send_event = XSendEvent(
    #   display : PDisplay,
    #   w : Window,
    #   propagate : Bool,
    #   event_mask : Int64,
    #   event_send : PEvent
    # ) : Status
    #
    # fun set_access_control = XSetAccessControl(
    #   display : PDisplay,
    #   mode : Int32
    # ) : Int32
    #
    # fun set_arc_mode = XSetArcMode(
    #   display : PDisplay,
    #   gc : GC,
    #   arc_mode : Int32
    # ) : Int32
    #
    # fun set_background = XSetBackground(
    #   display : PDisplay,
    #   gc : GC,
    #   background : UInt64
    # ) : Int32
    #
    # fun set_clip_mask = XSetClipMask(
    #   display : PDisplay,
    #   gc : GC,
    #   pixmap : Pixmap
    # ) : Int32
    #
    # fun set_clip_origin = XSetClipOrigin(
    #   display : PDisplay,
    #   gc : GC,
    #   clip_x_origin : Int32,
    #   clip_y_origin : Int32
    # ) : Int32
    #
    # fun set_clip_rectangles = XSetClipRectangles(
    #   display : PDisplay,
    #   gc : GC,
    #   clip_x_origin : Int32,
    #   clip_y_origin : Int32,
    #   rectangles : PRectangle,
    #   n : Int32,
    #   ordering : Int32
    # ) : Int32
    #
    # fun set_close_down_mode = XSetCloseDownMode(
    #   display : PDisplay,
    #   close_mode : Int32
    # ) : Int32
    #
    # fun set_command = XSetCommand(
    #   display : PDisplay,
    #   w : Window,
    #   argv : PPChar,
    #   argc : Int32
    # ) : Int32
    #
    # fun set_dashes = XSetDashes(
    #   display : PDisplay,
    #   gc : GC,
    #   dash_offset : Int32,
    #   dash_list : PChar,
    #   n : Int32
    # ) : Int32
    #
    # fun set_fill_rule = XSetFillRule(
    #   display : PDisplay,
    #   gc : GC,
    #   fill_rule : Int32
    # ) : Int32
    #
    # fun set_fill_style = XSetFillStyle(
    #   display : PDisplay,
    #   gc : GC,
    #   fill_style : Int32
    # ) : Int32
    #
    # fun set_font = XSetFont(
    #   display : PDisplay,
    #   gc : GC,
    #   font : Font
    # ) : Int32
    #
    # fun set_font_path = XSetFontPath(
    #   display : PDisplay,
    #   directories : PPChar,
    #   ndirs : Int32
    # ) : Int32
    #
    # fun set_foreground = XSetForeground(
    #   display : PDisplay,
    #   gc : GC,
    #   foreground : UInt64
    # ) : Int32
    #
    # fun set_function = XSetFunction(
    #   display : PDisplay,
    #   gc : GC,
    #   function : Int32
    # ) : Int32
    #
    # fun set_graphics_exposures = XSetGraphicsExposures(
    #   display : PDisplay,
    #   gc : GC,
    #   graphics_exposures : Bool
    # ) : Int32
    #
    # fun set_icon_name = XSetIconName(
    #   display : PDisplay,
    #   w : Window,
    #   icon_name : PChar
    # ) : Int32
    #
    # fun set_input_focus = XSetInputFocus(
    #   display : PDisplay,
    #   focus : Window,
    #   revert_to : Int32,
    #   time : Time
    # ) : Int32
    #
    # fun set_line_attributes = XSetLineAttributes(
    #   display : PDisplay,
    #   gc : GC,
    #   line_width : UInt32,
    #   line_style : Int32,
    #   cap_style : Int32,
    #   join_style : Int32
    # ) : Int32
    #
    # fun set_modifier_mapping = XSetModifierMapping(
    #   display : PDisplay,
    #   modmap : PModifierKeymap
    # ) : Int32
    #
    # fun set_plane_mask = XSetPlaneMask(
    #   display : PDisplay,
    #   gc : GC,
    #   plane_mask : UInt64
    # ) : Int32
    #
    # fun set_pointer_mapping = XSetPointerMapping(
    #   display : PDisplay,
    #   map : PChar,
    #   nmap : Int32
    # ) : Int32
    #
    # fun set_screen_saver = XSetScreenSaver(
    #   display : PDisplay,
    #   timeout : Int32,
    #   interval : Int32,
    #   prefer_blanking : Int32,
    #   allow_exposures : Int32
    # ) : Int32
    #
    # fun set_selection_owner = XSetSelectionOwner(
    #   display : PDisplay,
    #   selection : Atom,
    #   owner : Window,
    #   time : Time
    # ) : Int32
    #
    # fun set_state = XSetState(
    #   display : PDisplay,
    #   gc : GC,
    #   foreground : UInt64,
    #   background : UInt64,
    #   function : Int32,
    #   plane_mask : UInt64
    # ) : Int32
    #
    # fun set_stipple = XSetStipple(
    #   display : PDisplay,
    #   gc : GC,
    #   stipple : Pixmap
    # ) : Int32
    #
    # fun set_subwindow_mode = XSetSubwindowMode(
    #   display : PDisplay,
    #   gc : GC,
    #   subwindow_mode : Int32
    # ) : Int32
    #
    # fun set_ts_origin = XSetTSOrigin(
    #   display : PDisplay,
    #   gc : GC,
    #   ts_x_origin : Int32,
    #   ts_y_origin : Int32
    # ) : Int32
    #
    # fun set_title = XSetTile(
    #   display : PDisplay,
    #   gc : GC,
    #   tile : Pixmap
    # ) : Int32
    #
    # fun set_window_background = XSetWindowBackground(
    #   display : PDisplay,
    #   w : Window,
    #   background_pixel : UInt64
    # ) : Int32
    #
    # fun set_window_background_pixmap = XSetWindowBackgroundPixmap(
    #   display : PDisplay,
    #   w : Window,
    #   background_pixmap : Pixmap
    # ) : Int32
    #
    # fun set_window_border = XSetWindowBorder(
    #   display : PDisplay,
    #   w : Window,
    #   border_pixel : UInt64
    # ) : Int32
    #
    # fun set_window_border_pixmap = XSetWindowBorderPixmap(
    #   display : PDisplay,
    #   w : Window,
    #   border_pixmap : Pixmap
    # ) : Int32
    #
    # fun set_window_border_width = XSetWindowBorderWidth(
    #   display : PDisplay,
    #   w : Window,
    #   width : UInt32
    # ) : Int32
    #
    # fun set_window_colormap = XSetWindowColormap(
    #   display : PDisplay,
    #   w : Window,
    #   colormap : Colormap
    # ) : Int32
    #
    # fun store_buffer = XStoreBuffer(
    #   display : PDisplay,
    #   bytes  : PChar,
    #   nbytes : Int32,
    #   buffer : Int32
    # ) : Int32
    #
    # fun store_bytes = XStoreBytes(
    #   display : PDisplay,
    #   bytes : PChar,
    #   nbytes : Int32
    # ) : Int32
    #
    # fun store_color = XStoreColor(
    #   display : PDisplay,
    #   colormap : Colormap,
    #   color : PColor
    # ) : Int32
    #
    # fun store_colors = XStoreColors(
    #   display : PDisplay,
    #   colormap : Colormap,
    #   color : PColor,
    #   ncolors : Int32
    # ) : Int32
    #
    # fun store_name = XStoreName(
    #   display : PDisplay,
    #   w : Window,
    #   window_name : PChar
    # ) : Int32
    #
    # fun store_named_color = XStoreNamedColor(
    #   display : PDisplay,
    #   colormap : Colormap,
    #   color : PColor,
    #   pixel : UInt64,
    #   flags : Int32
    # ) : Int32
    #
    # fun sync = XSync(
    #   display : PDisplay,
    #   discard : Bool
    # ) : Int32

    # fun translate_coordinates = XTranslateCoordinates(
    #   display : PDisplay,
    #   src_w : Window,
    #   dest_w : Window,
    #   src_x : Int32,
    #   src_y : Int32,
    #   dest_x_return : PInt32,
    #   dest_y_return : PInt32,
    #   child_return : PWindow
    # ) : Bool
    #
    # fun undefine_cursor = XUndefineCursor(
    #   display : PDisplay,
    #   w : Window
    # ) : Int32
    #
    # fun ungrab_button = XUngrabButton(
    #   display : PDisplay,
    #   button : UInt32,
    #   modifiers : UInt32,
    #   grab_window : Window
    # ) : Int32
    #
    # fun ungrab_key = XUngrabKey(
    #   display : PDisplay,
    #   keycode : Int32,
    #   modifiers : UInt32,
    #   grab_window : Window
    # ) : Int32
    #
    # fun ungrab_keyboard = XUngrabKeyboard(
    #   display : PDisplay,
    #   time : Time
    # ) : Int32
    #
    # fun ungrab_pointer = XUngrabPointer(
    #   display : PDisplay,
    #   time : Time
    # ) : Int32
    #
    # fun ungrab_server = XUngrabServer(
    #   display : PDisplay
    # ) : Int32
    #
    # fun uninstall_colormap = XUninstallColormap(
    #   display : PDisplay,
    #   colormap : Colormap
    # ) : Int32
    #
    # fun unload_font = XUnloadFont(
    #   display : PDisplay,
    #   font : Font
    # ) : Int32
    #
    # fun unmap_subwindows = XUnmapSubwindows(
    #   display : PDisplay,
    #   w : Window
    # ) : Int32
    #
    # fun unmap_window = XUnmapWindow(
    #   display : PDisplay,
    #   w : Window
    # ) : Int32
    #
    # fun vendor_release = XVendorRelease(
    #   display : PDisplay
    # ) : Int32
    #
    # fun warp_pointer = XWarpPointer(
    #   display : PDisplay,
    #   src_w : Window,
    #   dest_w : Window,
    #   src_x : Int32,
    #   src_y : Int32,
    #   src_width : UInt32,
    #   src_height : UInt32,
    #   dest_x : Int32,
    #   dest_y : Int32
    # ) : Int32

    # fun window_event = XWindowEvent(
    #   display : PDisplay,
    #   w : Window,
    #   event_mask : Int64,
    #   event_return : PEvent
    # ) : Int32
    #
    # fun write_bitmap_file = XWriteBitmapFile(
    #   display : PDisplay,
    #   filename : PChar,
    #   bitmap : Pixmap,
    #   width : UInt32,
    #   height : UInt32,
    #   x_hot : Int32,
    #   y_hot : Int32
    # ) : Int32

    # fun open_om = XOpenOM(
    #   display : PDisplay,
    #   rdb : PrmHashBucketRec,
    #   res_name : PChar,
    #   res_class : PChar
    # ) : XOM

    # fun create_font_set = XCreateFontSet(
    #   display : PDisplay,
    #   base_font_name_list : PChar,
    #   missing_charset_list : PPChar*,
    #   missing_charset_count : PInt32,
    #   def_string : PPChar
    # ) : FontSet
    #
    # fun free_font_set = XFreeFontSet(
    #   display : PDisplay,
    #   font_set : FontSet
    # ) : NoReturn

    # fun mb_draw_text = XmbDrawText(
    #   display : PDisplay,
    #   d : Drawable,
    #   gc : GC,
    #   x : Int32,
    #   y : Int32,
    #   text_items : PmbTextItem,
    #   nitems : Int32
    # ) : NoReturn
    #
    # fun wc_draw_text = XwcDrawText(
    #   display : PDisplay,
    #   d : Drawable,
    #   gc : GC,
    #   x : Int32,
    #   y : Int32,
    #   text_items : PwcTextItem,
    #   nitems : Int32
    # ) : NoReturn
    #
    # fun utf8_draw_text = Xutf8DrawText(
    #   display : PDisplay,
    #   d : Drawable,
    #   gc : GC,
    #   x : Int32,
    #   y : Int32,
    #   text_items : PmbTextItem,
    #   nitems : Int32
    # ) : NoReturn
    #
    # fun mb_draw_string = XmbDrawString(
    #   display : PDisplay,
    #   d : Drawable,
    #   font_set : FontSet,
    #   gc : GC,
    #   x : Int32,
    #   y : Int32,
    #   text : PChar,
    #   bytes_text : Int32
    # ) : NoReturn
    #
    # fun wc_draw_string = XwcDrawString(
    #   display : PDisplay,
    #   d : Drawable,
    #   font_set : FontSet,
    #   gc : GC,
    #   x : Int32,
    #   y : Int32,
    #   text : PWChar_t,
    #   num_wchars : Int32
    # ) : NoReturn
    #
    # fun utf8_draw_string = Xutf8DrawString(
    #   display : PDisplay,
    #   d : Drawable,
    #   font_set : FontSet,
    #   gc : GC,
    #   x : Int32,
    #   y : Int32,
    #   text : PChar,
    #   bytes_text : Int32
    # ) : NoReturn
    #
    # fun mb_draw_image_string = XmbDrawImageString(
    #   display : PDisplay,
    #   d : Drawable,
    #   font_set : FontSet,
    #   gc : GC,
    #   x : Int32,
    #   y : Int32,
    #   text : PChar,
    #   bytes_text : Int32
    # ) : NoReturn
    #
    # fun wc_draw_image_string = XwcDrawImageString(
    #   display : PDisplay,
    #   d : Drawable,
    #   font_set : FontSet,
    #   gc : GC,
    #   x : Int32,
    #   y : Int32,
    #   text : PWChar_t,
    #   num_wchars : Int32
    # ) : NoReturn
    #
    # fun utf8_draw_image_string = Xutf8DrawImageString(
    #   display : PDisplay,
    #   d : Drawable,
    #   font_set : FontSet,
    #   gc : GC,
    #   x : Int32,
    #   y : Int32,
    #   text : PChar,
    #   bytes_text : Int32
    # ) : NoReturn
    #
    # fun open_im = XOpenIM(
    #   dpy : PDisplay,
    #   rdb : PrmHashBucketRec,
    #   res_name : PChar,
    #   res_class : PChar
    # ) : XIM

    # fun register_im_instantiate_callback = XRegisterIMInstantiateCallback(
    #   dpy : PDisplay,
    #   rdb : PrmHashBucketRec,
    #   res_name : PChar,
    #   res_class : PChar,
    #   callback : IDProc,
    #   client_data : Pointer
    # ) : Bool
    #
    # fun unregister_im_instantiate_callback = XUnregisterIMInstantiateCallback(
    #   dpy : PDisplay,
    #   rdb : PrmHashBucketRec,
    #   res_name : PChar,
    #   res_class : PChar,
    #   callback : IDProc,
    #   client_data : Pointer
    # ) : Bool
    #
    # fun internal_connection_numbers = XInternalConnectionNumbers(
    #   dpy : PDisplay,
    #   fd_return : PInt32*,
    #   count_return : PInt32
    # ) : Status
    #
    # fun process_internal_connection = XProcessInternalConnection(
    #   dpy : PDisplay,
    #   fd : Int32
    # ) : NoReturn
    #
    # fun add_connectioin_watch = XAddConnectionWatch(
    #   dpy : PDisplay,
    #   callback : ConnectionWatchProc,
    #   client_data : Pointer
    # ) : Status
    #
    # fun remove_connection_watch = XRemoveConnectionWatch(
    #   dpy : PDisplay,
    #   callback : ConnectionWatchProc,
    #   client_data : Pointer
    # ) : NoReturn

    # fun get_event_data = XGetEventData(
    #   dpy : PDisplay,
    #   cookie : PGenericEventCookie
    # ) : Bool
    #
    # fun free_event_data = XFreeEventData(
    #   dpy : PDisplay,
    #   cookie : PGenericEventCookie
    # ) : NoReturn

    # -------------------

    def select_input(w : Window, event_mask)
      X.select_input @dpy, w, event_mask
    end

    def map_window(w : Window)
      X.map_window @dpy, w
    end

    def pending : Int32
      X.pending @dpy
    end

    def next_event : X::Event
      e = uninitialized X::Event
      X.next_event @dpy, pointerof(e)
      e
    end

    def store_name(w : Window, name : String) : Int32
      X.store_name @dpy, w, name.to_unsafe
    end

    # Pointer to the underlieing XDisplay object.
    def to_unsafe : X11::C::X::PDisplay
      @dpy
    end
  end
end
