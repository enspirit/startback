require 'spec_helper'
require 'startback/websocket'

module Startback
  module Websocket
    describe App do
      include Rack::Test::Methods

      def app
        App.new(SpecHelpers::SubContext.new)
      end

      it 'returns a 400 when not used with proper websocket handshake' do
        get '/'
        expect(last_response.status).to eql(400)
        expect(last_response.body).to eql('Websocket only!')
      end

      it 'does respond with proper handshake in the context of websocket connections' do
        header 'connection', 'upgrade'
        header 'upgrade', 'websocket'
        get '/'
        # https://github.com/faye/faye-websocket-ruby/blob/main/lib/faye/websocket.rb#L93
        expect(last_response.status).to eql(-1)
      end

      it 'serves the javascript client properly' do
        get '/client.js'
        expect(last_response.status).to eql(200)
        expect(last_response['Content-Type']).to eql('application/javascript')
      end

    end # describe
  end # module Web
end # module Startback
