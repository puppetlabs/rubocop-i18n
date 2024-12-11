# frozen_string_literal: true

def investigate(cop, src, filename = nil)
  processed_source = RuboCop::ProcessedSource.new(src, RUBY_VERSION.to_f, filename)
  team = RuboCop::Cop::Team.new([cop], configuration, raise_error: true)
  report = team.investigate(processed_source)
  report.offenses
end
