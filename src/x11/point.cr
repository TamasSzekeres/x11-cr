require "./c/Xlib"

module X11
  struct Point
    property x : Int16
    property y : Int16

    def initialize(point : X11::C::X::Point)
      @x = point.x
      @y = point.y
    end

    def initialize(point : X11::C::X::PPoint)
      raise BadAllocException.new if point.null?
      initialize(point.value)
    end

    def initialize(@x : Int16, @y : Int16)
    end

    def to_x : X11::C::X::Point
      point = X11::C::X::Point.new
      point.x = @x
      point.y = @y
      point
    end
  end
end
