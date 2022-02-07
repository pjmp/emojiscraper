build: clean
	dart run build_runner build --delete-conflicting-outputs
	dart compile exe bin/emojiscraper.dart

clean:
	if [ -f bin/emojiscraper.exe ]; then rm bin/emojiscraper.exe; fi;
	dart run build_runner clean

publish: clean build
	pub publish

run:
	dart run build_runner run --delete-conflicting-outputs bin/emojiscraper.dart -- $(filter-out $@,$(MAKECMDGOALS))
