# frozen_string_literal: true

module RuboCop
  module Cop
    module I18n
      module GetText
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
        #   _("Result is good.")
        class DecorateString < Cop

          SUPPORTED_DECORATORS = ['_', 'n_', 'N_']
          STRING_REGEXP = /^\s*[[:upper:]][[:alpha:]]*[[:blank:]]+.*[.!?]$/

          def on_dstr(node)
            if dstr_contains_sentence?(node)
              check_for_parent_decorator(node)
            end
          end

          def on_str(node)
            return unless is_sentence?(node)

            parent = node.parent
            # ignore regexp expressions and dstr is covered by on_dstr
            if parent.regexp_type? or parent.dstr_type?
              return
            end

            check_for_parent_decorator(node)
          end

          private

          def is_sentence?(node)
            child = node.children[0]
            if child.is_a?(String)
              if child.valid_encoding?
                child.chomp.force_encoding(Encoding::UTF_8) =~ STRING_REGEXP
              else
                false
              end
            elsif child.respond_to?(:str_type?) and child.str_type?
              is_sentence?(child)
            else
              false
            end
          end

          def dstr_contains_sentence?(node)
            node.children.any? { |child| is_sentence?(child) }
          end

          def check_for_parent_decorator(node)
            parent = node.parent
            if parent.send_type?
              method_name = parent.loc.selector.source
              unless SUPPORTED_DECORATORS.include?(method_name)
                add_offense(node, :expression, "decorator is missing around string, instead found #{method_name}")
              end
            elsif parent.method_name == :[]
              return
            else
              add_offense(node, :expression, "decorator is missing around string")
            end
          end

        end
      end
    end
  end
end
