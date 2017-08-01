require "./c/Xlib"

module X11
  # Wrapper for `X11::C::X::ButtonEvent` structure.
  struct ButtonEvent
    def initialize
      @button_event = X11::C::X::ButtonEvent.new
    end

    def initialize(button_event : X11::C::X::PButtonEvent)
      raise BadAllocException.new if button_event.null?
      @button_event = button_event.value
    end

    def initialize(@button_event : X11::C::X::ButtonEvent)
    end

    def to_unsafe : X11::C::X::PButtonEvent
      pointerof(@button_event)
    end

    def to_x : X11::C::X::ButtonEvent
      @button_event
    end

    def type : Int32
      @button_event.type
    end

    def type=(type : Int32)
      @button_event.type = type
    end

    def serial : UInt64
      @button_event.serial
    end

    def serial=(serial : UInt64)
      @button_event.serial = serial
    end

    def send_event : Bool
      @button_event.send_event ? true : false
    end

    def send_event=(send_event : Bool)
      @button_event.send_event = send_event ? 1 : 0
    end

    def display : Display
      Display.new @button_event.display
    end

    def display=(display : Display)
      @button_event.display = display.to_unsafe
    end

    def window : X11::C::Window
      @button_event.window
    end

    def window=(window : X11::C::Window)
      @button_event.window = window
    end

    def root : X11::C::Window
      @button_event.root
    end

    def root=(root : X11::C::Window)
      @button_event.root = root
    end

    def sub_window : X11::C::Window
      @button_event.subwindow
    end

    def sub_window=(sub_window : X11::C::Window)
      @button_event.subwindow = sub_window
    end

    def time : X11::C::Time
      @button_event.time
    end

    def time=(time : X11::C::Time)
      @button_event.time = time
    end

    def x : Int32
      @button_event.x
    end

    def x=(x : Int32)
      @button_event.x = x
    end

    def y : Int32
      @button_event.y
    end

    def y=(y : Int32)
      @button_event.y = y
    end

    def x_root : Int32
      @button_event.x_root
    end

    def x_root=(x_root : Int32)
      @button_event.x_root = x_root
    end

    def y_root : Int32
      @button_event.y_root
    end

    def y_root=(y_root : Int32)
      @button_event.y_root = y_root
    end

    def state : UInt32
      @button_event.state
    end

    def state=(state : UInt32)
      @button_event.state = state
    end

    def button : UInt32
      @button_event.button
    end

    def button=(button : UInt32)
      @button_event.button = button
    end

    def same_screen : Bool
      @button_event.same_screen ? true : false
    end

    def same_screen=(same_screen : Bool)
      @button_event.same_screen = same_screen ? 1 : 0
    end
  end
end
