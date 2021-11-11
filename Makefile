build: clean
	dart run build_runner build --delete-conflicting-outputs
	dart compile exe bin/emojiscraper.dart

clean:
	rm bin/emojiscraper.exe
	dart run build_runner clean

publish: clean build
	pub publish

run:
	dart run build_runner run --delete-conflicting-outputs bin/emojiscraper.dart -- $(filter-out $@,$(MAKECMDGOALS))
