# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::I18n::RailsI18n::DecorateStringFormattingUsingInterpolation do
  let(:config) { RuboCop::Config.new }
  subject(:cop) { described_class.new(config) }
  before(:each) do
    investigate(cop, source)
  end

  RuboCop::Cop::I18n::RailsI18n.supported_decorators.each do |decorator|
    error_message = "function, message key string should not contain \#{} formatting"

    context "#{decorator} decoration not used" do
      it_behaves_like 'a_no_cop_required', 'thing("a \#{true} that is not decorated")'
    end

    context "#{decorator} decoration used but strings contain no \#{}" do
      it_behaves_like 'a_no_cop_required', "#{decorator}('a.string')"
      it_behaves_like 'a_no_cop_required', "#{decorator} 'a.string'"
      it_behaves_like 'a_no_cop_required', "#{decorator}(\"a.string\")"
      it_behaves_like 'a_no_cop_required', "Log.warning #{decorator}(\"a.string.%{status}\") % { status: 'done' }"
    end

    context "#{decorator} decoration with formatting" do
      it_behaves_like 'a_detecting_cop', "#{decorator}(\"a.\#{true}\")", 't', error_message
    end

    context "#{decorator} decoration with multiple interpolations" do
      it_behaves_like 'a_detecting_cop', "#{decorator}(\"a.\#{true}.\#{false}\")", 't', error_message
      it_behaves_like 'a_detecting_cop', "#{decorator} \"a.\#{true}.\#{false}\"", 't', error_message
    end

    context "#{decorator} decoration with interpolation on second string" do
      it_behaves_like 'a_detecting_cop', "#{decorator}(\"a.string\" + \"\#{true}.\#{false}\")", 't', error_message
    end

    context "#{decorator} decoration with a constant and then an interplation string" do
      it_behaves_like 'a_detecting_cop', "#{decorator}(CONSTANT, \"a \#{true}\")", 't', error_message
    end
  end
end
