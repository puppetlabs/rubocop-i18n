# frozen_string_literal: true
require 'spec_helper'

describe RuboCop::Cop::I18n::GetText::DecorateFunctionMessage do
  let(:config) { RuboCop::Config.new }
  subject(:cop) { described_class.new(config) }
  before(:each) {
    investigate(cop, source)
  }

  functions = ['fail', 'raise']
  functions.each do |function|
    context "#{function} undecorated double-quote message" do
      let(:source) { "#{function} \"a string\"" }

      it 'has the correct message' do
        expect(cop.offenses[0]).not_to be_nil
        expect(cop.offenses[0].message).to match(/should have a decorator around the message/)
      end

      it 'has the correct offenses' do
        expect(cop.offenses.size).to eq(1)
      end

      it 'autocorrects' do
        corrected = autocorrect_source("#{function}(\"a string\")")
        expect(corrected).to eq("#{function}(_(\"a string\"))")
      end
    end

    context "#{function} undecorated single-quoted message" do
      let(:source) { "#{function} 'a string'" }

      it 'has the correct message' do
        expect(cop.offenses[0]).not_to be_nil
        expect(cop.offenses[0].message).to match(/should have a decorator around the message/)
      end

      it 'has the correct offenses' do
        expect(cop.offenses.size).to eq(1)
      end

      it 'autocorrects' do
        corrected = autocorrect_source("#{function}('a string')")
        expect(corrected).to eq("#{function}(_('a string'))")
      end
    end

    context "#{function} undecorated constant & message" do
      let(:source) { "#{function} CONSTANT, 'a string'" }

      it 'has the correct message' do
        expect(cop.offenses[0]).not_to be_nil
        expect(cop.offenses[0].message).to match(/should have a decorator around the message/)
      end

      it 'has the correct offenses' do
        expect(cop.offenses.size).to eq(1)
      end

      it 'autocorrects' do
        corrected = autocorrect_source("#{function}(CONSTANT, 'a string')")
        expect(corrected).to eq("#{function}(CONSTANT, _('a string'))")
      end
    end

    context "#{function} multiline message", broken: true do
      let(:source) { "#{function} 'multi '\\ 'line'"}
      it 'rejects' do
        expect(cop.offenses[0]).not_to be_nil
        expect(cop.offenses[0].message).to match(/should not use a multi-line string/)
      end

      it 'has the correct offenses' do
        expect(cop.offenses.size).to eq(1)
      end
    end

    context "#{function} heredoc message", broken: true do
      let(:source) { <<-RUBY
#{function} <<-ERROR
this
is
a
string
ERROR
RUBY
      }

      it 'rejects' do
        expect(cop.offenses[0]).not_to be_nil
        expect(cop.offenses[0].message).to match(/should not use a multi-line string/)
      end

      it 'has the correct offenses' do
        expect(cop.offenses.size).to eq(1)
      end
    end

    context "#{function} concatenated message" do
      let(:source) { "fail 'this' + 'string' + 'is' + 'concatenated'"}

      it 'rejects' do
        expect(cop.offenses[0]).not_to be_nil
        expect(cop.offenses[0].message).to match(/should not use a concatenated string/)
      end

      it 'has the correct offenses' do
        expect(cop.offenses.size).to eq(1)
      end
    end

    context "#{function} interpolated string" do
      let(:source) { "#{function} \"this string has a \#{var}\""}

      it 'rejects' do
        expect(cop.offenses[0]).not_to be_nil
        expect(cop.offenses[0].message).to match(/interpolation is a sin/)
      end

      it 'has the correct offenses' do
        expect(cop.offenses.size).to eq(1)
      end

      it 'autocorrects' do
        corrected = autocorrect_source("#{function}(\"a string \#{var}\")")
        expect(corrected).to eq("#{function}(_(\"a string %{value0}\") % { value0: var, })")

  #      corrected = autocorrect_source('raise(Puppet::ParseError, "mysql_password(): Wrong number of arguments given (#{args.size} for 1)")')
  #      expect(corrected).to eq('raise(Puppet::ParseError, _("mysql_password(): Wrong number of arguments given (%{value0} for 1)") % { value0: args.size, })')
      end
    end
  end
end
