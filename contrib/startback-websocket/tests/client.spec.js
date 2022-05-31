import { Client } from '../src';
import { expect } from 'chai';
import MockWebSocket from './mock-websocket';

describe('Client', () => {

  it('is a class', () => {
    expect(new Client()).to.be.an.instanceof(Client);
  });

  let client;
  beforeEach(() => {
    client = new Client('ws://localhost');

    global.WebSocket = MockWebSocket;
  });

  describe('connect()', () => {

    it('is a function', () => {
      expect(client.connect).to.be.a('function');
    });

    it('creates a websocket for the correct url', () => {
      expect(global.WebSocket.instance).to.equal(undefined);

      client.connect();

      expect(MockWebSocket.instance.listeners).to.not.equal(null);
      expect(MockWebSocket.instance.baseUrl).to.equal('ws://localhost');
    });

    it('subscribes to the websocket events', () => {
      client.connect();

      expect(MockWebSocket.instance.listeners).to.contain.keys('open', 'close', 'error', 'message');
    });

  });

  describe('on()', () => {

    it('is a function', () => {
      expect(client.on).to.be.a('function');
    });

    it('allows users to subscribe to websocket raw events', () => {
      let event;
      client.connect();
      client.on('message', (e) => event = e);

      const originalEvent = { some: 'data' };
      global.WebSocket.instance.emit('message', originalEvent);
      expect(event).to.equal(originalEvent);
    });

  });

  describe('send()', () => {
    it('just forwards to the websocket.send() method', () => {
      const payload = '{ "foo": "bar" }';
      client.connect();
      client.send(payload);
      expect(MockWebSocket.instance.lastMessage).to.equal(payload);
    });
  });

});
