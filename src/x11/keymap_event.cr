require "./c/Xlib"
require "./window_event"

module X11
  # Wrapper for `X11::C::X::KeymapEvent` structure.
  class KeymapEvent < WindowEvent
    def initialize
      @event = X11::C::X::KeymapEvent.new
    end

    def initialize(event : X11::C::X::PKeymapEvent)
      raise BadAllocException.new if event.null?
      @event = event.value
    end

    def initialize(@event : X11::C::X::KeymapEvent)
    end

    def to_unsafe : X11::C::X::PKeymapEvent
      pointerof(@event)
    end

    def to_x : X11::C::X::KeymapEvent
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

    def key_vector : StaticArray(UInt8, 32)
      @event.key_vector
    end

    def key_vector=(key_vector : StaticArray(UInt8, 32))
      @event.key_vector = key_vector
    end
  end
end
