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
       it_behaves_like 'a_detecting_cop', "#{function}(\"a string\")", function, 'should have a decorator around the message'
       it_behaves_like 'a_fixing_cop', "#{function}(\"a string\")", "#{function}(_(\"a string\"))", function
     end
     context "#{function} with undecorated single-quoted message" do
       it_behaves_like 'a_detecting_cop', "#{function}('a string')", function, 'should have a decorator around the message'
       it_behaves_like 'a_fixing_cop', "#{function}('a string')", "#{function}(_('a string'))", function
     end
     context "#{function} with undecorated constant & message" do
       it_behaves_like 'a_detecting_cop', "#{function}(CONSTANT, 'a string')", function, 'should have a decorator around the message'
       it_behaves_like 'a_fixing_cop', "#{function}(CONSTANT, 'a string')", "#{function}(CONSTANT, _('a string'))", function
     end
     context "#{function} with multiline message" do
       it_behaves_like 'a_detecting_cop', "#{function} 'multi '\\ 'line'", function, 'should not use a multi-line string'
     end
     context "#{function} with heredoc message" do
     #{function} <<-ERROR
     #this
     #is
     #a
     #string
     #ERROR
     #it_behaves_like 'a_detecting_cop', "#{function}(CONSTANT, 'a string')", function, 'heredoc'
     end
     context "#{function} with concatenated message" do
       it_behaves_like 'a_detecting_cop', "fail 'this' + 'string' + 'is' + 'concatenated'", function, 'should not use a concatenated string'
     end
     context "#{function} with interpolated string" do
       it_behaves_like 'a_detecting_cop', "#{function}(\"a string \#{var}\")", function, 'interpolation is a sin'
#      it_behaves_like 'a_fixing_cop', "#{function}(\"a string \#{var}\")", "#{function}(_(\"a string %{value0}\")) % { value0: var, }", function
     end
  end
  context "real life examples," do
    context "message is multiline with interpolated" do
      let(:source) { "raise(Puppet::ParseError, \"mysql_password(): Wrong number of arguments \" \\ \"given (\#{args.size} for 1)\")" }

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
