module StartbackTodo
  class RateLimited < Operation

    rate_limit

    def initialize(input)
      @input = input
    end

    def call
      true
    end

  end
end
