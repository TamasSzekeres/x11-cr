require "./c/Xlib"

module X11
  struct Segment
    property x1 : Int16
    property y1 : Int16
    property x2 : Int16
    property y2 : Int16

    def initialize(segment : X11::C::X::Segment)
      @x1 = segment.x1
      @y1 = segment.y1
      @x2 = segment.x2
      @y2 = segment.y2
    end

    def initialize(segment : X11::C::X::PSegment)
      raise BadAllocException.new if segment.null?
      initialize(segment.value)
    end

    def initialize(@x1 : Int16, @y1 : Int16, @x2 : Int16, @y2 : Int16)
    end

    def to_x : X11::C::X::Segment
      segment = X11::C::X::Segment.new
      segment.x1 = @x1
      segment.y1 = @y1
      segment.x2 = @x2
      segment.y2 = @y2
      segment
    end
  end
end
