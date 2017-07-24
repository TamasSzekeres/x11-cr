require "./c/Xlib"

module X11
  struct Rectangle
    property x : Int16
    property y : Int16
    property width : UInt16
    property height : UInt16

    def initialize(rectangle : X11::C::X::Rectangle)
      @x = rectangle.x
      @y = rectangle.y
      @width = rectangle.width
      @height = rectangle.height
    end

    def initialize(rectangle : X11::C::X::PRectangle)
      raise BadAllocException.new if rectangle.null?
      initialize(rectangle.value)
    end

    def initialize(@x : Int16, @y : Int16, @width : UInt16, @height : UInt16)
    end

    def to_x : X11::C::X::Rectangle
      rectangle = X11::C::X::Rectangle.new
      rectangle.x = @x
      rectangle.y = @y
      rectangle.width = @width
      rectangle.height = @height
      rectangle
    end
  end
end
