module X11::C
  WORLD64 = false

  {% if flag?(:x86_64) %}
    LONG64 = true
  {% else %}
    LONG64 = false
  {% end %}
end # module X11
