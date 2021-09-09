require "./c/Xlib"
require "./window_event"

module X11
  # Wrapper from `X11::C::X::GravityEvent` structure.
  class GravityEvent < WindowEvent
    def initialize
      @event = X11::C::X::GravityEvent.new
    end

    def initialize(event : X11::C::X::PGravityEvent)
      raise BadAllocException.new if event.null?
      @event = event.value
    end

    def initialize(@event : X11::C::X::GravityEvent)
    end

    def to_unsafe : X11::C::X::PGravityEvent
      pointerof(@event)
    end

    def to_x : X11::C::X::GravityEvent
      @event
    end

    def type : Int32
      @event.type
    end

    def type=(type : Int32)
      @event.type = type
    end

    def serial : UInt64
      @event.serial
    end

    def serial=(serial : UInt64)
      @event.serial = serial
    end

    def send_event : Bool
      @event.send_event ? true : false
    end

    def send_event=(send_event : Bool)
      @event.send_event = send_event ? 1 : 0
    end

    def display : Display
      Display.new @event.display
    end

    def display=(display : Display)
      @event.display = display.to_unsafe
    end

    def event : X11::C::Window
      @event.event
    end

    def event=(event : X11::C::Window)
      @event.event = event
    end

    def window : X11::C::Window
      @event.window
    end

    def window=(window : X11::C::Window)
      @event.window = window
    end

    def x : Int32
      @event.x
    end

    def x=(x : Int32)
      @event.x = x
    end

    def y : Int32
      @event.y
    end

    def y=(y : Int32)
      @event.y = y
    end
  end
end
