require "./c/Xlib"
require "./window_event"

module X11
  # Wrapper from `X11::C::X::PropertyEvent` structure.
  class PropertyEvent < WindowEvent
    def initialize
      @event = X11::C::X::PropertyEvent.new
    end

    def initialize(event : X11::C::X::PPropertyEvent)
      raise BadAllocException.new if event.null?
      @event = event.value
    end

    def initialize(@event : X11::C::X::PropertyEvent)
    end

    def to_unsafe : X11::C::X::PPropertyEvent
      pointerof(@event)
    end

    def to_x : X11::C::X::PropertyEvent
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

    def window : X11::C::Window
      @event.window
    end

    def window=(window : X11::C::Window)
      @event.window = window
    end

    def atom : X11::C::Atom
      @event.atom
    end

    def atom=(atom : X11::C::Atom)
      @event.atom = atom
    end

    def time : X11::C::Time
      @event.time
    end

    def time=(time : X11::C::Time)
      @event.time = time
    end

    def state : Int32
      @event.state
    end

    def state=(state : Int32)
      @event.state = state
    end
  end
end
