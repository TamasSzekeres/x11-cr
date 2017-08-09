require "./c/Xlib"

module X11
  class Visual
    getter visual : X11::C::X::PVisual

    def initialize(@visual : X11::C::X::PVisual)
      raise BadAllocException.new if @visual.null?
    end

    def visual_id : X11::C::VisualID
      X.visual_id_from_visual @visual
    end

    def to_unsafe : X11::C::X::PVisual
      @visual
    end
  end
end
