# upml Makefile

PKG_NAME=upml
PKG_VERSION=$(shell cat VERSION)
BUILD_DIR=$(PKG_NAME)-deb-build
OUTPUT_DEB=${PKG_NAME}_${PKG_VERSION}_all.deb
RELEASE_DIR=releases

all: help

help:
	@echo ""
	@echo "Available targets:"
	@echo "  make clean      - Clean previous builds"
	@echo "  make build        - Build the .deb package"
	@echo "  make release    - Build and move the .deb to the releases/ folder"
	@echo ""

clean:
	@echo "Cleaning previous builds..."
	@rm -rf $(BUILD_DIR) $(PKG_NAME)_*.deb $(RELEASE_DIR)
	@echo "Cleaned."

build: clean
	@echo "Building .deb package..."
	@rm -rf $(BUILD_DIR)
	@mkdir -p $(BUILD_DIR)/DEBIAN
	@mkdir -p $(BUILD_DIR)/usr/local/bin
	@mkdir -p $(BUILD_DIR)/etc
	@mkdir -p $(BUILD_DIR)/var/log/upml
	@mkdir -p $(BUILD_DIR)/etc/bash_completion.d
	@echo "Package: $(PKG_NAME)" > $(BUILD_DIR)/DEBIAN/control
	@echo "Version: $(PKG_VERSION)" >> $(BUILD_DIR)/DEBIAN/control
	@echo "Section: admin" >> $(BUILD_DIR)/DEBIAN/control
	@echo "Priority: optional" >> $(BUILD_DIR)/DEBIAN/control
	@echo "Architecture: all" >> $(BUILD_DIR)/DEBIAN/control
	@echo "Depends: bash, curl, deborphan" >> $(BUILD_DIR)/DEBIAN/control
	@echo "Maintainer: Iolar Demartini Junior <iolardemartini@gmail.com>" >> $(BUILD_DIR)/DEBIAN/control
	@echo "Description: Bash script for secure and efficient Ubuntu server maintenance with full automation and real-time monitoring." >> $(BUILD_DIR)/DEBIAN/control
	@cp upml.sh $(BUILD_DIR)/usr/local/bin/upml
	@cp scripts/upml_completion.sh $(BUILD_DIR)/etc/bash_completion.d/upml
	@echo 'DISCORD_WEBHOOK=""' > $(BUILD_DIR)/etc/upml.conf
	@echo 'LOG_DIR="/var/log/upml"' >> $(BUILD_DIR)/etc/upml.conf
	@chmod 755 $(BUILD_DIR)/usr/local/bin/upml
	@chmod 644 $(BUILD_DIR)/etc/upml.conf
	@chmod 644 $(BUILD_DIR)/etc/bash_completion.d/upml
	@dpkg-deb --build --root-owner-group $(BUILD_DIR)
	@mv $(BUILD_DIR).deb $(OUTPUT_DEB)
	@echo ".deb package created: $(OUTPUT_DEB)"

release: build
	@echo "Preparing release..."
	@mkdir -p $(RELEASE_DIR)
	@mv $(OUTPUT_DEB) $(RELEASE_DIR)/
	@echo "Release package moved to $(RELEASE_DIR)/"
