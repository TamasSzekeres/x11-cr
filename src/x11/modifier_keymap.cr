require "./c/Xlib"
require "./event"

module X11
  class ModifierKeymap
    getter modifier_keymap : X11::C::X::PModifierKeymap

    def initialize(@modifier_keymap : X11::C::X::PModifierKeymap)
      raise BadAllocException.new if @modifier_keymap.null?
    end

    # Creates a new `ModifierKeymap` structure.
    #
    # ###Arguments
    # - **max_keys_per_mod** Specifies the number of KeyCode entries preallocated to the modifiers in the map.
    #
    # ###See also
    # `Display::change_keyboard_mapping`, `delete_entry`, `Display::display_keycodes`,
    # `finalize`, `Display::keyboard_mapping`, `Display::modifier_mapping`,
    # `insert_entry`, `Display::set_modifier_mapping`, `Display::set_pointer_mapping`.
    def initialize(max_keys_per_mod : Int32)
      @modifier_keymap = X.new_modifier_map max_keys_per_mod
      raise BadAllocException.new if @modifier_keymap.null?
    end

    def finalize
      X.free_modifiermap @modifier_keymap
    end

    # Specifies the number of KeyCode entries preallocated to the modifiers in the map.
    def max_keys_per_mod : Int32
      @modifier_keymap.value.max_keys_per_mod
    end

    # Deletes the specified KeyCode from the set that controls the specified modifier.
    #
    # ###Arguments
    # - **keycode_entry** Specifies the KeyCode.
    # - **modifier** Specifies the modifier.
    #
    # ###Description
    # The `delete_entry` function deletes the specified KeyCode from the set that
    # controls the specified modifier and returns a pointer to the resulting `ModifierKeymap` structure.
    #
    # ###See also
    # `Display::change_keyboard_mapping`, `Display::display_keycodes`,
    # `finalize`, `Display::keyboard_mapping`, `Display::modifier_mapping`,
    # `insert_entry`, `new`, `Display::set_modifier_mapping`, `Display::set_pointer_mapping`.
    def delete_entry(entry : X11::C::KeyCode, modifier : Int32) : ModifierKeymap
      @modifier_keymap = X.delete_modifiermap_entry @modifier_keymap, entry, modifier
      self
    end

    # Adds the specified KeyCode to the set that controls the specified modifier.
    #
    # ###Arguments
    # - **keycode_entry** Specifies the KeyCode.
    # - **modifier** Specifies the modifier.
    #
    # ###Description
    # The `insert_entry` function adds the specified KeyCode to the set that controls
    # the specified modifier and returns the resulting `ModifierKeymap` structure (expanded as needed).
    #
    # ###See also
    # `Display::change_keyboard_mapping`, `delete_entry`, `Display::display_keycodes`,
    # `finalize`, `Display::keyboard_mapping`, `Display::modifier_mapping`,
    # `insert_entry`, `new`, `Display::set_modifier_mapping`, `Display::set_pointer_mapping`.
    def insert_entry(entry : X11::C::KeyCode, modifier : Int32) : ModifierKeymap
      @modifier_keymap = X.insert_modifier_entry @modifier_keymap, entry, modifier
      self
    end
  end
end
