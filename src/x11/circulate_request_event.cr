require "./c/Xlib"
require "./window_event"

module X11
  # Wrapper from `X11::C::X::CirculateRequestEvent` structure.
  class CirculateRequestEvent < WindowEvent
    def initialize
      @event = X11::C::X::CirculateRequestEvent.new
    end

    def initialize(event : X11::C::X::PCirculateRequestEvent)
      raise BadAllocException.new if event.null?
      @event = event.value
    end

    def initialize(@event : X11::C::X::CirculateRequestEvent)
    end

    def to_unsafe : X11::C::X::PCirculateRequestEvent
      pointerof(@event)
    end

    def to_x : X11::C::X::CirculateRequestEvent
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

    def parent : X11::C::Window
      @event.parent
    end

    def parent=(parent : X11::C::Window)
      @event.parent = parent
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
