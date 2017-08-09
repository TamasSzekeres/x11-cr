require "./c/X"
require "./c/Xlib"

module X11
  class Screen
    def initialize(@screen : X11::C::X::PScreen)
      raise BadAllocException.new if @screen.null?
    end

    # Returns the SCREEN_RESOURCES property from the root window.
    #
    # ###Description
    # The `resource_string` function returns the SCREEN_RESOURCES property from
    # the root window of the actual screen. The property is converted from
    # type STRING to the current locale. The conversion is identical to that
    # produced by `Display::mb_text_property_to_text_list` for a single element STRING
    # property. The property value must be in a format that is acceptable to
    # `X11::rm_get_string_database`. If no property exists, empty string is returned.
    #
    # ###See also
    # `Display::resource_manager_string`.
    def resource_string : String
      pstr = X.screen_resource_string @screen
      return "" if pstr.null?
      str = String.new pstr
      X.free pstr
      str
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

    # Returns the number of colormap cells in the default colormap.
    def cells : Int32
      X.cells_of_screen @screen
    end

    # Returns the depth of the root window.
    def default_depth : Int32
      X.default_depth_of_screen @screen
    end

    # Returns a value indicating whether the screen supports backing stores.
    # The value returned can be one of **WhenMapped**, **NotUseful**, or **Always**
    def does_backing_store : Int32
      X.does_backing_store @screen
    end

    # Returns a `Bool` value indicating whether the screen supports save unders.
    # If `true`, the screen supports save unders. If `false`, the screen does not support save unders
    def does_save_unders : Bool
      (X.does_save_unders(@screen)) == X11::C::X::True ? true : false
    end

    # Returns height of screen in millimeters.
    def height_mm : Int32
      X.height_of_screen @screen
    end

    # Returns height of screen in pixels.
    def height : Int32
      X.height_of_screen @screen
    end

    # Returns the maximum number of installed colormaps supported by the specified screen.
    def max_cmaps : Int32
      X.max_cmaps_of_screen @screen
    end

    # Returns the minimum number of installed colormaps supported by the specified screen.
    def min_cmaps : Int32
      X.min_cmaps_of_screen @screen
    end

    # Returns the depth of the root window.
    def plane : Int32
      X.plane_of_screen @screen
    end

    # Returns the width of the specified screen in millimeters.
    def width_mm : Int32
      X.width_mm_of_screen @screen
    end

    # Returns the width of the specified screen in pixels.
    def width : Int32
      X.width_of_screen @screen
    end

    # Returns the underlieing `X11::C::X::PScreen` pointer
    def to_unsafe : X11::C::X::PScreen
      @screen
    end
  end
end
