require "./c/Xlib"
require "./window_event"

module X11
  # Wrapper from `X11::C::X::FocusChangeEvent` structure.
  class FocusChangeEvent < WindowEvent
    def initialize
      @event = X11::C::X::FocusChangeEvent.new
    end

    def initialize(event : X11::C::X::PFocusChangeEvent)
      raise BadAllocException.new if event.null?
      @event = event.value
    end

    def initialize(@event : X11::C::X::FocusChangeEvent)
    end

    def to_unsafe : X11::C::X::PFocusChangeEvent
      pointerof(@event)
    end

    def to_x : X11::C::X::FocusChangeEvent
      @event
    end

    def in? : Bool
      @event.type == FocusIn
    end

    def out? : Bool
      @event.type == FocusOut
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

    def mode : Int32
      @event.mode
    end

    def mode=(mode : Int32)
      @event.mode = mode
    end

    def detail : Int32
      @event.keycode
    end

    def detail=(detail : Int32)
      @event.detail = detail
    end
  end
end
