# Changelog

## Unreleased

### Added transitions - (29 Oct, 2026)
* Added fade transition and integrated with existing navigation.

### Fixes - (29 Oct, 2026)
* Fixed issues in game during testing inside test environment.

### Added support for youtube playables - (29 Oct, 2026)
* Added new export preset for youttube playables (web).
* Added `yt_game_sdk.js` and `vendor/youtube` wrapper script.
* Integrated signals - `audio_enabled_changed`,`game_paused`,`game_resumed`,`save_data_success`,`save_data_failed`,`load_data_received`.
* Added Makefile. Also, an additional file needs to be copied directly which is included in `.pck` file if added ad resource.
* Added script for gzip based web server (for test_suite)

## Version 0.1.1 - (28 Oct, 2026)
Optimisations to enhance performance in mobile web.

### Modified - (28 Oct, 2026)
Scene `HitParticles.tscn` now extends from `CPUParticles2D`. Reducing GPU setup overhead just for duration less than a second.

### Modified - (28 Oct, 2026)
Converted `lavender_chillwave.wav` to `lavender_chillwave.ogg`. Optimised for less fie size reducing initial load time.

### Modified - (28 Oct, 2026)
Modified project settings and export settings.
* stretch_mode = viewport (project setting)
* canvas_resize_policy = adaptive (export setting fro web)

## Version 0.1.0 - 27 Oct, 2026
Initial release.
