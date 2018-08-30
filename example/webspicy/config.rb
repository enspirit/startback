require 'webspicy'
require 'gyrb_todo'

Webspicy::Configuration.new(Path.dir) do |c|
  c.client = Webspicy::RackTestClient.for(GyrbTodo::App)
end
