# frozen_string_literal: true

module RuboCop
  module Cop
    module I18n
      module RailsI18n
        # This cop is looks for strings that appear to be sentences but are not decorated.
        # Sentences are determined by the STRING_REGEXP. (Upper case character, at least one space,
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
        class DecorateString < Cop
          STRING_REGEXP = /^\s*[[:upper:]][[:alpha:]]*[[:blank:]]+.*[.!?]$/.freeze

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
                child.encode(Encoding::UTF_8).chomp =~ STRING_REGEXP
              else
                false
              end
            elsif child.respond_to?(:type) && child.str_type?
              sentence?(child)
            else
              false
            end
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
            return ignoring_raised_parent?(parent.parent) if parent.respond_to?(:method_name) && parent.method_name == :new

            false
          end

          def parent_is_indexer?(parent)
            parent.respond_to?(:method_name) && parent.method_name == :[]
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
