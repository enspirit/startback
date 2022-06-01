# We need to build the javascript assets for the websocket contrib
contrib/startback-websocket/startback-websocket.gem: contrib/startback-websocket/dist/client.js
contrib/startback-websocket/dist/client.js: contrib/startback-websocket/node_modules $(shell find contrib/startback-websocket/src)
	@cd contrib/startback-websocket && npm run build

contrib/startback-websocket/node_modules: contrib/startback-websocket/package.json
	@cd contrib/startback-websocket && npm install
