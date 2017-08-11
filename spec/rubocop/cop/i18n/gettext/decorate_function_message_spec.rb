# frozen_string_literal: true
require 'spec_helper'

describe RuboCop::Cop::I18n::GetText::DecorateFunctionMessage do
  let(:config) { RuboCop::Config.new }
  subject(:cop) { described_class.new(config) }

  it_behaves_like 'accepts', 'fail _("a string")'

  context 'undecorated string' do
    let(:source) { 'fail "a string"' }

    it 'rejects' do
      investigate(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses[0].message).to match(/should have a decorator around the message/)
    end
  end

  context 'multiline string' do
    let(:source) { <<-RUBY
fail <<-STR
  this
  is
  a
  string
STR
    RUBY
    }

    it 'rejects', broken: true do
      investigate(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses[0].message).to match(/should not use a multi-line string/)
    end
  end

  context 'concatenated string' do
    let(:source) { <<-RUBY
fail "this" + "string" + "is" + "concatenated"
    RUBY
    }

    it 'rejects' do
      investigate(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses[0].message).to match(/should not use a concatenated string/)
    end
  end

  context 'interpolated string' do
    let(:source) { <<-RUBY
var = "foo"
fail "this string has a \#{var}"
    RUBY
    }

    it 'rejects' do
      investigate(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses[0].message).to match(/interpolation is a sin/)
    end
  end

end
