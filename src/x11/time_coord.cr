require "./c/Xlib"

module X11
  struct TimeCoord
    # The time in milliseconds.
    property time : UInt64

    # The x and y members are set to the coordinates of the pointer and are reported relative to the origin of the specified window.
    property x, y : Int16

    def initialize(@time : UInt64, @x : Int16, @y : Int16)
    end

    def initialize(time_coord : X11::C::TimeCoord)
      @time = time_coord.time
      @x = time_coord.x
      @y = time_coord.y
    end

    def initialize(time_coord : X11::C::PTimeCoord)
      raise BadAllocException.new if time_coord.null?
      initialize time_coord.value
    end
  end
end
