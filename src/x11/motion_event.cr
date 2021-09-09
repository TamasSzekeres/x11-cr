require "./c/Xlib"
require "./window_event"

module X11
  # Wrapper for `X11::C::X::MotionEvent` structure.
  class MotionEvent < WindowEvent
    def initialize
      @event = X11::C::X::MotionEvent.new
    end

    def initialize(event : X11::C::X::PMotionEvent)
      raise BadAllocException.new if event.null?
      @event = event.value
    end

    def initialize(@event : X11::C::X::MotionEvent)
    end

    def to_unsafe : X11::C::X::PMotionEvent
      pointerof(@event)
    end

    def to_x : X11::C::X::MotionEvent
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

    def root : X11::C::Window
      @event.root
    end

    def root=(root : X11::C::Window)
      @event.root = root
    end

    def sub_window : X11::C::Window
      @event.subwindow
    end

    def sub_window=(sub_window : X11::C::Window)
      @event.subwindow = sub_window
    end

    def time : X11::C::Time
      @event.time
    end

    def time=(time : X11::C::Time)
      @event.time = time
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

    def x_root : Int32
      @event.x_root
    end

    def x_root=(x_root : Int32)
      @event.x_root = x_root
    end

    def y_root : Int32
      @event.y_root
    end

    def y_root=(y_root : Int32)
      @event.y_root = y_root
    end

    def state : UInt32
      @event.state
    end

    def state=(state : UInt32)
      @event.state = state
    end

    def is_hist : UInt8
      @event.is_hint
    end

    def is_hint=(is_hint : UInt8)
      @event.is_hint = is_hint
    end

    def same_screen : Bool
      @event.same_screen ? true : false
    end

    def same_screen=(same_screen : Bool)
      @event.same_screen = same_screen ? 1 : 0
    end
  end
end
