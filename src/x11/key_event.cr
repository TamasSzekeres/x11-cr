require "./c/Xlib"

module X11
  # Wrapper from `X11::C::X::KeyEvent` structure.
  struct KeyEvent
    def initialize
      @key_event = X11::C::X::KeyEvent.new
    end

    def initialize(key_event : X11::C::X::PKeyEvent)
      raise BadAllocException.new if key_event.null?
      @key_event = key_event.value
    end

    def initialize(@key_event : X11::C::X::KeyEvent)
    end

    def to_unsafe : X11::C::X::PKeyEvent
      return pointerof(@key_event)
    end

    def to_x : X11::C::X::KeyEvent
      @key_event
    end

    def type : Int32
      @key_event.type
    end

    def type=(type : Int32)
      @key_event.type = type
    end

    def serial : UInt64
      @key_event.serial
    end

    def serial=(serial : UInt64)
      @key_event.serial = serial
    end

    def send_event : Bool
      @key_event.send_event ? true : false
    end

    def send_event=(send_event : Bool)
      @key_event.send_event = send_event ? 1 : 0
    end

    def display : Display
      Display.new @key_event.display
    end

    def display=(display : Display)
      @key_event.display = display.to_unsafe
    end

    def window : X11::C::Window
      @key_event.window
    end

    def window=(window : X11::C::Window)
      @key_event.window = window
    end

    def root : X11::C::Window
      @key_event.root
    end

    def root=(root : X11::C::Window)
      @key_event.root = root
    end

    def sub_window : X11::C::Window
      @key_event.subwindow
    end

    def sub_window=(sub_window : X11::C::Window)
      @key_event.subwindow = sub_window
    end

    def time : X11::C::Time
      @key_event.time
    end

    def time=(time : X11::C::Time)
      @key_event.time = time
    end

    def x : Int32
      @key_event.x
    end

    def x=(x : Int32)
      @key_event.x = x
    end

    def y : Int32
      @key_event.y
    end

    def y=(y : Int32)
      @key_event.y = y
    end

    def x_root : Int32
      @key_event.x_root
    end

    def x_root=(x_root : Int32)
      @key_event.x_root = x_root
    end

    def y_root : Int32
      @key_event.y_root
    end

    def y_root=(y_root : Int32)
      @key_event.y_root = y_root
    end

    def state : UInt32
      @key_event.state
    end

    def state=(state : UInt32)
      @key_event.state = state
    end

    def keycode : UInt32
      @key_event.keycode
    end

    def keycode=(keycode : UInt32)
      @key_event.keycode = keycode
    end

    def same_screen : Bool
      @key_event.same_screen ? true : false
    end

    def same_screen=(same_screen : Bool)
      @key_event.same_screen = same_screen ? 1 : 0
    end
  end
end
