require "./c/Xlib"
require "./event"

module X11
  # Wraper for `X11::C::X::KeyboardControl` structure.
  class KeyboardControl
    def initialize(keyboard_control : X11::C::X::PKeyboardControl)
      raise BadAllocException.new if keyboard_control.null?
      @keyboard_control = keyboard_control.value
    end

    def initialize(@keyboard_control : X11::C::X::KeyboardControl)
    end

    def initialize
      @keyboard_control = X11::C::X::KeyboardControl.new
    end

    def to_x : X11::C::X::KeyboardControl
      @keyboard_control
    end

    def to_unsafe : X11::C::X::PKeyboardControl
      pointerof(@keyboard_control)
    end

    def key_click_percent : Int32
      @keyboard_control.key_click_percent
    end

    def key_click_percent=(key_click_percent : Int32)
      @keyboard_control.key_click_percent = key_click_percent
    end

    def bell_percent : Int32
      @keyboard_control.bell_percent
    end

    def bell_percent=(bell_percent : Int32)
      @keyboard_control.bell_percent = bell_percent
    end

    def bell_pitch : Int32
      @keyboard_control.bell_pitch
    end

    def bell_pitch=(bell_pitch : Int32)
      @keyboard_control.bell_pitch = bell_pitch
    end

    def bell_duration : Int32
      @keyboard_control.bell_duration
    end

    def bell_duration=(bell_duration : Int32)
      @keyboard_control.bell_duration = bell_duration
    end

    def led : Int32
      @keyboard_control.led
    end

    def led=(led : Int32)
      @keyboard_control.led = led
    end

    def led_mode : Int32
      @keyboard_control.led_mode
    end

    def led_mode=(led_mode : Int32)
      @keyboard_control.led_mode = led_mode
    end

    def key : Int32
      @keyboard_control.key
    end

    def key=(key : Int32)
      @keyboard_control.key = key
    end

    def auto_repeat_mode : Int32
      @keyboard_control.auto_repeat_mode
    end

    def auto_repeat_mode=(auto_repeat_mode : Int32)
      @keyboard_control.auto_repeat_mode = auto_repeat_mode
    end
  end
end
