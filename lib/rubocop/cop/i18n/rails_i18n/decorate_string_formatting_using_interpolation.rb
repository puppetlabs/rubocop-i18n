module RuboCop
  module Cop
    module I18n
      module RailsI18n
        # When using an decorated string to support I18N, any strings inside the decoration should not contain
        # the '#{}' interpolation string as this makes it hard to translate the strings.
        #
        # @example
        #
        #   # bad
        #
        #   t("status.#{status_string}")
        #   t("status." + "accepted")
        #
        # @example
        #
        #   # good
        #
        #   t("status.accepted")
        #
        class DecorateStringFormattingUsingInterpolation < Cop
          def on_send(node)
            return unless node.loc && node.loc.selector
            decorator_name = node.loc.selector.source
            return unless RailsI18n.supported_decorator?(decorator_name)

            _, method_name, *arg_nodes = *node
            if !arg_nodes.empty? && contains_string_formatting_with_interpolation?(arg_nodes)
              message_section = arg_nodes[0]
              add_offense(message_section, message: error_message(method_name))
            end
          end

          private

          def error_message(method_name)
            "'#{method_name}' function, message key string should not contain \#{} formatting"
          end

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
