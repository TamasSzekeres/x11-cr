require "./c/Xlib"
require "./window_event"

module X11
  # Wrapper from `X11::C::X::CirculateEvent` structure.
  class CirculateEvent < WindowEvent
    def initialize
      @event = X11::C::X::CirculateEvent.new
    end

    def initialize(event : X11::C::X::PCirculateEvent)
      raise BadAllocException.new if event.null?
      @event = event.value
    end

    def initialize(@event : X11::C::X::CirculateEvent)
    end

    def to_unsafe : X11::C::X::PCirculateEvent
      pointerof(@event)
    end

    def to_x : X11::C::X::CirculateEvent
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

    def place : Int32
      @event.place
    end

    def place=(place : Int32)
      @event.place = place
    end

    def on_top? : Bool
      @event.place == PlaceOnTop
    end

    def on_bottom? : Bool
      @event.place == PlaceOnBottom
    end
  end
end
