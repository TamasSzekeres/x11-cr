require "./c/Xlib"

module X11
  abstract class Event
    # ameba:disable Metrics/CyclomaticComplexity
    def self.from_xevent(xevent : X11::C::X::Event) : Event
      case xevent.type
      when KeyPress, KeyRelease then KeyEvent.new xevent.key
      when ButtonPress, ButtonRelease then ButtonEvent.new xevent.button
      when MotionNotify then MotionEvent.new xevent.motion
      when EnterNotify, LeaveNotify then CrossingEvent.new xevent.crossing
      when FocusIn, FocusOut then FocusChangeEvent.new xevent.focus
      when Expose then ExposeEvent.new xevent.expose
      when GraphicsExpose then GraphicsExposeEvent.new xevent.graphicsexpose
      when NoExpose then NoExposeEvent.new xevent.noexpose
      when VisibilityNotify then VisibilityEvent.new xevent.visibility
      when CreateNotify then CreateWindowEvent.new xevent.createwindow
      when DestroyNotify then DestroyWindowEvent.new xevent.destroywindow
      when UnmapNotify then UnmapEvent.new xevent.unmap
      when MapNotify then MapEvent.new xevent.map
      when MapRequest then MapRequestEvent.new xevent.maprequest
      when ReparentNotify then ReparentEvent.new xevent.reparent
      when ConfigureNotify then ConfigureEvent.new xevent.configure
      when GravityNotify then GravityEvent.new xevent.gravity
      when ResizeRequest then ResizeRequestEvent.new xevent.resizerequest
      when ConfigureRequest then ConfigureRequestEvent.new xevent.configurerequest
      when CirculateNotify then CirculateEvent.new xevent.circulate
      when CirculateRequest then CirculateRequestEvent.new xevent.circulaterequest
      when PropertyNotify then PropertyEvent.new xevent.property
      when SelectionClear then SelectionClearEvent.new xevent.selectionclear
      when SelectionRequest then SelectionRequestEvent.new xevent.selectionrequest
      when SelectionNotify then SelectionEvent.new xevent.selection
      when ColormapNotify then ColormapEvent.new xevent.colormap
      when ClientMessage then ClientMessageEvent.new xevent.client
      when MappingNotify then MappingEvent.new xevent.mapping
      when KeymapNotify then KeymapEvent.new xevent.keymap
      when X11::C::GenericEvent then GenericEvent.new xevent.cookie
      else
        AnyEvent.new xevent.any
      end
    end

    abstract def type : Int32
    abstract def type=(type : Int32)
    abstract def serial : UInt64
    abstract def serial=(serial : UInt64)
  end
end
