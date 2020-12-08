require 'webspicy'
require 'startback_todo'

Webspicy::Configuration.new(Path.dir) do |c|
  c.before_each do
    StartbackTodo::DB.reset
  end
  c.client = Webspicy::RackTestClient.for(StartbackTodo::App)
end
