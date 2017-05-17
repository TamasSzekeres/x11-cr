# x11-cr

X11 bindings for Crystal language.

[![Build Status](https://travis-ci.org/TamasSzekeres/x11-cr.svg?branch=master)](https://travis-ci.org/TamasSzekeres/x11-cr)

## Installation


Add this to your application's `shard.yml`:

```yaml
dependencies:
  x11-cr:
    github: TamasSzekeres/x11-cr
```

Then run in terminal:
```bash
crystal deps
```

## Usage


```crystal
require "./x11-cr/*"

module YourModule
  include X11 # For simpler use
end
```

For more details see the sample in [/sample](/sample) folder.

## Sample

Build and run the sample:
```bash
  mkdir bin
  crystal build -o bin/sample sample/simple_window.cr --release
  ./bin/sample

```
![Simple Window](https://raw.githubusercontent.com/TamasSzekeres/x11-cr/master/sample/simple-window.png)

## Contributing

1. Fork it ( https://github.com/TamasSzekeres/x11-cr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [TamasSzekeres](https://github.com/TamasSzekeres) Tamás Szekeres - creator, maintainer
