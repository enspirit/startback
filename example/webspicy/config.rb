require 'webspicy'
require 'startback_todo'

Webspicy::Configuration.new(Path.dir) do |c|
  c.before_all do
    StartbackTodo::ENGINE.connect
    StartbackTodo::ENGINE.create_agents
  end
  c.before_each do
    StartbackTodo::DB.reset
  end
  c.client = Webspicy::RackTestClient.for(StartbackTodo::Webpoint)
  c.precondition AnOperationHasRun
end
