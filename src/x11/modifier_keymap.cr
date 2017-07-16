require "./c/Xlib"

module X11
  class ModifierKeymap
    getter modifier_keymap : X11::C::X::PModifierKeymap

    def initialize(@modifier_keymap : X11::C::X::PModifierKeymap)
      raise BadAllocException.new if @modifier_keymap.null?
    end

    def initialize(max_keys_per_mod)
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
    def delete_entry(entry : X11::C::KeyCode, modifier : Int32) : ModifierKeymap
      @modifier_keymap = X.delete_modifiermap_entry @modifier_keymap, entry, modifier
      self
    end

    # Adds the specified KeyCode to the set that controls the specified modifier.
    def insert_entry(entry : X11::C::KeyCode, modifier : Int32) : ModifierKeymap
      @modifier_keymap = X.insert_modifier_entry @modifier_keymap, entry, modifier
      self
    end
  end
end
