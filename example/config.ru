$:.unshift File.expand_path('../lib',__FILE__)
require 'startback_todo'
StartbackTodo::ENGINE.connect
StartbackTodo::ENGINE.create_agents
run StartbackTodo::Webpoint
