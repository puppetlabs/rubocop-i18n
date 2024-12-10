# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::I18n::GetText::DecorateStringFormattingUsingPercent, :config do
  before(:each) do
    @offenses = investigate(cop, source)
  end

  RuboCop::Cop::I18n::GetText.supported_decorators.each do |decorator|
    context "#{decorator} decoration not used" do
      it_behaves_like 'a_no_cop_required', 'thing("a %s that is not decorated")'
    end

    context "#{decorator} decoration used but strings contain no % format" do
      it_behaves_like 'a_no_cop_required', "#{decorator}('a string')"
      it_behaves_like 'a_no_cop_required', "#{decorator} \"a string\""
      it_behaves_like 'a_no_cop_required', "#{decorator}(\"a string\" + \"another string\")"
      it_behaves_like 'a_no_cop_required', "#{decorator}(\"a %-5.2.s thing s string\")"
      it_behaves_like 'a_no_cop_required', "Log.warning #{decorator}(\"could not change to group %{group}: %{detail}\") % { group: group, detail: detail }"
    end

    # context "#{decorator} decoration with %% entry ignored" do
    #   it_behaves_like 'a_no_cop_required', "#{decorator}(\"a %%s thing #{format} string\")"
    # end

    formats = %w[b B d i o u x X e E f g G a A c p s]
    formats.each do |format|
      context "#{decorator} decoration with string % format" do
        it_behaves_like 'a_detecting_cop', "#{decorator}(\"a %#{format} string\")", '_', 'message string should not contain sprintf style formatting'
        it_behaves_like 'a_detecting_cop', "#{decorator}(\"a %#{format} string\" % [\"thing\"])", '_', 'message string should not contain sprintf style formatting'
        it_behaves_like 'a_detecting_cop', "#{decorator} \"a %#{format} string\" % [\"thing\"]", '_', 'message string should not contain sprintf style formatting'
        it_behaves_like 'a_detecting_cop', "#{decorator} 'a %#{format} string'", '_', 'message string should not contain sprintf style formatting'
        it_behaves_like 'a_detecting_cop', "#{decorator}(\"a %#{format} string\")", '_', 'message string should not contain sprintf style formatting'
        it_behaves_like 'a_detecting_cop', "#{decorator}(\"a string\" + \"second string with %#{format}\")", '_', 'message string should not contain sprintf style formatting'
        it_behaves_like 'a_detecting_cop', "#{decorator} \"a string\" + \"second string with %#{format}\" ", '_', 'message string should not contain sprintf style formatting'
      end

      context "#{decorator} decoration with paramaterized %0s" do
        it_behaves_like 'a_detecting_cop', "#{decorator}(\"a %1#{format} string\" % [\"abcdef\"])", '_', 'message string should not contain sprintf style formatting'
        it_behaves_like 'a_detecting_cop', "#{decorator}(\"a %3.2#{format} string\" % [\"abcdef\"])", '_', 'message string should not contain sprintf style formatting'
        it_behaves_like 'a_detecting_cop', "#{decorator} \"a %-1#{format} string\" % [\"abcdef\"]", '_', 'message string should not contain sprintf style formatting'
        it_behaves_like 'a_detecting_cop', "#{decorator}(\"a %-5.2#{format} string\" % [\"abcdef\"])", '_', 'message string should not contain sprintf style formatting'
        it_behaves_like 'a_detecting_cop', "#{decorator}(\"a %+5.2#{format} string\" % [\"abcdef\"])", '_', 'message string should not contain sprintf style formatting'
      end
    end
  end
end
