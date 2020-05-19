# frozen_string_literal: true

module RuboCop
  module Cop
    module I18n
      module RailsI18n
        # This cop is looks for strings that appear to be sentences but are not decorated.
        # Sentences are determined by the SENTENCE_REGEXP. (Upper case character, at least one space,
        # and sentence punctuation at the end)
        #
        # @example
        #
        #   # bad
        #
        #   "Result is bad."
        #
        # @example
        #
        #   # good
        #
        #   t("result_is_good")
        #   I18n.t("result_is_good")
        #
        # There are several options for configuration.
        #
        # @example IgnoreExceptions: true
        #   # OK
        #
        #   raise "Some string sentence"
        #
        # @example EnforcedSentenceType: sentence
        #   # bad
        #
        #   "Result is bad."
        #
        #   # good
        #
        #   t("result_is_good")
        #   I18n.t("result_is_good")
        #
        # @example EnforcedSentenceType: fragmented_sentence
        #   # bad
        #
        #   "Result is bad"   # Contains a capital to start
        #   "result is bad."  # Ends in punctuation
        #
        #   # good
        #
        #   t("result_is_good")
        #   I18n.t("result_is_good")
        #
        # @example EnforcedSentenceType: fragment
        #   # bad
        #
        #   "result is bad"   # A series of words
        #
        #   # good
        #
        #   t("result_is_good")
        #   I18n.t("result_is_good")
        #
        # @example Regexp: ^only-this-text$
        #
        #   # bad
        #
        #   "only-this-text"
        #
        #   # good
        #
        #   "Any other string is fine now"
        #   t("only_this_text")
        #
        class DecorateString < Cop
          SENTENCE_REGEXP = /^\s*[[:upper:]][[:alpha:]]*[[:blank:]]+.*[.!?]$/.freeze
          FRAGMENTED_SENTENCE_REGEXP = /^\s*([[:upper:]][[:alpha:]]*[[:blank:]]+.*)|([[:alpha:]]*[[:blank:]]+.*[.!?])$/.freeze
          FRAGMENT_REGEXP = /^\s*[[:alpha:]]*[[:blank:]]+.*$/.freeze
          SUPPORTED_DECORATORS = %w[
            t
            t!
            translate
            translate!
          ].freeze

          def on_dstr(node)
            check_for_parent_decorator(node) if dstr_contains_sentence?(node)
          end

          def on_str(node)
            return unless sentence?(node)

            parent = node.parent
            if parent.respond_to?(:type)
              return if parent.regexp_type? || parent.dstr_type?
            end

            check_for_parent_decorator(node)
          end

          private

          def sentence?(node)
            child = node.children[0]
            if child.is_a?(String)
              if child.valid_encoding?
                child.encode(Encoding::UTF_8).chomp =~ regexp
              else
                false
              end
            elsif child.respond_to?(:type) && child.str_type?
              sentence?(child)
            else
              false
            end
          end

          def regexp
            @regexp ||= regexp_from_config || regexp_from_string_type
          end

          def regexp_from_string_type
            case cop_config['EnforcedSentenceType'].to_s.downcase
            when 'sentence'            then SENTENCE_REGEXP
            when 'fragmented_sentence' then FRAGMENTED_SENTENCE_REGEXP
            when 'fragment'            then FRAGMENT_REGEXP
            else
              SENTENCE_REGEXP
            end
          end

          def regexp_from_config
            Regexp.new(cop_config['Regexp']) if cop_config['Regexp']
          end

          def dstr_contains_sentence?(node)
            node.children.any? { |child| sentence?(child) }
          end

          def check_for_parent_decorator(node)
            return if parent_is_translator?(node.parent)
            return if parent_is_indexer?(node.parent)
            return if ignoring_raised_parent?(node.parent)

            add_offense(node, message: 'decorator is missing around sentence')
          end

          def ignoring_raised_parent?(parent)
            return false unless cop_config['IgnoreExceptions']

            return true if parent.respond_to?(:method_name) && %i[raise fail].include?(parent.method_name)

            # Commonly exceptions are initialized manually.
            return ignoring_raised_parent?(parent.parent) if parent.respond_to?(:method_name) && parent.method?(:new)

            false
          end

          def parent_is_indexer?(parent)
            parent.respond_to?(:method_name) && parent.method?(:[])
          end

          def parent_is_translator?(parent)
            if parent.respond_to?(:type) && parent.send_type?
              method_name = parent.loc.selector.source
              if RailsI18n.supported_decorator?(method_name)
                # Implicit receiver is assumed correct.
                return true if parent.receiver.nil?
                return true if parent.receiver.children == [nil, :I18n]
              end
            end
            false
          end
        end
      end
    end
  end
end
