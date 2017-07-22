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
    # variable that can be accessed by using the #default_screen function.
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

    def close : Int32
      res = 0
      if @initialization == DisplayInitialization::Name
        res = X.close_display @dpy
      end
      @dpy = X11::C::X::PDisplay.null
      @closed = true
      res
    end

    # The `load_query_font` function provides the most common way for accessing a font.
    # load_query_font both opens (loads) the specified font and returns a `FontStruct` object.
    #
    # ###Arguments
    # *name* Specifies the name of the font.
    def load_query_font(name : String) : FontStruct
      FontStruct.new(self, X.load_query_font(@dpy, name.to_unsafe))
    end

    # The `query_font` function returns a `FontStruct` object, which contains information associated with the font.
    # You can query a font or the font stored in a `GC`. The *font_id* stored in the `FontStruct` object will be the `GContext` ID,
    # and you need to be careful when using this ID in other functions (see `g_context_from_gc`).
    def query_font(font_id : X11::C::XID) : FontStruct
      FontStruct.new(self, X.query_font(@dpy, font_id))
    end

    # Returns all events in an array from the motion history buffer that fall between the specified start and stop times,
    # inclusive, and that have coordinates that lie within the specified window (including its borders) at its present placement.
    # If the server does not support motion history, if the start time is later than the stop time,
    # or if the start time is in the future, no events are returned; *motion_events* returns empty array.
    # If the stop time is in the future, it is equivalent to specifying *CurrentTime* .
    def motion_events(w : X11::C::Window, start : X11::C::Time, stop : X11::C::Time) : Array(TimeCoord)
      p_time_coords = X.get_motion_events @dpy, w, start, stop, out num_time_coords
      return [] of TimeCoord if num_time_coords == 0
      time_coords = Array(TimeCoord).new num_time_coords
      (0...num_time_coords).each do |i|
        time_coords[i] = TimeCoord.new(p_time_coords[i])
      end
    end

    # Returns a newly created *ModifierKeymap* object that contains the keys being used as modifiers.
    def modifier_mapping : ModifierKeymap
      ModifierKeymap.new(X.get_modifier_mapping(@dpy))
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
    # - **BadValue** Some numeric value falls outside the range of values accepted by the request. Unless a specific range is specified for an argument, the full range defined by the argument's type is accepted. Any argument defined as a set of alternatives can generate this error.
    def get_image(d : X11::C::Drawable, x : Int32, y : Int32, width : UInt32, height : UInt32, plane_mask : UInt64, format : Int32) : Image
      Image.new(X.get_image(@dpy, d, x, y, width, height, plane_mask, format))
    end

    # Updates `dest_image` with the specified subimage in the same manner as #get_image.
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
    # The `get_sub_image` function updates `dest_image` with the specified subimage in the same manner as `get_image`.
    # If the `format` argument is **XYPixmap**, the image contains only the bit planes you passed to the `plane_mask` argument.
    # If the `format` argument is **ZPixmap** , #get_sub_image returns as zero the bits in all planes not specified in the `plane_mask` argument.
    # The function performs no range checking on the values in `plane_mask` and ignores extraneous bits.
    # As a convenience, `get_sub_image` returns an image object specified by `dest_image`.
    # The depth of the destination Image object must be the same as that of the drawable.
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
    # If a problem occurs, `get_sub_image` raises exception.
    #
    # `get_sub_image` can generate **BadDrawable**, **BadGC**, **BadMatch**, and **BadValue** errors.
    #
    # ###Diagnostics
    # - **BadDrawable** A value for a *Drawable* argument does not name a defined *Window* or *Pixmap*.
    # - **BadGC** A value for a *GContext* argument does not name a defined *GContext*.
    # - **BadMatch** An *InputOnly* window is used as a *Drawable*.
    # - **BadMatch** Some argument or pair of arguments has the correct type and range but fails to match in some other way required by the request.
    # - **BadValue** Some numeric value falls outside the range of values accepted by the request. Unless a specific range is specified for an argument, the full range defined by the argument's type is accepted. Any argument defined as a set of alternatives can generate this error.
    def get_sub_image(d : X11::C::Drawable, x : Int32, y : Int32, width : UInt32, height : UInt32, plane_mask : UInt64, format : Int32, dest_image : Image, dest_x : Int32, dest_y : Int32) : Image
      Image.new(X.get_sub_image(@dpy, d, x, y, width, height, plane_mask, format, dest_image.imagem dest_x, dest_y))
    end

    # Returns data from cut buffer 0
    #
    # ###Description
    # Returns a non empty `String` if the buffer contains data, otherwise returns an empty `String`.
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

    # Return ther string representation of a given *keysym*.
    #
    # ###Arguments
    # - **keysym** Specifies the `X::C::KeySym` that is to be converted.
    #
    # ###Description
    # The returned string is in a static area and must not be modified.
    # The returned string is in the Host Portable Character Encoding.
    # If the specified `KeySym` is not defined, returns an empty `String`.
    def self.keysym_to_string(keysym : X11::C::KeySym) : String
      pstr = X.keysym_to_string keysym
      return "" if pstr.null?
      str = String.new pstr
      X.free pstr
      str
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
    # `GrayScale`, `PseudoColor`, and `DirectColor`. For `StaticGray`, `StaticColor`,
    # and `TrueColor`, the entries have defined values, but those values are specific
    # to the visual and are not defined by X. For `StaticGray`, `StaticColor`, and `TrueColor`,
    # alloc must be **AllocNone**, or a **BadMatch** error results. For the other visual classes,
    # if alloc is **AllocNone**, the colormap initially has no allocated entries,
    # and clients can allocate them. For information about the visual types, see "Visual Types".
    #
    # If alloc is **AllocAll the entire colormap is allocated writable.
    # The initial values of all allocated entries are undefined.
    # For `GrayScale` and `PseudoColor`, the effect is as if an `alloc_color_cells` call returned
    # all pixel values from zero to `N - 1`, where `N` is the colormap entries value in the specified visual.
    # For `DirectColor`, the effect is as if an `alloc_color_planes` call returned a
    # pixel value of zero and red_mask, green_mask, and blue_mask values containing the same
    # bits as the corresponding masks in the specified visual. However, in all cases,
    # none of these entries can be freed by using `free_colors`.
    #
    # `create_colormap` can generate **BadAlloc**, **BadMatch**, **BadValue**, and **BadWindow** errors.
    #
    # ###Diagnostics
    # - **BadAlloc** The server failed to allocate the requested source or server memory.
    # - **BadMatch** An `InputOnly` window is used as a `Drawable`.
    # - **BadMatch** Some argument or pair of arguments has the correct type and range but fails to match in some other way required by the request.
    # - **BadPixmap** A value for a `Pixmap` argument does not name a defined `Pixmap`.
    # - **BadValue** Some numeric value falls outside the range of values accepted by the request.
    # Unless a specific range is specified for an argument, the full range defined by the argument's type is accepted.
    # Any argument defined as a set of alternatives can generate this error.
    # - **BadWindow** A value for a Window argument does not name a defined `Window`.
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
    # The foreground and background RGB values must be specified using `foreground_color` and `background_color`,
    # even if the X server only has a `StaticGray` or `GrayScale` screen.
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
    # - **BadPixmap** A value for a `Pixmap` argument does not name a defined `Pixmap`.
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
    # The source_char must be a defined glyph in `source_font`, or a **BadValue** error results.
    # If mask_font is given, mask_char must be a defined glyph in `mask_font`, or a **BadValue** error results.
    # The `mask_font` and character are optional. The origins of the `source_char` and `mask_char`
    # (if defined) glyphs are positioned coincidently and define the hotspot.
    # The source_char and mask_char need not have the same bounding box metrics,
    # and there is no restriction on the placement of the hotspot relative to the bounding boxes.
    # If no mask_char is given, all pixels of the source are displayed. You can
    # free the fonts immediately by calling `X.free_font` if no further explicit references to them are to be made.
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
    # When the characters ``?'' and ``*'' are used in a font name, a pattern match
    # is performed and any matching font is used. In the pattern, the ``?'' character
    # will match any single character, and the ``*'' character will match any number of characters.
    # A structured format for font names is specified in the X Consortium standard
    # **X Logical Font Description Conventions**. If `load_font` was unsuccessful at loading the specified font,
    # a **BadName** error results. Fonts are not associated with a particular
    # screen and can be stored as a component of any `GC`.
    # When the font is no longer needed, call `unload_font`.
    #
    # `load_font` can generate **BadAlloc** and **BadName** errors.
    #
    # ###Diagnostics
    # - **BadAlloc** The server failed to allocate the requested source or server memory.
    # - **BadName** A font or color of the specified name does not exist.
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
    # - **BadDrawable** A value for a `Drawable` argument does not name a defined `Window` or `Pixmap`.
    # - **BadFont** A value for a font argument does not name a defined font (or, in some cases, `GContext`).
    # - **BadMatch** An **InputOnly** window is used as a `Drawable`.
    # - **BadMatch** Some argument or pair of arguments has the correct type and range but fails to match in some other way required by the request.
    # - **BadPixmap** A value for a `Pixmap` argument does not name a defined `Pixmap`.
    # - **BadValue** Some numeric value falls outside the range of values accepted by the request.
    # Unless a specific range is specified for an argument, the full range defined
    # by the argument's type is accepted. Any argument defined as a set of alternatives can generate this error.
    def create_gc(d : Drawable, valuemask : UInt64, values : GCValues) : X11::X::GC
      X.create_gc @dpy, d, valuemask, values.values
    end

    # Returns GC-context from GC.
    #
    # ###Arguments
    # - **gc** Specifies the GC for which you want the resource ID.
    def self.gc_context_from_gc(gc : X11::C::GC) : X11::C::GC
      X.gc_context_from_gc gc
    end

    # Forces GC component change.
    #
    # ###Arguments
    # - **display** Specifies the connection to the X server.
    # - **gc** Specifies the GC.
    #
    # ###Description
    # Force sending GC component changes.
    def flush_gc(gc : X11::C::GC)
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
    # - **BadDrawable** A value for a `Drawable` argument does not name a defined `Window` or `Pixmap`.
    # - **BadValue** Some numeric value falls outside the range of values accepted by the request.
    # Unless a specific range is specified for an argument, the full range defined
    # by the argument's type is accepted. Any argument defined as a set of alternatives can generate this error.
    def create_pixmap(d : Drawable, width : UInt32, height : UInt32, depth : UInt32) : Pixmap
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
    # - **BadGC** A value for a `GContext` argument does not name a defined `GContext`.
    def create_bitmap_from_data(d : Drawable, data : Bytes, width : UInt32, height : UInt32) : Pixmap
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
    # - **BadDrawable** A value for a `Drawable` argument does not name a defined `Window` or `Pixmap`.
    # - **BadGC** A value for a `GContext` argument does not name a defined `GContext`.
    # - **BadMatch** An **InputOnly** window is used as a `Drawable`.
    # - **BadMatch** Some argument or pair of arguments has the correct type and range but fails to match in some other way required by the request.
    def create_pixmap_from_bitmap_data(d : Drawable, data : Bytes, width : UInt32, height : UInt32, fg : UInt64, bg : UInt64, depth : UInt64) : Pixmap
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
    def create_simple_window(parent : Window, x : Int32, y : Int32, width : UInt32, height : UInt32, border_width : UInt32, border : UInt64, background : UInt64) : Window
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
    def selection_owner(selection : Atom | X11::C::Atom) : Window
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
    def create_window(parent : Window, x : Int32, y : Int32, width : UInt32, height : UInt32, border_width : UInt32, depth : Int32, c_class : UInt32, visual : Visual, valuemask : UInt64, attributes : SetWindowAttributes) : Window
      X.create_window @dpy, parent, x, y, width, height, border_width, depth, c_class, visual.to_unsafe, valuemask, attributes.to_unsafe
    end

    # TODO: test & document
    def installed_colormaps(w : Window) : Array(Colormap)
      pcolormaps = X.list_installed_colormaps @dpy, w, out num
      return [] of Colormap if pcolormaps.null? || num <= 0
      colormaps = Array(Colormap).new num
      (0...num).each do |i|
        colormaps[i] = pcolormaps[0].value
      end
      colormaps
    end

    # TODO: test & document
    def fonts(pattern : String, maxnames : Int32) : Array(String)
      pstrings = X.list_fonts @dpy, pattern.to_unsafe, out count
      return [] of String if pstrings.null? || count <= 0
      font_names = Array(String).new count
      (0...count).each do |i|
        font_names[i] = String.new pstrings[i]
      end
    end

    # TODO: implement this
    def fonts_with_info(pattern : String, maxnames : Int32) : Array(String)
    end

    # TODO: implement this
    def font_path : Array(String)
    end

    # Lists supported extensions.
    #
    # ###Description
    #
    # The `extensions` function returns a list of all extensions supported by the server.
    # If the data returned by the server is in the Latin Portable Character Encoding,
    # then the returned strings are in the Host Portable Character Encoding.
    # Otherwise, the result is implementation dependent.
    def extensions : Array(String)
      pstrings = X.list_extensions @dpy, out num_extensions
      return [] of String if num_extensions == 0
      strings = Array(String).new
      (0...num_extensions).each do |i|
        strings << String.new((pstrings + i).value)
      end
      strings
    end

    # Return property-atoms.
    #
    # ###Arguments
    #
    # - **w** Specifies the window whose property list you want to obtain.
    #
    # ###Description
    #
    # The `properties` function returns an array of atom properties
    # that are defined for the specified window or returns empty array if no properties were found.
    #
    # `properties` can generate a **BadWindow** error.
    #
    # ###Diagnostics
    #
    # - **BadWindow** A value for a Window argument does not name a defined Window.
    def properties(w : X11::C::Window) : Array(X11::C::Atom)
      patoms = X.list_properties @dpy, w, out num_properties
      return [] of X11::C::Atom if num_properties == 0
      atoms = Array(X11::C::Atom).new
      (0...num_properties).each do |i|
        atoms << patoms[i]
      end
      atoms
    end

    # Return current access control list.
    #
    # ###Description
    #
    # The `hosts` function returns the current access control list as well as whether
    # the use of the list at connection setup was enabled or disabled. `hosts` allows a
    # program to find out what machines can make connections. It also returns an array of host objects
    # that were allocated by the function.
    # TODO: implement
    def hosts : Array(HostAddress)
    end

    # TODO: implement & document
    def keycode_to_keysym(keycode : X11::C::KeyCode, index : Int32) : X11::C::KeySym
    end

    # TODO: implement & document
    def lookup_keysym(key_event : KeyEvent, index : Int32) : X11::C::KeySym
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

    # TODO: document
    def self.string_to_keysym(string : String) : X11::C::KeySym
      X.string_to_keysym string.to_unsafe
    end

    # TODO: document
    def max_request_size : Int64
      X.max_request_size @dpy
    end

    # TODO: document
    def extended_map_request_size : Int64
      X.extended_map_request_size @dpy
    end

    # TODO: document
    def resource_manager_string : String
      pstr = X.resource_manager_string @dpy
      return "" if pstr.null?
      str = String.new pstr
      X.free pstr
      str
    end

    # TODO: implement this, make Screen class?
    # def self.screen_resource_string(screen : PScreen) : String
    # end

    # TODO: document
    def motion_buffer_size : UInt64
      X.display_motion_buffer_size @dpy
    end

    # TODO: document
    def self.init_threads : X11::C::Status
      X.init_threads
    end

    # TODO: document
    def lock
      X.lock_display
      self
    end

    # TODO: document
    def unlock
      X.unlock_display @dpy
      self
    end

    # Returns the root window of the specified screen.
    #
    # ###Arguments
    # - **screen_number** Specifies the appropriate screen number on the host server.
    #
    # ###See Also
    # - `default_root_window`
    def root_window(screen_number : Int32) : X11::C::Window
      X.root_window @dpy, screen_number
    end

    # Returns the root window of the default screen.
    def default_root_window : X11::C::Window
      X.default_root_window @dpy
    end

    #Returns the default visual type for the specified screen.
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

    # Returns a value with all bits set to 1 suitable for use in a plane argument to a procedure.
    def self.all_planes : UInt64
      X.all_planes
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

    # TODO: implement & document
    def reconfigure_wm_window
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
    def withdraw_window(w : X11::C::Window, screen_number : Int32) : X11::C::X::Status
      X.withdraw_window @dpy, w, screen_number
    end

    # Reads the WM_COMMAND property from the
    # specified windowreads the WM_COMMAND property from the
    # specified window.
    #
    # ###Arguments
    # - **w** Specifies the window.
    #
    # ###Description
    # The `get_command` function reads the WM_COMMAND property from the
    # specified window and returns a string list. If the WM_COMMAND property exists,
    # it is of type STRING and format 8. If sufficient memory can be allocated
    # to contain the string list, `get_command` returns an array of strings.
    # Otherwise, it returns an empty array. If the data returned by the server is in the Latin Portable Character Encoding,
    # then the returned strings are in the Host Portable Character Encoding.
    # Otherwise, the result is implementation dependent.
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
    def wm_colormap_windows(w : X11::C::Window) : Array(X11::C::Window)
      status = X.get_wm_colormap_windows @dpy, w, out pwindows, out count
      puts "win count = #{count}"
      p pwindows
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
    def set_transient_for_hint(w : X11::C::Window, prop_window : X11::C::Window) : Int32
      X.set_transient_for_hint @dpy, w, prop_window
    end

    # Activates the screen saver.
    def activate_screen_saver : Int32
      X.activate_screen_saver @dpy
    end

    # TODO: implement & document
    # def add_host(host : PHostAddress) : Int32
    # end

    # TODO: implement & document
    # def add_hosts(hosts : PHostAddress, num_hosts : Int32) : Int32
    # end

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
    def add_to_save_set(w : X11::C::Window) : Int32
      X.add_to_save_set @dpy, w
    end

    # TODO: implement & document
    # def alloc_color(colormap : Colormap, screen_in_out : PColor) : X11::C::X::Status
    # end

    # TODO: implement & document
    # def alloc_color_cells(colormap : Colormap, contig : Bool, plane_masks_return : PUInt64, nplanes : UInt32, pixels_return : PUInt64, npixels : UInt32) : Status
    # end

    # TODO: implement & document
    # def alloc_color_planes(display : PDisplay, colormap : Colormap, contig : Bool, pixels_return : PUInt64, ncolors : Int32, nreds : Int32, ngreens : Int32, nblues : Int32, rmask_return : PUInt64, gmask_return : PUInt64,   bmask_return : PUInt64) : Status
    # end

    # TODO: implement & document
    # def alloc_named_color(colormap : Colormap, color_name : PChar, screen_def_return : PColor, exact_def_return : PColor ) : Status
    # end

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
    def change_keyboard_control(value_mask : UInt64, values : KeyboardControl) : Int32
      X.change_keyboard_control @dpy, value_mask, values.to_unsafe
    end

    def change_keyboard_mapping(first_keycode : Int32, keysyms_per_keycode : Int32, keysyms : Array(X11::C::KeySym)) : Int32
      X.change_keyboard_mapping @dpy, first_keycode, keysyms_per_keycode, keysyms.to_unsafe, keysyms.size
    end

    # -------------------

    def display_keycodes : NamedTuple{min_keycodes : Int32, max_keycode : Int32, res : Int32}
      res = X.display_keycodes @dpy, out min, out max
      {min_keycodes: min, max_keycodes: max, result: res}
    end

    def destroy_window(w : Window) : Int32
      X.destroy_window @dpy, w
    end

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

    def draw_string(d, gc, x : Int32, y : Int32, string : String) : Int32
      X.draw_string @dpy, d, gc, x, y, string.to_unsafe, string.size
    end

    def store_name(w : Window, name : String) : Int32
      X.store_name @dpy, w, name.to_unsafe
    end

    def default_screen_number : Int32
      X.default_screen @dpy
    end

    # Pointer to the underlieing XDisplay object.
    def to_unsafe : X11::C::X::PDisplay
      @dpy
    end
  end
end
