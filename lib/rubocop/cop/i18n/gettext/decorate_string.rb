# frozen_string_literal: true

module RuboCop
  module Cop
    module I18n
      module GetText
        # This cop checks for sentence-like strings that are undecorated
        # @example
        #
        #   # bad
        #
        #   "The result is success."
        #
        # @example
        #
        #   # good
        #
        #   _("The result is success.")
        class DecorateString < Cop
          SUPPORTED_DECORATORS = ['_', 'n_', 'N_']

          def on_str(node)
            return if node.parent && supported_decorator_name?(node.parent.method_name.to_s)
            str = node.children[0]

            # look for strings starting with a capitalized letter, followed by some spaces and other characters, and then some punctuation.
            if str =~ /^[[:upper:]][[:alpha:]]*[[:blank:]]+.*[.!?]$/
              add_offense(node, :expression, "decorator is missing around sentence") if node.loc.respond_to?(:begin)
            end
          end

          private

          def message(node)
            node.receiver ? MSG_DEFAULT : MSG_SELF
          end

          def supported_decorator_name?(decorator_name)
            SUPPORTED_DECORATORS.include?(decorator_name)
          end
        end
      end
    end
  end
end
