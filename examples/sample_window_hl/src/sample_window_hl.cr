require "x11"

module X11Sample
  include X11
  WM_DELETE_WINDOW_STR = "WM_DELETE_WINDOW"

  def self.main
    d = Display.new
    wm_delete_window = d.intern_atom(WM_DELETE_WINDOW_STR, false)

    s = d.default_screen
    root_win = d.root_window s
    black_pix = d.black_pixel s
    white_pix = d.white_pixel s
    win = d.create_simple_window root_win, 10, 10, 400, 300, 1, black_pix, white_pix
    d.select_input win,
      ButtonPressMask | ButtonReleaseMask |
      ButtonMotionMask | ExposureMask | EnterWindowMask |
      LeaveWindowMask | KeyPressMask | KeyReleaseMask
    d.map_window win
    d.set_wm_protocols win, pointerof(wm_delete_window), 1

    # Set Window Title.
    d.store_name win, "Simple Window"

    display_string = "Hello X11!"

    while true
      if d.pending
        e = d.next_event
        case e.type
        when Expose
          d.draw_string win, d.default_gc(s), 10, 50, display_string
        when ClientMessage
          break if e.client.data.ul[0] == wm_delete_window
        when KeyPress
          break
       end
     end
    end

    d.destroy_window win
    d.close
    0
  end

  main
end
