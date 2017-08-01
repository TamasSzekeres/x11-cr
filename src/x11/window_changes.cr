require "./c/Xlib"

module X11
  # Wrapper for `X11::C::X::WindowChanges` structure.
  class WindowChanges
    def initialize(@changes : X11::C::X::WindowChanges)
    end

    def initialize(changes : X11::C::X::PWindowChanges)
      raise BadAllocException.new if changes.null?
      @changes = changes.value
    end

    def initialize
      @changes = X11::C::X::WindowChanges.new
    end

    def to_x : X11::C::X::WindowChanges
      @changes
    end

    def to_unsafe : X11::C::X::PWindowChanges
      pointerof(@changes)
    end

    def x: Int32
      @changes.x
    end

    def x=(x : Int32)
      @changes.x = x
    end

    def y : Int32
      @changes.y
    end

    def y=(y : Int32)
      @changes.y = y
    end

    def width : Int32
      @changes.width
    end

    def width=(width : Int32)
      @changes.width = width
    end

    def height : Int32
      @changes.height
    end

    def height=(height : Int32)
      @changes.height = height
    end

    def border_width : Int32
      @changes.border_width
    end

    def border_width=(border_width : Int32)
      @changes.border_width = border_width
    end

    def sibling : X11::C::Window
      @changes.sibling
    end

    def sibling=(sibling : X11::C::Window)
      @changes.sibling = sibling
    end

    def stack_mode : Int32
      @changes.stack_mode
    end

    def stack_mode=(stack_mode : Int32)
      @changes.stack_mode = stack_mode
    end
  end
end
