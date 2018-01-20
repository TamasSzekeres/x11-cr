# x11-cr

X11 bindings for Crystal language.

[![Build Status](https://travis-ci.org/TamasSzekeres/x11-cr.svg?branch=master)](https://travis-ci.org/TamasSzekeres/x11-cr)
[![Dependency Status](https://shards.rocks/badge/github/TamasSzekeres/x11-cr/status.svg)](https://shards.rocks/github/TamasSzekeres/x11-cr)
[![devDependency Status](https://shards.rocks/badge/github/TamasSzekeres/x11-cr/dev_status.svg)](https://shards.rocks/github/TamasSzekeres/x11-cr)

## Installation


Add this to your application's `shard.yml`:

```yaml
dependencies:
  x11:
    github: TamasSzekeres/x11-cr
```

Then run in terminal:
```bash
crystal deps
```

## Usage


```crystal
require "x11"

module YourModule
  include X11 # For simpler use
end
```

For more details see the examples in [/examples](/examples) folder.

## Samples

Build and run the low-level sample:
```shell
  cd examples/sample_window
  crystal deps
  make
  ./sample_window
```
![Sample Window](https://raw.githubusercontent.com/TamasSzekeres/x11-cr/master/examples/sample_window/screenshot/sample_window.png)


Build and run the high-level sample:
```shell
  cd examples/sample_window_hl
  crystal deps
  make
  ./sample_window_hl
```

## Documentation

You can generate documentation for yourself:
```shell
crystal doc
```
Then you can open `/doc/index.html` in your browser.

Or you can view last commited documentation online at: [https://tamasszekeres.github.io/x11-cr/](https://tamasszekeres.github.io/x11-cr/).

## Contributing

1. Fork it ( https://github.com/TamasSzekeres/x11-cr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [TamasSzekeres](https://github.com/TamasSzekeres) Tamás Szekeres - creator, maintainer
