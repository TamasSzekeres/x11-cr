require "./c/Xlib"

module X11
  include C

  class Display
    # Pointer to the underlieing XDisplay object.
    getter dpy : X::PDisplay

    # Opens a new display.
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
    # load_query_font both opens (loads) the specified font and returns a pointer to the appropriate FontStruct structure.
    # If the font name is not in the Host Portable Character Encoding, the result is implementation dependent.
    # If the font does not exist, load_query_font returns nil.
    # *name* Specifies the name of the font.
    def load_query_font(name : String) : FontStruct?
      pfs = X.load_query_font(@dpy, name.to_unsafe)
      pfs.null? ? nil : FontStruct.new(self, pfs)
    end

    def atom_name(atom : Atom | X11::C::Atom) : String
      String.new X.get_atom_name(@dpy, atom.to_u64)
    end

    # The create_simple_window function creates an unmapped InputOutput subwindow for a specified parent window,
    # returns the window ID of the created window, and causes the X server to generate a CreateNotify event.
    # The created window is placed on top in the stacking order with respect to siblings.
    # Any part of the window that extends outside its parent window is clipped.
    # The border_width for an InputOnly window must be zero, or a BadMatch error results.
    # create_simple_window inherits its depth, class, and visual from its parent.
    # All other window attributes, except background and border, have their default values.
    def create_simple_window(
      parent,
      x, y, width, height,
      border_width, border, background)
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

    def intern_atom(atom_name : String, only_if_exists : Bool)
      X.intern_atom @dpy, atom_name.to_unsafe, only_if_exists ? 1 : 0
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
