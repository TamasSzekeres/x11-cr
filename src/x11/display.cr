require "./c/Xlib"

module X11
  include C

  class Display
    # Pointer to the underlieing XDisplay object.
    getter dpy : X::PDisplay

    # Opens a connection to the X server that controls a display.
    #
    # #Arguments
    # - **name** Specifies the hardware display name, which determines the display and communications domain to be used.
    # On a `POSIX`-conformant system, if the `name` is *nil*, it defaults to the value of the `DISPLAY` environment variable.
    #
    # #Description
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

    # The load_query_font function provides the most common way for accessing a font.
    # load_query_font both opens (loads) the specified font and returns a FontStruct object.
    # *name* Specifies the name of the font.
    def load_query_font(name : String) : FontStruct
      FontStruct.new(self, X.load_query_font(@dpy, name.to_unsafe))
    end

    # The query_font function returns a FontStruct object, which contains information associated with the font.
    # You can query a font or the font stored in a GC. The *font_id* stored in the FontStruct object will be the GContext ID,
    # and you need to be careful when using this ID in other functions (see g_context_from_gc).
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
    # #Arguments
    # - **d** Specifies the drawable.
    # - **x**, **y** Specify the *x* and *y* coordinates, which are relative to the origin of the drawable and define the upper-left corner of the rectangle.
    # - **width**, **height** Specify the *width* and *height* of the subimage, which define the dimensions of the rectangle.
    # - **plane_mask** Specifies the plane mask.
    # - **format** Specifies the format for the image. You can pass **XYPixmap** or **ZPixmap** .
    #
    # #Description
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
    # #Diagnostic
    # - **BadDrawable** A value for a `Drawable` argument does not name a defined `Window` or `Pixmap`.
    # - **BadMatch** An `InputOnly` window is used as a `Drawable`.
    # - **BadMatch** Some argument or pair of arguments has the correct type and range but fails to match in some other way required by the request.
    # - **BadValue** Some numeric value falls outside the range of values accepted by the request. Unless a specific range is specified for an argument, the full range defined by the argument's type is accepted. Any argument defined as a set of alternatives can generate this error.
    def get_image(d : X11::C::Drawable, x : Int32, y : Int32, width : UInt32, height : UInt32, plane_mask : UInt64, format : Int32) : Image
      Image.new(X.get_image(@dpy, d, x, y, width, height, plane_mask, format))
    end

    # Updates `dest_image` with the specified subimage in the same manner as #get_image.
    #
    # #Arguments
    # - **d** Specifies the drawable.
    # - **x**, **y** Specify the *x* and *y* coordinates, which are relative to the origin of the drawable and define the upper-left corner of the rectangle.
    # - **width**, **height** Specify the *width* and *height* of the subimage, which define the dimensions of the rectangle.
    # - **plane_mask** Specifies the plane mask.
    # - **format** Specifies the format for the image. You can pass **XYPixmap** or **ZPixmap**.
    # - **dest_image** Specifies the destination image.
    # - **dest_x**, **dest_y** Specify the *x* and *y* coordinates, which are relative to the origin of the destination rectangle, specify its upper-left corner, and determine where the subimage is placed in the destination image.
    #
    # #Description
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
    # #Diagnostics
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
    # #Description
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
    # #Arguments
    # - **buffer** Specifies the buffer from which you want the stored data returned.
    #
    # #Description
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
    # #Arguments
    # - **atom** Specifies the atom for the property name you want returned.
    #
    # #Description
    # If the data returned by the server is in the Latin Portable Character Encoding,
    # then the returned string is in the Host Portable Character Encoding.
    # Otherwise, the result is implementation dependent.
    #
    # #Diagnostics
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
    # #Arguments
    # - **display** Specifies the connection to the X server.
    # - **program** Specifies the program name for the Xlib defaults (usually argv[0] of the main program).
    # - **option** Specifies the option name.
    #
    # #Description
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
    # #Arguments
    # - **string** Specifies the character string.
    #
    # #Description
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

    # #Arguments
    # - **keysym** Specifies the `X::C::KeySym` that is to be converted.
    #
    # #Description
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

    # #Arguments
    # - **display** Specifies the connection to the X server.
    # - **atom_name** Specifies the *name* associated with the atom you want returned.
    # - **only_if_exists** Specifies a `Bool` value that indicates whether the atom must be created.
    #
    # #Description
    # `intern_atom` function returns the atom identifier associated with the specified `atom_name` string.
    # If `only_if_exists` is **false**, the atom is created if it does not exist.
    # Therefore, `intern_atom` can return `None`. If the atom name is not in the Host Portable Character Encoding,
    # the result is implementation dependent. Uppercase and lowercase matter; the strings ``thing'', ``Thing'', and ``thinG'' all designate different atoms.
    # The atom will remain defined even after the client's connection closes.
    # It will become undefined only when the last connection to the X server closes.
    #
    # `intern_atom` can generate **BadAlloc** and **BadValue** errors.
    #
    # #Diagnostics
    # - **BadAlloc** The server failed to allocate the requested source or server memory.
    # - **BadValue** Some numeric value falls outside the range of values accepted by the request.
    # Unless a specific range is specified for an argument, the full range defined by the argument's type is accepted.
    # Any argument defined as a set of alternatives can generate this error.
    def intern_atom(atom_name : String, only_if_exists : Bool)
      X.intern_atom @dpy, atom_name.to_unsafe, only_if_exists ? 1 : 0
    end

    def default_visual(screen_number : Int32) : Visual
      Visual.new(self, X.default_visual(@dpy, screen_number))
    end

    # The create_simple_window function creates an unmapped InputOutput subwindow for a specified parent window,
    # returns the window ID of the created window, and causes the X server to generate a CreateNotify event.
    # The created window is placed on top in the stacking order with respect to siblings.
    # Any part of the window that extends outside its parent window is clipped.
    # The border_width for an InputOnly window must be zero, or a BadMatch error results.
    # create_simple_window inherits its depth, class, and visual from its parent.
    # All other window attributes, except background and border, have their default values.
    def create_simple_window(parent, x, y, width, height, border_width, border, background)
      X.create_simple_window @dpy, parent, x, y, width, height, border_width, border, background
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
  end
end
