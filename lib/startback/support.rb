module Startback
  module Support

    def logger
      Startback::LOGGER
    end

    def deep_merge(h1, h2)
      h1.merge(h2){|k,v1,v2|
        v1.is_a?(Hash) && v2.is_a?(Hash) ? deep_merge(v1, v2) : v2
      }
    end
    module_function :deep_merge

  end # module Support
end # module Startback
require_relative 'support/env'
require_relative 'support/log_formatter'
require_relative 'support/logger'
require_relative 'support/robustness'
require_relative 'support/hooks'
require_relative 'support/operation_runner'
require_relative 'support/transaction_policy'
require_relative 'support/transaction_manager'
