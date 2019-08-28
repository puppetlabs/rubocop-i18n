# frozen_string_literal: true

def investigate(cop, src, filename = nil)
  processed_source = RuboCop::ProcessedSource.new(src, RUBY_VERSION.to_f, filename)
  commissioner = RuboCop::Cop::Commissioner.new([cop], [], raise_error: true)
  commissioner.investigate(processed_source)
  commissioner
end
