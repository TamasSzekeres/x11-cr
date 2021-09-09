require "./c/Xlib"
require "./window_event"

module X11
  # Wrapper from `X11::C::X::ClientMessageEvent` structure.
  class ClientMessageEvent < WindowEvent
    def initialize
      @event = X11::C::X::ClientMessageEvent.new
    end

    def initialize(event : X11::C::X::PClientMessageEvent)
      raise BadAllocException.new if event.null?
      @event = event.value
    end

    def initialize(@event : X11::C::X::ClientMessageEvent)
    end

    def to_unsafe : X11::C::X::PClientMessageEvent
      pointerof(@event)
    end

    def to_x : X11::C::X::ClientMessageEvent
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

    def message_type : X11::C::Atom
      @event.message_type
    end

    def message_type=(message_type : X11::C::Atom)
      @event.message_type = message_type
    end

    def format : Int32
      @event.format
    end

    def format=(format : Int32)
      @event.format = format
    end

    def char_data : StaticArray(UInt8, 20)
      @event.data.b
    end

    def char_data=(char_data : StaticArray(UInt8, 20))
      @event.data.b = char_data
    end

    def short_data : StaticArray(Int16, 10)
      @event.data.s
    end

    def short_data=(short_data : StaticArray(Int16, 10))
      @event.data.s = short_data
    end

    def long_data : StaticArray(Int64, 5)
      @event.data.l
    end

    def long_data=(long_data : StaticArray(Int64, 5))
      @event.data.l = long_data
    end
  end
end
