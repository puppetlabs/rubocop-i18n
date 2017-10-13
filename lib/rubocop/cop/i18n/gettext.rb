# frozen_string_literal: true

module RuboCop
  module Cop
    module I18n
      module GetText
        SUPPORTED_METHODS = ['raise', 'fail']
        SUPPORTED_DECORATORS = ['_', 'n_', 'N_']

        def self.supported_method?(method_name)
          SUPPORTED_METHODS.include?(method_name)
        end

        def self.supported_decorator?(decorator_name)
          SUPPORTED_DECORATORS.include?(decorator_name)
        end
      end
    end
  end
end
