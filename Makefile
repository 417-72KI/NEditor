.SILENT: run

init:
	@mint bootstrap
	$(MAKE) xcodeproj

xcodeproj:
	@mint run xcodegen xcodegen generate --use-cache
	@open NEditor.xcodeproj

xcodeproj-quiet:
	@mint run xcodegen xcodegen generate --use-cache --quiet

build: xcodeproj-quiet
	@xcrun xcodebuild -configuration Debug build | xcpretty

run: build
	@open build/Debug/NEditor.app
