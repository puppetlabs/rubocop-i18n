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
    context "#{function} with undecorated double-quote message" do
      let(:source) { "#{function} \"a string\"" }

      it 'has the correct message' do
        expect(cop.offenses[0]).not_to be_nil
        expect(cop.offenses[0].message).to match(/should have a decorator around the message/)
      end

      it 'has the correct number of offenses' do
        expect(cop.offenses.size).to eq(1)
      end

      it 'autocorrects' do
        corrected = autocorrect_source("#{function}(\"a string\")")
        expect(corrected).to eq("#{function}(_(\"a string\"))")
      end
    end

    context "#{function} with undecorated single-quoted message" do
      let(:source) { "#{function} 'a string'" }

      it 'has the correct message' do
        expect(cop.offenses[0]).not_to be_nil
        expect(cop.offenses[0].message).to match(/should have a decorator around the message/)
      end

      it 'has the correct number of offenses' do
        expect(cop.offenses.size).to eq(1)
      end

      it 'autocorrects' do
        corrected = autocorrect_source("#{function}('a string')")
        expect(corrected).to eq("#{function}(_('a string'))")
      end
    end

    context "#{function} with undecorated constant & message" do
      let(:source) { "#{function} CONSTANT, 'a string'" }

      it 'has the correct message' do
        expect(cop.offenses[0]).not_to be_nil
        expect(cop.offenses[0].message).to match(/should have a decorator around the message/)
      end

      it 'has the correct number of offenses' do
        expect(cop.offenses.size).to eq(1)
      end

      it 'autocorrects' do
        corrected = autocorrect_source("#{function}(CONSTANT, 'a string')")
        expect(corrected).to eq("#{function}(CONSTANT, _('a string'))")
      end
    end

    context "#{function} with multiline message" do
      let(:source) { "#{function} 'multi '\\ 'line'"}
      it 'has the correct error message' do
        expect(cop.offenses[0]).not_to be_nil
        expect(cop.offenses[0].message).to match(/should not use a multi-line string/)
      end

      it 'has the correct number of offenses' do
        expect(cop.offenses.size).to eq(1)
      end
    end

    context "#{function} with heredoc message", broken: true do
      let(:source) { <<-RUBY
#{function} <<-ERROR
this
is
a
string
ERROR
RUBY
      }

      it 'has the correct error message' do
        expect(cop.offenses[0]).not_to be_nil
        expect(cop.offenses[0].message).to match(/should not use a multi-line string/)
      end

      it 'has the correct number of offenses' do
        expect(cop.offenses.size).to eq(1)
      end
    end

    context "#{function} with concatenated message" do
      let(:source) { "fail 'this' + 'string' + 'is' + 'concatenated'"}

      it 'has the correct error message' do
        expect(cop.offenses[0]).not_to be_nil
        expect(cop.offenses[0].message).to match(/should not use a concatenated string/)
      end

      it 'has the correct number of offenses' do
        expect(cop.offenses.size).to eq(1)
      end
    end

    context "#{function} with interpolated string" do
      let(:source) { "#{function} \"this string has a \#{var}\""}

      it 'has the correct error message' do
        expect(cop.offenses[0]).not_to be_nil
        expect(cop.offenses[0].message).to match(/interpolation is a sin/)
      end

      it 'has the correct number of offenses' do
        expect(cop.offenses.size).to eq(1)
      end

      it 'autocorrects' do
        corrected = autocorrect_source("#{function}(\"a string \#{var}\")")
        expect(corrected).to eq("#{function}(_(\"a string %{value0}\") % { value0: var, })")
      end
    end
  end

  context "real life examples," do
    context "message is multiline with interpolated" do
      let(:source) { "raise(Puppet::ParseError, \"mysql_password(): Wrong number of arguments \" \\ \"given (\#{args.size} for 1)\")" }
      #let(:source) { "raise(Puppet::ParseError, \"mysql_password(): Wrong number of arguments \" \\ \"given (\#{args.size} for 1)\"" }

      it 'has the correct error message' do
        expect(cop.offenses[0]).not_to be_nil
        expect(cop.offenses[0].message).to match(/interpolation is a sin/)
      end

      it 'has the correct number of offenses' do
        expect(cop.offenses.size).to eq(1)
      end

      it 'autocorrects', broken: true do
        corrected = autocorrect_source( "raise(Puppet::ParseError, \"mysql_password(): Wrong number of arguments \" \\ \"given (\#{args.size} for 1)\")" ) 
        expect(corrected).to eq("raise(Puppet::ParseError, _(\"a string %{value0}\") % { value0: var, })")
      end
    end
  end
end
