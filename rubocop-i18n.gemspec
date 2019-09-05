# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
rubocop_version = '~> 0.51'

Gem::Specification.new do |spec|
  spec.name          = 'rubocop-i18n'
  spec.version       = '2.0.1'
  spec.authors       = ['Puppet', 'Brandon High', 'TP Honey', 'Helen Campbell']
  spec.email         = ['team-modules@puppet.com', 'brandon.high@puppet.com', 'tp@puppet.com', 'helen@puppet.com']

  spec.summary       = 'RuboCop rules for i18n'
  spec.description   = 'RuboCop rules for detecting and autocorrecting undecorated strings for i18n (gettext and rails-i18n)'
  spec.homepage      = 'https://github.com/puppetlabs/rubocop-i18n'
  spec.license       = 'Apache-2.0'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.17.3'
  spec.add_development_dependency 'pry', '~> 0.12.2'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rb-readline', '~> 0.5.5'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', rubocop_version
  spec.add_runtime_dependency 'rubocop', rubocop_version
end
