# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::I18n::RailsI18n::DecorateString do
  let(:config) { RuboCop::Config.new }
  subject(:cop) { described_class.new(config) }
  before(:each) do
    investigate(cop, source)
  end

  context 'decoration needed for string' do
    it_behaves_like 'a_detecting_cop', 'a = "A sentence that is not decorated."', 't', 'decorator is missing around sentence'
    it_behaves_like 'a_detecting_cop', 'thing("A sentence that is not decorated.")', 't', 'decorator is missing around sentence'
  end

  context 'decoration not needed for string' do
    it_behaves_like 'a_no_cop_required', "'keyword'"
    # a regexp is a string
    it_behaves_like 'a_no_cop_required', '@regexp = /[ =]/'
    it_behaves_like 'a_no_cop_required', 'Dir[File.dirname(__FILE__) + "/parser/compiler/catalog_validator/*.rb"].each { |f| require f }'
    it_behaves_like 'a_no_cop_required', 'stream.puts "#@version\n" if @version'
    it_behaves_like 'a_no_cop_required', '
          f.puts(<<-YAML)
            ---
            :tag: yaml
            :yaml:
               :something: #{variable}
          YAML'
  end

  context 'decoration not needed for a hash key' do
    # a string as an hash key is ok
    it_behaves_like 'a_no_cop_required', 'memo["#{class_path}##{method}-#{source_line}"] += 1'
  end

  context 'string with invalid UTF-8' do
    it_behaves_like 'a_no_cop_required', '
        STRING_MAP = {
      Encoding::UTF_8 => "\uFFFD",
      Encoding::UTF_16LE => "\xFD\xFF".force_encoding(Encoding::UTF_16LE),
    }'
  end

  context 'decoration missing for dstr' do
    it_behaves_like 'a_detecting_cop', "b = \"A sentence line one.
        line two\"", 't', 'decorator is missing around sentence'
    it_behaves_like 'a_detecting_cop', "b = \"line one.
        A sentence line two.\"", 't', 'decorator is missing around sentence'
  end

  RuboCop::Cop::I18n::RailsI18n::DecorateString::SUPPORTED_DECORATORS.each do |decorator|
    context "#{decorator} already present" do
      it_behaves_like 'a_no_cop_required', "#{decorator}('a string')"
      it_behaves_like 'a_no_cop_required', "#{decorator} \"a string\""
      it_behaves_like 'a_no_cop_required', "a = #{decorator}('a string')"
      it_behaves_like 'a_no_cop_required', "#{decorator}(\"a %-5.2.s thing s string\")"
      it_behaves_like 'a_no_cop_required', "Log.warning #{decorator}(\"could not change to group %{group}: %{detail}\", group: group, detail: detail)"
      it_behaves_like 'a_no_cop_required', "Log.warning #{decorator}(\"could not change to group %{group}: %{detail}\",
                                            group: #{decorator}(\"group\"), detail: #{decorator}(\"detail\"))"
    end

    context "#{decorator} around dstr" do
      it_behaves_like 'a_no_cop_required', "a = #{decorator}(\"A sentence line one.
        line two\")"
      it_behaves_like 'a_no_cop_required', "a = #{decorator}(\"line one.
        A sentence line two.\")"
    end

    context "I18n.#{decorator} already present" do
      it_behaves_like 'a_no_cop_required', "I18n.#{decorator}('a string')"
      it_behaves_like 'a_no_cop_required', "I18n.#{decorator} \"a string\""
      it_behaves_like 'a_no_cop_required', "a = I18n.#{decorator}('a string')"
      it_behaves_like 'a_no_cop_required', "I18n.#{decorator}(\"a %-5.2.s thing s string\")"
      it_behaves_like 'a_no_cop_required', "Log.warning I18n.#{decorator}(\"could not change to group %{group}: %{detail}\", group: group, detail: detail)"
      it_behaves_like 'a_no_cop_required', "Log.warning I18n.#{decorator}(\"could not change to group %{group}: %{detail}\",
                                            group: I18n.#{decorator}(\"group\"), detail: I18n.#{decorator}(\"detail\"))"
    end

    context "I18n.#{decorator} around dstr" do
      it_behaves_like 'a_no_cop_required', "a = I18n.#{decorator}(\"A sentence line one.
        line two\")"
      it_behaves_like 'a_no_cop_required', "a = I18n.#{decorator}(\"line one.
        A sentence line two.\")"
    end

    context "SomeOtherMod.#{decorator} is used" do
      it_behaves_like 'a_no_cop_required', "SomeOtherMod.#{decorator}('a string')"
      it_behaves_like 'a_no_cop_required', "SomeOtherMod.#{decorator} \"a string\""
      it_behaves_like 'a_no_cop_required', "a = SomeOtherMod.#{decorator}('a string')"
      it_behaves_like 'a_no_cop_required', "SomeOtherMod.#{decorator}(\"a %-5.2.s thing s string\")"
      it_behaves_like 'a_no_cop_required', "Log.warning SomeOtherMod.#{decorator}(\"could not change to group %{group}: %{detail}\", group: group, detail: detail)"
      it_behaves_like 'a_no_cop_required', "Log.warning SomeOtherMod.#{decorator}(\"could not change to group %{group}: %{detail}\",
                                            group: SomeOtherMod.#{decorator}(\"group\"), detail: SomeOtherMod.#{decorator}(\"detail\"))"

      it_behaves_like 'a_detecting_cop', "SomeOtherMod.#{decorator}('Some sentence like text.')", decorator, 'decorator is missing around sentence'
      it_behaves_like 'a_detecting_cop', "SomeOtherMod.#{decorator} \"Some sentence like text.\"", decorator, 'decorator is missing around sentence'
    end

    context "SomeOtherMod.#{decorator} around dstr" do
      it_behaves_like 'a_detecting_cop', "a = SomeOtherMod.#{decorator}(\"A sentence line one.
        line two\")", decorator, 'decorator is missing around sentence'
      it_behaves_like 'a_detecting_cop', "a = SomeOtherMod.#{decorator}(\"line one.
        A sentence line two.\")", decorator, 'decorator is missing around sentence'

      it_behaves_like 'a_no_cop_required', "a = SomeOtherMod.#{decorator}(\"line one.
        a sentence line two\")"
    end
  end

  context 'when ignoring raised exceptions' do
    let(:config) do
      RuboCop::Config.new('RailsI18n/DecorateString' => { 'IgnoreExceptions' => true })
    end

    %w(fail raise).each do |type|
      it_behaves_like 'a_no_cop_required', "#{type} \"A sentence that is not decorated.\""
      it_behaves_like 'a_no_cop_required', "#{type} StandardError, \"A sentence that is not decorated.\""
      it_behaves_like 'a_no_cop_required', "#{type} StandardError.new(\"A sentence that is not decorated.\")"
    end
  end
end
