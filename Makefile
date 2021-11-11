build: clean
	dart run build_runner build --delete-conflicting-outputs

clean:
	rm bin/emojiscraper.exe
	dart run build_runner clean

publish: clean build
	pub publish

compile:
	dart compile exe bin/emojiscraper.dart

run:
	dart run build_runner run --delete-conflicting-outputs bin/emojiscraper.dart -- $(filter-out $@,$(MAKECMDGOALS))
