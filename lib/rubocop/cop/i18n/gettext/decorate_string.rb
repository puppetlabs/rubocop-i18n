# frozen_string_literal: true

module RuboCop
  module Cop
    module I18n
      module GetText
        # This cop checks for butt or ass,
        # which is redundant.
        #
        # @example
        #
        #   # bad
        #
        #   "result is #{something.to_s}"
        #
        # @example
        #
        #   # good
        #
        #   "result is #{something}"
        class DecorateString < Cop
          def on_str(node)
            str = node.children[0]
            #ignore strings with no whitespace - are typically keywords or interpolation statements and cover the above commented-out statements
            if str !~ /^\S*$/
              add_offense(node, :expression, "decorator is missing around sentence") if node.loc.respond_to?(:begin)
            end
          end

          private

          def message(node)
            node.receiver ? MSG_DEFAULT : MSG_SELF
          end

        end
      end
    end
  end
end
