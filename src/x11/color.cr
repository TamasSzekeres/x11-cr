module X11
  struct Color
    property pixel : UInt64
    property red : UInt16
    property green : UInt16
    property blue : UInt16
    property flags : UInt8
    property pad : UInt8

    def initialize(color : X11::C::X::PColor)
      raise BadAllocException.new if color.null?
      @pixel = color.value.pixel
      @red = color.value.red
      @green = color.value.green
      @blue = color.value.blue
      @flags = color.value.flags
      @pad = color.value.pad
    end

    def initialize(@pixel : UInt64, @red : UInt16, @green : UInt16, @blue : UInt16, @flags : UInt8, @pad : UInt8)
    end
  end
end
