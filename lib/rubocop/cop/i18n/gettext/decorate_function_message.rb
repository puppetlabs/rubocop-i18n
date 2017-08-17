module RuboCop
  module Cop
    module I18n
      module GetText
        class DecorateFunctionMessage < Cop
          SUPPORTED_METHODS = ['raise', 'fail']
          SUPPORTED_DECORATORS = ["_", 'n_']

          def on_send(node)
            method_name = node.loc.selector.source
            return if !supported_method_name?(method_name)
            _, method_name, *arg_nodes = *node
            if !arg_nodes.empty? && !already_decorated?(arg_nodes) && (contains_string?(arg_nodes) || string_constant?(arg_nodes))
              if string_constant?(arg_nodes)
                arg_node = arg_nodes[1]
              else
                arg_node = arg_nodes[0]
              end

              how_bad_is_it(node, method_name, arg_node)
            end
          end

          private

          def supported_method_name?(method_name)
            SUPPORTED_METHODS.include?(method_name)
          end

          def already_decorated?(nodes)
            decorated = false
            if nodes[0].class == RuboCop::AST::SendNode
              decorated = true if SUPPORTED_DECORATORS.include?(nodes[0].loc.selector.source)
            elsif nodes[1].class == RuboCop::AST::SendNode
              decorated = true if SUPPORTED_DECORATORS.include?(nodes[1].loc.selector.source)
            end
            decorated
          end

          def string_constant?(nodes)
            nodes[0].type == :const && nodes[1]
          end

          def contains_string?(nodes)
            nodes[0].inspect.include?(":str") || nodes[0].inspect.include?(":dstr")
          end

          def how_bad_is_it(node, method_name, message)
            if message.str_type?
              add_offense(message, :expression, "'#{method_name}' should have a decorator around the message")
            elsif multiline_offense?(message)
              add_offense(message, :expression, "'#{method_name}' should not use a multi-line string")
            elsif concatenation_offense?(message)
              add_offense(message, :expression, "'#{method_name}' should not use a concatenated string")
            elsif interpolation_offense?(message)
              add_offense(message, :expression, "'#{method_name}' interpolation is a sin")
            end
          end

          def multiline_offense?(message)
            found_multiline = false
            found_strings = false
            message.children.each { |child|
              if child == :/
                found_multiline = true
              elsif ( (!child.nil? && child.class != Symbol) && ( child.str_type? || child.dstr_type? ) )
                found_strings = true
              end
            }

            (found_multiline || found_strings) && (!interpolation_offense?(message)) && (!concatenation_offense?(message))
          end

          def concatenation_offense?(message)
            found_concat = false
            found_strings = false
              message.children.each { |child|
                if child == :+
                  found_concat = true
                elsif ( (!child.nil? && child.class != Symbol) && ( child.str_type? || child.dstr_type? ) )
                  found_strings = true
                end
              }
            found_concat && found_strings
          end

          def interpolation_offense?(message)
            found_funct = false
            message.children.each { |child|
              if !child.nil? && child.class != Symbol
                if child.begin_type? || child.send_type?
                  found_funct = true
                elsif child.dstr_type?
                  found_funct = true if child.inspect.include?(":send") || child.inspect.include?(":begin")
                end
              end
            }
            found_funct
          end

          def autocorrect(node)
            if node.str_type?
              single_string_correct(node)
            elsif multiline_offense?(node)
            # stuff
            elsif concatenation_offense?(node)
            # stuff
            elsif interpolation_offense?(node)
            # interpolation_correct(node)
            end
          end

          def single_string_correct(node)
            ->(corrector) { corrector.insert_before(node.source_range , "_(")
            corrector.insert_after(node.source_range , ")") }
          end

          def multiline_string_correct(node)
          end

          def interpolation_correct(node)
            interpolated_values_string = ""
            count = 0
            ->(corrector) { 
              node.children.each do |child|
                # dstrs are split into "str" segments and other segments.
                # The "other" segments are the interpolated values.
                if child.type == :begin
                  value = child.children[0]
                  hash_key = "value"
                  if value.type == :lvar
                    # Use the variable's name as the format key
                    hash_key = value.loc.name.source
                  else
                    # These are placeholders that will manually need to be given
                    # a descriptive name
                    hash_key << "#{count}"
                    count += 1
                  end
                  if interpolated_values_string.empty?
                    interpolated_values_string << "{ "
                  end
                  interpolated_values_string << "#{hash_key}: #{value.loc.expression.source}, "

                  # Replace interpolation with format string
                  corrector.replace(child.loc.expression, "%{#{hash_key}}")
                end
              end
              if !interpolated_values_string.empty?
                interpolated_values_string << "}"
              end
              corrector.insert_before(node.source_range, '_(') 
              corrector.insert_after(node.source_range, ") % #{interpolated_values_string}") 
            } 
          end

        end
      end
    end
  end
end
