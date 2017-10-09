module RuboCop
  module Cop
    module I18n
      module GetText
        # When using a decorated string to support I18N, any strings inside the decoration should not contain sprintf
        # style formatting as this makes it hard to translate the string. This cop checks the decorators listed in
        # SUPPORTED_DECORATORS and checks for each of the formats in SUPPORTED_FORMATS. NOTE: this cop does not
        # check for all possible sprintf formats.
        #
        # @example
        #
        #   # bad
        #
        #   _("result is %s" % ["value"])
        #   n_("a string" + "a string with a %-3.1f" % [size])
        #   N_("a string" + "a string with a %04d" % [size])
        #
        # @example
        #
        #   # good
        #
        #   _("result is %{detail}" % {detail: message})
        #
        class DecorateStringFormattingUsingPercent < Cop

          SUPPORTED_DECORATORS = ['_', 'n_', 'N_']
          SUPPORTED_FORMATS = %w[b B d i o u x X e E f g G a A c p s]

          def on_send(node)
            decorator_name = node.loc.selector.source
            return if !supported_decorator_name?(decorator_name)
            _, method_name, *arg_nodes = *node
            if !arg_nodes.empty? && contains_string_with_percent_format?(arg_nodes)
              message_section = arg_nodes[0]
              add_offense(message_section, :expression, "'#{method_name}' function, message string should not contain sprintf style formatting (ie %s)")
            end
          end

          private

          def supported_decorator_name?(decorator_name)
            SUPPORTED_DECORATORS.include?(decorator_name)
          end

          def string_contains_percent_format?(str)
            SUPPORTED_FORMATS.any? { |format| str.match(/%([-+])?[0-9]*(\.[0-9]*)?#{format}/) }
          end

          def contains_string_with_percent_format?(node)
            if node.is_a?(Array)
              return node.any? { |n| contains_string_with_percent_format?(n) }
            end

            if node.respond_to?(:type)
              if node.type == :str or node.type == :dstr
                return string_contains_percent_format?(node.source)
              end
            end

            if node.respond_to?(:children)
              return node.children.any? { |child| contains_string_with_percent_format?(child) }
            end
            false
          end

        end
      end
    end
  end
end
