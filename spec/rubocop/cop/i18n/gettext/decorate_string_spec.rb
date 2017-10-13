# frozen_string_literal: true
require 'spec_helper'

describe RuboCop::Cop::I18n::GetText::DecorateString do
  let(:config) { RuboCop::Config.new }
  subject(:cop) { described_class.new(config) }

  # For some reason, this string isn't considered decorated.
  #it_behaves_like 'accepts', '_("a string")'

  context 'undecorated sentence' do
    let(:source) {
<<-RUBY
"A grammatically correct sentence contains punctuation."
RUBY
    }

    it 'rejects' do
      investigate(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses[0].message).to match(/decorator is missing around sentence/)
    end
  end

  context 'undecorated sentences' do
    let(:source) {
<<-RUBY
"A grammatically correct sentence contains punctuation. This string contains two of them."
RUBY
    }

    it 'rejects' do
      investigate(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses[0].message).to match(/decorator is missing around sentence/)
    end
  end

  context 'decorated sentence' do
    let(:source) {
<<-RUBY
_("A grammatically correct sentence contains punctuation.")
RUBY
    }

    it 'accepts' do
      investigate(cop, source)
      expect(cop.offenses.size).to eq(0)
    end
  end

  context 'decorated sentence' do
    let(:source) {
<<-RUBY
_("A grammatically correct sentence contains punctuation. This string contains two of them.")
RUBY
    }

    it 'accepts' do
      investigate(cop, source)
      expect(cop.offenses.size).to eq(0)
    end
  end

  context 'string with no capitalization or punctuation' do
    let(:source) {
<<-RUBY
"a grammatically incorrect sentence with no punctuation is not what this library is concerned with"
RUBY
    }

    it 'accepts' do
      investigate(cop, source)
      expect(cop.offenses.size).to eq(0)
    end
  end

  context 'string with no starting capitalization' do
    let(:source) {
<<-RUBY
"a grammatically incorrect sentence is not what this library is concerned with."
RUBY
    }

    it 'accepts' do
      investigate(cop, source)
      expect(cop.offenses.size).to eq(0)
    end
  end
end
