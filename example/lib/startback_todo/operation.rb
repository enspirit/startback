module StartbackTodo
  class Operation < Startback::Operation
  end
end
require_relative "operation/create_todo"
require_relative "operation/rate_limited"
