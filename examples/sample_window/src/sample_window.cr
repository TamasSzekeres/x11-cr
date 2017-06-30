require "x11"

module X11Sample
  include X11
  WM_DELETE_WINDOW_STR = "WM_DELETE_WINDOW"

  def self.main
    d = uninitialized X::PDisplay
    d = X.open_display(nil)
    wm_delete_window = X.intern_atom(d, WM_DELETE_WINDOW_STR, 0)

    if d.is_a?(Nil)
      return 1
    end

    s = X11.default_screen d
    root_win = X11.root_window d, s
    black_pix = X11.black_pixel d, s
    white_pix = X11.white_pixel d, s
    win = X.create_simple_window d, root_win, 10, 10, 400, 300, 1, black_pix, white_pix
    X.select_input d, win,
      ButtonPressMask | ButtonReleaseMask |
      ButtonMotionMask | ExposureMask | EnterWindowMask |
      LeaveWindowMask | KeyPressMask | KeyReleaseMask
    X.map_window d, win
    X.set_wm_protocols d, win, pointerof(wm_delete_window), 1

    # Set Window Title.
    X.store_name d, win, "Simple Window"

    display_string = "Hello X11!"

    e = uninitialized X::Event
    while true
      if X.pending d
        X.next_event(d, pointerof(e))
        case e.type
        when Expose
          X.draw_string d, win, X.default_gc(d, s), 10, 50, display_string, display_string.size
        when ClientMessage
          break if e.client.data.ul[0] == wm_delete_window
        when KeyPress
          break
        end
      end
    end

    X.destroy_window d, win
    X.close_display d
    0
  end

  main
end
