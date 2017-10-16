# frozen_string_literal: true

module RuboCop
  module Cop
    module I18n
      module GetText
        def self.supported_methods
          %w[raise fail]
        end

        # Supports decorators from
        # * mutoh/gettext https://github.com/mutoh/gettext/blob/master/lib/gettext.rb
        # * grosser/fast_gettext https://github.com/grosser/fast_gettext/blob/master/lib/fast_gettext/translation.rb
        def self.supported_decorators
          %w[
            _
            n_
            np_
            ns_
            N_
            Nn_
            D_
            Dn_
            Ds_
            Dns_
            d_
            dn_
            ds_
            dns_
            p_
            s_
          ]
        end

        def self.supported_method?(method_name)
          supported_methods.include?(method_name)
        end

        def self.supported_decorator?(decorator_name)
          supported_decorators.include?(decorator_name)
        end
      end
    end
  end
end
