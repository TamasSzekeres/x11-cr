require "./c/Xlib"
require "./event"

module X11
  abstract class WindowEvent < Event
    abstract def display : Display
    abstract def display=(display : Display)
    abstract def window : X11::C::Window
    abstract def window=(window : X11::C::Window)
  end
end
