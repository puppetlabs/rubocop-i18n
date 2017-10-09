# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "rubocop-i18n"
  spec.version       = '1.1.0'
  spec.authors       = ["Brandon High", "TP Honey", "Helen Campbell"]
  spec.email         = ["brandon.high@puppet.com", "tp@puppet.com", "helen@puppet.com"]

  spec.summary       = %q{RuboCop rules for i18n}
  spec.description   = %q{RuboCop rules for detecting and autocorrecting undecorated strings for i18n}
  spec.homepage      = "https://github.com/puppetlabs/rubocop-i18n"
  spec.license       = 'Apache-2'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rb-readline"
  spec.add_development_dependency "pry"
  spec.add_runtime_dependency "rubocop", "~> 0.49"
end
