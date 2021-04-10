require "./c/Xlib"

module X11
  struct Arc
    property x : Int16
    property y : Int16
    property width : UInt16
    property height : UInt16
    property angle1 : Int16
    property angle2 : Int16

    def initialize(arc : X11::C::X::Arc)
      @x = arc.x
      @y = arc.y
      @width = arc.width
      @height = arc.height
      @angle1 = arc.angle1
      @angle2 = arc.angle2
    end

    def initialize(arc : X11::C::X::PArc)
      raise BadAllocException.new if arc.null?
      initialize(arc.value)
    end

    def initialize(@x : Int16, @y : Int16, @width : UInt16, @height : UInt16, @angle1 : Int16, @angle2 : Int16)
    end

    def to_x : X11::C::X::Arc
      arc = X11::C::X::Arc.new
      arc.x = @x
      arc.y = @y
      arc.width = @width
      arc.height = @height
      arc.angle1 = @angle1
      arc.angle2 = @angle2
      arc
    end
  end
end
