class AnOperationHasRun
  include Webspicy::Precondition

  def self.match(service, desc)
    return unless desc =~ /Given a CreateTodo operation has run/
    AnOperationHasRun.new
  end

  def instrument(test_case, client)
    res = client.api.post("/api/todos/", {
      id: 145678,
      description: "Do something smart"
    })
    unless res.status == 201
      puts res.body
      raise "Unexpected status: `#{res.status}`"
    end
    nil
  end

end
