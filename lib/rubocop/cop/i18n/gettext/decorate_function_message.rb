module RuboCop
  module Cop
    module I18n
      module GetText
        class DecorateFunctionMessage < Cop

          def on_send(node)
            method_name = node.loc.selector.source
            return if !/raise|fail/.match(method_name)
            if supported_method_name?(method_name)
              _, method_name, *arg_nodes = *node
              if !arg_nodes.empty? && contains_string?(arg_nodes)
                if string_constant?(arg_nodes)
                  arg_node = arg_nodes[1]
                else
                  arg_node = arg_nodes[0]
                end

                how_bad_is_it(node, method_name, arg_node)
              end
            end
          end

          private

          def supported_method_name?(method_name)
            ["raise", "fail"].include?(method_name)
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
            elsif concatination_offense?(message)
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
            found_multiline && found_strings
          end

          def concatination_offense?(message)
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
            else
              multiline_string_correct(node)
            end
          end

          def single_string_correct(node)
            ->(corrector) { corrector.insert_before(node.source_range , "_(")
            corrector.insert_after(node.source_range , ")") }
          end

          def multiline_string_correct(node)
          end
        end
      end
    end
  end
end
