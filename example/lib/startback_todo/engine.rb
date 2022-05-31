module StartbackTodo
  class Engine < Startback::Event::Engine
    auto_create_agents StartbackTodo::Agent

  end
end
