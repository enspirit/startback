# Sinatra 4 restricts the Host header to localhost-like values in the
# `development` environment, which is the one used when RACK_ENV is unset.
# Webspicy's RackTestClient issues requests against `example.org`, hence the
# need to be explicit about running in test mode here.
ENV['RACK_ENV'] ||= 'test'

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
