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

    # Performs the size computation locally.
    #
    # ###Arguments
    # - **string** Specifies the character string.
    #
    # ###Returns
    # - **direction** Returns the value of the direction hint
    # (**FontLeftToRight** or **FontRightToLeft**).
    # - **font_ascent** Returns the font ascent.
    # - **font_descent** Returns the font descent.
    # - **overall** Returns the overall size in the specified `CharStruct` structure.
    #
    # ###Description
    # The `text_extents` function performs the size computation locally and,
    # thereby, avoid the round-trip overhead of `query_text_extents` and
    # `query_text_extents_16`. The function returns an `CharStruct` structure,
    # whose members are set to the values as follows.
    #
    # The ascent member is set to the maximum of the ascent metrics of all
    # characters in the string. The descent member is set to the maximum of the
    # descent metrics. The width member is set to the sum of the character-width
    # metrics of all characters in the string. For each character in the string,
    # let W be the sum of the character-width metrics of all characters preceding
    # it in the string. Let L be the left-side-bearing metric of the character
    # plus W. Let R be the right-side-bearing metric of the character plus W.
    # The lbearing member is set to the minimum L of all characters in the string.
    # The rbearing member is set to the maximum R.
    #
    # For fonts defined with linear indexing rather than 2-byte matrix indexing,
    # each `X11::C::X::Char2b` structure is interpreted as a 16-bit number with
    # byte1 as the most-significant byte. If the font has no defined default
    # character, undefined characters in the string are taken to have all zero metrics.
    #
    # ###See also
    # `Display::query_text_extents`, `Display::query_text_extents_16`, `text_extents_16`.
    def text_extents(string : String) : NamedTuple(direction: Int32, font_ascent: Int32, font_descent: Int32, overall: CharStruct, res: Int32)
      res = X.text_extents @font_struct, string.to_unsafe, string.size, out direction_return, out font_ascent_return, out font_descent_return, out overall_return
      {direction: direction_return, font_ascent: font_ascent_return, font_descent: font_descent_return, overall: CharStruct.new(overall_return), res: res}
    end

    # Performs the size computation locally.
    #
    # ###Arguments
    # - **string** Specifies the character string.
    #
    # ###Returns
    # - **direction** Returns the value of the direction hint
    # (**FontLeftToRight** or **FontRightToLeft**).
    # - **font_ascent** Returns the font ascent.
    # - **font_descent** Returns the font descent.
    # - **overall** Returns the overall size in the specified `CharStruct` structure.
    #
    # ###Description
    # The `text_extents_16` function performs the size computation locally and,
    # thereby, avoid the round-trip overhead of `query_text_extents` and
    # `query_text_extents_16`. The function returns an `CharStruct` structure,
    # whose members are set to the values as follows.
    #
    # The ascent member is set to the maximum of the ascent metrics of all
    # characters in the string. The descent member is set to the maximum of the
    # descent metrics. The width member is set to the sum of the character-width
    # metrics of all characters in the string. For each character in the string,
    # let W be the sum of the character-width metrics of all characters
    # preceding it in the string. Let L be the left-side-bearing metric of the
    # character plus W. Let R be the right-side-bearing metric of the character
    # plus W. The lbearing member is set to the minimum L of all characters in
    # the string. The rbearing member is set to the maximum R.
    #
    # For fonts defined with linear indexing rather than 2-byte matrix indexing,
    # each `X1::C::X::Char2b` structure is interpreted as a 16-bit number with
    # byte1 as the most-significant byte. If the font has no defined default
    # character, undefined characters in the string are taken to have all zero metrics.
    #
    # ###See also
    # `Display::query_text_extents`, `Display::query_text_extents_16`, `text_extents`.
    def text_extents_16(string : Array(X11::C::X::Char2b)) : NamedTuple(direction: Int32, font_ascent: Int32, font_descent: Int32, overall: CharStruct, res: Int32)
      res = X.text_extents_16 @font_struct, string.to_unsafe, string.size, out direction_return, out font_ascent_return, out font_descent_return, out overall_return
      {direction: direction_return, font_ascent: font_ascent_return, font_descent: font_descent_return, overall: CharStruct.new(overall_return), res: res}
    end

    # Determines the width of an 8-bit character string.
    #
    # ###Arguments
    # - **string** Specifies the character string.
    #
    # ###See also
    # `text_width_16`, `Display::load_font`, `text_extents`.
    def text_width(string : String) : Int32
      X.text_width @font_struct, string.to_unsafe, string.size
    end

    # Determines the width of an 16-bit character string.
    #
    # ###Arguments
    # - **string** Specifies the character string.
    #
    # ###See also
    # `text_width`, `Display::load_font`, `text_extents`.
    def text_width_16(string : Array(X11::C::X::Char2b)) : Int32
      X.text_width_16 @font_struct, string.to_unsafe, string.size
    end

    def to_unsafe : X11::C::X::PFontStruct
      @font_struct
    end

    def to_x : X11::C::X::FontStruct
      @font_struct.value
    end
  end
end
