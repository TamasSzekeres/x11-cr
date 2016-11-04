require "./x11/X"
require "./x11/Xlib"
require "./x11/cursorfont"
require "./x11/keysym"
require "./x11/keysymdef"
require "./x11/Xatom"
require "./x11/XlibConf"
require "./x11/Xtos"
require "./x11/Xregion"
require "./x11/Xutil"
require "./x11/Xmd"
require "./x11-cr/*"

module X11Cr
  WM_DELETE_WINDOW_STR = "WM_DELETE_WINDOW"

  def self.main
    d = uninitialized Xlib::PDisplay
    d = Xlib.open_display(nil)
    wm_delete_window = Xlib.intern_atom(d, WM_DELETE_WINDOW_STR, 0)

    if d.is_a?(Nil)
      return 1
    else
    end

    s = Xlib.default_screen d
    root_win = Xlib.root_window d, s
    black_pix = Xlib.black_pixel d, s
    white_pix = Xlib.white_pixel d, s
    win = Xlib.create_simple_window d, root_win, 10, 10, 400, 300, 1, black_pix, white_pix
    Xlib.select_input d, win,
      X11::ButtonPressMask | X11::ButtonReleaseMask |
      X11::ButtonMotionMask | X11::ExposureMask | X11::EnterWindowMask |
      X11::LeaveWindowMask | X11::KeyPressMask | X11::KeyReleaseMask
    Xlib.map_window d, win
    Xlib.set_wm_protocols d, win, pointerof(wm_delete_window), 1

    e = uninitialized Xlib::Event
    while true
      if Xlib.pending d
        Xlib.next_event(d, pointerof(e))
        case e.type
        when X11::ClientMessage
          break if e.client.data.ul[0] == wm_delete_window
        when X11::KeyPress
          break
        end
      end
    end

    Xlib.close_display d
    0
  end

  main
end
