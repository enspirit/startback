import Client from './client';
import Room from './room';
import { v4 as uuidv4 } from 'uuid';

export default class HubClient extends Client {

  #rooms
  #runningCommands

  constructor(baseUrl) {
    super(baseUrl);
    this.#rooms = {};
    this.#runningCommands = {};
  }

  send(body, headers = {}) {
    super.send(JSON.stringify({
      headers,
      body,
    }));
  }

  connect() {
    super.connect();
    this.on('message', (event) => {
      const msg = JSON.parse(event.data);

      // plain messages are ignored
      if (!msg.headers) {
        return;
      }

      // First handle responses to executed commands
      const commandId = msg.headers['in-reply-to'];
      if (commandId) {
        const promise = this.#runningCommands[commandId];
        if (promise) {
          promise.resolve(msg);
          delete this.#runningCommands[commandId];
        }
      }

      // Handle messages for rooms
      if (msg.headers.room) {
        const room = this.#rooms[msg.headers.room];
        return room.process(msg);
      }
    });
  }

  execute(command, data = {}, headers = {}) {
    const commandId = uuidv4();

    return new Promise((resolve, reject) => {
      this.#runningCommands[commandId] = { resolve, reject };

      this.send(data, {
        ...headers,
        command,
        'reply-to': commandId,
      });
    });
  }

  room(name) {
    return this.#rooms[name] ||= new Room(name, this);
  }

}
