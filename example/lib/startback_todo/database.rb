module StartbackTodo
  class Database

    def initialize
      @todos ||= [
        {id: 1, description: "Write more code"}
      ]
    end
    attr_reader :todos

    def transaction
      yield
    end

  end
end
