# Change Log

### [master (Unreleased)](https://github.com/puppetlabs/rubocop-i18n/compare/v2.0.2...master)

### [2.0.2](https://github.com/puppetlabs/rubocop-i18n/compare/v2.0.1...v2.0.2)

* Add auto-correct for `DecorateString` (#40) Thanks @mvz!
* Update rake and bundler requirements to be more permissive of newer versions (#43)

### 2.0.1

* `chmod` all the files to be world readable and ensured that `gem
build` doesn't emit any warnings.
* fixes license name
* specifies version for pry and rb-readline
* bump Z version

### 2.0.0

* Add rails-i18n support and documentation in README. Thanks @kbacha!

### 1.3.1, 1.3.0, 1.2.0

 * Updated DecorateString to look for sentences using a regular expression that should be decorated. This limits the number of strings that it finds to things that look like a sentence.
 * Code restructure (no API changes)
 * RuboCop lint fixes

### 1.1.0

 * Added support for DecorateStringFormattingUsingPercent
 * Added support for DecorateStringFormattingUsingInterpolation

### 1.0.0

 * Improvements to DecorateFunctionMessage

### 0.0.1

 * Initial import of rubocop rules from https://github.com/tphoney/puppetlabs-mysql/tree/poc_i18nTesting/rubocop by [@tphoney]
