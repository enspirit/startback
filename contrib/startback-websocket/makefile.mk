startback-websocket_DEPS += contrib/startback-websocket/dist/client.js

print-% : ; $(info $* is a $(flavor $*) variable set to [$($*)]) @true

contrib/startback-websocket/dist/client.js:
	@cd contrib/startback-websocket && \
		npm install && \
		npm run build
