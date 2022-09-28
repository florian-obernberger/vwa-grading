.PHONY: clean update format appimage split-apk bundle web

clean:
	@echo "╠ Cleaning the project..."
	@rm -rf pubspec.lock
	@rm -rf VwaGrading.AppDir/lib/ VwaGrading.AppDir/data/ VwaGrading.AppDir/vwa_grading VwaGrading.AppImage
	@flutter clean
	@flutter pub get

update:
	@echo "╠ Updating dependencies..."
	@flutter pub get
	@flutter pub upgrade

format:
	@echo "╠ Formatting the code..."
	@dart format .

web: | clean
	@echo "╠ Building web bundle..."
	@flutter build web --web-renderer html --profile --source-maps

appimage: | clean
	@echo "╠ Building AppImage..."
	@flutter build linux --release
	@cp -r build/linux/x64/release/bundle/* VwaGrading.AppDir
	@cp assets/icons/icon-1024x1024-squircle.png VwaGrading.AppDir/logo.png
	@appimagetool.AppImage VwaGrading.AppDir/ build/linux/x64/release/VwaGrading.AppImage

split-apk: | clean
	@echo "╠ Building Split APK..."
	@flutter build apk --split-per-abi

bundle: | clean
	@echo "╠ Building bundle..."
	@flutter build bundle
