# frozen_string_literal: true

require 'rubocop/cop/i18n'
require 'rubocop/rspec/cop_helper'
require 'shared_examples'
require 'shared_functions'

RSpec.configure do |config|
  # These two settings work together to allow you to limit a spec run
  # to individual examples or groups you care about by tagging them with
  # `:focus` metadata. When nothing is tagged with `:focus`, all examples
  # get run.
  unless defined?(::TestQueue)
    # See. https://github.com/tmm1/test-queue/issues/60#issuecomment-281948929
    config.filter_run :focus
    config.run_all_when_everything_filtered = true
  end

  config.example_status_persistence_file_path = 'spec/examples.txt'

  config.order = :random
  Kernel.srand config.seed

  broken_filter = lambda do |v|
    v.is_a?(Symbol) ? RUBY_ENGINE == v.to_s : v
  end
  config.filter_run_excluding broken: broken_filter

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    expectations.syntax = :expect # Disable `should`
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect # Disable `should_receive` and `stub`
    mocks.verify_partial_doubles = true
  end
end
