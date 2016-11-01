require "./x11/X"
require "./x11/Xlib"
require "./x11-cr/*"

module X11Cr
  puts "Hello"

  def self.main
    #d = uninitialized X11::PDisplay
    #d = X11.open_display(nil)

    #if d.is_a?(Nil)
    #  puts "d is nil!"
    #  return 1
    #else
    #  puts "d not nil"
    #end

    #s = X11.default_screen d
    #root_win = X11.root_window d, s
    #black_pix = X11.black_pixel d, s
    #white_pix = X11.white_pixel d, s
    #win = X11.create_simple_window d, root_win, 10, 10, 100, 100, 1, black_pix, white_pix
    #X11.select_input d, win, X11::EventMask::ExposureMask
    #X11.map_window d, win

    #e = uninitialized X11::Event
    #while true
    #  X11.next_event(d, pointerof(e))
    #  if e.type == X11::EventName::KeyPress
    #    break
    #  end
    #end

    #X11.close_display d
    puts X11::X_PROTOCOL
    0
  end

  main
end
