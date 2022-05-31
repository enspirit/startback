startback-websocket_DEPS += contrib/startback-websocket/dist/client.js

contrib/startback-websocket/dist/client.js:
	@cd contrib/startback-websocket && \
		npm install && \
		npm run build
