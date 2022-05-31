require 'spec_helper'
require 'startback/websocket'

module Startback
  module Websocket
    module Hub
      describe Builder do

        class TestMiddleware

          def initialize(app, opts = {})
            @app = app
            @@init = true
            @@opts = opts
          end

          def call(data, socket)
            @@calls ||= []
            @@calls << data
            @app.call(data, socket)
          end

          def self.reset
            @@init = false
            @@calls = []
          end

          def self.init
            @@init
          end

          def self.calls
            @@calls
          end

          def self.opts
            @@opts
          end
        end

        before(:each) do
          TestMiddleware.reset
        end

        it 'calls the block given at initialization' do
          called = false
          Builder.new(SpecHelpers::SubContext.new) { called = true }
          expect(called).to eql(true)
        end

        context 'to_websocket_app' do
          it 'returns an App instance' do
            builder = Builder.new(SpecHelpers::SubContext.new) do
            end
            app = builder.to_websocket_app
            expect(app).to be_a(App)
          end
        end

        context 'to_handler' do

          it 'instantiates middleware classes' do
            handler = Builder.new(SpecHelpers::SubContext.new) do
              use TestMiddleware
            end.to_handler

            expect(TestMiddleware.init).to eql(true)
          end

          it 'allows options to be passed to middleware classes' do
            handler = Builder.new(SpecHelpers::SubContext.new) do
              use TestMiddleware, { some: 'option' }
            end.to_handler

            expect(TestMiddleware.init).to eql(true)
            expect(TestMiddleware.opts).to eql({ some: 'option' })
          end

          it 'creates the correct chain of handlers' do
            handler = Builder.new(SpecHelpers::SubContext.new) do
              use TestMiddleware
              use TestMiddleware
            end.to_handler

            handler.call({test: 42}, SpecHelpers::MockSocket.new)
            expect(TestMiddleware.calls.size).to eql(2)
          end

          it 'supports commands' do
            handler = Builder.new(SpecHelpers::SubContext.new) do
              command :hello do |command, socket|
                socket.send('from hello')
              end

              command :foo do |command, socket|
                socket.send('from foo')
              end
            end.to_handler

            socket = SpecHelpers::MockSocket.new

            msg = SpecHelpers::MockFayeEvent.new({ :headers => { :command => 'hello' } })
            handler.call(msg, socket, {})
            expect(socket.last_message).to eql('from hello')

            msg = SpecHelpers::MockFayeEvent.new({ :headers => { :command => 'foo' } })
            handler.call(msg, socket, {})
            expect(socket.last_message).to eql('from foo')
          end

          it 'supports rooms' do
            handler = Builder.new(SpecHelpers::SubContext.new) do
              room 'a' do |room|
                command :hello do |command, socket|
                  socket.send("hi from #{room.name}!")
                end
              end

              room 'b' do
                command :hello do |command, socket|
                  socket.send(command)
                end
              end
            end.to_handler

            socket = SpecHelpers::MockSocket.new

            msg = SpecHelpers::MockFayeEvent.new({ :headers => { command: 'hello', room: 'a' } })
            handler.call(msg, socket, {})
            expect(socket.last_message).to eql('hi from a!')

            msg = SpecHelpers::MockFayeEvent.new({ :headers => { command: 'hello', room: 'b' } })
            handler.call(msg, socket, {})
            expect(socket.last_message).to eql(msg)
          end

        end
      end # describe
    end # module Hub
  end # module Websocket
end # module Startback
