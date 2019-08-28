# frozen_string_literal: true

module RuboCop
  module Cop
    module I18n
      module GetText
        # When using a decorated string to support I18N, any strings inside the decoration should not contain sprintf
        # style formatting as this makes it hard to translate the string. This cop checks the decorators listed in
        # GetText.supported_decorators and checks for each of the formats in SUPPORTED_FORMATS. NOTE: this cop does not
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
          SUPPORTED_FORMATS = %w[b B d i o u x X e E f g G a A c p s].freeze

          def on_send(node)
            decorator_name = node.loc.selector.source
            return unless GetText.supported_decorator?(decorator_name)

            method_name = node.method_name
            arg_nodes = node.arguments
            if !arg_nodes.empty? && contains_string_with_percent_format?(arg_nodes)
              message_section = arg_nodes[0]
              add_offense(message_section, message: "'#{method_name}' function, message string should not contain sprintf style formatting (ie %s)")
            end
          end

          private

          def string_contains_percent_format?(str)
            SUPPORTED_FORMATS.any? { |format| str.match(/%([-+])?[0-9]*(\.[0-9]*)?#{format}/) }
          end

          def contains_string_with_percent_format?(node)
            if node.is_a?(Array)
              return node.any? { |n| contains_string_with_percent_format?(n) }
            end

            if node.respond_to?(:type)
              if node.str_type? || node.dstr_type?
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
