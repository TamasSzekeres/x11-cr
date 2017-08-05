require "./c/X"
require "./c/Xlib"

module X11
  include C

  class FontStruct
    getter display : Display
    getter font_struct : X::PFontStruct

    def initialize(@display : Display, @font_struct : X::PFontStruct)
      raise BadAllocException.new if @font_struct.null?
    end

    def finalize
      X.free_font @display.dpy, @font_struct
    end

    # Returns the font's name.
    def name : String
      property_name Atom::Font
    end

    # Returns the value of the specified font property.
    #
    # ###Arguments
    # - **atom** Specifies the atom for the property name you want returned.
    #
    # ###Description
    # Given the atom for that property, the property() function returns the value of the specified font property.
    # property() also returns false if the property was not defined or true if it was defined.
    # A set of predefined atoms exists for font properties, which can be found in x11/atom.cr .
    # This set contains the standard properties associated with a font.
    # Although it is not guaranteed, it is likely that the predefined font properties will be present.
    #
    # ###See also
    # `Display::create_gc`, `finalize`, `Display::fonts`, `Display::load_font`,
    # `Display::load_query_font`, `Display::query_font`,
    # `Display::set_font_path`, `Display::unload_font`.
    def property(atom : Atom | X11::C::Atom) : Atom | X11::C::Atom | Bool
      res = X.get_font_property @font_struct, atom.to_u64, out ret
      res == X::True ? ret : false
    end

    def property_name(atom : Atom | X11::C::Atom)
      case prop = property(atom)
      when Atom, X11::C::Atom then @display.atom_name(prop)
      else
        "<unknown>"
      end
    end

    def to_unsafe : X11::C::X::PFontStruct
      @font_struct
    end

    def to_x : X11::C::X::FontStruct
      @font_struct.value
    end
  end
end
