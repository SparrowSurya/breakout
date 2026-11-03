# ==============================================================================
# Breakout Makefile - Multi-Platform Export (Itch.io, YouTube Playables & Android)
# ==============================================================================

GODOT ?= godot
BUILD_DIR ?= build

ITCH_DIR ?= $(BUILD_DIR)/itch
YT_DIR ?= $(BUILD_DIR)/youtube
ANDROID_DIR ?= $(BUILD_DIR)/android

# Extract semver from project.godot
VERSION := $(shell python3 -c "import re; f=open('project.godot').read(); m=re.search(r'config/version=\"([^\"]+)\"', f); print(m.group(1) if m else '0.1.0')" 2>/dev/null || echo "0.1.0")
PROJECT_NAME := Breakout

ITCH_ZIP := $(PROJECT_NAME)-Itch-v$(VERSION).zip
YT_ZIP := $(PROJECT_NAME)-YouTube-v$(VERSION).zip
ANDROID_APK := $(PROJECT_NAME)-v$(VERSION).apk

# Release mode configuration (default: true)
RELEASE ?= true
ifeq ($(filter 0 false FALSE False NO no,$(RELEASE)),)
  EXPORT_FLAG := --export-release
  BUILD_TYPE := release
else
  EXPORT_FLAG := --export-debug
  BUILD_TYPE := debug
endif

.PHONY: all help build-all build-itch build-yt build-android export-itch export-yt export-android server-itch server-yt clean clean-itch clean-yt clean-android

all: build-all

help:
	@echo "Available commands:"
	@echo "  make build-all       - Export and package both Itch.io and YouTube Playables builds"
	@echo "  make build-itch      - Export and zip for Itch.io ($(BUILD_DIR)/$(ITCH_ZIP))"
	@echo "  make build-yt        - Export and zip for YouTube Playables ($(BUILD_DIR)/$(YT_ZIP))"
	@echo "  make build-android   - Export and package Android APK ($(BUILD_DIR)/$(ANDROID_APK))"
	@echo "  make export-itch     - Export Itch.io Web files to $(ITCH_DIR)/"
	@echo "  make export-yt       - Export YouTube Web files to $(YT_DIR)/"
	@echo "  make export-android  - Export Android APK to $(ANDROID_DIR)/breakout.apk"
	@echo "  make server-itch     - Host Itch build locally on http://localhost:8000"
	@echo "  make server-yt       - Host YouTube build locally on http://localhost:8000"
	@echo "  make clean           - Remove entire $(BUILD_DIR) directory"
	@echo "  make clean-android   - Remove Android output from $(BUILD_DIR)"
	@echo ""
	@echo "Options:"
	@echo "  RELEASE=false        - Build in debug mode (--export-debug) instead of release (--export-release)"

# ------------------------------------------------------------------------------
# Itch.io Target
# ------------------------------------------------------------------------------
export-itch:
	@echo "==> Exporting Web (Itch.io preset) [$(BUILD_TYPE)]..."
	@mkdir -p $(ITCH_DIR)
	$(GODOT) --headless $(EXPORT_FLAG) "itch" $(ITCH_DIR)/index.html
	@echo "==> Itch export completed in $(ITCH_DIR)/"

build-itch: export-itch
	@echo "==> Packaging Itch build into $(BUILD_DIR)/$(ITCH_ZIP)..."
	@cd $(ITCH_DIR) && rm -f ../$(ITCH_ZIP) && zip -q -r ../$(ITCH_ZIP) .
	@echo "==> Itch package created: $(BUILD_DIR)/$(ITCH_ZIP)"

# ------------------------------------------------------------------------------
# YouTube Playables Target
# ------------------------------------------------------------------------------
export-yt:
	@echo "==> Exporting Web (YouTube preset) [$(BUILD_TYPE)]..."
	@mkdir -p $(YT_DIR)
	$(GODOT) --headless $(EXPORT_FLAG) "youtube" $(YT_DIR)/index.html
	@# Ensure the JS SDK connector is included in the output directory
	@if [ -f yt_game_sdk.js ]; then cp yt_game_sdk.js $(YT_DIR); fi
	@echo "==> YouTube export completed in $(YT_DIR)/"

build-yt: export-yt
	@echo "==> Packaging YouTube build into $(BUILD_DIR)/$(YT_ZIP)..."
	@cd $(YT_DIR) && rm -f ../$(YT_ZIP) && zip -q -r ../$(YT_ZIP) .
	@echo "==> YouTube package created: $(BUILD_DIR)/$(YT_ZIP)"

# ------------------------------------------------------------------------------
# Android Target
# ------------------------------------------------------------------------------
export-android:
	@echo "==> Exporting Android APK [$(BUILD_TYPE)]..."
	@mkdir -p $(ANDROID_DIR)
	$(GODOT) --headless $(EXPORT_FLAG) "Android" $(ANDROID_DIR)/breakout.apk
	@echo "==> Android export completed in $(ANDROID_DIR)/breakout.apk"

build-android: export-android
	@echo "==> Packaging Android build into $(BUILD_DIR)/$(ANDROID_APK)..."
	@cp $(ANDROID_DIR)/breakout.apk $(BUILD_DIR)/$(ANDROID_APK)
	@echo "==> Android package created: $(BUILD_DIR)/$(ANDROID_APK)"

# ------------------------------------------------------------------------------
# Build Both Web Targets
# ------------------------------------------------------------------------------
build-all: build-itch build-yt
	@echo "==> Both builds completed successfully in $(BUILD_DIR)/"

# ------------------------------------------------------------------------------
# Local Testing Servers
# ------------------------------------------------------------------------------
server-itch:
	@if [ ! -f $(ITCH_DIR)/index.html ]; then $(MAKE) export-itch; fi
	python3 scripts/server.py $(ITCH_DIR) 8000

server-yt:
	@if [ ! -f $(YT_DIR)/index.html ]; then $(MAKE) export-yt; fi
	python3 scripts/server.py $(YT_DIR) 8000

# ------------------------------------------------------------------------------
# Cleanup
# ------------------------------------------------------------------------------
clean-itch:
	@rm -rf $(ITCH_DIR) $(BUILD_DIR)/$(ITCH_ZIP)

clean-yt:
	@rm -rf $(YT_DIR) $(BUILD_DIR)/$(YT_ZIP)

clean-android:
	@rm -rf $(ANDROID_DIR) $(BUILD_DIR)/$(PROJECT_NAME)-v*.apk

clean:
	@echo "==> Cleaning $(BUILD_DIR)..."
	@rm -rf $(BUILD_DIR)
	@echo "==> Build directory removed."
