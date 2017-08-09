require "./c/Xlib"

module X11
  class GCValues
    getter values : X11::C::X::PGCValues

    def initialize(@values : X11::C::X::PGCValues)
      raise BadAllocException.new if @values.null?
    end

    def to_unsafe : X11::C::X::PGCValues
      @values
    end
  end
end
