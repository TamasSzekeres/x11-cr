require "./c/Xlib"

module X11
  class SetWindowAttributes
    def initialize(attributes : X11::C::X::PSetWindowAttributes)
      raise BadAllocException.new if attributes.null?
      @attributes = attributes.value
    end

    def initialize(@attributes : X11::C::X::SetWindowAttributes)
    end

    def initialize
      @attributes = X11::C::X::SetWindowAttributes.new
    end

    def to_unsafe : X11::C::X::PSetWindowAttributes
      pointerof(@attributes)
    end

    def background_pixmap : X11::C::Pixmap
      @attributes.background_pixmap
    end

    def background_pixel : UInt64
      @attributes.background_pixel
    end

    def background_pixel=(bg_pix : UInt64)
      @attributes.background_pixel = bg_pix
    end

    def border_pixmap : X11::C::Pixmap
      @attibutes.border_pixmap
    end

    def border_pixmap=(pixmap : X11::C::Pixmap)
      @attibutes.border_pixmap = pixmap
    end

    def border_pixel : UInt64
      @attributes.border_pixel
    end

    def border_pixel=(pixel : UInt64)
      @attributes.border_pixel = pixel
    end

    def bit_gravity : Int32
      @attributes.bit_gravity
    end

    def bit_gravity=(gravity : Int32)
      @attributes.bit_gravity = gravity
    end

    def win_gravity : Int32
      @attributes.win_gravity
    end

    def win_gravity=(gravity : Int32)
      @attributes.win_gravity = gravity
    end

    def backing_store : Int32
      @attributes.backing_store
    end

    def backing_store=(store : Int32)
      @attributes.backing_store = store
    end

    def backing_planes : UInt64
      @attributes.backing_planes
    end

    def backing_planes=(planes : UInt64)
      @attributes.backing_planes = planes
    end

    def backing_pixel : UInt64
      @attributes.backing_pixel
    end

    def backing_pixel=(pixel : UInt64)
      @attributes.backing_pixel = pixel
    end

    def save_under : Bool
      @attributes.save_under
    end

    def save_under=(b : Bool)
      @attributes.save_under = (b ? 1 : 0)
    end

    def event_mask : Int64
      @attributes.event_mask
    end

    def event_mask=(mask : Int64)
      @attributes.event_mask = mask
    end

    def do_not_propagate_mask : Int64
      @attributes.do_not_propagate_mask
    end

    def do_not_propagate_mask=(mask : Int64)
      @attributes.do_not_propagate_mask = mask
    end

    def override_redirect : Bool
      @attributes.override_redirect == 1 ? true : false
    end

    def override_redirect=(redirect : Bool)
      @attributes.override_redirect = (redirect ? 1 : 0)
    end

    def colormap : X11::C::Colormap
      @attributes.colormap
    end

    def colormap=(colormap : X11::C::Colormap)
      @attributes.colormap = colormap
    end

    def cursor : X11::C::Cursor
      @attributes.cursor
    end

    def cursor=(cursor : X11::C::Cursor)
      @attributes.cursor = cursor
    end
  end
end
