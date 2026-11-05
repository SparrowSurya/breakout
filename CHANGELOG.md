# Changelog

## Unreleased

### Fixed GameoverMenu - (5 Nov, 2026)
* Modified z-index to 30.
* Renamed some nodes.

### Added common EndMenu - (4 Nov, 2026)
* Added common EndMenu for game modes having win and lose menus.
* Integrated EndMenu in quick and levels mode.

### Added common PauseMenu - (4 Nov, 2026)
* Added and integrated common PauseMenu for all game modes.
* Deleted previous pause_menu scene and script files.

### Added SoundMenu - (4 Nov, 2026)
* Added SoundMenu
* Integrated SoundMenu to MainMenu

### Modified CustomSpinbox and CustomSwitchButton - (4 Nov, 2026)
* Clicking on individual level indicator also changes the value.
* Adding correct texture for on and off state of switch.

### Added CustomSwitchButton - (4 Nov, 2026)
* Added new scene for switch button.
* Added its script.
* Added textures.

### Added CustomSpinbox - (3 Nov, 2026)
* Added new scene for spinbox.
* Added its script.
* Added few icons.

### Bugfixes - (3 Nov, 2026)
* Preventing any powerup being carried on to next stage or after losing last ball.
* Multiball 1+ ball collission fix.
* Multiball no spawn balls with more damage than normal ball.
* Reviavl now drop more frequqne and granteed after few stages.
* Reduced the witing time and min tile hit to spawn powerup.
* Every 3rd combo spawns a new powerup.
* Randomised speed of falling powerup.
* Added more formations.
* THe new layouts now have wide range of dimensions.
* Changed backgroud of survival mode.

### Improved powerup - (1 Nov, 2026)
* Fixed glitches and powerup bugs.
* Added sounds effects to the powerup collecting adn expire sound.

### Added powerups - (31 Oct, 2026)
* Added powerups related assets.
* Implemented and integrated powerups to survival mode.

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
