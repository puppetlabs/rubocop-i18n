# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::I18n::GetText::DecorateStringFormattingUsingInterpolation, :config, :config do
  before(:each) do
    investigate(cop, source)
  end

  RuboCop::Cop::I18n::GetText.supported_decorators.each do |decorator|
    error_message = "function, message string should not contain \#{} formatting"

    context "#{decorator} decoration not used" do
      it_behaves_like 'a_no_cop_required', 'thing("a \#{true} that is not decorated")'
    end

    context "#{decorator} decoration used but strings contain no \#{}" do
      it_behaves_like 'a_no_cop_required', "#{decorator}('a string')"
      it_behaves_like 'a_no_cop_required', "#{decorator} 'a string'"
      it_behaves_like 'a_no_cop_required', "#{decorator}(\"a string\")"
      it_behaves_like 'a_no_cop_required', "Log.warning #{decorator}(\"could not change to group %{group}: %{detail}\") % { group: group, detail: detail }"
    end

    context "#{decorator} decoration with formatting" do
      it_behaves_like 'a_detecting_cop', "#{decorator}(\"a \#{true}\")", '_', error_message
    end

    context "#{decorator} decoration with multiple interpolations" do
      it_behaves_like 'a_detecting_cop', "#{decorator}(\"a \#{true} \#{false}\")", '_', error_message
      it_behaves_like 'a_detecting_cop', "#{decorator} \"a \#{true} \#{false}\"", '_', error_message
    end

    context "#{decorator} decoration with interpolation on second string" do
      it_behaves_like 'a_detecting_cop', "#{decorator}(\"a string\" + \"\#{true} \#{false}\")", '_', error_message
    end

    context "#{decorator} decoration with a constant and then an interplation string" do
      it_behaves_like 'a_detecting_cop', "#{decorator}(CONSTANT, \"a \#{true}\")", '_', error_message
    end
  end
end
