require "./c/Xlib"

module X11
  # Wrapper for `X11::C::X::XmbTextItem` structure.
  struct MbTextItem
    def initialize
      @text_item = X11::C::X::XmbTextItem.new
    end

    def initialize(text_item : X11::C::X::PmbTextItem)
      raise BadAllocException.new if text_item.null?
      @text_item = text_item.value
    end

    def initialize(@text_item : X11::C::X::XmbTextItem)
    end

    def to_unsafe : X11::C::X::PmbTextItem
      pointerof(@text_item)
    end

    def to_x : X11::C::X::XmbTextItem
      @text_item
    end

    def chars : String
      @text_item.chars.null? ? "" : String.new @text_item.chars
    end

    def chars=(chars : String)
      @text_item.chars = chars.to_unsafe
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
