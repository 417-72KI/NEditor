.SILENT: run

init:
	mint bootstrap

run:
	xcrun xcodebuild -configuration Debug build | xcpretty
	open build/Debug/NEditor.app
