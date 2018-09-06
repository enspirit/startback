require 'webspicy'
require 'startback_todo'

Webspicy::Configuration.new(Path.dir) do |c|
  c.client = Webspicy::RackTestClient.for(StartbackTodo::App)
end
