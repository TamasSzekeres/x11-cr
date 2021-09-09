require "./c/Xlib"
require "./window_event"

module X11
  # Wrapper from `X11::C::X::ColormapEvent` structure.
  class ColormapEvent < WindowEvent
    def initialize
      @event = X11::C::X::ColormapEvent.new
    end

    def initialize(event : X11::C::X::PColormapEvent)
      raise BadAllocException.new if event.null?
      @event = event.value
    end

    def initialize(@event : X11::C::X::ColormapEvent)
    end

    def to_unsafe : X11::C::X::PColormapEvent
      pointerof(@event)
    end

    def to_x : X11::C::X::ColormapEvent
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

    def colormap : X11::C::Colormap
      @event.colormap
    end

    def colormap=(colormap : X11::C::Colormap)
      @event.colormap = colormap
    end

    def is_new : Bool
      @event.is_new ? true : false
    end

    def is_new=(is_new : Bool)
      @event.is_new = is_new ? 1 : 0
    end

    def state : Int32
      @event.state
    end

    def state=(state : Int32)
      @event.state = state
    end
  end
end
