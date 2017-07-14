module X11
  class Display
    getter dpy : X::PDisplay

    def initialize(name : String? = nil)
      if name.is_a?(String)
        @dpy = X.open_display name.to_unsafe
      else
        @dpy = X.open_display nil
      end
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

    def select_input(w, event_mask)
      X.select_input @dpy, w, event_mask
    end

    def map_window(w)
      X.map_window @dpy, w
    end

    def set_wm_protocols(w : Window, protocols : PAtom, count : Int32)
      X.set_wm_protocols @dpy, w, protocols, count
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

    def black_pixel(scr)
      X.black_pixel @dpy, scr
    end

    def white_pixel(scr)
      X.white_pixel @dpy, scr
    end
  end
end
