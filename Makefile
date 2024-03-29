.PHONY: clean update format appimage split-apk bundle web webbundle

clean:
	@echo "╠ Cleaning the project..."
	@rm -rf pubspec.lock
	@rm -rf VwaGrading.AppDir/lib/ VwaGrading.AppDir/data/ VwaGrading.AppDir/vwa_grading build/release/VwaGrading.AppImage
	@flutter clean
	@flutter pub get

update:
	@echo "╠ Updating dependencies..."
	@flutter pub get
	@flutter pub upgrade

format:
	@echo "╠ Formatting the code..."
	@dart format .

web:
	@echo "╠ Building web..."
	@flutter build web --web-renderer html --no-tree-shake-icons

webbundle: | web
	@echo "╠ Creating web bundle..."
	@mkdir -rp build/release/
	@zip -j build/release/webrelease.zip build/web/*

appimage:
	@echo "╠ Building AppImage..."
	@flutter build linux --release --no-tree-shake-icons
	@rm -rf VwaGrading.AppDir/lib/ VwaGrading.AppDir/data/ VwaGrading.AppDir/vwa_grading build/release/VwaGrading.AppImage
	@cp -r build/linux/x64/release/bundle/* VwaGrading.AppDir
	@cp assets/icons/icon-1024x1024-squircle.png VwaGrading.AppDir/logo.png
	@mkdir -p build/release/
	@appimagetool.AppImage VwaGrading.AppDir/ build/release/VwaGrading.AppImage

split-apk:
	@echo "╠ Building Split APK..."
	@flutter build apk --split-per-abi --no-tree-shake-icons

apk:
	@echo "╠ Building APK..."
	@flutter build apk --no-tree-shake-icons

bundle:
	@echo "╠ Building bundle..."
	@flutter build bundle --no-tree-shake-icons

release: clean update webbundle appimage
