.SILENT: run

PRODUCT_NAME := NEditor

init:
	@mint bootstrap
	$(MAKE) xcproj

xcproj:
	@mint run xcodegen xcodegen generate
	@xed .

xcproj-quiet:
	@mint run xcodegen xcodegen generate --use-cache --quiet

build: xcproj-quiet
	@xcrun xcodebuild -configuration Debug build | xcpretty

test: xcproj-quiet
	@xcrun xcodebuild -scheme ${PRODUCT_NAME} test | xcpretty

run: build
	@open build/Debug/${PRODUCT_NAME}.app
