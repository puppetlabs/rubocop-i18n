# Rubocop::I18n

A set of cops for detecting strings that need i18n decoration in your project.

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
GetText/DecorateString:
  Enabled: false
GetText/DecorateFunctionMessage:
  Enabled: true
```

## Cops
### GetText/DecorateFunctionMessage
This cop looks for any raise / fail functions and checks the user visible message is using gettext decoration with the _() function.
This cop will make sure the message is decorated as well as checking that the formatting of the message is compliant according to the follow rules.
This cop supports autocorrecting of [Simple decoration of a message](#Simple-decoration-of-a-message). See the rubocop documentation on how to run autocorrect.

#### Simple decoration of a message
All simple message strings for should be decorated thusly.
##### Error message thrown
```
'raise' function, message should be decorated
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
The message should not span multiple lines. This will cause issues when translating and with the gettext library.
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
The message should not concatenate multiple strings. This will cause issues in translation and with the gettext.
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
The message should be formated in a particular style. Otherwise this will cause issues in translation and with the gettext gem.
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

#### No decoration
The raise / fail function does not contain any decoration
##### Error message thrown
```
'raise' function, should have decoration around the message
```
##### Bad
``` ruby
raise(someOtherFuntioncall(foo, "bar"))
```
##### Good
Because the message does not contain any decoration or a simple message to decorate eg [Simple decoration of a message](#Simple-decoration-of-a-message) 
It may make mores sense to ignore decoration. Please refer to the [How to ignore rules in code](#How-to-ignore-rules-in-code) section.

## How to ignore rules in code
It may be necessary to ignore a cop for a particular piece of code. We follow standard rubocop idioms.
``` ruby
raise("We don't want this translated")  # rubocop:disable GetText/DecorateFunctionMessage 
```

## Known Issues

Heredoc style messages are not detected correctly by rubocop. This prevents this plugin from detecting them correctly.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/highb/rubocop-i18n. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

