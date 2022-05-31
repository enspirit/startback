import { HubClient, Client } from '../src';
import { expect } from 'chai';
import MockWebSocket from './mock-websocket';
import Room from '../src/room';

describe('HubClient', () => {

  it('is a subclass of Client', () => {
    expect(new HubClient()).to.be.an.instanceof(Client);
  });

  let client;
  beforeEach(() => {
    client = new HubClient('ws://localhost');
    client.connect();
  });

  describe('send', () => {

    it('sends proper payload with body and headers', () => {
      client.send({ foo: 'bar' });
      expect(MockWebSocket.instance.lastMessage).to.equal(JSON.stringify({
        headers: {},
        body: { foo: 'bar' },
      }));
    });

    it('uses the headers when provided', () => {
      client.send({ foo: 'bar' }, { some: 'header' });
      expect(MockWebSocket.instance.lastMessage).to.equal(JSON.stringify({
        headers: { 'some': 'header' },
        body: { foo: 'bar' },
      }));
    });

  });

  describe('execute', () => {

    it('sends correct proper payload with body and `command` header', () => {
      client.execute('a-command-name', { foo: 'bar' });

      const message = JSON.parse(MockWebSocket.instance.lastMessage);
      expect(message.headers.command).to.equal('a-command-name');
      expect(message.body).to.deep.equal({
        foo: 'bar',
      });
    });

    it('includes a reply-to unique identifier', () => {
      client.execute('a-command-name', { foo: 'bar' });

      const message = JSON.parse(MockWebSocket.instance.lastMessage);
      expect(message.headers['reply-to']).to.be.a('string');
    });

    it('uses the headers when provided', () => {
      client.execute('a-command-name', { foo: 'bar' }, { some: 'header' });

      const message = JSON.parse(MockWebSocket.instance.lastMessage);
      expect(message.headers.some).to.equal('header');
    });

    it('returns a promise', () => {
      const p = client.execute('a-command-name', { foo: 'bar' }, { some: 'header' });
      expect(p).to.be.an.instanceof(Promise);
    });

    it('resolves the promise if the backend send a message using the `in-reply-to` header', async () => {
      const promise = client.execute('a-command-name', { foo: 'bar' }, { some: 'header' });

      const message = JSON.parse(MockWebSocket.instance.lastMessage);
      const messageId = message.headers['reply-to'];

      MockWebSocket.instance.emit('message', {
        data: JSON.stringify({
          headers: {
            'in-reply-to': messageId,
          },
          body: { success: true },
        }),
      });

      let reply;
      await promise.then((_reply) => {
        reply = _reply;
      });

      expect(reply).to.deep.equal({
        headers: { 'in-reply-to': messageId },
        body: { success: true },
      });
    });
  });

  describe('room', () => {

    it('returns a Room instance', () => {
      expect(client.room('notifications')).to.be.an.instanceof(Room);
    });

    it('reuses existing Room instances when possible', () => {
      const room1 = client.room('notifications');
      const room2 = client.room('notifications');
      expect(room1).to.equal(room2);
    });

    it('routes message to rooms properly', () => {

      const room1 = client.room('room1');
      let room1Msg;
      room1.on('message', (msg) => {
        room1Msg = msg;
      });

      const room2 = client.room('room2');
      let room2Msg;
      room2.on('message', (msg) => {
        room2Msg = msg;
      });

      const fakeSendToRoom = (room, msg) => {
        MockWebSocket.instance.emit('message', {
          data: JSON.stringify({
            headers: {
              'room': room,
            },
            body: msg,
          }),
        });

      };

      fakeSendToRoom('room1', 'msg1');
      fakeSendToRoom('room2', 'msg2');

      expect(room1Msg).to.deep.equal({
        headers: {
          room: 'room1',
        },
        body: 'msg1',
      });

      expect(room2Msg).to.deep.equal({
        headers: {
          room: 'room2',
        },
        body: 'msg2',
      });
    });

  });

});
