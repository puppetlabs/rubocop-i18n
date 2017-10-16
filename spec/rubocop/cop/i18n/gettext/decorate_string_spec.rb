# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::I18n::GetText::DecorateString do
  let(:config) { RuboCop::Config.new }
  subject(:cop) { described_class.new(config) }

  context 'undecorated string' do
    let(:source) do
      <<-RUBY
        "a string"
      RUBY
    end

    it 'rejects' do
      investigate(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses[0].message).to match(/decorator is missing around sentence/)
    end
  end
end
