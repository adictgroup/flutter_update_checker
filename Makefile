format: 
	@dart format .

fix:
	@dart fix --apply

fix_dry:
	@dart fix --dry-run

publish_dry:
	@dart pub global activate pana
	@dart pub global run pana
	@dart pub publish --dry-run

publish:
	@dart pub publish