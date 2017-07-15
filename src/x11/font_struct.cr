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

    # Returns the font's name.
    def name : String
      property_name Atom::Font
    end

    # Given the atom for that property, the property() function returns the value of the specified font property.
    # property() also returns false if the property was not defined or true if it was defined.
    # A set of predefined atoms exists for font properties, which can be found in x11/atom.cr .
    # This set contains the standard properties associated with a font.
    # Although it is not guaranteed, it is likely that the predefined font properties will be present.
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
  end
end
