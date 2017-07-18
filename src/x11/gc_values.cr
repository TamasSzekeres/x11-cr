require "./c/Xlib"

module X11
  class GCValues
    getter values : X11::C::X::PGCValues

    def initialize(@values : X11::C::X::PGCValues)
      raise BadAllocException.new if @values.null?
    end
  end
end
