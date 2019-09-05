# frozen_string_literal: true

module RuboCop
  module Cop
    module I18n
      module GetText
        # When using an decorated string to support I18N, any strings inside the decoration should not contain
        # the '#{}' interpolation string as this makes it hard to translate the strings.
        #
        # Check GetText.supported_decorators for a list of decorators that can be used.
        #
        # @example
        #
        #   # bad
        #
        #   _("result is #{this_is_the_result}")
        #   n_("a string" + "a string with a #{float_value}")
        #
        # @example
        #
        #   # good
        #
        #   _("result is %{detail}" % {detail: message})
        #
        class DecorateStringFormattingUsingInterpolation < Cop
          def on_send(node)
            decorator_name = node.loc.selector.source
            return unless GetText.supported_decorator?(decorator_name)

            method_name = node.method_name
            arg_nodes = node.arguments
            if !arg_nodes.empty? && contains_string_formatting_with_interpolation?(arg_nodes)
              message_section = arg_nodes[0]
              add_offense(message_section, message: "'#{method_name}' function, message string should not contain \#{} formatting")
            end
          end

          private

          def string_contains_interpolation_format?(str)
            str.match(/\#{[^}]+}/)
          end

          def contains_string_formatting_with_interpolation?(node)
            if node.is_a?(Array)
              return node.any? { |n| contains_string_formatting_with_interpolation?(n) }
            end

            if node.respond_to?(:type)
              if node.str_type? || node.dstr_type?
                return string_contains_interpolation_format?(node.source)
              end
            end

            if node.respond_to?(:children)
              return node.children.any? { |child| contains_string_formatting_with_interpolation?(child) }
            end

            false
          end
        end
      end
    end
  end
end
