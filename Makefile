# ==============================================================================
# Breakout Makefile - Web Export & Build Automation
# ==============================================================================

GODOT ?= godot
BUILD_DIR ?= build
WEB_DIR ?= $(BUILD_DIR)/web

# Extract semver directly from Constants.gd
VERSION := $(shell python3 -c "import re; f=open('src/core/constants.gd').read(); print('.'.join(re.findall(r'const VERSION_(?:MAJOR|MINOR|PATCH):\s*int\s*=\s*(\d+)', f)))" 2>/dev/null || echo "0.1.0")
PROJECT_NAME := Breakout
ZIP_NAME := $(PROJECT_NAME)-Web-v$(VERSION).zip

.PHONY: all help export-web build-web server-web clean-web clean-build

all: build-web

help:
	@echo "Available commands:"
	@echo "  make export-web   - Export Godot project to Web ($(WEB_DIR))"
	@echo "  make build-web    - Export Web and package into $(BUILD_DIR)/$(ZIP_NAME)"
	@echo "  make server-web   - Host $(WEB_DIR) locally via python3 http.server on port 8000"
	@echo "  make clean-web    - Remove $(WEB_DIR) directory"
	@echo "  make clean-build  - Remove entire $(BUILD_DIR) directory"

export-web:
	@echo "==> Exporting Web release..."
	@mkdir -p $(WEB_DIR)
	$(GODOT) --headless --export-release "Web" $(WEB_DIR)/index.html
	@echo "==> Web export completed in $(WEB_DIR)/"

build-web: export-web
	@echo "==> Packaging Web build into $(BUILD_DIR)/$(ZIP_NAME)..."
	@cd $(WEB_DIR) && rm -f ../$(ZIP_NAME) && zip -q -r ../$(ZIP_NAME) .
	@echo "==> Package created: $(BUILD_DIR)/$(ZIP_NAME)"

server-web:
	@which python3 > /dev/null 2>&1 || (echo "Error: python3 is required but not found in PATH." && exit 1)
	@if [ ! -f $(WEB_DIR)/index.html ]; then \
		echo "Web build not found in $(WEB_DIR). Running 'make export-web' first..."; \
		$(MAKE) export-web; \
	fi
	@echo "Serving $(WEB_DIR) on http://localhost:8000 (Press Ctrl+C to stop)..."
	python3 -m http.server -d $(WEB_DIR) 8000

clean-web:
	@echo "==> Cleaning $(WEB_DIR)..."
	@rm -rf $(WEB_DIR)
	@echo "==> Web directory removed."

clean-build:
	@echo "==> Cleaning $(BUILD_DIR)..."
	@rm -rf $(BUILD_DIR)
	@echo "==> Build directory removed."
