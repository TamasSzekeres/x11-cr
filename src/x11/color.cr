module X11
  struct Color
    property pixel : UInt64
    property red : UInt16
    property green : UInt16
    property blue : UInt16
    property flags : UInt8
    property pad : UInt8

    def initialize(color : X11::C::X::Color)
      @pixel = color.pixel
      @red = color.red
      @green = color.green
      @blue = color.blue
      @flags = color.flags
      @pad = color.pad
    end

    def initialize(color : X11::C::X::PColor)
      raise BadAllocException.new if color.null?
      initialize(color.value)
    end

    def initialize(@pixel : UInt64, @red : UInt16, @green : UInt16, @blue : UInt16, @flags : UInt8, @pad : UInt8)
    end

    def to_unsafe : X11::C::X::PColor
      pointerof(@pixel).as(X11::C::X::PColor)
    end

    def to_x : X11::C::X::Color
      color = X11::C::X::Color.new
      color.pixel = @pixel
      color.red = @red
      color.green = @green
      color.blue= @blue
      color.flags = @flags
      color.pad = @pad
      color
    end
  end
end
