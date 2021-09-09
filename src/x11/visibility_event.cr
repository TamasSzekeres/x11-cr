require "./c/Xlib"
require "./window_event"

module X11
  # Wrapper from `X11::C::X::VisibilityEvent` structure.
  class VisibilityEvent < WindowEvent
    def initialize
      @event = X11::C::X::VisibilityEvent.new
    end

    def initialize(event : X11::C::X::PVisibilityEvent)
      raise BadAllocException.new if event.null?
      @event = event.value
    end

    def initialize(@event : X11::C::X::VisibilityEvent)
    end

    def to_unsafe : X11::C::X::PVisibilityEvent
      pointerof(@event)
    end

    def to_x : X11::C::X::VisibilityEvent
      @event
    end

    def enter? : Bool
      @event.type == EnterNotify
    end

    def leave? : Bool
      @event.type == LeaveNotify
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

    def state : Int32
      @event.state
    end

    def state=(state : Int32)
      @event.state = state
    end
  end
end
