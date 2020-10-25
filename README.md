# Rubocop::I18n

[![Build Status](https://travis-ci.org/puppetlabs/rubocop-i18n.svg?branch=master)](https://travis-ci.org/puppetlabs/rubocop-i18n)

A set of cops for detecting strings that need i18n decoration in your project.

Supports the following framework styles:

- gettext
- rails-i18n

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rubocop-i18n'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rubocop-i18n

## Usage

In your `rubocop.yml`:
```
require:
 - rubocop-i18n
...
# You *must* choose GetText or Rails-i18n style checking
# If you want GetText-style checking
I18n/GetText:
  Enabled: true
I18n/RailsI18n:
  Enabled: false
# If you want rails-i18n-style checking
I18n/RailsI18n:
  Enabled: true
I18n/GetText:
  Enabled: false
# If you want custom control of all the cops
I18n/GetText/DecorateString:
  Enabled: false
  # Disable the autocorrect
  AutoCorrect: false
I18n/GetText/DecorateFunctionMessage:
  Enabled: false
I18n/GetText/DecorateStringFormattingUsingInterpolation:
  Enabled: false
I18n/GetText/DecorateStringFormattingUsingPercent:
  Enabled: false
I18n/RailsI18n/DecorateString:
  Enabled: false
```

## Cops

### I18n/GetText/DecorateString

This cop is looks for strings that appear to be sentences but are not decorated. 
Sentences are determined by the STRING_REGEXP.

##### Error message thrown

```
decorator is missing around sentence
```

##### Bad

``` ruby
"Result is bad."
```

##### Good

``` ruby
_("Result is good.")
```

##### Ignored
``` ruby
"string"
"A string with out a punctuation at the end"
"a string that doesn't start with a capital letter."
```

### I18n/GetText/DecorateFunctionMessage

This cop looks for any raise or fail functions and checks that the user visible message is using gettext decoration with the _() function.
This cop makes sure the message is decorated, as well as checking that the formatting of the message is compliant according to the follow rules.
This cop supports autocorrecting of [Simple decoration of a message](#Simple-decoration-of-a-message). See the rubocop documentation on how to run autocorrect.

#### Simple decoration of a message

Simple message strings should be decorated with the _() function

##### Error message thrown

```
'raise' function, message string should be decorated
```

##### Bad

``` ruby
raise("Warning")
```

##### Good

``` ruby
raise(_("Warning"))
```

#### Multi-line message

The message should not span multiple lines, it causes issues during the translation process.

##### Error message thrown

```
'raise' function, message should not be a multi-line string
```

##### Bad

``` ruby
raise("this is a multi" \
"line message")
```

##### Good

``` ruby
raise(_("this is a multi line message"))
```

#### Concatenated message

The message should not concatenate multiple strings, it causes issues during translation and with the gettext.

##### Error message thrown

```
'raise' function, message should not be a concatenated string
```

##### Bad

``` ruby
raise("this is a concatenated" + "message")
```

##### Good

``` ruby
raise(_("this is a concatenated message"))
```

#### Interpolated message

The message should be formated in this particular style. Otherwise it causes issues during translation and with the gettext gem.

##### Error message thrown

```
'raise' function, message should use correctly formatted interpolation
```

##### Bad

``` ruby
raise("this is an interpolated message IE #{variable}")
```

##### Good

``` ruby
raise(_("this is an interpolated message IE %{value0}") % {value0: var,})
```

#### No decoration and no string detected

The raise or fail function does not contain any decoration, or a simple string

##### Error message thrown

```
'raise' function, message should be decorated
```

##### Bad

``` ruby
raise(someOtherFuntioncall(foo, "bar"))
```

##### Good

In this raise or fail function, the message does not contain any decoration at all and the message is not a simple string. It may make sense to convert the message to a simple string. eg [Simple decoration of a message](#Simple-decoration-of-a-message). 
Or ignore this raise or fail function following this [How to ignore rules in code](#How-to-ignore-rules-in-code) section.

### I18n/GetText/DecorateStringFormattingUsingInterpolation

This cop looks for decorated gettext methods _() and checks that all strings contained
within do not use string interpolation '#{}'

#### Simple decoration of a message

Simple message strings should be decorated with the _() function

##### Error message thrown

```
'_' function, message string should not contain #{} formatting
```

##### Bad

``` ruby
puts _("a message with a #{'interpolation'}")
```

##### Good

``` ruby
puts _("a message that is %{type}") % { type: 'translatable' }
```

### I18n/GetText/DecorateStringFormattingUsingPercent

This cop looks for decorated gettext methods _() and checks that all strings contained
within do not use sprintf formatting '%s' etc

##### Error message thrown

```
'_' function, message string should not contain sprintf style formatting (ie %s)
```

##### Bad

``` ruby
raise(_("Warning is %s") % ['bad'])
```

##### Good

``` ruby
raise(_("Warning is %{value}") % { value: 'bad' })
```

### I18n/RailsI18n/DecorateString

This cop looks for decorated rails-i18n methods.

##### Error message thrown

```
decorator is missing around sentence
```

##### Bad

``` ruby
raise("Warning is %s" % ['bad'])
```

##### Good

``` ruby
raise(t("Warning is %{value}") % { value: 'good' })
raise(translate("Warning is %{value}") % { value: 'good' })
raise(I18n.t("Warning is %{value}") % { value: 'good' })
```

### I18n/RailsI18n/DecorateStringFormattingUsingInterpolation

This cop looks for decorated rails-i18n methods like `t()` and `translate()` and checks that all strings contained
within do not use string interpolation '#{}'

#### Simple decoration of a message

Simple message strings should be decorated with the t() function

##### Error message thrown

```
't' function, message key string should not contain #{} formatting
```

##### Bad

``` ruby
puts t("path.to.key.with.#{'interpolation'}")
```

##### Good

``` ruby
puts t("path.to.key.with.interpolation")
```

## How to ignore rules in code

It may be necessary to ignore a cop for a particular piece of code. We follow standard rubocop idioms.
``` ruby
raise("We don't want this translated.")                 # rubocop:disable I18n/GetText/DecorateString
raise("We don't want this translated.")                 # rubocop:disable I18n/RailsI18n/DecorateString
raise("We don't want this translated")                  # rubocop:disable I18n/GetText/DecorateFunctionMessage
raise(_("We don't want this translated #{crazy}")       # rubocop:disable I18n/GetText/DecorateStringFormattingUsingInterpolation)
raise(_("We don't want this translated %s") % ['crazy'] # rubocop:disable I18n/GetText/DecorateStringFormattingUsingPercent)
```

## Known Issues

Rubocop currently does not detect Heredoc style messages in functions correctly, which in turn prevents this plugin from detecting them correctly.
Not all sprintf formatting strings are detected.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that allows you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which creates a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/puppetlabs/rubocop-i18n. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

