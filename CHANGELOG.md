# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [1.1.1] - 2022-10-29
### Fixed
- `Display::grab_button` typo in variable name

## [1.1.0] - 2022-08-06
### Added
- `Image::to_unsafe`
### Fixed
- `Display::change_window_attributes` undefined variable name
- `Image::finalize` invalid pointer
### Changed
- **(breaking change)** `X11::C::Char` renamed to `X11::C::CChar` (#15)
- Window Attribute contants changed to `UInt64`

## [1.0.1] - 2021-09-06
### Fixed
- `Display::change_property` (#7, thanks @cmizzi)

## [1.0.0] - 2021-04-10
- Updated to Crystal 1.0.0
### Fixed
- Drawing functions

## [0.3.2] - 2020-10-30
### Fixed
- `Display::close` - check already closed
### Updated
- examples
- README.md - using examples

## [0.3.1] - 2018-01-20
### Fixed
- `Display::default_visual` wrong arguments.
- `Display::set_foreground` erroneous assignment statement. (#5, thanks @t-richards)

## [0.3.0] - 2017-08-09
### Added
- High level classes and structs
- [Example](/examples/sample_window_hl) for using high level x11
### Changed
- **(breaking change)** Low level binding moved to **C** namespace
### Fixed
- Some typos in `/c/Xlib.cr`

## [0.2.1] - 2017-07-13
### Added
- Crystal app structure for sample
- CHANGELOG.md
- .github/CODE_OF_CONDUCT.md
- .github/CONTRIBUTING.md
### Changed
- reformat code
- move sample to /examples folder
### Updated
- README.md
- shard.yml (version)
- .editorconfig

## [0.2.0] - 2017-05-17
### Added
- .travis.yml
- image for sample
### Updated
- README.md

## [0.1.0] - 2016-10-06
- First release
