SHELL := /bin/bash
.SHELLFLAGS := -o pipefail -c
.SILENT:

INSTALLER_SIGN_IDENTITY := 21E03A44ACC2B48753BABB3DAE9B5F9A9CFF0480

lib:
	go run ./cmd/internal/build_libsharing

build_ios:
	xcodebuild build -skipMacroValidation -scheme ScreenSharingRemote -configuration Debug -destination 'generic/platform=iOS' | xcbeautify | grep -A 10 -e "Build Succeeded" -e "BUILD FAILED" -e "❌"

release_ios: lib archive_ios upload_ios

archive_ios:
	rm -rf build/ScreenSharingRemote-iOS.xcarchive
	xcodebuild archive -skipMacroValidation $(XCODEBUILD_FLAGS) -scheme ScreenSharingRemote -configuration Release -destination 'generic/platform=iOS' -archivePath build/ScreenSharingRemote-iOS.xcarchive | xcbeautify

upload_ios:
	xcodebuild -exportArchive -archivePath build/ScreenSharingRemote-iOS.xcarchive -exportOptionsPlist ScreenSharingRemote/Upload.plist

export_ios:
	rm -rf build/ScreenSharingRemote-iOS
	xcodebuild -exportArchive -archivePath build/ScreenSharingRemote-iOS.xcarchive -exportOptionsPlist ScreenSharingRemote/Export.plist -exportPath build/ScreenSharingRemote-iOS

build_ios_ipa: lib archive_ios_ipa

archive_ios_ipa:
	rm -rf build/ScreenSharingRemote-Sideload.xcarchive build/Payload build/ScreenSharingRemote.ipa
	xcodebuild archive -skipMacroValidation $(XCODEBUILD_FLAGS) -scheme ScreenSharingRemote -configuration Release -destination 'generic/platform=iOS' -archivePath build/ScreenSharingRemote-Sideload.xcarchive \
		CODE_SIGNING_ALLOWED=NO SWIFT_ACTIVE_COMPILATION_CONDITIONS=SIDELOAD APP_INFOPLIST_FILE=ScreenSharingRemote/Info-Server.plist EXCLUDED_SOURCE_FILE_NAMES='$$(SRCROOT)/ScreenSharingRemote/Demo/*.jpg' | xcbeautify
	mkdir build/Payload
	cp -R build/ScreenSharingRemote-Sideload.xcarchive/Products/Applications/Screen\ Sharing.app build/Payload/
	cd build && zip -qry ScreenSharingRemote.ipa Payload
	rm -rf build/Payload

.PHONY: screenshots
screenshots:
	go run ./cmd/internal/screenshots

build_macos:
	xcodebuild build -skipMacroValidation -scheme ScreenSharingRemote -configuration Debug -destination 'generic/platform=macOS' | xcbeautify | grep -A 10 -e "Build Succeeded" -e "BUILD FAILED" -e "❌"

release_macos: lib archive_macos export_macos build_macos_pkg notarize_macos_pkg

archive_macos:
	rm -rf build/ScreenSharingRemote-macOS.xcarchive
	xcodebuild archive -skipMacroValidation $(XCODEBUILD_FLAGS) -scheme ScreenSharingRemote -configuration Release -destination 'generic/platform=macOS' -archivePath build/ScreenSharingRemote-macOS.xcarchive | xcbeautify

export_macos:
	rm -rf build/ScreenSharingRemote-macOS
	xcodebuild -exportArchive -archivePath build/ScreenSharingRemote-macOS.xcarchive -exportOptionsPlist ScreenSharingRemote/ExportDeveloperID.plist -exportPath build/ScreenSharingRemote-macOS

build_macos_pkg:
	rm -rf build/pkgroot build/component.pkg build/ScreenSharingRemote.pkg
	mkdir -p build/pkgroot
	ditto "build/ScreenSharingRemote-macOS/Screen Sharing.app" "build/pkgroot/Screen Sharing.app"
	pkgbuild --root build/pkgroot \
		--component-plist ScreenSharingRemote/component.plist \
		--identifier app.screensharingremote.ios \
		--install-location /Applications \
		--min-os-version 14.0 \
		--compression latest \
		build/component.pkg
	productbuild --distribution ScreenSharingRemote/distribution.xml \
		--package-path build \
		--sign "$(INSTALLER_SIGN_IDENTITY)" \
		build/ScreenSharingRemote.pkg
	rm -rf build/pkgroot build/component.pkg

notarize_macos_pkg:
	xcrun notarytool submit build/ScreenSharingRemote.pkg --wait --keychain-profile "notarytool-password"
	xcrun stapler staple build/ScreenSharingRemote.pkg

fmt:
	gofumpt -l -w cmd libsharing internal
	go run ./cmd/internal/format_xcstrings $$(find ScreenSharingRemote -name '*.xcstrings')
