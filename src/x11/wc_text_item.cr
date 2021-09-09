require "./c/Xlib"

module X11
  # Wrapper for `X11::C::X::XwcTextItem` structure.
  struct WcTextItem
    def initialize
      @text_item = X11::C::X::XwcTextItem.new
    end

    def initialize(text_item : X11::C::X::PwcTextItem)
      raise BadAllocException.new if text_item.null?
      @text_item = text_item.value
    end

    def initialize(@text_item : X11::C::X::XwcTextItem)
    end

    def to_unsafe : X11::C::X::PwcTextItem
      pointerof(@text_item)
    end

    def to_x : X11::C::X::XwcTextItem
      @text_item
    end

    def chars : X11::C::X::PWCharT
      @text_item.chars
    end

    def chars=(chars : X11::C::X::PWCharT)
      @text_item.chars = chars
    end

    def nchars : Int32
      @text_item.nchars
    end

    def delta : Int32
      @text_item.delta
    end

    def delta=(delta : Int32)
      @text_item.delta = delta
    end

    def font_set : X11::C::X::FontSet
      @text_item.font_set
    end

    def font_set=(font_set : X11::C::X::FontSet)
      @text_item.font_set = font_set
    end
  end
end
