require "./Xtos"

module X11
  # Xmd.cr: MACHINE DEPENDENT DECLARATIONS.

  # Special per-machine configuration flags.
  {% if flag?(:x86_64) %}
    # Stuff to handle large architecture machines; the constants were generated
    # on a 32-bit machine and must correspond to the protocol.
    MUSTCOPY = true;
  {% else %}
    MUSTCOPY = false
  {% end %}

  # Bitfield suffixes for the protocol structure elements, if you
  # need them.  Note that bitfields are not guaranteed to be signed
  # (or even unsigned) according to ANSI C.
  {% if LONG64 %}
    alias INT64 = Int64
    alias INT32 = Int32
  {% else %}
    alias INT32 = Int64
  {% end %}

  alias INT8 = Int8

  {% if LONG64 %}
    alias CARD64 = UInt64
    alias CARD32 = UInt32
  {% else %}
    alias CARD64 = UInt64
    alias CARD32 = UInt64
  {% end %}
  alias CARD16 = UInt16
  alias CARD8 = UInt8

  alias BITS32 = CARD32
  alias BITS16 = CARD16

  alias BYTE = CARD8
  alias BOOL = CARD8
end # module X11
