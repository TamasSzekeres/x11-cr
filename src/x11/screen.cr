require "./c/X"
require "./c/Xlib"

module X11
  class Screen
    def initialize(@screen : X11::C::X::PScreen)
      raise BadAllocException.new if @screen.null?
    end

    # Returns root window
    def root_window : X11::C::Window
      X.root_window_of_screen @screen
    end

    # Returns the default visual.
    def default_visual : Visual
      Visual.new(X.default_visual_of_screen(@screen))
    end

    # Returns the default graphics context (GC), which has the same depth as the root window of the screen.
    def default_gc : X11::C::X::GC
      X.default_gc_of_screen @screen
    end

    # Returns the black pixel.
    def black_pixel : UInt64
      X.black_pixel_of_screen @screen
    end

    # Returns the white pixel.
    def white_pixel : UInt64
      X.white_pixel_of_screen @screen
    end

    # Returns the default colormap ID.
    def default_colormap : X11::C::Colormap
      X.default_colormap_of_screen @screen
    end

    # Returns the display
    def display : Display
      Display.new(X.display_of_screen(@screen))
    end

    # Returns the event mask of the root window at connection setup time.
    def event_mask : Int64
      X.event_mask_of_screen @screen
    end

    # Returns the screen index number.
    def screen_number : Int32
      X.screen_number_of_screen @screen
    end

    def to_unsafe : X11::C::X::PScreen
      @screen
    end
  end
end
