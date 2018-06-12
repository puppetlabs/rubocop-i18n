# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::I18n::GetText::DecorateString do
  let(:config) { RuboCop::Config.new }
  subject(:cop) { described_class.new(config) }
  before(:each) do
    investigate(cop, source)
  end

  context 'decoration needed for string' do
    it_behaves_like 'a_detecting_cop', 'a = "A sentence that is not decorated."', '_', 'decorator is missing around sentence'
    it_behaves_like 'a_detecting_cop', 'thing("A sentence that is not decorated.")', '_', 'decorator is missing around sentence'
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
        line two\"", '_', 'decorator is missing around sentence'
    it_behaves_like 'a_detecting_cop', "b = \"line one.
        A sentence line two.\"", '_', 'decorator is missing around sentence'
  end

  RuboCop::Cop::I18n::GetText.supported_decorators.each do |decorator|
    context "#{decorator} already present" do
      it_behaves_like 'a_no_cop_required', "#{decorator}('a string')"
      it_behaves_like 'a_no_cop_required', "#{decorator} \"a string\""
      it_behaves_like 'a_no_cop_required', "a = #{decorator}('a string')"
      it_behaves_like 'a_no_cop_required', "#{decorator}(\"a %-5.2.s thing s string\")"
      it_behaves_like 'a_no_cop_required', "Log.warning #{decorator}(\"could not change to group %{group}: %{detail}\") % { group: group, detail: detail }"
      it_behaves_like 'a_no_cop_required', "Log.warning #{decorator}(\"could not change to group %{group}: %{detail}\") %
                                            { group: #{decorator}(\"group\"), detail: #{decorator}(\"detail\") }"
    end

    context "#{decorator} around dstr" do
      it_behaves_like 'a_no_cop_required', "a = #{decorator}(\"A sentence line one.
        line two\")"
      it_behaves_like 'a_no_cop_required', "a = #{decorator}(\"line one.
        A sentence line two.\")"
    end
  end
end
