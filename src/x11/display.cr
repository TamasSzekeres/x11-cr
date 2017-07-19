require "./c/Xlib"

module X11
  include C

  class Display
    # Pointer to the underlieing XDisplay object.
    getter dpy : X::PDisplay

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
    end

    def finalize
      close
    end

    def close : Int32
      X.close_display @dpy
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

    def installed_colormaps(w : Window) : Array(Colormap)
      pcolormaps = X.list_installed_colormaps @dpy, w, out num
      return [] of Colormap if pcolormaps.null? || num <= 0
      colormaps = Array(Colormap).new num
      (0...num).each do |i|
        colormaps[i] = pcolormaps[0].value
      end
      colormaps
    end

    def fonts(pattern : String, maxnames : Int32) : Array(String)
      pstrings = X.list_fonts @dpy, pattern.to_unsafe, out count
      return [] of String if pstrings.null? || count <= 0
      font_names = Array(String).new count
      (0...count).each do |i|
        font_names[i] = String.new pstrings[i]
      end
    end

    def fonts_with_info(pattern : String, maxnames : Int32) : Array(String)
    end

    def font_path : Array(String)
    end

    def extensions : Array(String)
    end

    def properties(w : X11::C::Window) : Array(Atom | X11::C::Atom)
    end

    def hosts : Array(HostAddress)
    end

    def keycode_to_keysym(keycode : X11::C::KeyCode, index : Int32) : X11::C::KeySym
    end

    def lookup_keysym(key_event : KeyEvent, index : Int32) : X11::C::KeySym
    end

    def keyboard_mapping(first_keycode : X11::C::KeyCode, keycode_count : Int32) : Array(KeySym)
    end

    def self.string_to_keysym(string : String) : X11::C::KeySym
      X.string_to_keysym string.to_unsafe
    end

    def max_request_size : Int64
      X.max_request_size @dpy
    end

    def extended_map_request_size : Int64
      X.extended_map_request_size @dpy
    end

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

    def motion_buffer_size : UInt64
      X.display_motion_buffer_size @dpy
    end

    def self.init_threads : X11::C::Status
      X.init_threads
    end

    def lock
      X.lock_display
      self
    end

    def unlock
      X.unlock_display @dpy
      self
    end

    def default_visual(screen_number : Int32) : Visual
      Visual.new(self, X.default_visual(@dpy, screen_number))
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

    def set_wm_protocols(w : Window, protocols : PAtom, count : Int32)
      X.set_wm_protocols @dpy, w, protocols, count
    end

    def store_name(w : Window, name : String) : Int32
      X.store_name @dpy, w, name.to_unsafe
    end

    def default_screen
      X.default_screen @dpy
    end

    def root_window(scr) : Window
      X.root_window @dpy, scr
    end

    def default_gc(scr)
      X.default_gc @dpy, scr
    end

    def black_pixel(scr)
      X.black_pixel @dpy, scr
    end

    def white_pixel(scr)
      X.white_pixel @dpy, scr
    end

    # Pointer to the underlieing XDisplay object.
    def to_unsafe : X11::C::X::PDisplay
      @dpy
    end
  end
end
