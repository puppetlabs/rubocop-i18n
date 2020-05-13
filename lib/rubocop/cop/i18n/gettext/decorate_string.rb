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

          def autocorrect(node)
            single_string_correct(node) if node.str_type?
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
            parent = node.parent
            if parent.respond_to?(:type) && parent.send_type?
              method_name = parent.loc.selector.source
              return if GetText.supported_decorator?(method_name)
            elsif parent.respond_to?(:method_name) && parent.method?(:[])
              return
            end
            add_offense(node, message: 'decorator is missing around sentence')
          end

          def single_string_correct(node)
            lambda { |corrector|
              corrector.insert_before(node.source_range, '_(')
              corrector.insert_after(node.source_range, ')')
            }
          end
        end
      end
    end
  end
end
